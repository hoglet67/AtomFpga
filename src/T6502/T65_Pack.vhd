library IEEE;
use IEEE.std_logic_1164.all;

package T65_Pack is

	constant Flag_C : integer := 0;
	constant Flag_Z : integer := 1;
	constant Flag_I : integer := 2;
	constant Flag_D : integer := 3;
	constant Flag_B : integer := 4;
	constant Flag_1 : integer := 5;
	constant Flag_V : integer := 6;
	constant Flag_N : integer := 7;

	component T65_MCode
	port(
		IR                      : in  std_logic_vector(7 downto 0);
		MCycle                  : in  std_logic_vector(2 downto 0);
		P                       : in  std_logic_vector(7 downto 0);
		LCycle                  : out std_logic_vector(2 downto 0);
		ALU_Op                  : out std_logic_vector(3 downto 0);
		Set_BusA_To             : out std_logic_vector(2 downto 0); -- DI,A,X,Y,S,P
		Set_Addr_To             : out std_logic_vector(1 downto 0); -- PC Adder,S,AD,BA
		Write_Data              : out std_logic_vector(2 downto 0); -- DL,A,X,Y,S,P,PCL,PCH
		Jump                    : out std_logic_vector(1 downto 0); -- PC,++,DIDL,Rel
		BAAdd                   : out std_logic_vector(1 downto 0);     -- None,DB Inc,BA Add,BA Adj
		BreakAtNA               : out std_logic;
		ADAdd                   : out std_logic;
		AddY                    : out std_logic;
		PCAdd                   : out std_logic;
		Inc_S                   : out std_logic;
		Dec_S                   : out std_logic;
		LDA                     : out std_logic;
		LDP                     : out std_logic;
		LDX                     : out std_logic;
		LDY                     : out std_logic;
		LDS                     : out std_logic;
		LDDI                    : out std_logic;
		LDALU                   : out std_logic;
		LDAD                    : out std_logic;
		LDBAL                   : out std_logic;
		LDBAH                   : out std_logic;
		SaveP                   : out std_logic;
		Write                   : out std_logic
	);
	end component;

	component T65_ALU
	port(
		Op      : in  std_logic_vector(3 downto 0);
		BusA    : in  std_logic_vector(7 downto 0);
		BusB    : in  std_logic_vector(7 downto 0);
		P_In    : in  std_logic_vector(7 downto 0);
		P_Out   : out std_logic_vector(7 downto 0);
		Q       : out std_logic_vector(7 downto 0)
	);
	end component;

end;
