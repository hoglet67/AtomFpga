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
--Device: spartan3E

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Atomic_top_papilio is
    port (clk_32M00 : in  std_logic;
           ps2_clk  : in  std_logic;
           ps2_data : in  std_logic;
           ps2_mouse_clk  : inout  std_logic;
           ps2_mouse_data : inout  std_logic;
           ERST     : in  std_logic;
           red      : out std_logic_vector (2 downto 0);
           green    : out std_logic_vector (2 downto 0);
           blue     : out std_logic_vector (2 downto 0);
           vsync    : out std_logic;
           hsync    : out std_logic;
           audiol   : out std_logic;
           audioR   : out std_logic;
           SDMISO   : in  std_logic;
           SDSS     : out std_logic;
           SDCLK    : out std_logic;
           SDMOSI   : out std_logic;
           RxD      : in  std_logic;
           TxD      : out std_logic;
           LED1     : out std_logic;
           LED2     : out std_logic;
           LED3     : out std_logic;
           LED4     : out std_logic
          );
end Atomic_top_papilio;

architecture behavioral of Atomic_top_papilio is

    component dcm4
        port (
            CLKIN_IN   : in  std_logic;
            CLK0_OUT  : out std_logic;
            CLK0_OUT1 : out std_logic;
            CLK2X_OUT : out std_logic
        ); 
    end component;

    component dcm5
        port (
            CLKIN_IN   : in  std_logic;
            CLK0_OUT  : out std_logic;
            CLK0_OUT1 : out std_logic;
            CLK2X_OUT : out std_logic
        ); 
    end component;
 
    component RAM_2K
        port (
            clk     : in  std_logic;
            we_uP   : in  std_logic;
            ce      : in  std_logic;
            addr_uP : in  std_logic_vector (10 downto 0);
            D_uP    : in  std_logic_vector (7 downto 0);
            Q_uP    : out std_logic_vector (7 downto 0)
        );
    end component;

    component RAM_8K
        port (
            clk     : in  std_logic;
            we_uP   : in  std_logic;
            ce      : in  std_logic;
            addr_uP : in  std_logic_vector (12 downto 0);
            D_uP    : in  std_logic_vector (7 downto 0);
            Q_uP    : out std_logic_vector (7 downto 0)
        );
    end component; 

    component InternalROM
        port (
            CLK  : in  std_logic;
            ADDR : in  std_logic_vector(16 downto 0);
            DATA : out std_logic_vector(7 downto 0)
        );
    end component; 
    
    component fpgautils
        port (
            CLK  : in  std_logic;
            ADDR : in  std_logic_vector(11 downto 0);
            DATA : out std_logic_vector(7 downto 0));
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
            clk_vga        : in    std_logic;
            clk_16M00      : in    std_logic;
            clk_32M00      : in    std_logic;
            ps2_clk        : in    std_logic;
            ps2_data       : in    std_logic;
            ps2_mouse_clk  : inout std_logic;
            ps2_mouse_data : inout std_logic;
            ERSTn          : in    std_logic;
            IRSTn          : out   std_logic;
            SDMISO         : in    std_logic;
            red            : out   std_logic_vector(2 downto 0);
            green          : out   std_logic_vector(2 downto 0);
            blue           : out   std_logic_vector(2 downto 0);
            vsync          : out   std_logic;
            hsync          : out   std_logic;
            RamCE          : out   std_logic;
            RomCE          : out   std_logic;
            ExternWE       : out   std_logic;
            ExternA        : out   std_logic_vector (16 downto 0);
            ExternDin      : out   std_logic_vector (7 downto 0);
            ExternDout     : in    std_logic_vector (7 downto 0);
            audiol         : out   std_logic;
            audioR         : out   std_logic;
            SDSS           : out   std_logic;
            SDCLK          : out   std_logic;
            SDMOSI         : out   std_logic;
            uart_RxD       : in    std_logic;
            uart_TxD       : out   std_logic;
            LED1           : out   std_logic;        
            LED2           : out   std_logic
            );
    end component;
   
    signal clk_vga   : std_logic;
    signal clk_16M00 : std_logic;

    signal ERSTn     : std_logic;

    signal RamCE     : std_logic;
    signal RomCE     : std_logic;
    signal RomCE1    : std_logic;
    signal RomCE2    : std_logic;
    signal RamCE1    : std_logic;
    signal RamCE2    : std_logic;
    signal ExternWE  : std_logic;
    signal ExternA   : std_logic_vector (16 downto 0);
    signal ExternDin : std_logic_vector (7 downto 0);
    signal ExternDout: std_logic_vector (7 downto 0);
    signal RamDout1  : std_logic_vector (7 downto 0);
    signal RamDout2  : std_logic_vector (7 downto 0);
    signal RomDout1  : std_logic_vector (7 downto 0);
    signal RomDout2  : std_logic_vector (7 downto 0);
    
begin

    inst_dcm4 : dcm4 port map(
        CLKIN_IN  => clk_32M00,
        CLK0_OUT  => clk_vga,
        CLK0_OUT1 => open,
        CLK2X_OUT => open);

    inst_dcm5 : dcm5 port map(
        CLKIN_IN  => clk_32M00,
        CLK0_OUT  => clk_16M00,
        CLK0_OUT1 => open,
        CLK2X_OUT => open);

    ram_0000_07ff : RAM_2K port map(
        clk     => clk_16M00,
        we_uP   => ExternWE,
        ce      => RamCE1,
        addr_uP => ExternA (10 downto 0),
        D_uP    => ExternDin,
        Q_uP    => RamDout1
        );

    ram_2000_3fff : RAM_8K port map(
        clk     => clk_16M00,
        we_uP   => ExternWE,
        ce      => RamCE2,
        addr_uP => ExternA (12 downto 0),
        D_uP    => ExternDin,
        Q_uP    => RamDout2
        );
    
    rom_c000_ffff : InternalROM port map(
        CLK     => clk_16M00,
        ADDR    => ExternA,
        DATA    => RomDout1
        );

    rom_a000 : fpgautils port map(
        CLK     => clk_16M00,
        ADDR    => ExternA(11 downto 0),
        DATA    => RomDout2
        );
    
    RamCE1 <= '1' when RamCE = '1' and ExternA(14 downto 11) = "0000" else '0';
    RamCE2 <= '1' when RamCE = '1' and ExternA(14 downto 13) = "01"   else '0';
    RomCE1 <= '1' when RomCE = '1' and ExternA(15 downto 14) = "11"   else '0';
    RomCE2 <= '1' when RomCE = '1' and ExternA(15 downto 12) = "1010" else '0';
        
    ExternDout(7 downto 0) <= RamDout1 when RamCE1 = '1' else
                              RamDout2 when RamCE2 = '1' else
                              RomDout1 when RomCE1 = '1' else
                              RomDout2 when RomCE2 = '1' else
                              "11110001";                
    ERSTn <= not ERST;

    inst_Atomic_core : Atomic_core
    generic map (
        CImplSDDOS       => true,
        CImplGraphicsExt => true,
        CImplSoftChar    => false,
        CImplSID         => true,
        CImplVGA80x40    => true,
        CImplHWScrolling => true,
        CImplMouse       => true,
        CImplUart        => true,
        MainClockSpeed   => 16000000,
        DefaultBaud      => 115200          
     )
    port map(
        clk_vga   => clk_vga,
        clk_16M00 => clk_16M00,
        clk_32M00 => clk_32M00,
        ps2_clk   => ps2_clk,
        ps2_data  => ps2_data,
        ps2_mouse_clk   => ps2_mouse_clk,
        ps2_mouse_data  => ps2_mouse_data,
        ERSTn     => ERSTn,
        red       => red,
        green     => green,
        blue      => blue,
        vsync     => vsync,
        hsync     => hsync,
        RamCE     => RamCE,
        RomCE     => RomCE,
        ExternWE  => ExternWE,
        ExternA   => ExternA,
        ExternDin => ExternDin,
        ExternDout=> ExternDout,        
        audiol    => audiol,
        audioR    => audioR,
        SDMISO    => SDMISO,
        SDSS      => SDSS,
        SDCLK     => SDCLK,
        SDMOSI    => SDMOSI,
        uart_RxD  => RxD,
        uart_TxD  => TxD,
        LED1      => LED1,
        LED2      => LED2
       );

        LED3 <= '0';
        LED4 <= '0';

end behavioral;


