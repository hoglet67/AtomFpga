library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-- For f_log2 definition
use WORK.SynthCtrlPack.all;

-- For loadin
use std.textio.all;
use IEEE.std_logic_textio.all;

entity XPM is
    generic (
        WIDTH    : integer;
        SIZE     : integer;
        FILENAME : string
    );
    port(
        cp2     : in  std_logic;
        ce      : in  std_logic;
        address : in  std_logic_vector(f_log2(SIZE) - 1 downto 0);
        din     : in  std_logic_vector(WIDTH - 1 downto 0);
        dout    : out std_logic_vector(WIDTH - 1 downto 0);
        we      : in  std_logic
    );
end;

architecture RTL of XPM is

    type ram_type is array (0 to SIZE - 1) of std_logic_vector (WIDTH - 1 downto 0);

    impure function InitRamFromFile (RamFileName : in string) return ram_type is
        FILE ramfile : text is in RamFileName;
        variable RamFileLine : line;
        variable ram : ram_type;
    begin
        for i in ram_type'range loop
            readline(ramfile, RamFileLine);
            hread(RamFileLine, ram(i));
        end loop;
        return ram;
    end function;

    signal RAM : ram_type := InitRamFromFile(FILENAME);

begin

    process (cp2)
    begin
        if rising_edge(cp2) then
            if ce = '1' then
                if (we = '1') then
                    RAM(conv_integer(address)) <= din;
                end if;
                dout <= RAM(conv_integer(address));
            end if;
        end if;
    end process;

end RTL;
