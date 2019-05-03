--------------------------------------------------------------------------------
-- Copyright (c) 2019 David Banks and Roland Leurs
--
-- based on work by Alan Daly. Copyright(c) 2009. All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : AtomFpga_Atom2K18.vhd
-- /___/   /\     Timestamp : 21/04/2019
-- \   \  /  \
--  \___\/\___\
--
--Design Name: AtomFpga_Atom2K18
--Device: Spartan6

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity AtomFpga_Atom2K18 is
    port (
        -- Clock
        clk_50         : in  std_logic;

        -- External Bus
        bus_a          : out   std_logic_vector(18 downto 0);
        bus_d          : inout std_logic_vector(7 downto 0);
        bus_blk_b      : out   std_logic;
        bus_phi2       : out   std_logic;
        bus_rnw        : out   std_logic;
        bus_nrds       : out   std_logic;
        bus_nwds       : out   std_logic;
        bus_sync       : out   std_logic;
        bus_nmi_n      : in    std_logic;
        bus_irq_n      : in    std_logic;
        bus_rst_n      : in    std_logic;
        bus_rdy        : in    std_logic;
        bus_so         : in    std_logic;

        -- External device chip selects
        cs_ram_n       : out   std_logic;
        cs_rom_n       : out   std_logic;
        cs_via_n       : out   std_logic;
        cs_tube_n      : out   std_logic;
        cs_buf_n       : out   std_logic;
        buf_dir        : out   std_logic;

        -- Video
        vga_red1       : out   std_logic; -- this is the MSB
        vga_red2       : out   std_logic;
        vga_green1     : out   std_logic; -- this is the MSB
        vga_green2     : out   std_logic;
        vga_blue1      : out   std_logic; -- this is the MSB
        vga_blue2      : out   std_logic;
        vga_vsync      : out   std_logic;
        vga_hsync      : out   std_logic;

        -- Audio
        audio          : out   std_logic;
        dac_cs_n       : out   std_logic;
        dac_sdi        : out   std_logic;
        dac_ldac_n     : out   std_logic;
        dac_sck        : out   std_logic;

        -- Keyboard
        kbd_pa         : out   std_logic_vector(3 downto 0);
        kbd_pb         : in    std_logic_vector(7 downto 0);
        kbd_pc         : in    std_logic_vector(6 downto 6);

        -- Mouse
        ps2_mouse_clk  : inout std_logic;
        ps2_mouse_data : inout std_logic;

        -- Cassette
        cas_in         : in    std_logic;
        cas_out        : out   std_logic;

        -- Serial
        serial_tx      : out   std_logic;
        serial_rx      : in    std_logic;

        -- SD Card
        mmc_led_red    : out   std_logic;
        mmc_led_green  : out   std_logic;
        mmc_clk        : out   std_logic;
        mmc_ss         : out   std_logic;
        mmc_mosi       : out   std_logic;
        mmc_miso       : in    std_logic
        );

end AtomFpga_Atom2K18;

architecture behavioral of AtomFpga_Atom2K18 is

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

    -- Reset generation
    signal reset_n         : std_logic;
    signal hard_reset_n    : std_logic;
    signal powerup_reset_n : std_logic;
    signal reset_counter   : std_logic_vector(9 downto 0);

    -- External bus interface
    signal extern_bus      : std_logic;
    signal extern_ce       : std_logic;
    signal extern_we       : std_logic;
    signal extern_din      : std_logic_vector (7 downto 0);
    signal extern_dout     : std_logic_vector (7 downto 0);
    signal extern_a        : std_logic_vector (18 downto 0);
    signal phi2            : std_logic;
    signal rnw             : std_logic;

    -- Audio mixer and DAC
    constant dacwidth      : integer := 16; -- this needs to match the MCP4822 frame size

    signal atom_audio      : std_logic;
    signal sid_audio       : std_logic_vector(17 downto 0);
    signal cycle           : std_logic_vector(6 downto 0);
    signal audio_l         : std_logic_vector(dacwidth - 1 downto 0);
    signal audio_r         : std_logic_vector(dacwidth - 1 downto 0);
    signal dac_shift_reg_l : std_logic_vector(dacwidth - 1 downto 0);
    signal dac_shift_reg_r : std_logic_vector(dacwidth - 1 downto 0);

    -- Matrix Keyboard
    signal ps2_kbd_enable  : std_logic;
    signal ps2_kbd_clk     : std_logic;
    signal ps2_kbd_data    : std_logic;
    signal int_kbd_pb      : std_logic_vector(7 downto 0);
    signal int_kbd_pc      : std_logic_vector(6 downto 6);

    -- External devices
    signal extern_tube     : std_logic;
    signal extern_via      : std_logic;

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
            I => clk_50,
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
    -- Reset generation
    --------------------------------------------------------

    -- The external reset signal is not asserted on power up
    -- This internal counter forces power up reset to happen
    -- This is needed by AtomGodilVideo to initialize some of the registers
    process (clock_16)
    begin
        if rising_edge(clock_16) then
            if (reset_counter(reset_counter'high) = '0') then
                reset_counter <= reset_counter + 1;
            end if;
            powerup_reset_n <= reset_counter(reset_counter'high);
            hard_reset_n    <= reset_counter(reset_counter'high) and bus_rst_n;
        end if;
    end process;

    ------------------------------------------------
    -- Atom FPGA Core
    ------------------------------------------------

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
        CImplDoubleVideo        => false,    -- make room for ROMs for testing
        CImplRamRomNone         => false,
        CImplRamRomPhill        => false,
        CImplRamRomAtom2015     => true,
        CImplRamRomSchakelKaart => false,
        CImplVIA                => false,
        MainClockSpeed          => 16000000,
        DefaultBaud             => 115200
     )
     port map(
        clk_vga             => clock_25,
        clk_16M00           => clock_16,
        clk_32M00           => clock_32,

        kbd_pa              => kbd_pa,
        kbd_pb              => int_kbd_pb,
        kbd_pc              => int_kbd_pc,

        ps2_clk             => ps2_kbd_clk,
        ps2_data            => ps2_kbd_data,
        ps2_mouse_clk       => ps2_mouse_clk,
        ps2_mouse_data      => ps2_mouse_data,

        ERSTn               => hard_reset_n,
        IRSTn               => reset_n,          -- not currently used

        red(2)              => vga_red1,
        red(1)              => vga_red2,
        red(0)              => open,
        green(2)            => vga_green1,
        green(1)            => vga_green2,
        green(0)            => open,
        blue(2)             => vga_blue1,
        blue(1)             => vga_blue2,
        blue(0)             => open,
        vsync               => vga_vsync,
        hsync               => vga_hsync,

        phi2                => phi2,
        sync                => bus_sync,
        rnw                 => rnw,
        blk_b               => bus_blk_b,
        rdy                 => bus_rdy,
        so                  => bus_so,
        irq_n               => bus_irq_n,
        nmi_n               => bus_nmi_n,

        ExternBus           => extern_bus,      -- active high external bus select
        ExternCE            => extern_ce,       -- active high Ram/Rom chip select
        ExternWE            => extern_we,       -- active high Ram/Rom write
        ExternA             => extern_a,
        ExternDin           => extern_din,
        ExternDout          => extern_dout,

        sid_audio           => open,
        sid_audio_d         => sid_audio,
        atom_audio          => atom_audio,

        SDMISO              => mmc_miso,
        SDSS                => mmc_ss,
        SDCLK               => mmc_clk,
        SDMOSI              => mmc_mosi,

        uart_RxD            => serial_rx,
        uart_TxD            => serial_tx,

        avr_RxD             => '1',
        avr_TxD             => open,

        cas_in              => cas_in,
        cas_out             => cas_out,

        LED1                => mmc_led_green,
        LED2                => mmc_led_red,

        charSet             => '1'
        );

    ------------------------------------------------
    -- External bus
    ------------------------------------------------

    -- 22/4/2019
    --
    -- I'm not happy with the design of the external bus interface, for the
    -- following reasons:
    --
    -- 1. extern_we and extern_ce are mediated by the pluggable RAMROM modules
    --    in AtomFpga_Core. This means they are not active when external devices
    --    in Bxxx are accessed.
    --
    -- 2. As a work around, I've exposed the 6502 RNW (rnw) signal directly,
    --    which is probably the right thing to do, as Atom2K18 does have a full
    --    external bus. But it's now confusing as to when to use extern_we and
    --    when to use rnw.
    --
    -- 3. It's not clear how addresses on extern_a correspond to what the CPU
    --    accessed, again because this signal is the output of a RAMROM module.
    --
    -- 4. It seemed wrong to have to add ExternTube and ExternVIA signals to the
    --    AtomFpga_Core. It should have been possible to implement these externally
    --    in the FPGA target specific wrapper. But (3) made this difficult.
    --
    -- 5. The NRDS and NWDS signals are currently generated from the RAMROM
    --    specific extern_ce and extern_we. It would be better if they uses
    --    rnw and ignored extern_ce. But this is more dangerous, so lets
    --    see how the current version works before breaking things more!
    --
    -- What's in place currently will work (I think) for the VIA and Tube, but
    -- will not currently allow any devices to be added to the bus. Need to
    -- talk with Roland about how he thinks the external bus should be mapped
    -- into the Atom address space.
    --
    -- 22/4/2019
    --
    -- Roland's reply:
    --
    -- All addresses from #B000 - #BFFF should be external except for:
    -- #B000 - #B003 (8255)
    -- #B400 - #B403 (AtoMMC)
    -- #B800 - #B80F (6522)
    -- #BD00 - #BDFF (Godil + reserved address space)
    -- #BFF0 - #BFFF (control registers, some addresses are reserved)
    --
    -- 23/4/2019
    --
    -- For consistency, I ended up using a minimum of 16-byte blocks.
    -- This is all implemented in AtomFpga_Core
    --
    -- To answer my concerns above
    -- 1. This is resolved by adding a seperate ExternBus output from the core
    -- 2. I'm happy exposing RNW directly
    -- 3. The RamRom modules should just output the CPU address when not selected
    -- 4. ExternVia and ExternTube replaced with ExternBus
    -- 5. Use ExternCE/ExternWE (for RamRom) and ExternBus/rnw (for Bus)

    bus_phi2    <= phi2;
    bus_rnw     <= rnw;
    bus_a       <= extern_a;
    bus_d       <= extern_din when rnw = '0' else "ZZZZZZZZ";

    bus_nrds    <= '0' when extern_ce  = '1' and extern_we = '0' and phi2 = '1' else -- RamRom
                   '0' when extern_bus = '1' and rnw       = '1' and phi2 = '1' else -- Bus
                   '1';

    bus_nwds    <= '0' when extern_ce  = '1' and extern_we = '1' and phi2 = '1' else -- RamRom
                   '0' when extern_bus = '1' and rnw       = '0' and phi2 = '1' else -- Bus
                   '1';

    extern_dout <= bus_d;

    ------------------------------------------------
    -- External device chip selects
    ------------------------------------------------

    extern_via  <= '1' when extern_bus = '1' and extern_a(15 downto 4) = x"B80" else '0';
    extern_tube <= '1' when extern_bus = '1' and extern_a(15 downto 4) = x"BEE" else '0';

    cs_rom_n    <= not(extern_ce and not extern_a(17));
    cs_ram_n    <= not(extern_ce and     extern_a(17));

    cs_via_n    <= not(extern_via);
    cs_tube_n   <= not(extern_tube);

    cs_buf_n    <= not(extern_bus and not extern_tube);  -- Tube is on the 3v3 side of the bus
    buf_dir     <= not rnw;

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

    ------------------------------------------------
    -- Atom Audio
    ------------------------------------------------

    audio <= atom_audio;

    ------------------------------------------------
    -- Keyboard
    ------------------------------------------------

    process(clock_16)
    begin
        if rising_edge(clock_16) then
            if powerup_reset_n = '0' then
                -- PC(7) linked to ground indicates a PS/2 keyboard should be used
                ps2_kbd_enable <= not kbd_pc(6);
            end if;
        end if;
    end process;

    -- Enable/Disable the PS/2 keyboard
    ps2_kbd_clk  <= kbd_pb(6) when ps2_kbd_enable = '1' else '1';
    ps2_kbd_data <= kbd_pb(7) when ps2_kbd_enable = '1' else '1';

    -- Enable/Disable the Matrix keyboard
    int_kbd_pb   <= kbd_pb when ps2_kbd_enable = '0' else (others => '1');
    int_kbd_pc   <= kbd_pc when ps2_kbd_enable = '0' else (others => '1');

end behavioral;
