--------------------------------------------------------------------------------
-- Copyright (c) 2009 Alan Daly.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    
-- \   \   \/    
--  \   \         
--  /   /         Filename  : Atomic_top.vhf
-- /___/   /\     Timestamp : 02/03/2013 06:17:50
-- \   \  /  \ 
--  \___\/\___\ 
--
--Design Name: Atomic_top
--Device: spartan3A
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Atomic_top is
    port (clk_25M00 : in    std_logic;
          ps2_clk   : in    std_logic;
          ps2_data  : in    std_logic;
          ERSTn     : in    std_logic;
          red       : out   std_logic_vector (2 downto 0);
          green     : out   std_logic_vector (2 downto 0);
          blue      : out   std_logic_vector (2 downto 0);
          vsync     : out   std_logic;
          hsync     : out   std_logic;
          CE1       : out   std_logic;
          RAMWRn    : out   std_logic;
          RAMOEn    : out   std_logic;
          RamA      : out   std_logic_vector (15 downto 0);
          RamD      : inout std_logic_vector (15 downto 0);
          audiol    : out   std_logic;
          audioR    : out   std_logic;
          SDMISO    : in    std_logic;
          SDSS      : out   std_logic;
          SDCLK     : out   std_logic;
          SDMOSI    : out   std_logic);
end Atomic_top;

architecture behavioral of Atomic_top is

    component dcm2
        port (
            CLKIN_IN  : in  std_logic;
            CLK0_OUT  : out std_logic;
            CLK0_OUT1 : out std_logic;
            CLK2X_OUT : out std_logic
        ); 
    end component;

    component dcm3
        port (CLKIN_IN  : in  std_logic;
              CLK0_OUT  : out std_logic;
              CLK0_OUT1 : out std_logic;
              CLK2X_OUT : out std_logic
         ); 
    end component;
    
    component InternalROM
        port (
            CLK  : in  std_logic;
            ADDR : in  std_logic_vector(16 downto 0);
            DATA : out std_logic_vector(7 downto 0)
        );
    end component; 

    component Atomic_core
        generic (
            CImplSDDOS       : boolean;
            CImplGraphicsExt : boolean;
            CImplSoftChar    : boolean;
            CImplSID         : boolean;
            CImplVGA80x40    : boolean;
            CImplHWScrolling : boolean;
            CImplMouse       : boolean;
            CImplUart        : boolean;
            MainClockSpeed   : integer;
            DefaultBaud      : integer
        );
        port (
            clk_vga : in  std_logic;
            clk_16M00 : in  std_logic;
            clk_32M00 : in  std_logic;
            ps2_clk   : in  std_logic;
            ps2_data  : in  std_logic;
            ps2_mouse_clk : inout    std_logic;
            ps2_mouse_data : inout    std_logic;
            ERSTn     : in  std_logic;
            IRSTn     : out std_logic;
            SDMISO    : in  std_logic;
            red       : out std_logic_vector(2 downto 0);
            green     : out std_logic_vector(2 downto 0);
            blue      : out std_logic_vector(2 downto 0);
            vsync     : out std_logic;
            hsync     : out std_logic;
            RamCE     : out std_logic;
            RomCE     : out std_logic;
            ExternWE  : out std_logic;
            ExternA   : out std_logic_vector (16 downto 0);
            ExternDin : out std_logic_vector (7 downto 0);
            ExternDout: in  std_logic_vector (7 downto 0);
            audiol    : out std_logic;
            audioR    : out std_logic;
            SDSS      : out std_logic;
            SDCLK     : out std_logic;
            SDMOSI    : out std_logic;
            uart_RxD  : in  std_logic;
            uart_TxD  : out std_logic;
            LED1      : out   std_logic;        
            LED2      : out   std_logic
            );
    end component;
    
    signal clk_12M58 : std_logic;
    signal clk_16M00 : std_logic;
    signal clk_32M00 : std_logic;

    signal RomDout      : std_logic_vector (7 downto 0);
    signal RamCE        : std_logic;
    signal RomCE        : std_logic;
    signal ExternA      : std_logic_vector (16 downto 0);
    signal ExternWE     : std_logic;
    signal ExternDin    : std_logic_vector (7 downto 0);
    signal ExternDout   : std_logic_vector (7 downto 0);

begin

    inst_dcm2 : dcm2 port map(
        CLKIN_IN  => clk_25M00,
        CLK0_OUT  => clk_16M00,
        CLK0_OUT1 => open,
        CLK2X_OUT => open);

    inst_dcm3 : dcm3 port map (
        CLKIN_IN  => clk_16M00,
        CLK0_OUT  => clk_32M00,
        CLK0_OUT1 => open,
        CLK2X_OUT => open);

    rom_c000_ffff : InternalROM port map(
        CLK     => clk_16M00,
        ADDR    => ExternA,
        DATA    => RomDout
        );
    
    inst_Atomic_core : Atomic_core
    generic map (
        CImplSDDOS       => true,
        CImplGraphicsExt => false,
        CImplSoftChar    => false,
        CImplSID         => true,
        CImplVGA80x40    => false,
        CImplHWScrolling => false,
        CImplMouse       => false,
        CImplUart        => false,
        MainClockSpeed   => 16000000,
        DefaultBaud      => 115200          
    )
    port map(
        clk_vga   => clk_25M00,
        clk_16M00 => clk_16M00,
        clk_32M00 => clk_32M00,
        ps2_clk => ps2_clk,
        ps2_data => ps2_data,
        ps2_mouse_clk   => open,
        ps2_mouse_data  => open,
        ERSTn => ERSTn,
        IRSTn => open,
        red => red,
        green => green,
        blue => blue,
        vsync => vsync,
        hsync => hsync,
        ExternWE => ExternWE,
        RamCE => RamCE,
        RomCE => RomCE,
        ExternA => ExternA,
        ExternDin => ExternDin,
        ExternDout => ExternDout,
        audiol => audiol,
        audioR => audioR,
        SDMISO => SDMISO,
        SDSS => SDSS,
        SDCLK => SDCLK,
        SDMOSI => SDMOSI,
        uart_RxD  => '1',
        uart_TxD  => open,
        LED1      => open,
        LED2      => open
    );
 
    CE1        <= not RAMCE;
    RAMWRn     <= not ExternWE;
    RAMOEn     <= not RAMCE;
    RamD       <= ExternDin & ExternDin when ExternWE = '1' else "ZZZZZZZZZZZZZZZZ";

    ExternDout <= RamD(7 downto 0) when RamCE = '1' else
                  RomDout  when RomCE = '1' else
                  "11110001";                

    RamA       <= '0' & ExternA(14 downto 0);
        
end behavioral;


