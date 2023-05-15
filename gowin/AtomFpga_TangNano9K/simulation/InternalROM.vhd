library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity InternalROM is
    port (
        CLK  : in  std_logic;
        ADDR : in  std_logic_vector(13 downto 0);
        DATA : out std_logic_vector(7 downto 0)
    );
end;

architecture BEHAVIORAL of InternalROM is

    constant ram_depth : natural := 16384;
    constant ram_width : natural := 8;

    type ram_type is array (0 to ram_depth - 1) of std_logic_vector(ram_width - 1 downto 0);

    impure function init_ram_hex return ram_type is
        file text_file : text open read_mode is "InternalROM.dat";
        variable text_line : line;
        variable value : bit_vector(ram_width - 1 downto 0);
        variable ram_content : ram_type;
    begin
        for i in 0 to ram_depth - 1 loop
            readline(text_file, text_line);
            read(text_line, value);
            ram_content(i) := to_stdlogicvector(value);
        end loop;
        return ram_content;
    end function;

    signal RAM : ram_type := init_ram_hex;

begin

    process (CLK)
    begin
        if rising_edge(CLK) then
            DATA <= RAM(conv_integer(ADDR(13 downto 0)));
        end if;
    end process;

end BEHAVIORAL;
