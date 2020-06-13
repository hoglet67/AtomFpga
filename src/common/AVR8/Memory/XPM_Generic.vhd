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

    -- If the ROM is not a power of 2, the ISE does a poor job of optimization
    -- e.g. a 10Kx16 rom takes up the space of a 16Kx16
    --
    -- To avoid this, we break the RAM into two parts

    function is_power_of_2 return boolean is
    begin
        return 2**f_log2(SIZE) = SIZE;
    end function;

    function ram1_size return integer is
    begin
        if is_power_of_2 then
            return SIZE;
        else
            return 2**(f_log2(SIZE) - 1);
        end if;
    end function;

    function ram2_size return integer is
    begin
        return SIZE - ram1_size;
    end function;

    type ram1_type is array (0 to ram1_size - 1) of std_logic_vector (WIDTH - 1 downto 0);

    type ram2_type is array (0 to ram2_size - 1) of std_logic_vector (WIDTH - 1 downto 0);

    impure function InitRam1FromFile (RamFileName : in string) return ram1_type is
        FILE ramfile : text is in RamFileName;
        variable RamFileLine : line;
        variable ram : ram1_type;
    begin
        for i in ram1_type'range loop
            readline(ramfile, RamFileLine);
            hread(RamFileLine, ram(i));
        end loop;
        return ram;
    end function;

    impure function InitRam2FromFile (RamFileName : in string) return ram2_type is
        FILE ramfile : text is in RamFileName;
        variable RamFileLine : line;
        variable ram : ram2_type;
    begin
        for i in ram1_type'range loop
            readline(ramfile, RamFileLine);
        end loop;
        for i in ram2_type'range loop
            readline(ramfile, RamFileLine);
            hread(RamFileLine, ram(i));
        end loop;
        return ram;
    end function;

    signal RAM1 : ram1_type := InitRam1FromFile(FILENAME);
    signal RAM2 : ram2_type := InitRam2FromFile(FILENAME);

    signal dout1 : std_logic_vector(WIDTH - 1 downto 0);
    signal dout2 : std_logic_vector(WIDTH - 1 downto 0);

begin

    process (cp2)
    begin
        if rising_edge(cp2) then
            if ce = '1' then
                if is_power_of_2 then
                    dout1 <= RAM1(conv_integer(address));
                    dout2 <= (others => '0');
                else
                    dout1 <= RAM1(conv_integer(address(f_log2(ram1_size) - 1 downto 0)));
                    dout2 <= RAM2(conv_integer(address(f_log2(ram2_size) - 1 downto 0)));
                end if;

            end if;
        end if;
    end process;

    dout <= dout1 when is_power_of_2 or address(f_log2(SIZE) - 1) = '0' else dout2;

end RTL;
