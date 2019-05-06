--------------------------------------------------------------------------------
-- Copyright (c) 2019 David Banks
--
-- based on work by Alan Daly. Copyright(c) 2009. All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : AtomFpga_BeebAdapter.vhd
-- /___/   /\     Timestamp : 21/04/2019
-- \   \  /  \
--  \___\/\___\
--
--Design Name: AtomFpga_BeebAdapter
--Device: Spartan6

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity AtomFpga_BeebAdapter is
    port (
        -- System oscillator
        clk50        : in    std_logic;
        -- BBC 1MHZ Bus
        clke         : in    std_logic;
        rnw          : in    std_logic;
        rst_n        : in    std_logic;
        pgfc_n       : in    std_logic;
        pgfd_n       : in    std_logic;
        bus_addr     : in    std_logic_vector (7 downto 0);
        bus_data     : inout std_logic_vector (7 downto 0);
        bus_data_dir : out   std_logic;
        bus_data_oel : out   std_logic;
        nmi          : out   std_logic;
        irq          : out   std_logic;
        -- SPI DAC
        dac_cs_n     : out   std_logic;
        dac_sck      : out   std_logic;
        dac_sdi      : out   std_logic;
        dac_ldac_n   : out   std_logic;
        -- RAM
        ram_addr     : out   std_logic_vector(18 downto 0);
        ram_data     : inout std_logic_vector(7 downto 0);
        ram_cel      : out   std_logic;
        ram_oel      : out   std_logic;
        ram_wel      : out   std_logic;
        -- UART
        uart_rxd     : in    std_logic;
        uart_txd     : out   std_logic;
        -- Flash
        flash_cs     : out   std_logic;
        flash_ck     : out   std_logic;
        flash_si     : out   std_logic;
        flash_so     : in    std_logic;
        -- Misc
        pmod0        : out   std_logic_vector(7 downto 0);
        pmod1        : inout std_logic_vector(7 downto 0);
        pmod2        : inout std_logic_vector(3 downto 0);
        sw1          : in    std_logic;
        sw2          : in    std_logic;
        led          : out   std_logic
        );

end AtomFpga_BeebAdapter;

architecture behavioral of AtomFpga_BeebAdapter is

    -- Clock generation
    signal clk0            : std_logic;
    signal clk1            : std_logic;
--  signal clk2            : std_logic;
    signal clkfb           : std_logic;
    signal clkfb_buf       : std_logic;
    signal clkin_buf       : std_logic;
    signal clock_16        : std_logic;
    signal clock_25        : std_logic;
    signal clock_32        : std_logic;

    signal reset_n         : std_logic;
    signal powerup_reset_n : std_logic;
    signal hard_reset_n    : std_logic;
    signal reset_counter   : std_logic_vector(9 downto 0);
    signal phi2            : std_logic;

    signal ext_A           : std_logic_vector(18 downto 0);
    signal ext_Din         : std_logic_vector(7 downto 0);
    signal ext_Dout        : std_logic_vector(7 downto 0);
    signal ext_nWE         : std_logic;
    signal ext_nOE         : std_logic;
    signal ext_nCS         : std_logic;

    signal ExternCE        : std_logic;
    signal ExternWE        : std_logic;
    signal ExternA         : std_logic_vector (18 downto 0);
    signal ExternDin       : std_logic_vector (7 downto 0);
    signal ExternDout      : std_logic_vector (7 downto 0);

    signal red             : std_logic_vector(2 downto 0);
    signal green           : std_logic_vector(2 downto 0);
    signal blue            : std_logic_vector(2 downto 0);
    signal hsync           : std_logic;
    signal vsync           : std_logic;

    -- Audio mixer and DAC
    constant dacwidth      : integer := 16; -- this needs to match the MCP4822 frame size
    signal atom_audio      : std_logic;
    signal sid_audio       : std_logic_vector(17 downto 0);
    signal cycle           : std_logic_vector(6 downto 0);
    signal audio_l         : std_logic_vector(dacwidth - 1 downto 0);
    signal audio_r         : std_logic_vector(dacwidth - 1 downto 0);
    signal dac_shift_reg_l : std_logic_vector(dacwidth - 1 downto 0);
    signal dac_shift_reg_r : std_logic_vector(dacwidth - 1 downto 0);

    signal mmc_clk         : std_logic;
    signal mmc_ss          : std_logic;
    signal mmc_mosi        : std_logic;
    signal mmc_miso        : std_logic;

    signal ps2_kbd_clk     : std_logic;
    signal ps2_kbd_data    : std_logic;

-----------------------------------------------
-- Bootstrap ROM Image from SPI FLASH into SRAM
-----------------------------------------------

    -- start address of user data in FLASH as obtained from bitmerge.py
    -- this is safely beyond the end of the bitstream
    constant user_address  : std_logic_vector(23 downto 0) := x"060000";

    -- lenth of user data in FLASH = 128KB (32x 4KB ROM) images
    constant user_length   : std_logic_vector(23 downto 0) := x"020000";

    -- high when FLASH is being copied to SRAM, can be used by user as active high reset
    signal bootstrap_busy  : std_logic;

begin

    ------------------------------------------------
    -- Clock generation
    --
    -- from the on-board 50MHz Oscillator
    -- using a PLL for the 16/32 MHz
    -- using a DCM for the 25.175 MHz (approx)
    ------------------------------------------------

    inst_clkin_buf : IBUFG
        port map (
            I => clk50,
            O => clkin_buf
            );

    inst_PLL : PLL_BASE
        generic map (
            BANDWIDTH            => "OPTIMIZED",
            CLK_FEEDBACK         => "CLKFBOUT",
            COMPENSATION         => "SYSTEM_SYNCHRONOUS",
            DIVCLK_DIVIDE        => 1,
            CLKFBOUT_MULT        => 16,      -- 50 * 16 = 800
            CLKFBOUT_PHASE       => 0.000,
            CLKOUT0_DIVIDE       => 50,      -- 800 / 50 = 16MHz
            CLKOUT0_PHASE        => 0.000,
            CLKOUT0_DUTY_CYCLE   => 0.500,
            CLKOUT1_DIVIDE       => 25,      -- 800 / 25 = 32MHz
            CLKOUT1_PHASE        => 0.000,
            CLKOUT1_DUTY_CYCLE   => 0.500,
--          CLKOUT2_DIVIDE       => 32,      -- 800 / 32 = 25MHz
--          CLKOUT2_PHASE        => 0.000,
--          CLKOUT2_DUTY_CYCLE   => 0.500,
            CLKIN_PERIOD         => 20.000,
            REF_JITTER           => 0.010
            )
        port map (
            -- Output clocks
            CLKFBOUT            => clkfb,
            CLKOUT0             => clk0,
            CLKOUT1             => clk1,
--          CLKOUT2             => clk2,
            RST                 => '0',
            -- Input clock control
            CLKFBIN             => clkfb_buf,
            CLKIN               => clkin_buf
            );

    inst_clkfb_buf : BUFG
        port map (
            I => clkfb,
            O => clkfb_buf
            );

    inst_clk0_buf : BUFG
        port map (
            I => clk0,
            O => clock_16
            );

    inst_clk1_buf : BUFG
        port map (
            I => clk1,
            O => clock_32
            );

--  inst_clk2_buf : BUFG
--      port map (
--          I => clk2,
--          O => clock_25
--          );


    inst_DCM : DCM
        generic map (
            CLKFX_MULTIPLY   => 11,
            CLKFX_DIVIDE     => 14,
            CLKIN_PERIOD     => 31.250,
            CLK_FEEDBACK     => "NONE"
            )
        port map (
            CLKIN            => clock_32,
            CLKFB            => '0',
            RST              => '0',
            DSSEN            => '0',
            PSINCDEC         => '0',
            PSEN             => '0',
            PSCLK            => '0',
            CLKFX            => clock_25
            );

    --------------------------------------------------------
    -- Power Up Reset Generation
    --------------------------------------------------------

    -- The external reset signal is not asserted on power up
    -- This internal counter forces power up reset to happen
    -- This is needed by the GODIL to initialize some of the registers
    ResetProcess : process (clock_16)
    begin
        if rising_edge(clock_16) then
            if (reset_counter(reset_counter'high) = '0') then
                reset_counter <= reset_counter + 1;
            end if;
            powerup_reset_n <= (not SW1) and reset_counter(reset_counter'high);
        end if;
    end process;

   -- extend the version seen by the core to hold the 6502 reset during bootstrap
   hard_reset_n <= powerup_reset_n and not bootstrap_busy;

    --------------------------------------------------------
    -- Atom Fpga Core
    --------------------------------------------------------

    inst_AtomFpga_Core : entity work.AtomFpga_Core
    generic map (
        CImplSDDOS              => false,
        CImplAtoMMC2            => true,
        CImplGraphicsExt        => true,
        CImplSoftChar           => true,
        CImplSID                => true,
        CImplVGA80x40           => true,
        CImplHWScrolling        => true,
        CImplMouse              => true,
        CImplUart               => true,
        CImplDoubleVideo        => true,
        CImplRamRomNone         => false,
        CImplRamRomPhill        => true,
        CImplRamRomAtom2015     => false,
        CImplRamRomSchakelKaart => false,
        MainClockSpeed          => 16000000,
        DefaultBaud             => 115200
     )
     port map (
        clk_vga             => clock_25,
        clk_16M00           => clock_16,
        clk_32M00           => clock_32,
        ps2_clk             => ps2_kbd_clk,
        ps2_data            => ps2_kbd_data,
        ps2_mouse_clk       => open,
        ps2_mouse_data      => open,
        ERSTn               => hard_reset_n,
        IRSTn               => reset_n,
        red                 => red,
        green               => green,
        blue                => blue,
        vsync               => vsync,
        hsync               => hsync,
        phi2                => phi2,
        ExternCE            => ExternCE,
        ExternWE            => ExternWE,
        ExternA             => ExternA,
        ExternDin           => ExternDin,
        ExternDout          => ExternDout,
        sid_audio           => open,
        sid_audio_d         => sid_audio,
        atom_audio          => atom_audio,
        SDMISO              => mmc_miso,
        SDSS                => mmc_ss,
        SDCLK               => mmc_clk,
        SDMOSI              => mmc_mosi,
        uart_RxD            => uart_rxd,
        uart_TxD            => uart_txd,
        avr_RxD             => '1',
        avr_TxD             => open,
        LED1                => led,
        LED2                => open,
        charSet             => '1',
        Joystick1           => (others => '1'),
        Joystick2           => (others => '1')
    );

    ------------------------------------------------
    -- Audio mixer
    ------------------------------------------------

    process(atom_audio, sid_audio)
        variable l : std_logic_vector(dacwidth - 1 downto 0);
        variable r : std_logic_vector(dacwidth - 1 downto 0);
    begin
        -- Atom Audio is a single bit
        if (atom_audio = '1') then
            l := x"1000";
            r := x"1000";
        else
            l := x"EFFF";
            r := x"EFFF";
        end if;
        -- SID output is 18-bit unsigned
        l := l + sid_audio(17 downto 2);
        r := r + sid_audio(17 downto 2);
        -- Currently the left and right channels are identical
        audio_l <= l;
        audio_r <= r;
    end process;

    ------------------------------------------------
    -- MCP4822 SPI 12-bit DAC
    --
    -- note: this actually takes 16-bit samples
    ------------------------------------------------

    process(clock_16)
    begin
        if rising_edge(clock_16) then
            cycle <= cycle + 1;
            if (unsigned(cycle(5 downto 0)) < 33) then
                dac_cs_n <= '0';
                dac_sck <= cycle(0);
            else
                dac_cs_n <= '1';
                dac_sck <= '0';
            end if;

            if (cycle(0) = '0') then
                if (unsigned(cycle(5 downto 1)) = 0) then
                    if (cycle(6) = '0') then
                        dac_shift_reg_l <= audio_l;
                        dac_shift_reg_r <= audio_r;
                    end if;
                    dac_sdi <= cycle(6);
                elsif (unsigned(cycle(5 downto 1)) < 4) then
                    dac_sdi <= '1';
                elsif (unsigned(cycle(5 downto 1)) < 16) then
                    if (cycle(6) = '0') then
                        dac_sdi <= dac_shift_reg_l(dacwidth - 1);
                        dac_shift_reg_l <= dac_shift_reg_l(dacwidth - 2 downto 0) & '0';
                    else
                        dac_sdi <= dac_shift_reg_r(dacwidth - 1);
                        dac_shift_reg_r <= dac_shift_reg_r(dacwidth - 2 downto 0) & '0';
                    end if;
                else
                    dac_sdi <= '0';
                end if;
                if (unsigned(cycle(6 downto 1)) = 60) then
                    dac_ldac_n <= '0';
                else
                    dac_ldac_n <= '1';
                end if;
            end if;
        end if;
     end process;

     --------------------------------------------------------
     -- BOOTSTRAP SPI FLASH to SRAM
     --------------------------------------------------------

    inst_bootstrap: entity work.bootstrap
    generic map (
        user_length          => user_length
    )
    port map(
        clock                => clock_16,
        powerup_reset_n      => powerup_reset_n,
        bootstrap_busy       => bootstrap_busy,
        user_address         => user_address,
        RAM_nOE              => ext_nOE,
        RAM_nWE              => ext_nWE,
        RAM_nCS              => ext_nCS,
        RAM_A                => ext_A,
        RAM_Din              => ext_Din,
        RAM_Dout             => ext_Dout,
        SRAM_nOE             => ram_oel,
        SRAM_nWE             => ram_wel,
        SRAM_nCS             => ram_cel,
        SRAM_A(20 downto 19) => open,
        SRAM_A(18 downto 0)  => ram_addr,
        SRAM_D               => ram_data,
        FLASH_CS             => flash_cs,
        FLASH_SI             => flash_si,
        FLASH_CK             => flash_ck,
        FLASH_SO             => flash_so
    );

    MemProcess : process (clock_16)
    begin
        if rising_edge(clock_16) then
            ext_A      <= ExternA;
            ext_nCS    <= not ExternCE;
            ext_nOE    <= not ((not ExternWE) and ExternCE and phi2);
            ext_nWE    <= not (ExternWE and ExternCE and phi2);
            ext_Din    <= ExternDin;
       end if;
    end process;

    ExternDout <= ext_Dout;

    bus_data     <= (others => 'Z');
    bus_data_dir <= '1';
    bus_data_oel <= '1';
    nmi          <= '0';
    irq          <= '0';

    pmod0        <= blue & "0" & red & "0";
    pmod1        <= "ZZ" & vsync & hsync & green & "0";
	 pmod2        <= "Z" & mmc_clk & mmc_mosi & mmc_ss;

    ps2_kbd_clk  <= pmod1(6);
    ps2_kbd_data <= pmod1(7);
	 mmc_miso     <= pmod2(3);

end behavioral;
