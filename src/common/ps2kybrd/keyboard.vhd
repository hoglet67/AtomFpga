library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity keyboard is
    generic (
        DefaultTurbo : std_logic_vector(1 downto 0) := "00"
    );
    port (
        CLOCK      : in  std_logic;
        nRESET     : in  std_logic;
        CLKEN_1MHZ : in  std_logic;
        PS2_CLK    : in  std_logic;
        PS2_DATA   : in  std_logic;
        KEYOUT     : out std_logic_vector(5 downto 0);
        ROW        : in  std_logic_vector(3 downto 0);
        ESC_IN     : in  std_logic;
        BREAK_IN   : in  std_logic;
        SHIFT_OUT  : out std_logic;
        CTRL_OUT   : out std_logic;
        REPEAT_OUT : out std_logic;
        BREAK_OUT  : out std_logic;
        TURBO      : out std_logic_vector(1 downto 0);
        ESC_OUT    : out std_logic;
        Joystick1  : in  std_logic_vector (7 downto 0);
        Joystick2  : in  std_logic_vector (7 downto 0)
        );
end entity;

architecture rtl of keyboard is
    component ps2_intf is
        generic (filter_length : positive := 8);
        port(
            CLK      : in  std_logic;
            nRESET   : in  std_logic;
            PS2_CLK  : in  std_logic;
            PS2_DATA : in  std_logic;
            DATA     : out std_logic_vector(7 downto 0);
            VALID    : out std_logic;
            error    : out std_logic
            );
    end component;

    signal keyb_data  : std_logic_vector(7 downto 0);
    signal keyb_valid : std_logic;
    signal keyb_error : std_logic;
    type   key_matrix is array(0 to 9) of std_logic_vector(5 downto 0);
    signal keys       : key_matrix;
    signal col        : unsigned(3 downto 0);
    signal released   : std_logic;
    signal extended   : std_logic;
    signal ESC_IN1    : std_logic;
    signal BREAK_IN1  : std_logic;

begin
    ps2 : ps2_intf port map (
        CLOCK,
        nRESET,
        PS2_CLK,
        PS2_DATA,
        keyb_data,
        keyb_valid,
        keyb_error);

    process(keys, ROW, Joystick1, Joystick2)
    variable key_data : std_logic_vector(5 downto 0);
    begin
        if (ROW > "1001") then
            key_data := (others => '1');
        else
            key_data := keys(conv_integer(ROW(3 downto 0)));
        end if;
        -- 0 U R D L F
        if (ROW = "0000") then
            KEYOUT <= key_data and ('1' & Joystick1(0) & Joystick1(3) & Joystick1(1) & Joystick1(2) & Joystick1(5));
        elsif (ROW = "0001") then
            KEYOUT <= key_data and ('1' & Joystick2(0) & Joystick2(3) & Joystick2(1) & Joystick2(2) & Joystick2(5));
        else
            KEYOUT <= key_data;
        end if;
    end process;

    process(CLOCK, nRESET, ESC_IN, BREAK_IN)
    begin
        if nRESET = '0' then
            released  <= '0';
            extended  <= '0';
            TURBO     <= DefaultTurbo;

            BREAK_OUT  <= '1';
            SHIFT_OUT  <= '1';
            CTRL_OUT   <= '1';
            REPEAT_OUT <= '1';

            ESC_IN1 <= ESC_IN;
            BREAK_IN1 <= BREAK_IN;

            keys(0) <= (others => '1');
            keys(1) <= (others => '1');
            keys(2) <= (others => '1');
            keys(3) <= (others => '1');
            keys(4) <= (others => '1');
            keys(5) <= (others => '1');
            keys(6) <= (others => '1');
            keys(7) <= (others => '1');
            keys(8) <= (others => '1');
            keys(9) <= (others => '1');

        elsif rising_edge(CLOCK) then

            -- handle the escape key seperately, as it's value also depends on ESC_IN
            if keyb_valid = '1' and keyb_data = X"76" then
                keys(0)(5) <= released;
            elsif ESC_IN /= ESC_IN1 then
                keys(0)(5) <= ESC_IN;
            end if;

            ESC_IN1 <= ESC_IN;
            -- handle the break key seperately, as it's value also depends on BREAK_IN
            if keyb_valid = '1' and keyb_data = X"09" then
                BREAK_OUT <= released;
            elsif BREAK_IN /= BREAK_IN1 then
                BREAK_OUT <= BREAK_IN;
            end if;
            BREAK_IN1 <= BREAK_IN;

            if keyb_valid = '1' then
                if keyb_data = X"e0" then
                    extended <= '1';
                elsif keyb_data = X"f0" then
                    released <= '1';
                else
                    released  <= '0';
                    extended <= '0';

                    case keyb_data is
                        when X"05" => TURBO      <= "00";     -- F1 (1MHz)
                        when X"06" => TURBO      <= "01";     -- F2 (2MMz)
                        when X"04" => TURBO      <= "10";     -- F3 (4MHz)
                        when X"0C" => TURBO      <= "11";     -- F4 (8MHz)
--                        when X"09" => BREAK_OUT  <= released;  -- F10 (BREAK)
                        when X"11" => REPEAT_OUT <= released;  -- LEFT ALT (SHIFT LOCK)
                        when X"12" | X"59" =>
                            if (extended = '0') then -- Ignore fake shifts
                                SHIFT_OUT  <= released; -- Left SHIFT -- Right SHIFT
                            end if;
                        when X"14" => CTRL_OUT   <= released;  -- LEFT/RIGHT CTRL (CTRL)
                        -----------------------------------------------------
                        -- process matrix
                        -----------------------------------------------------
                        when X"29" => keys(9)(0) <= released;  -- SPACE
                        when X"54" => keys(8)(0) <= released;  -- [
                        when X"5D" => keys(7)(0) <= released;  -- \
                        when X"5B" => keys(6)(0) <= released;  -- ]
                        when X"0D" => keys(5)(0) <= released;  -- UP
                        when X"58" => keys(4)(0) <= released;  -- CAPS LOCK
                        when X"74" => keys(3)(0) <= released;  -- RIGHT
                        when X"75" => keys(2)(0) <= released;  -- UP

                        when X"5A" => keys(6)(1) <= released;  -- RETURN
                        when X"69" => keys(5)(1) <= released;  -- END (COPY)
                        when X"66" => keys(4)(1) <= released;  -- BACKSPACE (DELETE)
                        when X"45" => keys(3)(1) <= released;  -- 0
                        when X"16" => keys(2)(1) <= released;  -- 1
                        when X"1E" => keys(1)(1) <= released;  -- 2
                        when X"26" => keys(0)(1) <= released;  -- 3

                        when X"25" => keys(9)(2) <= released;  -- 4
                        when X"2E" => keys(8)(2) <= released;  -- 5
                        when X"36" => keys(7)(2) <= released;  -- 6
                        when X"3D" => keys(6)(2) <= released;  -- 7
                        when X"3E" => keys(5)(2) <= released;  -- 8
                        when X"46" => keys(4)(2) <= released;  -- 9
                        when X"52" => keys(3)(2) <= released;  -- '   full colon substitute
                        when X"4C" => keys(2)(2) <= released;  -- ;
                        when X"41" => keys(1)(2) <= released;  -- ,
                        when X"4E" => keys(0)(2) <= released;  -- -

                        when X"49" => keys(9)(3) <= released;  -- .
                        when X"4A" => keys(8)(3) <= released;  -- /
                        when X"55" => keys(7)(3) <= released;  -- @ (TAB)
                        when X"1C" => keys(6)(3) <= released;  -- A
                        when X"32" => keys(5)(3) <= released;  -- B
                        when X"21" => keys(4)(3) <= released;  -- C
                        when X"23" => keys(3)(3) <= released;  -- D
                        when X"24" => keys(2)(3) <= released;  -- E
                        when X"2B" => keys(1)(3) <= released;  -- F
                        when X"34" => keys(0)(3) <= released;  -- G

                        when X"33" => keys(9)(4) <= released;  -- H
                        when X"43" => keys(8)(4) <= released;  -- I
                        when X"3B" => keys(7)(4) <= released;  -- J
                        when X"42" => keys(6)(4) <= released;  -- K
                        when X"4B" => keys(5)(4) <= released;  -- L
                        when X"3A" => keys(4)(4) <= released;  -- M
                        when X"31" => keys(3)(4) <= released;  -- N
                        when X"44" => keys(2)(4) <= released;  -- O
                        when X"4D" => keys(1)(4) <= released;  -- P
                        when X"15" => keys(0)(4) <= released;  -- Q

                        when X"2D" => keys(9)(5) <= released;  -- R
                        when X"1B" => keys(8)(5) <= released;  -- S
                        when X"2C" => keys(7)(5) <= released;  -- T
                        when X"3C" => keys(6)(5) <= released;  -- U
                        when X"2A" => keys(5)(5) <= released;  -- V
                        when X"1D" => keys(4)(5) <= released;  -- W
                        when X"22" => keys(3)(5) <= released;  -- X
                        when X"35" => keys(2)(5) <= released;  -- Y
                        when X"1A" => keys(1)(5) <= released;  -- Z
--                        when X"76" => keys(0)(5) <= released;  -- ESCAPE

                        when others => null;
                    end case;

                    -- Keys that are missing from the matrix (to avoid latch inferrence)
                    keys(0)(0) <= '1';
                    keys(1)(0) <= '1';
                    keys(7)(1) <= '1';
                    keys(8)(1) <= '1';
                    keys(9)(1) <= '1';

                end if;
            end if;
        end if;
    end process;

    ESC_OUT <= keys(0)(5);

end architecture;
