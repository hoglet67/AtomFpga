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
        douta => douta,
        doutb => doutb,
        clka => clka,
        ocea => '0',
        cea => '0',
        reseta => '0',
        wrea => wea,
        clkb => clkb,
        oceb => '0',
        ceb => '0',
        resetb => '0',
        wreb => web,
        ada => addra,
        dina => dina,
        adb => addrb,
        dinb => dinb
        );
 end BEHAVIORAL;
