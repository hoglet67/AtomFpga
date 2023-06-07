library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AtomFpga_TangNano9K is
    generic (
        CImplCpu65c02      : boolean := false;
        CImplDVIGowin      : boolean := false;
        CImplDVIOpenSource : boolean := true;
        CImplSDDOS         : boolean := false;
        CImplAtoMMC2       : boolean := true;
        CImplSID           : boolean := true;
        CImplUserFlash     : boolean := false;
        CImplBootstrap     : boolean := true;
        CImplMonitor       : boolean := true;
        -- Options that use the GPIO outputs, select just one
        CImplVGA           : boolean := false;
        CImplTrace         : boolean := false;
        CImplDebug         : boolean := true;
        DefaultTurbo       : std_logic_vector(1 downto 0) := "00";
        ResetCounterSize   : integer := 20
    );
    port (
        clock_27        : in    std_logic;
        btn1_n          : in    std_logic;
        btn2_n          : in    std_logic;
        ps2_clk         : in    std_logic;
        ps2_data        : in    std_logic;
        ps2_mouse_clk   : inout std_logic;
        ps2_mouse_data  : inout std_logic;
        tf_miso         : in    std_logic;
        tf_cs           : out   std_logic;
        tf_sclk         : out   std_logic;
        tf_mosi         : out   std_logic;
        uart_rx         : in    std_logic;
        uart_tx         : out   std_logic;
        led             : out   std_logic_vector (5 downto 0);
        -- VGA (1.8V)
        vga_r           : out   std_logic;
        vga_b           : out   std_logic;
        vga_g           : out   std_logic;
        vga_hs          : out   std_logic;
        vga_vs          : out   std_logic;
        -- HDMI
        tmds_clk_p      : out   std_logic;
        tmds_clk_n      : out   std_logic;
        tmds_d_p        : out   std_logic_vector(2 downto 0);
        tmds_d_n        : out   std_logic_vector(2 downto 0);
        -- GPIO (3.3V) (VGA, Trace or Debug)
        gpio            : out   std_logic_vector(13 downto 0);
        -- Flash
        flash_cs        : inout   std_logic;
        flash_ck        : inout   std_logic;
        flash_si        : inout   std_logic;
        flash_so        : in    std_logic;
        -- Magic ports for PSRAM to be inferred
        O_psram_ck      : out   std_logic_vector(1 downto 0);
        O_psram_ck_n    : out   std_logic_vector(1 downto 0);
        IO_psram_rwds   : inout std_logic_vector(1 downto 0);
        IO_psram_dq     : inout std_logic_vector(15 downto 0);
        O_psram_reset_n : out   std_logic_vector(1 downto 0);
        O_psram_cs_n    : out   std_logic_vector(1 downto 0)
    );
end AtomFpga_TangNano9K;

architecture behavioral of AtomFpga_TangNano9K is

    signal clock_main      : std_logic;
    signal clock_vga       : std_logic;
    signal clock_hdmi      : std_logic;
    signal clock_sid       : std_logic;
    signal clock_psram     : std_logic;
    signal clock_psram_p   : std_logic;

    signal ext_reset_n     : std_logic;
    signal reset_counter   : std_logic_vector(ResetCounterSize - 1 downto 0) := (others => '0'); -- 32ms
    signal powerup_reset_n : std_logic := '0';
    signal delayed_reset_n : std_logic;
    signal hard_reset_n    : std_logic;
    signal reset           : std_logic;
    signal led1            : std_logic;
    signal led2            : std_logic;

    -- Signals used for VGA video from the core
    signal red             : std_logic_vector(2 downto 0);
    signal green           : std_logic_vector(2 downto 0);
    signal blue            : std_logic_vector(2 downto 0);
    signal vsync           : std_logic;
    signal hsync           : std_logic;
    signal blank           : std_logic;
    signal audiol          : std_logic;
    signal audior          : std_logic;

    -- Signals used for DVI/HDMI
    signal rgb_r           : std_logic_vector(7 downto 0);
    signal rgb_g           : std_logic_vector(7 downto 0);
    signal rgb_b           : std_logic_vector(7 downto 0);
    signal rgb_hs          : std_logic;
    signal rgb_vs          : std_logic;
    signal rgb_de          : std_logic;
    signal ctrl            : std_logic_vector(1 downto 0);
    signal encoded_r       : std_logic_vector(9 downto 0);
    signal encoded_g       : std_logic_vector(9 downto 0);
    signal encoded_b       : std_logic_vector(9 downto 0);
    signal serialized_c    : std_logic;
    signal serialized_r    : std_logic;
    signal serialized_g    : std_logic;
    signal serialized_b    : std_logic;

    -- Signals used by the external bus interface (i.e. RAM and ROM)
    signal stb             : std_logic;
    signal phi2d1          : std_logic;
    signal phi2d2          : std_logic;
    signal RamCE           : std_logic;
    signal RomCE           : std_logic;
    signal ExternCE        : std_logic;
    signal ExternWE        : std_logic;
    signal ExternA         : std_logic_vector (18 downto 0);
    signal ExternDin       : std_logic_vector (7 downto 0);
    signal ExternDout      : std_logic_vector (7 downto 0);

    -- Signals used for tracing 6502 activity (CImplDebug)
    signal phi2            : std_logic;
    signal sync            : std_logic;
    signal rnw             : std_logic;
    signal data            : std_logic_vector (7 downto 0);

    -- Signals for the SPI FLASH bootstrap
    signal bootstrap_busy  : std_logic;

    -- Signals for the User Flash
    signal RomDout         : std_logic_vector (31 downto 0);
    signal xadr            : std_logic_vector (8 downto 0);
    signal yadr            : std_logic_vector (5 downto 0);

    -- Signals for the internal side of the PS Ram
    signal psram_stb       : std_logic;
    signal psram_ce        : std_logic;
    signal psram_we        : std_logic;
    signal psram_read      : std_logic;
    signal psram_write     : std_logic;
    signal psram_busy      : std_logic;
    signal psram_addr      : std_logic_vector(21 downto 0);
    signal psram_din       : std_logic_vector(15 downto 0);
    signal psram_dout      : std_logic_vector(15 downto 0);
    signal psram_din8      : std_logic_vector(7 downto 0);
    signal psram_dout8     : std_logic_vector(7 downto 0);

    -- Signals for the bootstrap health monitor

    -- Bit 5 is the error bit
    -- Bit 4 is the done bit
    -- Bit 3 is the write/read bit (0 = write, 1 = read)

    constant DBG_00 : std_logic_vector(5 downto 0) := "000000";
    constant DBG_01 : std_logic_vector(5 downto 0) := "000001";
    constant DBG_02 : std_logic_vector(5 downto 0) := "000010";
    constant DBG_03 : std_logic_vector(5 downto 0) := "000011";
    constant DBG_04 : std_logic_vector(5 downto 0) := "000100";
    constant DBG_05 : std_logic_vector(5 downto 0) := "000101";
    constant DBG_06 : std_logic_vector(5 downto 0) := "000110";
    constant DBG_07 : std_logic_vector(5 downto 0) := "000111";
    constant DBG_08 : std_logic_vector(5 downto 0) := "001000";
    constant DBG_09 : std_logic_vector(5 downto 0) := "001001";
    constant DBG_0A : std_logic_vector(5 downto 0) := "001010";
    constant DBG_0B : std_logic_vector(5 downto 0) := "001011";
    constant DBG_0C : std_logic_vector(5 downto 0) := "001100";
    constant DBG_0D : std_logic_vector(5 downto 0) := "001101";
    constant DBG_0E : std_logic_vector(5 downto 0) := "001110";
    constant DBG_0F : std_logic_vector(5 downto 0) := "001111";
    constant DBG_DONE : std_logic_vector(5 downto 0) := "011111";
    signal   state  : std_logic_vector(5 downto 0) := DBG_00;

    component DVI_TX_Top
        port (
            I_rst_n: in std_logic;
            I_serial_clk: in std_logic;
            I_rgb_clk: in std_logic;
            I_rgb_vs: in std_logic;
            I_rgb_hs: in std_logic;
            I_rgb_de: in std_logic;
            I_rgb_r: in std_logic_vector(7 downto 0);
            I_rgb_g: in std_logic_vector(7 downto 0);
            I_rgb_b: in std_logic_vector(7 downto 0);
            O_tmds_clk_p: out std_logic;
            O_tmds_clk_n: out std_logic;
            O_tmds_data_p: out std_logic_vector(2 downto 0);
            O_tmds_data_n: out std_logic_vector(2 downto 0)
        );
    end component;

    component rPLL
        generic (
            FCLKIN: in string := "100.0";
            DEVICE: in string := "GW1N-4";
            DYN_IDIV_SEL: in string := "false";
            IDIV_SEL: in integer := 0;
            DYN_FBDIV_SEL: in string := "false";
            FBDIV_SEL: in integer := 0;
            DYN_ODIV_SEL: in string := "false";
            ODIV_SEL: in integer := 8;
            PSDA_SEL: in string := "0000";
            DYN_DA_EN: in string := "false";
            DUTYDA_SEL: in string := "1000";
            CLKOUT_FT_DIR: in bit := '1';
            CLKOUTP_FT_DIR: in bit := '1';
            CLKOUT_DLY_STEP: in integer := 0;
            CLKOUTP_DLY_STEP: in integer := 0;
            CLKOUTD3_SRC: in string := "CLKOUT";
            CLKFB_SEL: in string := "internal";
            CLKOUT_BYPASS: in string := "false";
            CLKOUTP_BYPASS: in string := "false";
            CLKOUTD_BYPASS: in string := "false";
            CLKOUTD_SRC: in string := "CLKOUT";
            DYN_SDIV_SEL: in integer := 2
        );
        port (
            CLKOUT: out std_logic;
            LOCK: out std_logic;
            CLKOUTP: out std_logic;
            CLKOUTD: out std_logic;
            CLKOUTD3: out std_logic;
            RESET: in std_logic;
            RESET_P: in std_logic;
            CLKIN: in std_logic;
            CLKFB: in std_logic;
            FBDSEL: in std_logic_vector(5 downto 0);
            IDSEL: in std_logic_vector(5 downto 0);
            ODSEL: in std_logic_vector(5 downto 0);
            PSDA: in std_logic_vector(3 downto 0);
            DUTYDA: in std_logic_vector(3 downto 0);
            FDLY: in std_logic_vector(3 downto 0)
        );
    end component;

    component CLKDIV
        generic (
            DIV_MODE : string := "2";
            GSREN: in string := "false"
        );
        port (
            CLKOUT: out std_logic;
            HCLKIN: in std_logic;
            RESETN: in std_logic;
            CALIB: in std_logic
        );
    end component;

    component OSER10
        generic (
            GSREN : string := "false";
            LSREN : string := "true"
        );
        port (
            Q : out std_logic;
            D0 : in std_logic;
            D1 : in std_logic;
            D2 : in std_logic;
            D3 : in std_logic;
            D4 : in std_logic;
            D5 : in std_logic;
            D6 : in std_logic;
            D7 : in std_logic;
            D8 : in std_logic;
            D9 : in std_logic;
            FCLK : in std_logic;
            PCLK : in std_logic;
            RESET : in std_logic
        );
    end component;

    component ELVDS_OBUF
        port (
            I : in std_logic;
            O : out std_logic;
            OB : out std_logic
        );
    end component;

    component FLASH608K
        port (
            DOUT: out std_logic_vector(31 downto 0);
            XE: in std_logic;
            YE: in std_logic;
            SE: in std_logic;
            PROG: in std_logic;
            ERASE: in std_logic;
            NVSTR: in std_logic;
            XADR: in std_logic_vector(8 downto 0);
            YADR: in std_logic_vector(5 downto 0);
            DIN: in std_logic_vector(31 downto 0)
        );
    end component;

begin

    pll1 : rPLL
        generic map (
            FCLKIN => "27",
            DEVICE => "GW1NR-9C",
            IDIV_SEL => 8,
            FBDIV_SEL => 31,
            ODIV_SEL => 8,
            DYN_SDIV_SEL => 6,
            PSDA_SEL => "0100" -- CLKOUTP 90 degree phase shift
        )
        port map (
            CLKIN    => clock_27,
            CLKOUT   => clock_psram,
            CLKOUTD  => clock_main,
            CLKOUTP  => clock_psram_p,
            CLKOUTD3 => clock_sid,
            LOCK     => open,
            RESET    => '0',
            RESET_P  => '0',
            CLKFB    => '0',
            FBDSEL   => (others => '0'),
            IDSEL    => (others => '0'),
            ODSEL    => (others => '0'),
            PSDA     => (others => '0'),
            DUTYDA   => (others => '0'),
            FDLY     => (others => '0')
        );

    pll2 : rPLL
        generic map (
            FCLKIN => "27",
            DEVICE => "GW1NR-9C",
            IDIV_SEL => 2,
            FBDIV_SEL => 13,
            ODIV_SEL => 4
        )
        port map (
            CLKIN    => clock_27,
            CLKOUT   => clock_hdmi,
            CLKOUTP  => open,
            CLKOUTD  => open,
            CLKOUTD3 => open,
            LOCK     => open,
            RESET    => '0',
            RESET_P  => '0',
            CLKFB    => '0',
            FBDSEL   => (others => '0'),
            IDSEL    => (others => '0'),
            ODSEL    => (others => '0'),
            PSDA     => (others => '0'),
            DUTYDA   => (others => '0'),
            FDLY     => (others => '0')
        );

    clkdiv5 : CLKDIV
        generic map (
            DIV_MODE => "5",
            GSREN => "false"
        )
        port map (
            RESETN => '1', -- TODO, reset when previous PLL locked
            HCLKIN => clock_hdmi,
            CLKOUT => clock_vga,
            CALIB  => '1'
        );

    --------------------------------------------------------
    -- Power Up Reset Generation
    --------------------------------------------------------

    ext_reset_n     <= '1'; -- was btn2_n

    -- The external reset signal is not asserted on power up
    ResetProcess : process (clock_main)
    begin
        if rising_edge(clock_main) then
            if btn1_n = '0' then
                reset_counter <= (others => '0');
            elsif (reset_counter(reset_counter'high) = '0') then
                reset_counter <= reset_counter + 1;
            end if;
            powerup_reset_n <= reset_counter(reset_counter'high);
        end if;
    end process;


    -- On power up, wait for the psram controller to initialize before bootstrapping SPI flash
    process(clock_main)
    begin
        if rising_edge(clock_main) then
            if powerup_reset_n = '0' then
                delayed_reset_n <= '0';
            elsif psram_busy = '0' then
                delayed_reset_n <= '1';
            end if;
        end if;
    end process;

    -- On power up, wait for the flash bootstrap to complete before releasing the core
    hard_reset_n <= delayed_reset_n and not bootstrap_busy;

    --------------------------------------------------------
    -- PSRAM
    --------------------------------------------------------

    ram : entity work.PsramController
        generic map (
            FREQ => 96_000_000,
            LATENCY => 4,
            CS_DELAY => true
        )
        port map (
            clk           => clock_psram,
            clk_p         => clock_psram_p, -- phase-shifted clock for driving O_psram_ck
            resetn        => powerup_reset_n,
            read          => psram_read,
            write         => psram_write,
            addr          => psram_addr, -- Byte address to read / write
            din           => psram_din,  -- Data word to write
            dout          => psram_dout, -- Last read data. Read is always word-based.
            busy          => psram_busy, -- 1 while an operation is in progress, TODO: IGORNED FOR NOW
            byte_write    => '1',        -- When writing, only write one byte instead of the whole word.
                                         -- addr[0]==1 means we write the upper half of din. lower half otherwise.

            -- HyperRAM physical interface. Gowin interface is for 2 dies.
            -- We currently only use the first die (4MB).
            O_psram_ck    => O_psram_ck,
            O_psram_ck_n  => O_psram_ck_n,
            IO_psram_rwds => IO_psram_rwds,
            IO_psram_dq   => IO_psram_dq,
            O_psram_cs_n  => O_psram_cs_n
        );

-- VARIENT A
--
-- At 4MHz there is very little margin for error in the placement of the PSRAM read
--
-- PSRAM: CS_DELAY = true
--
--             phi2d1    stb    state
-- 96m 16m  phi2  |phi2d2 | ps_rd |
--  0   ^     0   0   1   0   0  IDLE
--  1         0   0   1   0   0  IDLE
--  2         0   0   1   0   0  IDLE
--  3   v     0   0   0   1   0  IDLE
--  4         0   0   0   1   1  IDLE
--  5         0   0   0   1   1  CS DELAY
--  6   ^     1   0   0   1   1  READ * psram_addr latched
--  7         1   0   0   1   1  READ
--  8         1   0   0   1   1  READ
--  9   v     1   1   0   0   1  READ
-- 10         1   1   0   0   0  READ
-- 11         1   1   0   0   0  READ
-- 12   ^     1   1   0   0   0  READ
-- 13         1   1   0   0   0  READ
-- 14         1   1   0   0   0  READ
-- 15   v     1   1   1   0   0  READ
-- 16         1   1   1   0   0  READ
-- 17         1   1   1   0   0  READ
-- 18   ^ 1   0   1   1   0   0  IDLE * psram_dout latched (latency = 1x)
-- 19     1   0   1   1   0   0  IDLE
-- 20     1   0   1   1   0   0  IDLE
-- 21   v 1   0   0   1   0   0  IDLE
-- 22     1   0   0   1   0   0  IDLE * psram_dout latched (latency = 2x)
-- 23     1   0   0   1   0   0  IDLE
-- 24   ^ |
--     cpuclken
--
-- In this varient there are:
--
--    6x 96MHz cycles from CPU being clocked to address being latched
--    (CS_DELAY=false will rereduce this by one)
--
--    2x 96MHz cycles from read data available to CPU being clocked
--    (CS_DELAY=false will increase this by one)

    process(clock_main)
    begin
        if falling_edge(clock_main) then
            phi2d1 <= phi2;
            phi2d2 <= phi2d1;
            if phi2d1 = '0' and phi2d2 = '1' then
                stb <= '1';
            else
                stb <= '0';
            end if;
        end if;
    end process;

-- VARIENT B
--
-- At 4MHz there is very little margin for error in the placement of the PSRAM read
--
-- PSRAM: CS_DELAY = true
--
--             phi2d1   ps_rd
-- 96m 16m  phi2  |  stb  | state
--  0   ^     0   0   1   0  IDLE
--  1         0   0   1   1  IDLE
--  2         0   0   1   1  CS DELAY
--  3   v     0   0   1   1  READ * psram_addr latched
--  4         0   0   1   1  READ
--  5         0   0   1   1  READ
--  6   ^     1   0   0   1  READ
--  7         1   0   0   0  READ
--  8         1   0   0   0  READ
--  9   v     1   1   0   0  READ
-- 10         1   1   0   0  READ
-- 11         1   1   0   0  READ
-- 12   ^     1   1   0   0  READ
-- 13         1   1   0   0  READ
-- 14         1   1   0   0  READ
-- 15   v     1   1   0   0  IDLE * psram_dout latched (latency = 1x)
-- 16         1   1   0   0  IDLE
-- 17         1   1   0   0  IDLE
-- 18   ^ 1   0   1   0   0  IDLE
-- 19     1   0   1   0   0  IDLE * psram_dout latched (latency = 2x)
-- 20     1   0   1   0   0  IDLE
-- 21   v 1   0   0   0   0  IDLE
-- 22     1   0   0   0   0  IDLE
-- 23     1   0   0   0   0  IDLE
-- 24   ^ |
--     cpuclken
--
-- In this varient there are:
--
--    3x 96MHz cycles from CPU being clocked to address being latched
--    (CS_DELAY=false will rereduce this by one)
--
--    5x 96MHz cycles from read data available to CPU being clocked
--    (CS_DELAY=false will increase this by one)

--  process(clock_main)
--  begin
--      if rising_edge(clock_main) then
--          phi2d1 <= phi2;
--          if phi2 = '0' and phi2d1 = '1' then
--              stb <= '1';
--          else
--              stb <= '0';
--          end if;
--      end if;
--  end process;

    process(clock_psram)
    begin
        if rising_edge(clock_psram) then
            O_psram_reset_n <= powerup_reset_n & powerup_reset_n;
            if psram_stb = '1' and psram_ce = '1' and psram_we = '0' then
                psram_read <= '1';
            else
                psram_read <= '0';
            end if;
            if psram_stb = '1' and psram_ce = '1' and psram_we = '1' then
                psram_write <= '1';
            else
                psram_write <= '0';
            end if;
        end if;
    end process;

    psram_din   <= psram_din8 & psram_din8;
    psram_dout8 <= psram_dout(15 downto 8) when psram_addr(0) = '1' else psram_dout(7 downto 0);

    --------------------------------------------------------
    -- User Flash
    --------------------------------------------------------

    -- CImplBootstrap CImplUserFlash    Notes
    --      false          false        Used to speed up simulation, where PSRAM can be pre-loaded
    --      false          true         ROM content stored in Internal User Flash
    --      true           false        ROM content stored in External SPI flash and bootsrapped into SRAM
    --      true           true         Invalid (doesn't make sense)

    cimpluserflash_true : if CImplUserFlash generate

        flash_inst : FLASH608K
        port map (
            DOUT  => RomDout,
            XE    => '1',
            YE    => '1',
            SE    => phi2,
            PROG  => '0',
            ERASE => '0',
            NVSTR => '0',
            XADR  => xadr,
            YADR  => yadr,
            DIN   => (others => '0')
                );
        xadr <= "000" & ExternA(13 downto 8);
        yadr <= ExternA(7 downto 2);

        RomCE <= '1' when ExternCE = '1' and ExternA(18 downto 17) = "00" else '0';
        RamCE <= '1' when ExternCE = '1' and ExternA(18 downto 17) = "01" else '0';

        ExternDout <= psram_dout8           when RamCE = '1'                                else
                      RomDout( 7 downto  0) when RomCE = '1' and ExternA(1 downto 0) = "00" else
                      RomDout(15 downto  8) when RomCE = '1' and ExternA(1 downto 0) = "01" else
                      RomDout(23 downto 16) when RomCE = '1' and ExternA(1 downto 0) = "10" else
                      RomDout(31 downto 24) when RomCE = '1' and ExternA(1 downto 0) = "11" else
                      x"AA";

    end generate;

    cimpluserflash_false : if not CImplUserFlash generate

        RomCE <= '0';
        RamCE <= '1' when ExternCE = '1' and ExternA(18) = '0' else '0';

        ExternDout <= psram_dout8 when RamCE = '1' else
                      x"AA";
    end generate;

    --------------------------------------------------------
    -- Bootstrap ROM content from SPI Flash into PSRAM
    --------------------------------------------------------

    cimplbootstrap_true : if CImplBootstrap generate

        boot : entity work.bootstrap
        port map (
            clock           => clock_main,

            -- initiate bootstrap
            powerup_reset_n => delayed_reset_n,

            -- high when FLASH is being copied to SRAM, can be used by user as active high reset
            bootstrap_busy  => bootstrap_busy,

            -- start address of user data in FLASH
            user_address    => (others => '0'),

            -- interface with the Atom core
            RAM_STB         => stb,
            RAM_CE          => RamCE,
            RAM_WE          => ExternWE,
            RAM_A           => ExternA,
            RAM_Din         => ExternDin,
            RAM_Dout        => open,        -- Internally this is pass through anyway

            -- interface with the PSRAM
            PSRAM_STB       => psram_stb,
            PSRAM_CE        => psram_ce,
            PSRAM_WE        => psram_we,
            PSRAM_A         => psram_addr,
            PSRAM_Din       => psram_din8,
            PSRAM_Dout      => psram_dout8,

            -- interface with the external FLASH
            FLASH_CS        => flash_cs,
            FLASH_CK        => flash_ck,
            FLASH_SI        => flash_si,
            FLASH_SO        => flash_so
            );

    end generate;

    cimplbootstrap_false : if not CImplBootstrap generate

        psram_stb <= stb;
        psram_ce <= '1' when RamCE = '1' else '0';
        psram_we <= ExternWE;
        psram_addr <= "000" & ExternA;
        psram_din8 <= ExternDin;

        flash_cs <= '1';
        flash_ck <= '1';
        flash_si <= '1';

        bootstrap_busy <= '0';

    end generate;

    --------------------------------------------------------
    -- Atom FPGA Core
    --------------------------------------------------------

    inst_AtomFpga_Core : entity work.AtomFpga_Core
    generic map (
        CImplCpu65c02           => CImplCpu65c02,
        CImplSDDOS              => CImplSDDOS,
        CImplAtoMMC2            => CImplAtoMMC2,
        CImplGraphicsExt        => true,
        CImplSoftChar           => false,
        CImplSID                => CImplSID,
        CImplVGA80x40           => true,
        CImplHWScrolling        => true,
        CImplMouse              => true,
        CImplUart               => false,
        CImplDoubleVideo        => false,
        CImplRamRomNone         => false,
        CImplRamRomPhill        => false,
        CImplRamRomAtom2015     => true,
        CImplRamRomSchakelKaart => false,
        CImplSampleExternData   => false,
        MainClockSpeed          => 16000000,
        DefaultBaud             => 115200,
        DefaultTurbo            => DefaultTurbo
    )
    port map(
        -- Clocking
        clk_vga             => clock_vga,
        clk_main            => clock_main,
        clk_avr             => clock_main,
        clk_avr_debug       => '0',
        clk_dac             => clock_sid,
        clk_32M00           => clock_sid,
        -- Keyboard/mouse
        kbd_pa              => open,
        kbd_pb              => (others => '1'),
        kbd_pc              => (others => '1'),
        ps2_clk             => ps2_clk,
        ps2_data            => ps2_data,
        ps2_mouse_clk       => ps2_mouse_clk,
        ps2_mouse_data      => ps2_mouse_data,
        -- Resets
        powerup_reset_n     => hard_reset_n,
        ext_reset_n         => ext_reset_n,
        int_reset_n         => open,
        -- Video
        red                 => red,
        green               => green,
        blue                => blue,
        vsync               => vsync,
        hsync               => hsync,
        blank               => blank,
        -- External 6502 bus interface
        phi2                => phi2,
        sync                => sync,
        rnw                 => rnw,
        -- External Bus/Ram/Rom interface
        ExternCE            => ExternCE,
        ExternWE            => ExternWE,
        ExternA             => ExternA,
        ExternDin           => ExternDin,
        ExternDout          => ExternDout,
        -- Audio
        sid_audio           => audiol,
        sid_audio_d         => open,
        atom_audio          => audior,
        -- SD Card
        SDMISO              => tf_miso,
        SDSS                => tf_cs,
        SDCLK               => tf_sclk,
        SDMOSI              => tf_mosi,
        -- Serial
        uart_RxD            => uart_rx,
        uart_TxD            => uart_tx,
        avr_RxD             => '1',
        avr_TxD             => open,
        -- Cassette
        cas_in              => '0',
        cas_out             => open,
        -- Misc
        LED1                => led1,
        LED2                => led2,
        charSet             => '0',
        Joystick1           => (others => '1'),
        Joystick2           => (others => '1')
    );

    --------------------------------------------------------
    -- DVI / HDMI output
    --------------------------------------------------------

    rgb_r <= red   & "00000";
    rgb_g <= green & "00000";
    rgb_b <= blue  & "00000";
    rgb_vs <= not vsync;
    rgb_hs <= not hsync;
    rgb_de <= not blank;

    -- This is Gowin's proprietaty (and encrypted) DVI encoder

    dvi_gowin : if (CImplDVIGowin) generate
        dvi_tx1 : DVI_TX_Top
            port map (
                I_rst_n => powerup_reset_n,
                I_serial_clk => clock_hdmi,
                I_rgb_clk => clock_vga,
                I_rgb_vs => rgb_vs,
                I_rgb_hs => rgb_hs,
                I_rgb_de => rgb_de,
                I_rgb_r => rgb_r,
                I_rgb_g => rgb_g,
                I_rgb_b => rgb_b,
                O_tmds_clk_p => tmds_clk_p,
                O_tmds_clk_n => tmds_clk_n,
                O_tmds_data_p => tmds_d_p,
                O_tmds_data_n => tmds_d_n
                );
    end generate;

    -- This is an opensource version from here:
    --     https://github.com/fcayci/vhdl-hdmi-out/tree/master

    dvi_open_source : if (CImplDVIOpenSOurce) generate

        -- TODO: The source for this could be made much smaller with some for/generate loops!

        reset <= not powerup_reset_n;
        ctrl  <= rgb_vs & rgb_hs;

        -- Encode vsync, hsync, blanking and rgb data to Transition-minimized differential signaling (TMDS) format.

        tr : entity work.tmds_encoder(rtl)
            port map (
                clk  => clock_vga,
                en   => rgb_de,
                ctrl => "00",
                din  => rgb_r,
                dout => encoded_r
                );

        tg : entity work.tmds_encoder(rtl)
            port map (
                clk  => clock_vga,
                en   => rgb_de,
                ctrl => "00",
                din  => rgb_g,
                dout => encoded_g
                );

        tb : entity work.tmds_encoder(rtl)
            port map (
                clk  => clock_vga,
                en   => rgb_de,
                ctrl => ctrl,
                din  => rgb_b,
                dout => encoded_b
                );

        --  Serialize the three 10-bit TMDS channels to three serialized 1-bit TMDS streams

        ser_b : OSER10
            generic map (
                GSREN => "false",
                LSREN => "true"
                )
            port map(
                PCLK  => clock_vga,
                FCLK  => clock_hdmi,
                RESET => reset,
                Q     => serialized_b,
                D0    => encoded_b(0),
                D1    => encoded_b(1),
                D2    => encoded_b(2),
                D3    => encoded_b(3),
                D4    => encoded_b(4),
                D5    => encoded_b(5),
                D6    => encoded_b(6),
                D7    => encoded_b(7),
                D8    => encoded_b(8),
                D9    => encoded_b(9)
                );

        ser_g : OSER10
            generic map (
                GSREN => "false",
                LSREN => "true"
                )
            port map (
                PCLK  => clock_vga,
                FCLK  => clock_hdmi,
                RESET => reset,
                Q     => serialized_g,
                D0    => encoded_g(0),
                D1    => encoded_g(1),
                D2    => encoded_g(2),
                D3    => encoded_g(3),
                D4    => encoded_g(4),
                D5    => encoded_g(5),
                D6    => encoded_g(6),
                D7    => encoded_g(7),
                D8    => encoded_g(8),
                D9    => encoded_g(9)
                );

        ser_r : OSER10
            generic map (
                GSREN => "false",
                LSREN => "true"
                )
            port map (
                PCLK  => clock_vga,
                FCLK  => clock_hdmi,
                RESET => reset,
                Q     => serialized_r,
                D0    => encoded_r(0),
                D1    => encoded_r(1),
                D2    => encoded_r(2),
                D3    => encoded_r(3),
                D4    => encoded_r(4),
                D5    => encoded_r(5),
                D6    => encoded_r(6),
                D7    => encoded_r(7),
                D8    => encoded_r(8),
                D9    => encoded_r(9)
                );

        ser_c : OSER10
            generic map (
                GSREN => "false",
                LSREN => "true"
                )
            port map (
                PCLK  => clock_vga,
                FCLK  => clock_hdmi,
                RESET => reset,
                Q     => serialized_c,
                D0    => '1',
                D1    => '1',
                D2    => '1',
                D3    => '1',
                D4    => '1',
                D5    => '0',
                D6    => '0',
                D7    => '0',
                D8    => '0',
                D9    => '0'
                );

        -- Encode the 1-bit serialized TMDS streams to Low-voltage differential signaling (LVDS) HDMI output pins

        OBUFDS_c : ELVDS_OBUF
            port map (
                I  => serialized_c,
                O  => tmds_clk_p,
                OB => tmds_clk_n
                );

        OBUFDS_b : ELVDS_OBUF
            port map (
                I  => serialized_b,
                O  => tmds_d_p(0),
                OB => tmds_d_n(0)
                );

        OBUFDS_g : ELVDS_OBUF
            port map (
                I  => serialized_g,
                O  => tmds_d_p(1),
                OB => tmds_d_n(1)
                );

        OBUFDS_r : ELVDS_OBUF
            port map (
                I  => serialized_r,
                O  => tmds_d_p(2),
                OB => tmds_d_n(2)
                );

    end generate;

    -- Statemachine for debugging bootstrap failures
    --------------------------------------------------------

    mon : if CImplMonitor generate

        -- TODO: the addesses on match when CImplAtoMMC2 is true, as this setting affects the OSRomBank

        -- Signals for the bootstrap health monitor
        signal ADDR_INS0 : std_logic_vector(18 downto 0);
        signal ADDR_INS1 : std_logic_vector(18 downto 0);
        signal ADDR_VEC0 : std_logic_vector(18 downto 0);
        signal ADDR_VEC1 : std_logic_vector(18 downto 0);

        signal DATA_INS0 : std_logic_vector(7 downto 0);
        signal DATA_INS1 : std_logic_vector(7 downto 0);
        signal DATA_VEC0 : std_logic_vector(7 downto 0);
        signal DATA_VEC1 : std_logic_vector(7 downto 0);

        signal i_X_A     : std_logic_vector(18 downto 0);
        signal i_X_Din   : std_logic_vector(7 downto 0);
        signal i_X_Dout  : std_logic_vector(7 downto 0);

        signal cmd_write1 : std_logic;
        signal cmd_write2 : std_logic;
        signal test_write : std_logic;
        signal cmd_read1  : std_logic;
        signal cmd_read2  : std_logic;
        signal test_read  : std_logic;
        signal test_Dout  : std_logic_vector(7 downto 0);

    begin

        ADDR_INS0 <= "001" & x"3F3F";
        ADDR_INS1 <= "001" & x"3F40";
        ADDR_VEC0 <= "001" & x"3FFC";
        ADDR_VEC1 <= "001" & x"3FFD";

        DATA_INS0 <= x"A2";
        DATA_INS1 <= x"17";
        DATA_VEC0 <= x"3F";
        DATA_VEC1 <= x"FF";

        i_X_A     <= psram_addr(18 downto 0);
        i_X_Dout  <= psram_dout8;
        i_X_Din   <= psram_din8;

        process(clock_main)
        begin
            if rising_edge(clock_main) then
                case (state) is
                    when DBG_00 =>
                        if powerup_reset_n = '0' then
                            if CimplBootstrap then
                                state <= DBG_01;
                            else
                                state <= DBG_08;
                            end if;
                        end if;
                    when DBG_01 =>
                        if powerup_reset_n = '1' then
                            state <= DBG_02;
                        end if;
                    when DBG_02 =>
                        if delayed_reset_n = '0' then
                            state <= DBG_03;
                        end if;
                    when DBG_03 =>
                        if delayed_reset_n = '1' then
                            state <= DBG_04;
                        end if;
                    when DBG_04 =>
                        if test_write = '1' then
                            if i_X_A = ADDR_INS0 then
                                if i_X_Din = DATA_INS0 then
                                    state <= DBG_05;
                                else
                                    state(5) <= '1';
                                end if;
                            end if;
                        end if;
                    when DBG_05 =>
                        if test_write = '1' then
                            if i_X_A = ADDR_INS1 then
                                if i_X_Din = DATA_INS1 then
                                    state <= DBG_06;
                                else
                                    state(5) <= '1';
                                end if;
                            end if;
                        end if;
                    when DBG_06 =>
                        if test_write = '1' then
                            if i_X_A = ADDR_VEC0 then
                                if i_X_Din = DATA_VEC0 then
                                    state <= DBG_07;
                                else
                                    state(5) <= '1';
                                end if;
                            end if;
                        end if;
                    when DBG_07 =>
                        if  test_write = '1' then
                            if i_X_A = ADDR_VEC1 then
                                if i_X_Din = DATA_VEC1 then
                                    state <= DBG_08;
                                else
                                    state(5) <= '1';
                                end if;
                            end if;
                        end if;
                    when DBG_08 =>
                        if bootstrap_busy = '1' then
                            state <= DBG_09;
                        end if;
                    when DBG_09 =>
                        if bootstrap_busy = '0' then
                            state <= DBG_0A;
                        end if;
                    when DBG_0A =>
                        if test_read = '1' then
                            if i_X_A = ADDR_VEC0 then
                                if test_Dout = DATA_VEC0 then
                                    state <= DBG_0B;
                                else
                                    state(5) <= '1';
                                end if;
                            end if;
                        end if;
                    when DBG_0B =>
                        if test_read = '1' then
                            if i_X_A = ADDR_VEC1 then
                                if test_Dout = DATA_VEC1 then
                                    state <= DBG_0C;
                                else
                                    state(5) <= '1';
                                end if;
                            end if;
                        end if;
                    when DBG_0C =>
                        if test_read = '1' then
                            if i_X_A = ADDR_INS0 then
                                if test_Dout = DATA_INS0 then
                                    state <= DBG_0D;
                                else
                                    state(5) <= '1';
                                end if;
                            end if;
                        end if;
                    when DBG_0D =>
                        if test_read = '1' then
                            if i_X_A = ADDR_INS1 then
                                if test_Dout = DATA_INS1 then
                                    state <= DBG_DONE;
                                else
                                    state(5) <= '1';
                                end if;
                            end if;
                        end if;
                    when others =>
                        if powerup_reset_n = '0' then
                            state <= DBG_00;
                        end if;
                end case;
                -- Check writes at the start of the write cycle
                if psram_stb = '1' and psram_ce = '1' and psram_we = '1' then
                    cmd_write1 <= '1';
                elsif psram_busy = '0' then
                    cmd_write1 <= '0';
                end if;
                cmd_write2 <= cmd_write1;
                test_write <= cmd_write1 and not cmd_write2;
                -- Check reads at the end of the read cycle
                if psram_stb = '1' and psram_ce = '1' and psram_we = '0' then
                    cmd_read1 <= '1';
                elsif psram_busy = '0' then
                    cmd_read1 <= '0';
                end if;
                cmd_read2  <= cmd_read1;
                test_read  <= not cmd_read1 and cmd_read2;
                -- Move dout back to main domain
                test_Dout <= i_X_Dout;
            end if;
        end process;
    end generate;

    led <= state xor "111111";

    -- 1.8V VGA outputs, as per BeebFpga
    vga_r  <= red(2);
    vga_g  <= green(2);
    vga_b  <= blue(2);
    vga_hs <= hsync;
    vga_vs <= vsync;

    -- Audio/VGA output to the 3.3V GPIO bus
    vga: if (CImplVGA) generate
        gpio <= audiol & audior & (not blank) & vsync & hsync & red(2) & blue & red(1 downto 0) & green;
    end generate;

    -- Audio/6502 Decoder tracing to the 3.3V GPIO bus
    trace: if (CImplTrace) generate
        data <= ExternDout when ExternCE = '1' and rnw = '1' else ExternDin;
        gpio <= audiol & audior & hard_reset_n & phi2 & sync & rnw & data;
    end generate;

    -- Debug output to the 3.3V GPIO bus
    debug: if (CImplDebug) generate
        data <= ExternDout when ExternCE = '1' and rnw = '1' else ExternDin;
        gpio <= audiol & audior & hard_reset_n & phi2 & sync & rnw & data when btn2_n = '0' else
                '0' & state(5) & psram_write & psram_read & psram_busy & IO_psram_rwds(0) & flash_cs & flash_ck & flash_si & flash_so & psram_din(3 downto 0) when state(3) = '0' else
                '0' & state(5) & psram_write & psram_read & psram_busy & IO_psram_rwds(0) & psram_dout8;
    end generate;


end behavioral;
