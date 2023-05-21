library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_bench is
end test_bench;

architecture beh of test_bench is

    signal clock_27       : std_logic := '0';
    signal btn1_n         : std_logic := '0';
    signal btn2_n         : std_logic := '1';
    signal ps2_clk        : std_logic := '1';
    signal ps2_data       : std_logic := '1';
    signal ps2_mouse_clk  : std_logic := '1';
    signal ps2_mouse_data : std_logic := '1';
    signal audiol         : std_logic;
    signal audior         : std_logic;
    signal tf_miso        : std_logic := '1';
    signal tf_cs          : std_logic;
    signal tf_sclk        : std_logic;
    signal tf_mosi        : std_logic;
    signal uart_rx        : std_logic := '1';
    signal uart_tx        : std_logic;
    signal led            : std_logic_vector(5 downto 0);
    signal tmds_clk_p     : std_logic;
    signal tmds_clk_n     : std_logic;
    signal tmds_d_p       : std_logic_vector(2 downto 0);
    signal tmds_d_n       : std_logic_vector(2 downto 0);
    signal gpio           : std_logic_vector(10 downto 0);
    signal trace          : std_logic_vector(15 downto 0);

    function hex (lvec: in std_logic_vector) return string is
        variable text: string(lvec'length / 4 - 1 downto 0) := (others => '9');
        subtype halfbyte is std_logic_vector(4-1 downto 0);
    begin
        assert lvec'length mod 4 = 0
            report "hex() works only with vectors whose length is a multiple of 4"
            severity FAILURE;
        for k in text'range loop
            case halfbyte'(lvec(4 * k + 3 downto 4 * k)) is
                when "0000" => text(k) := '0';
                when "0001" => text(k) := '1';
                when "0010" => text(k) := '2';
                when "0011" => text(k) := '3';
                when "0100" => text(k) := '4';
                when "0101" => text(k) := '5';
                when "0110" => text(k) := '6';
                when "0111" => text(k) := '7';
                when "1000" => text(k) := '8';
                when "1001" => text(k) := '9';
                when "1010" => text(k) := 'A';
                when "1011" => text(k) := 'B';
                when "1100" => text(k) := 'C';
                when "1101" => text(k) := 'D';
                when "1110" => text(k) := 'E';
                when "1111" => text(k) := 'F';
                when others => text(k) := '!';
            end case;
        end loop;
        return text;
    end function;

begin

    uut : entity work.AtomFpga_TangNano9K
        generic map (
            CImplCpu65c02      => false,
            CImplDVIGowin      => false,
            CImplDVIOpenSource => true,
            CImplVGA           => false,
            CImplTrace         => true
            )
        port map (
            clock_27       => clock_27       ,
            btn1_n         => btn1_n         ,
            btn2_n         => btn2_n         ,
            ps2_clk        => ps2_clk        ,
            ps2_data       => ps2_data       ,
            ps2_mouse_clk  => ps2_mouse_clk  ,
            ps2_mouse_data => ps2_mouse_data ,
            audiol         => audiol         ,
            audior         => audior         ,
            tf_miso        => tf_miso        ,
            tf_cs          => tf_cs          ,
            tf_sclk        => tf_sclk        ,
            tf_mosi        => tf_mosi        ,
            uart_rx        => uart_rx        ,
            uart_tx        => uart_tx        ,
            led            => led            ,
            tmds_clk_p     => tmds_clk_p     ,
            tmds_clk_n     => tmds_clk_n     ,
            tmds_d_p       => tmds_d_p       ,
            tmds_d_n       => tmds_d_n       ,
            flash_so       => '0'            ,
            gpio           => gpio
            );

    process
    begin
        wait for 18.5 ns;
        clock_27 <= not clock_27;
    end process;

    process
    begin
        wait for 100 us;
        btn1_n <= '1';
    end process;

    trace <= "111111" & gpio(9 downto 0) after 1 ns;

    process(gpio)
    begin
        if falling_edge(gpio(10)) then
            report "trace: " & hex(trace);
        end if;
    end process;

end beh;
