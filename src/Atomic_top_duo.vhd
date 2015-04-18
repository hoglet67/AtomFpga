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
--  /   /         Filename  : Atomic_top_duo.vhf
-- /___/   /\     Timestamp : 03/04/2014 19:27:00
-- \   \  /  \ 
--  \___\/\___\ 
--
--Design Name: Atomic_top_duo
--Device: Spartan6 LX9

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Atomic_top_duo is
    port (clk_32M00       : in    std_logic;
           ps2_clk        : in    std_logic;
           ps2_data       : in    std_logic;
           ps2_mouse_clk  : inout std_logic;
           ps2_mouse_data : inout std_logic;
           ERST           : in    std_logic;
           red            : out   std_logic_vector (3 downto 0);
           green          : out   std_logic_vector (3 downto 0);
           blue           : out   std_logic_vector (3 downto 0);
           vsync          : out   std_logic;
           hsync          : out   std_logic;
           audiol         : out   std_logic;
           audioR         : out   std_logic;
           RAMOEn         : out   std_logic;
           RAMWRn         : out   std_logic;
           RAMCEn         : out   std_logic;
           SRAM_ADDR      : out   std_logic_vector (20 downto 0);
           SRAM_DATA      : inout std_logic_vector (7 downto 0);
           SDMISO         : in    std_logic;
           SDSS           : out   std_logic;
           SDCLK          : out   std_logic;
           SDMOSI         : out   std_logic;
           avr_RxD        : in    std_logic;
           avr_TxD        : out   std_logic;
           uart_RxD       : in    std_logic;
           uart_TxD       : out   std_logic;
           LED1           : out   std_logic;
           LED2           : out   std_logic;
           charSet        : in    std_logic
           );
end Atomic_top_duo;

architecture behavioral of Atomic_top_duo is

    signal clk_vga    : std_logic;
    signal clk_16M00  : std_logic;
    signal IRSTn      : std_logic;
    signal ERSTn      : std_logic;     
    signal phi2       : std_logic;

    signal RamCE      : std_logic;
    signal RomCE      : std_logic;
    signal RomCE1     : std_logic;
    signal RomCE2     : std_logic;
    signal RomDout1   : std_logic_vector (7 downto 0);
    signal RomDout2   : std_logic_vector (7 downto 0);
    signal ExternWE   : std_logic;
    signal ExternA    : std_logic_vector (16 downto 0);
    signal ExternDin  : std_logic_vector (7 downto 0);
    signal ExternDout : std_logic_vector (7 downto 0);
    
    signal nARD       : std_logic;
    signal nAWR       : std_logic;
    signal AVRA0      : std_logic;
    signal AVRInt     : std_logic;
    signal AVRDataIn  : std_logic_vector (7 downto 0);
    signal AVRDataOut : std_logic_vector (7 downto 0);

    signal PL8Data    : std_logic_vector (7 downto 0);
    signal PL8Enable  : std_logic;

    signal LED1n      : std_logic;
    signal LED2n      : std_logic;

begin

    inst_dcm4 : entity work.dcm4 port map(
        CLKIN_IN          => clk_32M00,
        CLK0_OUT          => clk_vga,
        CLK0_OUT1         => open,
        CLK2X_OUT         => open
    );

    inst_dcm5 : entity work.dcm5 port map(
        CLKIN_IN          => clk_32M00,
        CLK0_OUT          => clk_16M00,
        CLK0_OUT1         => open,
        CLK2X_OUT         => open
    );
    
    inst_Atomic_core : entity work.Atomic_core
    generic map (
        CImplSDDOS        => false,
        CImplGraphicsExt  => true,
        CImplSoftChar     => true,
        CImplSID          => true,
        CImplVGA80x40     => true,
        CImplHWScrolling  => true,
        CImplMouse        => true,
        CImplUart         => true,
        CImplDoubleVideo  => true,
        MainClockSpeed    => 16000000,
        DefaultBaud       => 115200          
     )
     port map (
        clk_vga           => clk_vga,
        clk_16M00         => clk_16M00,
        clk_32M00         => clk_32M00,
        ps2_clk           => ps2_clk,
        ps2_data          => ps2_data,
        ps2_mouse_clk     => ps2_mouse_clk,
        ps2_mouse_data    => ps2_mouse_data,
        ERSTn             => ERSTn,
        IRSTn             => IRSTn,
        red               => red(3 downto 1),
        green             => green(3 downto 1),
        blue              => blue(3 downto 1),
        vsync             => vsync,
        hsync             => hsync,
        RamCE             => RamCE,
        RomCE             => RomCE,
        phi2              => phi2,
        ExternWE          => ExternWE,
        ExternA           => ExternA,
        ExternDin         => ExternDin,
        ExternDout        => ExternDout,        
        audiol            => audiol,
        audioR            => audioR,
        SDMISO            => '0',
        SDSS              => open,
        SDCLK             => open,
        SDMOSI            => open,
        uart_RxD          => uart_RxD,
        uart_TxD          => uart_TxD,
        LED1              => open,
        LED2              => open,
        charSet           => charSet
    );  

    Inst_AVR8: entity work.AVR8 port map(
        clk16M            => clk_16M00,
        nrst              => IRSTn,
        portain           => AVRDataOut,
        portaout          => AVRDataIn,

        portbin(0)        => '0',
        portbin(1)        => '0',
        portbin(2)        => '0',
        portbin(3)        => '0',
        portbin(4)        => AVRInt,
        portbin(5)        => '0',
        portbin(6)        => '0',
        portbin(7)        => '0',
        
        portbout(0)       => nARD,
        portbout(1)       => nAWR,
        portbout(2)       => open,
        portbout(3)       => AVRA0,
        portbout(4)       => open,
        portbout(5)       => open,
        portbout(6)       => LED1n,
        portbout(7)       => LED2n,

        portdin           => (others => '0'),
        portdout(0)       => open,
        portdout(1)       => open,
        portdout(2)       => open,
        portdout(3)       => open,
        portdout(4)       => SDSS,
        portdout(5)       => open,
        portdout(6)       => open,
        portdout(7)       => open,

        spi_mosio         => SDMOSI,
        spi_scko          => SDCLK,
        spi_misoi         => SDMISO,
     
        rxd               => avr_RxD,
        txd               => avr_TxD
    );
    
    Inst_AtomPL8: entity work.AtomPL8 port map(
        clk               => clk_16M00,
        enable            => PL8Enable,
        nRST              => IRSTn,
        RW                => not ExternWE,
        Addr              => ExternA(2 downto 0),
        DataIn            => ExternDin,
        DataOut           => PL8Data,
        AVRDataIn         => AVRDataIn,
        AVRDataOut        => AVRDataOut,
        nARD              => nARD,
        nAWR              => nAWR,
        AVRA0             => AVRA0,
        AVRINTOut         => AVRInt,
        AtomIORDOut       => open,
        AtomIOWROut       => open
    );

    rom_c000_ffff : entity work.InternalROM port map(
        CLK               => clk_16M00,
        ADDR              => ExternA,
        DATA              => RomDout1
    );

    rom_a000 : entity work.fpgautils port map(
        CLK               => clk_16M00,
        ADDR              => ExternA(11 downto 0),
        DATA              => RomDout2
    );
    
    ERSTn      <= not ERST;

    RomCE1     <= '1' when RomCE = '1' and ExternA(15 downto 14) = "11"   else '0';
    RomCE2     <= '1' when RomCE = '1' and ExternA(15 downto 12) = "1010" else '0';

    RAMCEn     <= not RamCE;
    RAMOEn     <= not ((not ExternWE) and RamCE);
    RAMWRn     <= not (ExternWE and RamCE and phi2);
    SRAM_DATA  <= ExternDin when ExternWE = '1' else "ZZZZZZZZ";
    SRAM_ADDR  <= "0000" & ExternA;

    PL8Enable  <= '1' when ExternA(15 downto 8) = "10110100" else '0';
    
    ExternDout <= PL8Data when PL8Enable = '1' else
                  RomDout1 when RomCE1 = '1' else
                  RomDout2 when RomCE2 = '1' else
                  SRAM_DATA;
    
    red(0)     <= '0';
    green(0)   <= '0';
    blue(0)    <= '0';
    
    LED1       <= not LED1n;
    LED2       <= not LED2n;
        
end behavioral;


