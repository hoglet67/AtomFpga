--------------------------------------------------------------------------------
-- Copyright (c) 2014 David Banks
--
-- based on work by Alan Daly. Copyright(c) 2009. All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : AtomFpga_Hoglet.vhd
-- /___/   /\     Timestamp : 03/04/2014 19:27:00
-- \   \  /  \
--  \___\/\___\
--
--Design Name: AtomFpga_Hoglet
--Device: spartan3E

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AtomFpga_Hoglet is
    port (clk_32M00 : in  std_logic;
           ps2_clk  : in  std_logic;
           ps2_data : in  std_logic;
           ps2_mouse_clk  : inout  std_logic;
           ps2_mouse_data : inout  std_logic;
           ERSTn    : in  std_logic;
           red      : out std_logic_vector (2 downto 2);
           green    : out std_logic_vector (2 downto 1);
           blue     : out std_logic_vector (2 downto 2);
           vsync    : out std_logic;
           hsync    : out std_logic;
           audiol   : out std_logic;
           audioR   : out std_logic;
           RAMOEn   : out std_logic;
           RAMWRn   : out std_logic;
           ROMOEn   : out std_logic;
           ROMWRn   : out std_logic;
           ExternA  : out std_logic_vector (16 downto 0);
           ExternD  : inout std_logic_vector (7 downto 0);
           SDMISO   : in  std_logic;
           SDSS     : out std_logic;
           SDCLK    : out std_logic;
           SDMOSI   : out std_logic;
           RxD      : in  std_logic;
           TxD      : out std_logic;
           LED1     : out std_logic;
           LED2     : out std_logic
           );
end AtomFpga_Hoglet;

architecture behavioral of AtomFpga_Hoglet is

    signal clock_16   : std_logic;
    signal clock_25   : std_logic;
    signal clock_32   : std_logic;
    signal reset_n    : std_logic;
    signal Phi2       : std_logic;

    signal RamCE      : std_logic;
    signal RomCE      : std_logic;
    signal ExternCE   : std_logic;
    signal ExternWE   : std_logic;
    signal ExternDin  : std_logic_vector (7 downto 0);
    signal ExternDout : std_logic_vector (7 downto 0);

    signal Addr       : std_logic_vector (18 downto 0);

    signal uart_RxD   : std_logic;
    signal uart_TxD   : std_logic;
    signal avr_TxD    : std_logic;

    signal LED1_int   : std_logic;
    signal LED2_int   : std_logic;

begin

    inst_dcm4 : entity work.dcm4 port map(
        CLKIN_IN  => clk_32M00,
        CLK0_OUT  => clock_32,
        CLKFX_OUT => clock_25
    );

    inst_dcm5 : entity work.dcm5 port map(
        CLKIN_IN  => clk_32M00,
        CLKFX_OUT => clock_16
    );

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
        CImplDoubleVideo        => false,
        CImplRamRomNone         => false,
        CImplRamRomPhill        => true,
        CImplRamRomAtom2015     => false,
        CImplRamRomSchakelKaart => false,
        MainClockSpeed          => 16000000,
        DefaultBaud             => 115200
     )
     port map(
        clk_vga             => clock_25,
        clk_16M00           => clock_16,
        clk_32M00           => clock_32,
        ps2_clk             => ps2_clk,
        ps2_data            => ps2_data,
        ps2_mouse_clk       => ps2_mouse_clk,
        ps2_mouse_data      => ps2_mouse_data,
        ERSTn               => ERSTn,
        IRSTn               => reset_n,
        red(2)              => red(2),
        red(1 downto 0)     => open,
        green(2 downto 1)   => green(2 downto 1),
        green(0)            => open,
        blue(2)             => blue(2),
        blue(1 downto 0)    => open,
        vsync               => vsync,
        hsync               => hsync,
        Phi2                => Phi2,
        ExternCE            => ExternCE,
        ExternWE            => ExternWE,
        ExternA             => Addr,
        ExternDin           => ExternDin,
        ExternDout          => ExternDout,
        sid_audio           => audiol,
        sid_audio_d         => open,
        atom_audio          => audioR,
        SDMISO              => SDMISO,
        SDSS                => SDSS,
        SDCLK               => SDCLK,
        SDMOSI              => SDMOSI,
        uart_RxD            => uart_RxD,
        uart_TxD            => uart_TxD,
        avr_RxD             => '1',
        avr_TxD             => avr_TxD,
        LED1                => LED1_int,
        LED2                => LED2_int,
        charSet             => '0'
        );

    ExternA    <= Addr(16 downto 0);
    
    RamCE      <= ExternCE and Addr(17);
    RomCE      <= ExternCE and not Addr(17);

    RAMWRn     <= not (ExternWE and RamCE and Phi2);
    RAMOEn     <= not ((not ExternWE) and RamCE and Phi2);

    ROMWRn     <= not (ExternWE and RomCE and Phi2);
    ROMOEn     <= not ((not ExternWE) and RomCE and Phi2);

    ExternD    <= ExternDin when ExternWE = '1' else "ZZZZZZZZ";
    ExternDout <= ExternD;

    uart_RxD <= RxD;
    -- Idle state is high, logically OR the active low signals
    TxD <= uart_TxD and avr_TxD;

    -- on the hoglet board the LEDs are active low
    LED1 <= not LED1_int;
    LED2 <= not LED2_int;
    
end behavioral;
