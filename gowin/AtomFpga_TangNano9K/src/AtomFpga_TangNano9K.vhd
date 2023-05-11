--------------------------------------------------------------------------------
-- Copyright (c) 2009 Alan Daly.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : AtomFpga_PapilioOne.vhd
-- /___/   /\     Timestamp : 02/03/2013 06:17:50
-- \   \  /  \
--  \___\/\___\
--
--Design Name: AtomFpga_PapilioOne
--Device: spartan3E

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AtomFpga_TangNano9K is
    port (
        clock_27       : in    std_logic;
        btn1_n         : in    std_logic;
        btn2_n         : in    std_logic;
        ps2_clk        : in    std_logic;
        ps2_data       : in    std_logic;
        ps2_mouse_clk  : inout std_logic;
        ps2_mouse_data : inout std_logic;
        red            : out   std_logic_vector (2 downto 0);
        green          : out   std_logic_vector (2 downto 0);
        blue           : out   std_logic_vector (2 downto 0);
        vsync          : out   std_logic;
        hsync          : out   std_logic;
        audiol         : out   std_logic;
        audior         : out   std_logic;
        tf_miso        : in    std_logic;
        tf_cs          : out   std_logic;
        tf_sclk        : out   std_logic;
        tf_mosi        : out   std_logic;
        uart_rx        : in    std_logic;
        uart_tx        : out   std_logic;
        led            : out   std_logic_vector (5 downto 0)
    );
end AtomFpga_TangNano9K;

architecture behavioral of AtomFpga_TangNano9K is

    signal clock_16   : std_logic;
    signal clock_25   : std_logic;
    signal clock_32   : std_logic;

    signal led1       : std_logic;
    signal led2       : std_logic;

    signal RomCE      : std_logic;
    signal RamCE1     : std_logic;
    signal RamCE2     : std_logic;
    signal ExternCE   : std_logic;
    signal ExternWE   : std_logic;
    signal ExternA    : std_logic_vector (18 downto 0);
    signal ExternDin  : std_logic_vector (7 downto 0);
    signal ExternDout : std_logic_vector (7 downto 0);
    signal RamDout1   : std_logic_vector (7 downto 0);
    signal RamDout2   : std_logic_vector (7 downto 0);
    signal RomDout    : std_logic_vector (7 downto 0);

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

begin

    pll1 : rPLL
        generic map (
            FCLKIN => "27",
            DEVICE => "GW1NR-9C",
            IDIV_SEL => 8,
            FBDIV_SEL => 31,
            ODIV_SEL => 8,
            DYN_SDIV_SEL => 6
        )
        port map (
            CLKIN    => clock_27,
            CLKOUT   => open,
            CLKOUTD  => clock_16,
            CLKOUTP  => open,
            CLKOUTD3 => clock_32,
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
            IDIV_SEL => 8,
            FBDIV_SEL => 24,
            ODIV_SEL => 8,
            DYN_SDIV_SEL => 6
        )
        port map (
            CLKIN    => clock_27,
            CLKOUT   => open,
            CLKOUTP  => open,
            CLKOUTD  => open,
            CLKOUTD3 => clock_25,
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

    ram_0000_07ff : entity work.RAM_2K port map(
        clk     => clock_16,
        we_uP   => ExternWE,
        ce      => RamCE1,
        addr_uP => ExternA(10 downto 0),
        D_uP    => ExternDin,
        Q_uP    => RamDout1
    );

    ram_2000_3fff : entity work.RAM_8K port map(
        clk     => clock_16,
        we_uP   => ExternWE,
        ce      => RamCE2,
        addr_uP => ExternA(12 downto 0),
        D_uP    => ExternDin,
        Q_uP    => RamDout2
    );

    rom_c000_ffff : entity work.InternalROM port map(
        CLK     => clock_16,
        ADDR    => ExternA(13 downto 0),
        DATA    => RomDout
    );

--    );

    RamCE1 <= '1' when ExternCE = '1' and ExternA(15 downto 11) = "00000" else '0';
    RamCE2 <= '1' when ExternCE = '1' and ExternA(15 downto 13) = "001"   else '0';
    RomCE  <= '1' when ExternCE = '1' and ExternA(15 downto 14) = "11"    else '0';

    ExternDout(7 downto 0) <= RamDout1 when RamCE1 = '1' else
                              RamDout2 when RamCE2 = '1' else
                              RomDout  when RomCE  = '1' else
                              "11110001";

    inst_AtomFpga_Core : entity work.AtomFpga_Core
    generic map (
        CImplSDDOS              => true,
        CImplAtoMMC2            => false,
        CImplGraphicsExt        => true,
        CImplSoftChar           => false,
        CImplSID                => true,
        CImplVGA80x40           => true,
        CImplHWScrolling        => true,
        CImplMouse              => true,
        CImplUart               => true,
        CImplDoubleVideo        => false,
        CImplRamRomNone         => true,
        CImplRamRomPhill        => false,
        CImplRamRomAtom2015     => false,
        CImplRamRomSchakelKaart => false,
        MainClockSpeed          => 16000000,
        DefaultBaud             => 115200
    )
    port map(
        clk_vga             => clock_25,
        clk_main            => clock_16,
        clk_avr             => clock_16,
        clk_avr_debug       => '0',
        clk_dac             => clock_32,
        clk_32M00           => clock_32,
        ps2_clk             => ps2_clk,
        ps2_data            => ps2_data,
        ps2_mouse_clk       => ps2_mouse_clk,
        ps2_mouse_data      => ps2_mouse_data,
        powerup_reset_n     => btn1_n,
        ext_reset_n         => btn2_n,
        int_reset_n         => open,
        red                 => red,
        green               => green,
        blue                => blue,
        vsync               => vsync,
        hsync               => hsync,
        phi2                => open,
        ExternCE            => ExternCE,
        ExternWE            => ExternWE,
        ExternA             => ExternA,
        ExternDin           => ExternDin,
        ExternDout          => ExternDout,
        sid_audio           => audiol,
        sid_audio_d         => open,
        atom_audio          => audior,
        SDMISO              => tf_miso,
        SDSS                => tf_cs,
        SDCLK               => tf_sclk,
        SDMOSI              => tf_mosi,
        uart_RxD            => uart_rx,
        uart_TxD            => uart_tx,
        avr_RxD             => '1',
        avr_TxD             => open,
        LED1                => led1,
        LED2                => led2,
        charSet             => '0'
    );

    led <= btn2_n & btn2_n & btn2_n & led2 & led2 & btn1_n;

end behavioral;
