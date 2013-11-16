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
           SDMOSI   : out std_logic);
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
 
    component Atomic_core
        port (
            clk_12M58 : in  std_logic;
            clk_16M00 : in  std_logic;
            clk_32M00 : in  std_logic;
            ps2_clk   : in  std_logic;
            ps2_data  : in  std_logic;
            ERSTn     : in  std_logic;
            SDMISO    : in  std_logic;    
            red       : out std_logic_vector(2 downto 0);
            green     : out std_logic_vector(2 downto 0);
            blue      : out std_logic_vector(2 downto 0);
            vsync     : out std_logic;
            hsync     : out std_logic;
            RamCE     : out std_logic;
            RamWE     : out std_logic;
            RamA      : out std_logic_vector (14 downto 0);
            RamDin    : out std_logic_vector (7 downto 0);
            RamDout   : in  std_logic_vector (7 downto 0);
            audiol    : out std_logic;
            audioR    : out std_logic;
            SDSS      : out std_logic;
            SDCLK     : out std_logic;
            SDMOSI    : out std_logic
        );
	end component;
   
    signal clk_12M58 : std_logic;
    signal clk_16M00 : std_logic;

    signal ERSTn     : std_logic;

    signal RamCE     : std_logic;
    signal RamCE1    : std_logic;
    signal RamCE2    : std_logic;
    signal RamWE     : std_logic;
    signal RamA      : std_logic_vector (14 downto 0);
    signal RamDin    : std_logic_vector (7 downto 0);
    signal RamDout   : std_logic_vector (7 downto 0);
    signal RamDout1  : std_logic_vector (7 downto 0);
    signal RamDout2  : std_logic_vector (7 downto 0);

    
begin

    inst_dcm4 : dcm4 port map(
        CLKIN_IN  => clk_32M00,
        CLK0_OUT  => clk_12M58,
        CLK0_OUT1 => open,
        CLK2X_OUT => open);

    inst_dcm5 : dcm5 port map(
        CLKIN_IN  => clk_32M00,
        CLK0_OUT  => clk_16M00,
        CLK0_OUT1 => open,
        CLK2X_OUT => open);

    ram_0000_07ff : RAM_2K port map(
        clk     => clk_16M00,
        we_uP   => RamWE,
        ce      => RAMCE1,
        addr_uP => RamA (10 downto 0),
        D_uP    => RamDin,
        Q_uP    => RamDout1
        );

    ram_2000_3fff : RAM_8K port map(
        clk     => clk_16M00,
        we_uP   => RamWE,
        ce      => RAMCE2,
        addr_uP => RamA (12 downto 0),
        D_uP    => RamDin,
        Q_uP    => RamDout2
        );

    RAMCE1 <= '1' when RAMCE = '1' and RamA(14 downto 11) = "0000" else '0';

    RAMCE2 <= '1' when RAMCE = '1' and RamA(14 downto 13) = "01" else '0';
    
    RamDout(7 downto 0) <= RamDout1 when RAMWE = '0' and RAMCE1 = '1' else
                           RamDout2 when RAMWE = '0' and RAMCE2 = '1' else
                           "11110001";                
    ERSTn <= not ERST;

    inst_Atomic_core : Atomic_core port map(
        clk_12M58 => clk_12M58,
        clk_16M00 => clk_16M00,
        clk_32M00 => clk_32M00,
        ps2_clk   => ps2_clk,
        ps2_data  => ps2_data,
        ERSTn     => ERSTn,
        red       => red,
        green     => green,
        blue      => blue,
        vsync     => vsync,
        hsync     => hsync,
        RamCE     => RamCE,
        RamWE     => RamWE,
        RamA      => RamA,
        RamDin    => RamDin,
        RamDout   => RamDout,        
        audiol    => audiol,
        audioR    => audioR,
        SDMISO    => SDMISO,
        SDSS      => SDSS,
        SDCLK     => SDCLK,
        SDMOSI    => SDMOSI
        );  

end behavioral;


