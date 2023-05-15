library IEEE;
use IEEE.std_logic_1164.all;

entity AVR8 is
generic (
     CDATAMEMSIZE : integer;
     CPROGMEMSIZE : integer;
     FILENAME     : string;
-- Use these setting to control which peripherals you want to include with your custom AVR8 implementation.
     CImplPORTA   : boolean := FALSE;
     CImplPORTB   : boolean := FALSE;
     CImplPORTC   : boolean := FALSE;
     CImplPORTD   : boolean := FALSE;
     CImplPORTE   : boolean := FALSE;
     CImplPORTF   : boolean := FALSE;
     CImplUART    : boolean := FALSE;
     CImplSPI     : boolean := FALSE;
     CImplTmrCnt  : boolean := FALSE;
     CImplExtIRQ  : boolean := FALSE
);
port (
	 nrst   : in    std_logic;						--Uncomment this to connect reset to an external pushbutton. Must be defined in ucf.
	 clk16M : in    std_logic;
	 portaout  : out std_logic_vector(7 downto 0);
	 portain  : in std_logic_vector(7 downto 0);
	 portbout  : out std_logic_vector(7 downto 0);
	 portbin  : in std_logic_vector(7 downto 0);
	 portc  : inout std_logic_vector(7 downto 0);
	 portdin  : in std_logic_vector(7 downto 0);
	 portdout  : out std_logic_vector(7 downto 0);
	 portein  : in std_logic_vector(7 downto 0);
	 porteout  : out std_logic_vector(7 downto 0);
	 portf  : inout std_logic_vector(7 downto 0);

	 spi_mosio : out std_logic;
	 spi_scko : out std_logic;
	 spi_cs_n : out std_logic;
	 spi_misoi : in std_logic;

	-- UART
	rxd    : in    std_logic;
	txd    : out   std_logic

	);

end AVR8;

architecture Struct of AVR8 is

begin

    portaout <= (others => '0');
    portbout <= (others => '0');
    portc    <= (others => '0');
    portdout <= (others => '0');
    porteout <= (others => '0');
    portf    <= (others => '0');

    spi_mosio <= '0';
    spi_scko <= '0';
    spi_cs_n <= '0';
	txd    <= '0';

end Struct;
