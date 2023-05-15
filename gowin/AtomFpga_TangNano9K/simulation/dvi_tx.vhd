library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DVI_TX_Top is
    port(
        I_rst_n :  in std_logic;
        I_serial_clk :  in std_logic;
        I_rgb_clk :  in std_logic;
        I_rgb_vs :  in std_logic;
        I_rgb_hs :  in std_logic;
        I_rgb_de :  in std_logic;
        I_rgb_r :  in std_logic_vector(7 downto 0);
        I_rgb_g :  in std_logic_vector(7 downto 0);
        I_rgb_b :  in std_logic_vector(7 downto 0);
        O_tmds_clk_p :  out std_logic;
        O_tmds_clk_n :  out std_logic;
        O_tmds_data_p :  out std_logic_vector(2 downto 0);
        O_tmds_data_n :  out std_logic_vector(2 downto 0));
end DVI_TX_Top;
architecture beh of DVI_TX_Top is
begin
        O_tmds_clk_p <= '0';
        O_tmds_clk_n <= '0';
        O_tmds_data_p <= "000";
        O_tmds_data_n <= "000";

end beh;
