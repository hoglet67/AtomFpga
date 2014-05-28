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

entity Atomic_top_hoglet is
    port (clk_32M00 : in  std_logic;
           ps2_clk  : in  std_logic;
           ps2_data : in  std_logic;
           ERST     : in  std_logic;
           red      : out std_logic_vector (2 downto 1);
           green    : out std_logic_vector (2 downto 1);
           blue     : out std_logic_vector (2 downto 1);
           vsync    : out std_logic;
           hsync    : out std_logic;
           audiol   : out std_logic;
           audioR   : out std_logic;
           RAMCEn   : out std_logic;
           RAMOEn   : out std_logic;
           RAMWRn   : out std_logic;
           ROMCEn   : out std_logic;
           ROMOEn   : out std_logic;
           ROMWRn   : out std_logic;
           ExternA  : out std_logic_vector (16 downto 0);
           ExternD  : inout std_logic_vector (7 downto 0);
           SDMISO   : in  std_logic;
           SDSS     : out std_logic;
           SDCLK    : out std_logic;
           SDMOSI   : out std_logic;
           RxD      : in  std_logic;
           TxD      : out std_logic
           );
end Atomic_top_hoglet;

architecture behavioral of Atomic_top_hoglet is

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
 
    component Atomic_core
        generic  (
            CImplSID      : boolean;
            CImplSDDOS    : boolean
        );
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
            RomCE     : out std_logic;
            ExternWE  : out std_logic;
            ExternA   : out std_logic_vector (16 downto 0);
            ExternDin : out std_logic_vector (7 downto 0);
            ExternDout: in  std_logic_vector (7 downto 0);
            audiol    : out std_logic;
            audioR    : out std_logic;
            SDSS      : out std_logic;
            SDCLK     : out std_logic;
            SDMOSI    : out std_logic
        );
	end component;
   
	COMPONENT AtomPL8
	PORT(
		clk : IN std_logic;
		enable : IN std_logic;
		nRST : IN std_logic;
		PHI2 : IN std_logic;
		RW : IN std_logic;
		DataIn : IN std_logic_vector(7 downto 0);
		nARD : IN std_logic;
		nAWR : IN std_logic;
		AVRA0 : IN std_logic;    
		AVRData : INOUT std_logic_vector(7 downto 0);      
		DataOut : OUT std_logic_vector(7 downto 0);
		AVRINTOut : OUT std_logic
		);
	END COMPONENT;

	component AVR8
	port(
		clk16M : IN std_logic;
		nrst : IN std_logic;
		porta : INOUT std_logic_vector(7 downto 0);
		portb : INOUT std_logic_vector(7 downto 0);
		portc : INOUT std_logic_vector(7 downto 0);
		portd : INOUT std_logic_vector(7 downto 0);
		porte : INOUT std_logic_vector(7 downto 0);
		portf : INOUT std_logic_vector(7 downto 0);      
		rxd : IN std_logic;    
		txd : OUT std_logic
		);
	end component;

    signal clk_12M58 : std_logic;
    signal clk_16M00 : std_logic;

    signal ERSTn     : std_logic;

    signal RamCE     : std_logic;
    signal RomCE     : std_logic;
    signal ExternWE  : std_logic;
    signal ExternDin : std_logic_vector (7 downto 0);
    signal ExternDout: std_logic_vector (7 downto 0);
    
    signal nARD     : std_logic;
    signal nAWR     : std_logic;
    signal AVRA0    : std_logic;
    signal AVRInt   : std_logic;
    signal AVRIntTS : std_logic;
    signal AVRData  : std_logic_vector (7 downto 0);

    signal intSDMISO   : std_logic;
    signal intSDSS     : std_logic;
    signal intSDCLK    : std_logic;
    signal intSDMOSI   : std_logic;

    signal Addr  : std_logic_vector (16 downto 0);
    signal PL8Data  : std_logic_vector (7 downto 0);
    signal PL8Enable: std_logic;

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
    
    ERSTn <= not ERST;

    inst_Atomic_core : Atomic_core
    generic map (
        CImplSID => true,
        CImplSDDOS => false
    )
    port map(
        clk_12M58 => clk_12M58,
        clk_16M00 => clk_16M00,
        clk_32M00 => clk_32M00,
        ps2_clk   => ps2_clk,
        ps2_data  => ps2_data,
        ERSTn     => ERSTn,
        red(2 downto 1)   => red(2 downto 1),
        red(0)    => open,
        green(2 downto 1) => green(2 downto 1),
        green(0)  => open,
        blue(2 downto 1)  => blue(2 downto 1),
        blue(0)   => open,
        vsync     => vsync,
        hsync     => hsync,
        RamCE     => RamCE,
        RomCE     => RomCE,
        ExternWE  => ExternWE,
        ExternA   => Addr,
        ExternDin => ExternDin,
        ExternDout=> ExternDout,        
        audiol    => audiol,
        audioR    => audioR,
        SDMISO    => '0',
        SDSS      => open,
        SDCLK     => open,
        SDMOSI    => open
        );  

	Inst_AVR8: AVR8 PORT MAP(
		clk16M => clk_16M00,
		nrst => ERSTn,
   		porta      => AVRData,
		portb(0)   => nARD,
		portb(1)   => nAWR,
		portb(2)   => AVRInt,
		portb(3)   => AVRA0,
        portb(4)   => intSDMISO,
        portb(5)   => intSDSS,
        portb(6)   => intSDCLK,
        portb(7)   => intSDMOSI,
		rxd => RxD,
		txd => TxD 
	);
    
    Inst_AtomPL8: AtomPL8 port map(
		clk => clk_16M00,
		enable => PL8Enable,
		nRST => ERSTn,
		PHI2 => '1',
		RW => ExternWE,
		DataIn => ExternDin,
		DataOut => PL8Data,
		AVRData => AVRDATA,
		nARD => nARD,
		nAWR => nAWR,
		AVRA0 => AVRA0,
		AVRINTOut => AVRIntTS
	);   
   
    AVRIntTS <= '0' when AVRInt = '0' else 'Z';
   
    intSDMISO <= '0' when SDMISO = '0' else 'Z';
    SDSS      <= intSDSS;
    SDCLK     <= intSDCLK;
    SDMOSI    <= intSDMOSI;
        
    RAMCEn     <= not RamCE;
    RAMWRn     <= not ExternWE;
    RAMOEn     <= not RamCE;

    ROMCEn     <= not RomCE;
    ROMWRn     <= not ExternWE;
    ROMOEn     <= not RomCE;

    ExternD    <= ExternDin when ExternWE = '1' else "ZZZZZZZZ";
    
    PL8Enable  <= '1' when Addr(15 downto 7) = "10110100" else '0';
    
    ExternDout <= PL8Data when PL8Enable = '1' else ExternD;
    
    ExternA    <= Addr;
    
end behavioral;


