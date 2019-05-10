library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity debounce is
    generic (
        counter_size  :  integer := 18 -- approx 16ms @ 16MHz
    );
    port (
        clock    : in  std_logic;
        button   : in  std_logic; -- button input
        result   : out std_logic; -- debounced button input
        pressed  : out std_logic; -- active got one cycle when button pressed
        released : out std_logic  -- active got one cycle when button released
    );
end debounce;

architecture behavioural of debounce is
    signal button_in  : std_logic; -- synchronised to clock, but not debounced
    signal button_out : std_logic; -- fully debounced
    signal counter    : std_logic_vector(counter_size downto 0) := (others => '0');
begin
    process(clock)
    begin
        if rising_edge(clock) then
            button_in  <= button;
            pressed    <= '0';
            released   <= '0';
            if button_in = button_out then
                -- input same as output, reset the counter
                counter <= (others => '0');
            else
                -- input is different to output, start counting
                counter <= counter + 1;
                -- difference lasts for N-1 cycles, update the output
                if counter(counter_size) = '1'  then
                    button_out <= button_in;
                    if button_in = '1' then
                        pressed <= '1';
                    else
                        released <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;
    result <= button_out;
end behavioural;
