library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity VideoRam is

    port (
        clka  : in  std_logic;
        wea   : in  std_logic;
        addra : in  std_logic_vector(12 downto 0);
        dina  : in  std_logic_vector(7 downto 0);
        douta : out std_logic_vector(7 downto 0);
        clkb  : in  std_logic;
        web   : in  std_logic;
        addrb : in  std_logic_vector(12 downto 0);
        dinb  : in  std_logic_vector(7 downto 0);
        doutb : out std_logic_vector(7 downto 0)
        );
end VideoRam;

architecture BEHAVIORAL of VideoRam is

begin

 ram: entity work.dpram_8k
    port map (
        clka => clka,
        cea => '1',
        ocea => '1',
        reseta => '0',
        wrea => wea,
        ada => addra,
        dina => dina,
        douta => douta,
        clkb => clkb,
        ceb => '1',
        oceb => '1',
        resetb => '0',
        wreb => web,
        adb => addrb,
        dinb => dinb,
        doutb => doutb
        );
 end BEHAVIORAL;
