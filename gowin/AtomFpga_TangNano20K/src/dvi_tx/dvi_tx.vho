--
--Written by GowinSynthesis
--Product Version "V1.9.9 Beta"
--Thu May 11 17:52:08 2023

--Source file index table:
--file0 "\/disk1/home/dmb/gowin/v1.9.9beta/IDE/ipcore/DVI_TX/data/dvi_tx_top.v"
--file1 "\/disk1/home/dmb/gowin/v1.9.9beta/IDE/ipcore/DVI_TX/data/rgb2dvi.vp"
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library gw1n;
use gw1n.components.all;

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
  signal rgb2dvi_inst_sdataout_r : std_logic ;
  signal rgb2dvi_inst_sdataout_g : std_logic ;
  signal rgb2dvi_inst_sdataout_b : std_logic ;
  signal rgb2dvi_inst_sdataout_clk : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_de_d : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_c1_d : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_c1_d : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_c0_d : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n135 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n135_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n134 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n134_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n133 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n133_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n132 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n132_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n536 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n536_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n535 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n535_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n534 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n534_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n533 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n533_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n536_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n536_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n535_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n535_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n534_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n534_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n135 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n135_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n134 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n134_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n133 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n133_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n132 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n132_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n536 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n536_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n535 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n535_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n534 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n534_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n533 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n533_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n536_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n536_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n535_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n535_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n534_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n534_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n135 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n135_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n134 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n134_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n133 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n133_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n132 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n132_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n536 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n536_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n535 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n535_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n534 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n534_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n533 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n533_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n536_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n536_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n535_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n535_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n534_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n534_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n533_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n533_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n366 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n366_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n365 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n365_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n364 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n364_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n366 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n366_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n365 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n365_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n364 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n364_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n366 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n366_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n365 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n365_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n364 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n364_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n239 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n239_14 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n238 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n238_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n237 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n237_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n236 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n236_10 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n367 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n367_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n367_16 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n367_15 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n366_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n366_11 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n365_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n365_11 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n239 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n239_14 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n238 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n238_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n237 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n237_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n236 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n236_10 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n367 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n367_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n367_16 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n367_15 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n366_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n366_11 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n365_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n365_11 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n364_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n364_11 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n239 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n239_14 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n238 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n238_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n237 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n237_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n236 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n236_10 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n367 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n367_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n367_16 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n367_15 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n366_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n366_11 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n365_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n365_11 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n274 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n571 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n274 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n571 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n274 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n571 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n654 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n654 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n654 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n114 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n605 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n656 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n657 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n658 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n659 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n660 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n661 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n662 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n663 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n664 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n114 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n605 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n628 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n656 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n657 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n658 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n659 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n660 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n661 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n662 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n663 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n664 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n114 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n605 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n655 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n656 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n657 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n658 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n659 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n660 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n661 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n662 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n663 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n664 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_0 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n402 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n401 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n400 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_0 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n402 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n401 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n400 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_0 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n402 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n401 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n400 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n580 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n579 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n578 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n580 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n579 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n578 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n580 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n579 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n578 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n655 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n114_5 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n114_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n114_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n605_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n605_5 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n605_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n605_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n628 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n628_5 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n657_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n657_5 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n658_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n661_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n663_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n114_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n114_5 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n114_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n605_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n605_5 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n628_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n657_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n657_5 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n658_5 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n658_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n663_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n114_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n114_5 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n114_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n605_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n605_5 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n628 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n655_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n657_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n657_5 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n658_5 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n659_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n661_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n663_4 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_0_19 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_22 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_23 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_24 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_3 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_24 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_25 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_22 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_23 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_2 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n580_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n580_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n579_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n579_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n578_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n578_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n580_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n580_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n579_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n579_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n578_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n578_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n580_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n580_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n579_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n579_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n578_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n578_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n114_9 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n114_10 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n114_11 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n114_12 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n605_8 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n658_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n660_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n114_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n114_8 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n114_9 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n114_10 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n605_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n658_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n658_8 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n660_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n114_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n114_8 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n114_9 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n114_10 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n660_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_25 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_26 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_27 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_28 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_29 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_30 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_24 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_25 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_26 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_2_24 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_2_25 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n579_8 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n578_9 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n579_8 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n578_9 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n579_8 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n578_10 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n114_13 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n114_11 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n114_11 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_31 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_27 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n662_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n660_8 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n114_15 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n660_8 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1_25 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n661_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n660_8 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n662_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1_29 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n659_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n662_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n659_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n658_9 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n655 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n628_7 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n628_6 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n581 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n581 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n581 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n622 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n645 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n622 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n645 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n622 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n645 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n578_15 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n578_11 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n578_14 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n578_11 : std_logic ;
  signal rgb2dvi_inst_n36 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_b_n403 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_g_n403 : std_logic ;
  signal rgb2dvi_inst_TMDS8b10b_inst_r_n403 : std_logic ;
  signal GND_0 : std_logic ;
  signal VCC_0 : std_logic ;
  signal \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\ : std_logic_vector(7 downto 0);
  signal \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\ : std_logic_vector(4 downto 1);
  signal \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\ : std_logic_vector(9 downto 0);
  signal \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\ : std_logic_vector(7 downto 0);
  signal \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\ : std_logic_vector(4 downto 1);
  signal \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\ : std_logic_vector(9 downto 0);
  signal \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\ : std_logic_vector(7 downto 0);
  signal \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\ : std_logic_vector(4 downto 1);
  signal \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\ : std_logic_vector(9 downto 0);
  signal \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\ : std_logic_vector(3 downto 1);
  signal \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\ : std_logic_vector(3 downto 1);
  signal \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\ : std_logic_vector(3 downto 1);
begin
\rgb2dvi_inst/u_LVDS_r\: ELVDS_OBUF
port map (
  O => O_tmds_data_p(2),
  OB => O_tmds_data_n(2),
  I => rgb2dvi_inst_sdataout_r);
\rgb2dvi_inst/u_LVDS_g\: ELVDS_OBUF
port map (
  O => O_tmds_data_p(1),
  OB => O_tmds_data_n(1),
  I => rgb2dvi_inst_sdataout_g);
\rgb2dvi_inst/u_LVDS_b\: ELVDS_OBUF
port map (
  O => O_tmds_data_p(0),
  OB => O_tmds_data_n(0),
  I => rgb2dvi_inst_sdataout_b);
\rgb2dvi_inst/u_LVDS_clk\: ELVDS_OBUF
port map (
  O => O_tmds_clk_p,
  OB => O_tmds_clk_n,
  I => rgb2dvi_inst_sdataout_clk);
\rgb2dvi_inst/u_OSER10_r\: OSER10
generic map (
  GSREN => "false",
  LSREN => "true"
)
port map (
  Q => rgb2dvi_inst_sdataout_r,
  D0 => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(0),
  D1 => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(1),
  D2 => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(2),
  D3 => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(3),
  D4 => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(4),
  D5 => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(5),
  D6 => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(6),
  D7 => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(7),
  D8 => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(8),
  D9 => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(9),
  PCLK => I_rgb_clk,
  FCLK => I_serial_clk,
  RESET => rgb2dvi_inst_n36);
\rgb2dvi_inst/u_OSER10_g\: OSER10
generic map (
  GSREN => "false",
  LSREN => "true"
)
port map (
  Q => rgb2dvi_inst_sdataout_g,
  D0 => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(0),
  D1 => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(1),
  D2 => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(2),
  D3 => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(3),
  D4 => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(4),
  D5 => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(5),
  D6 => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(6),
  D7 => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(7),
  D8 => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(8),
  D9 => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(9),
  PCLK => I_rgb_clk,
  FCLK => I_serial_clk,
  RESET => rgb2dvi_inst_n36);
\rgb2dvi_inst/u_OSER10_b\: OSER10
generic map (
  GSREN => "false",
  LSREN => "true"
)
port map (
  Q => rgb2dvi_inst_sdataout_b,
  D0 => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(0),
  D1 => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(1),
  D2 => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(2),
  D3 => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(3),
  D4 => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(4),
  D5 => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(5),
  D6 => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(6),
  D7 => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(7),
  D8 => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(8),
  D9 => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(9),
  PCLK => I_rgb_clk,
  FCLK => I_serial_clk,
  RESET => rgb2dvi_inst_n36);
\rgb2dvi_inst/u_OSER10_clk\: OSER10
generic map (
  GSREN => "false",
  LSREN => "true"
)
port map (
  Q => rgb2dvi_inst_sdataout_clk,
  D0 => GND_0,
  D1 => GND_0,
  D2 => GND_0,
  D3 => GND_0,
  D4 => GND_0,
  D5 => VCC_0,
  D6 => VCC_0,
  D7 => VCC_0,
  D8 => VCC_0,
  D9 => VCC_0,
  PCLK => I_rgb_clk,
  FCLK => I_serial_clk,
  RESET => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/din_d_6_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(6),
  D => I_rgb_r(6),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/din_d_5_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(5),
  D => I_rgb_r(5),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/din_d_4_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(4),
  D => I_rgb_r(4),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/din_d_3_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(3),
  D => I_rgb_r(3),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/din_d_2_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(2),
  D => I_rgb_r(2),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/din_d_1_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(1),
  D => I_rgb_r(1),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/din_d_0_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(0),
  D => I_rgb_r(0),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/de_d_s0\: DFFC
port map (
  Q => rgb2dvi_inst_TMDS8b10b_inst_r_de_d,
  D => I_rgb_de,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/c1_d_s0\: DFFP
port map (
  Q => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  D => GND_0,
  CLK => I_rgb_clk,
  PRESET => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/sel_xnor_s0\: DFFC
port map (
  Q => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor,
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n114,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_4_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(4),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n578,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_3_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(3),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n579,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_2_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(2),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n580,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_1_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(1),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n581,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/dout_9_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(9),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n655,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/dout_8_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(8),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n656,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/dout_7_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(7),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n657,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/dout_6_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(6),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n658,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/dout_5_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(5),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n659,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/dout_4_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(4),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n660,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/dout_3_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(3),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n661,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/dout_2_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(2),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n662,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/dout_1_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(1),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n663,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/dout_0_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/q_out_r\(0),
  D => rgb2dvi_inst_TMDS8b10b_inst_r_n664,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/din_d_7_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(7),
  D => I_rgb_r(7),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/din_d_6_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(6),
  D => I_rgb_g(6),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/din_d_5_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(5),
  D => I_rgb_g(5),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/din_d_4_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(4),
  D => I_rgb_g(4),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/din_d_3_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(3),
  D => I_rgb_g(3),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/din_d_2_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(2),
  D => I_rgb_g(2),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/din_d_1_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(1),
  D => I_rgb_g(1),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/din_d_0_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(0),
  D => I_rgb_g(0),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/sel_xnor_s0\: DFFC
port map (
  Q => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor,
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n114,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_4_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(4),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n578,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_3_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(3),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n579,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_2_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(2),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n580,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_1_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(1),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n581,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/dout_9_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(9),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n655,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/dout_8_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(8),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n656,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/dout_7_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(7),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n657,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/dout_6_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(6),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n658,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/dout_5_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(5),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n659,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/dout_4_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(4),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n660,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/dout_3_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(3),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n661,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/dout_2_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(2),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n662,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/dout_1_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(1),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n663,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/dout_0_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/q_out_g\(0),
  D => rgb2dvi_inst_TMDS8b10b_inst_g_n664,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_g/din_d_7_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(7),
  D => I_rgb_g(7),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/din_d_6_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(6),
  D => I_rgb_b(6),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/din_d_5_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(5),
  D => I_rgb_b(5),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/din_d_4_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(4),
  D => I_rgb_b(4),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/din_d_3_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(3),
  D => I_rgb_b(3),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/din_d_2_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(2),
  D => I_rgb_b(2),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/din_d_1_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(1),
  D => I_rgb_b(1),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/din_d_0_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(0),
  D => I_rgb_b(0),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/c1_d_s0\: DFFP
port map (
  Q => rgb2dvi_inst_TMDS8b10b_inst_b_c1_d,
  D => I_rgb_vs,
  CLK => I_rgb_clk,
  PRESET => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/sel_xnor_s0\: DFFC
port map (
  Q => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor,
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n114,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_4_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(4),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n578,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_3_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(3),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n579,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_2_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(2),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n580,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_1_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(1),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n581,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/dout_9_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(9),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n655,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/dout_8_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(8),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n656,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/dout_7_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(7),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n657,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/dout_6_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(6),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n658,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/dout_5_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(5),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n659,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/dout_4_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(4),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n660,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/dout_3_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(3),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n661,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/dout_2_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(2),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n662,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/dout_1_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(1),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n663,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/dout_0_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/q_out_b\(0),
  D => rgb2dvi_inst_TMDS8b10b_inst_b_n664,
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/din_d_7_s0\: DFFC
port map (
  Q => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(7),
  D => I_rgb_b(7),
  CLK => I_rgb_clk,
  CLEAR => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_b/c0_d_s0\: DFFP
port map (
  Q => rgb2dvi_inst_TMDS8b10b_inst_b_c0_d,
  D => I_rgb_hs,
  CLK => I_rgb_clk,
  PRESET => rgb2dvi_inst_n36);
\rgb2dvi_inst/TMDS8b10b_inst_r/n135_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n135,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n135_3,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_0,
  I3 => GND_0,
  CIN => GND_0);
\rgb2dvi_inst/TMDS8b10b_inst_r/n134_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n134,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n134_3,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(2),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(1),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n135_3);
\rgb2dvi_inst/TMDS8b10b_inst_r/n133_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n133,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n133_3,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(3),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(2),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n134_3);
\rgb2dvi_inst/TMDS8b10b_inst_r/n132_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n132,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n132_3,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(4),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(3),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n133_3);
\rgb2dvi_inst/TMDS8b10b_inst_r/n536_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n536,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n536_3,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n403,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor,
  I3 => GND_0,
  CIN => GND_0);
\rgb2dvi_inst/TMDS8b10b_inst_r/n535_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n535,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n535_3,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n402,
  I1 => VCC_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n536_3);
\rgb2dvi_inst/TMDS8b10b_inst_r/n534_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n534,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n534_3,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n401,
  I1 => VCC_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n535_3);
\rgb2dvi_inst/TMDS8b10b_inst_r/n533_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n533,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n533_3,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n400,
  I1 => VCC_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n534_3);
\rgb2dvi_inst/TMDS8b10b_inst_r/n536_s1\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n536_6,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n536_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n536,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_0,
  I3 => GND_0,
  CIN => VCC_0);
\rgb2dvi_inst/TMDS8b10b_inst_r/n535_s1\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n535_6,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n535_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n535,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(1),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n536_7);
\rgb2dvi_inst/TMDS8b10b_inst_r/n534_s1\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n534_6,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n534_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n534,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(2),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n535_7);
\rgb2dvi_inst/TMDS8b10b_inst_g/n135_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n135,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n135_3,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_0,
  I3 => GND_0,
  CIN => GND_0);
\rgb2dvi_inst/TMDS8b10b_inst_g/n134_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n134,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n134_3,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(2),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(1),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n135_3);
\rgb2dvi_inst/TMDS8b10b_inst_g/n133_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n133,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n133_3,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(3),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(2),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n134_3);
\rgb2dvi_inst/TMDS8b10b_inst_g/n132_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n132,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n132_3,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(4),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(3),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n133_3);
\rgb2dvi_inst/TMDS8b10b_inst_g/n536_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n536,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n536_3,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n403,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor,
  I3 => GND_0,
  CIN => GND_0);
\rgb2dvi_inst/TMDS8b10b_inst_g/n535_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n535,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n535_3,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n402,
  I1 => VCC_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n536_3);
\rgb2dvi_inst/TMDS8b10b_inst_g/n534_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n534,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n534_3,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n401,
  I1 => VCC_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n535_3);
\rgb2dvi_inst/TMDS8b10b_inst_g/n533_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n533,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n533_3,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n400,
  I1 => VCC_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n534_3);
\rgb2dvi_inst/TMDS8b10b_inst_g/n536_s1\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n536_6,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n536_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n536,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_0,
  I3 => GND_0,
  CIN => VCC_0);
\rgb2dvi_inst/TMDS8b10b_inst_g/n535_s1\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n535_6,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n535_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n535,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(1),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n536_7);
\rgb2dvi_inst/TMDS8b10b_inst_g/n534_s1\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n534_6,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n534_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n534,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(2),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n535_7);
\rgb2dvi_inst/TMDS8b10b_inst_b/n135_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n135,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n135_3,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_0,
  I3 => GND_0,
  CIN => GND_0);
\rgb2dvi_inst/TMDS8b10b_inst_b/n134_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n134,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n134_3,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(2),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(1),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n135_3);
\rgb2dvi_inst/TMDS8b10b_inst_b/n133_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n133,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n133_3,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(3),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(2),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n134_3);
\rgb2dvi_inst/TMDS8b10b_inst_b/n132_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n132,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n132_3,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(4),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(3),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n133_3);
\rgb2dvi_inst/TMDS8b10b_inst_b/n536_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n536,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n536_3,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n403,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor,
  I3 => GND_0,
  CIN => GND_0);
\rgb2dvi_inst/TMDS8b10b_inst_b/n535_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n535,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n535_3,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n402,
  I1 => VCC_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n536_3);
\rgb2dvi_inst/TMDS8b10b_inst_b/n534_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n534,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n534_3,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n401,
  I1 => VCC_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n535_3);
\rgb2dvi_inst/TMDS8b10b_inst_b/n533_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n533,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n533_3,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n400,
  I1 => VCC_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n534_3);
\rgb2dvi_inst/TMDS8b10b_inst_b/n536_s1\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n536_6,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n536_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n536,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_0,
  I3 => GND_0,
  CIN => VCC_0);
\rgb2dvi_inst/TMDS8b10b_inst_b/n535_s1\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n535_6,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n535_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n535,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(1),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n536_7);
\rgb2dvi_inst/TMDS8b10b_inst_b/n534_s1\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n534_6,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n534_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n534,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(2),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n535_7);
\rgb2dvi_inst/TMDS8b10b_inst_b/n533_s1\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n533_6,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n533_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n533,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(3),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n534_7);
\rgb2dvi_inst/TMDS8b10b_inst_r/n366_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n366,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n366_4,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(2),
  I1 => GND_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n367_12);
\rgb2dvi_inst/TMDS8b10b_inst_r/n365_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n365,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n365_4,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(3),
  I1 => GND_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n366_4);
\rgb2dvi_inst/TMDS8b10b_inst_r/n364_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n364,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n364_4,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(4),
  I1 => GND_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n365_4);
\rgb2dvi_inst/TMDS8b10b_inst_g/n366_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n366,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n366_4,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(2),
  I1 => GND_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n367_12);
\rgb2dvi_inst/TMDS8b10b_inst_g/n365_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n365,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n365_4,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(3),
  I1 => GND_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n366_4);
\rgb2dvi_inst/TMDS8b10b_inst_g/n364_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n364,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n364_4,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(4),
  I1 => GND_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n365_4);
\rgb2dvi_inst/TMDS8b10b_inst_b/n366_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n366,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n366_4,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(2),
  I1 => GND_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n367_12);
\rgb2dvi_inst/TMDS8b10b_inst_b/n365_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n365,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n365_4,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(3),
  I1 => GND_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n366_4);
\rgb2dvi_inst/TMDS8b10b_inst_b/n364_s\: ALU
generic map (
  ALU_MODE => 0
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n364,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n364_4,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(4),
  I1 => GND_0,
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n365_4);
\rgb2dvi_inst/TMDS8b10b_inst_r/n239_s6\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n239,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n239_14,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_0,
  I3 => GND_0,
  CIN => GND_0);
\rgb2dvi_inst/TMDS8b10b_inst_r/n238_s5\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n238,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n238_12,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(2),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(1),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n239_14);
\rgb2dvi_inst/TMDS8b10b_inst_r/n237_s5\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n237,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n237_12,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(3),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(2),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n238_12);
\rgb2dvi_inst/TMDS8b10b_inst_r/n236_s4\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n236,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n236_10,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(4),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(3),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n237_12);
\rgb2dvi_inst/TMDS8b10b_inst_r/n367_s4\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n367,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n367_12,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor,
  I3 => GND_0,
  CIN => GND_0);
\rgb2dvi_inst/TMDS8b10b_inst_r/n367_s5\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n367_16,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n367_15,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n367,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_0,
  I3 => GND_0,
  CIN => VCC_0);
\rgb2dvi_inst/TMDS8b10b_inst_r/n366_s3\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n366_12,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n366_11,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n366,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(1),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n367_15);
\rgb2dvi_inst/TMDS8b10b_inst_r/n365_s3\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_r_n365_12,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_r_n365_11,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n365,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(2),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_r_n366_11);
\rgb2dvi_inst/TMDS8b10b_inst_g/n239_s6\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n239,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n239_14,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_0,
  I3 => GND_0,
  CIN => GND_0);
\rgb2dvi_inst/TMDS8b10b_inst_g/n238_s5\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n238,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n238_12,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(2),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(1),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n239_14);
\rgb2dvi_inst/TMDS8b10b_inst_g/n237_s5\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n237,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n237_12,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(3),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(2),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n238_12);
\rgb2dvi_inst/TMDS8b10b_inst_g/n236_s4\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n236,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n236_10,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(4),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(3),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n237_12);
\rgb2dvi_inst/TMDS8b10b_inst_g/n367_s4\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n367,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n367_12,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor,
  I3 => GND_0,
  CIN => GND_0);
\rgb2dvi_inst/TMDS8b10b_inst_g/n367_s5\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n367_16,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n367_15,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n367,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_0,
  I3 => GND_0,
  CIN => VCC_0);
\rgb2dvi_inst/TMDS8b10b_inst_g/n366_s3\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n366_12,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n366_11,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n366,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(1),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n367_15);
\rgb2dvi_inst/TMDS8b10b_inst_g/n365_s3\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n365_12,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n365_11,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n365,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(2),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n366_11);
\rgb2dvi_inst/TMDS8b10b_inst_g/n364_s3\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_g_n364_12,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_g_n364_11,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n364,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(3),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_g_n365_11);
\rgb2dvi_inst/TMDS8b10b_inst_b/n239_s6\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n239,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n239_14,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_0,
  I3 => GND_0,
  CIN => GND_0);
\rgb2dvi_inst/TMDS8b10b_inst_b/n238_s5\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n238,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n238_12,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(2),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(1),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n239_14);
\rgb2dvi_inst/TMDS8b10b_inst_b/n237_s5\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n237,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n237_12,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(3),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(2),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n238_12);
\rgb2dvi_inst/TMDS8b10b_inst_b/n236_s4\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n236,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n236_10,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(4),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(3),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n237_12);
\rgb2dvi_inst/TMDS8b10b_inst_b/n367_s4\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n367,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n367_12,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor,
  I3 => GND_0,
  CIN => GND_0);
\rgb2dvi_inst/TMDS8b10b_inst_b/n367_s5\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n367_16,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n367_15,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n367,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_0,
  I3 => GND_0,
  CIN => VCC_0);
\rgb2dvi_inst/TMDS8b10b_inst_b/n366_s3\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n366_12,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n366_11,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n366,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(1),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n367_15);
\rgb2dvi_inst/TMDS8b10b_inst_b/n365_s3\: ALU
generic map (
  ALU_MODE => 1
)
port map (
  SUM => rgb2dvi_inst_TMDS8b10b_inst_b_n365_12,
  COUT => rgb2dvi_inst_TMDS8b10b_inst_b_n365_11,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n365,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(2),
  I3 => GND_0,
  CIN => rgb2dvi_inst_TMDS8b10b_inst_b_n366_11);
\rgb2dvi_inst/TMDS8b10b_inst_r/n274_s0\: LUT3
generic map (
  INIT => X"3A"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n274,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n135,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n239,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_r/n571_s0\: LUT3
generic map (
  INIT => X"CA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n571,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n536_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n367_16,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n628_7);
\rgb2dvi_inst/TMDS8b10b_inst_g/n274_s0\: LUT3
generic map (
  INIT => X"3A"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n274,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n135,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n239,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_g/n571_s0\: LUT3
generic map (
  INIT => X"CA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n571,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n536_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n367_16,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n628);
\rgb2dvi_inst/TMDS8b10b_inst_b/n274_s0\: LUT3
generic map (
  INIT => X"3A"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n274,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n135,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n239,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_b/n571_s0\: LUT3
generic map (
  INIT => X"CA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n571,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n536_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n367_16,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n628_6);
\rgb2dvi_inst/TMDS8b10b_inst_r/n654_s0\: MUX2_LUT5
port map (
  O => rgb2dvi_inst_TMDS8b10b_inst_r_n654,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n645,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n622,
  S0 => rgb2dvi_inst_TMDS8b10b_inst_r_n605);
\rgb2dvi_inst/TMDS8b10b_inst_g/n654_s0\: MUX2_LUT5
port map (
  O => rgb2dvi_inst_TMDS8b10b_inst_g_n654,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n645,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n622,
  S0 => rgb2dvi_inst_TMDS8b10b_inst_g_n605);
\rgb2dvi_inst/TMDS8b10b_inst_b/n654_s0\: MUX2_LUT5
port map (
  O => rgb2dvi_inst_TMDS8b10b_inst_b_n654,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n645,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n622,
  S0 => rgb2dvi_inst_TMDS8b10b_inst_b_n605);
\rgb2dvi_inst/TMDS8b10b_inst_r/n114_s0\: LUT4
generic map (
  INIT => X"CDF0"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n114,
  I0 => I_rgb_r(0),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n114_5,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n114_6,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n114_7);
\rgb2dvi_inst/TMDS8b10b_inst_r/n605_s0\: LUT4
generic map (
  INIT => X"FAFC"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n605,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_4,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_5,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_6,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_7);
\rgb2dvi_inst/TMDS8b10b_inst_r/n656_s1\: LUT3
generic map (
  INIT => X"35"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n656,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_r/n657_s0\: LUT4
generic map (
  INIT => X"C3AA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n657,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n657_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n657_5,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_r/n658_s1\: LUT4
generic map (
  INIT => X"3C55"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n658,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n658_9,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n658_6,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_r/n659_s0\: LUT4
generic map (
  INIT => X"3CAA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n659,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n658_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n659_6,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_r/n660_s1\: LUT4
generic map (
  INIT => X"3C55"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n660,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n658_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n660_8,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_r/n661_s0\: LUT4
generic map (
  INIT => X"3CAA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n661,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n661_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n658_6,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_r/n662_s1\: LUT4
generic map (
  INIT => X"3C55"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n662,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n658_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n662_7,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_r/n663_s0\: LUT4
generic map (
  INIT => X"C3AA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n663,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n663_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n657_4,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_r/n664_s0\: LUT3
generic map (
  INIT => X"AC"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n664,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n654,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_g/n114_s0\: LUT4
generic map (
  INIT => X"A3CC"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n114,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n114_4,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n114_5,
  I2 => I_rgb_g(0),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n114_6);
\rgb2dvi_inst/TMDS8b10b_inst_g/n605_s0\: LUT4
generic map (
  INIT => X"4F44"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n605,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n605_4,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(4),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n605_5);
\rgb2dvi_inst/TMDS8b10b_inst_g/n628_s0\: LUT4
generic map (
  INIT => X"F004"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n628,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n605_5,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n605_4,
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(4),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n628_4);
\rgb2dvi_inst/TMDS8b10b_inst_g/n656_s1\: LUT3
generic map (
  INIT => X"53"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n656,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_g/n657_s0\: LUT4
generic map (
  INIT => X"C3AA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n657,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n657_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n657_5,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_g/n658_s1\: LUT4
generic map (
  INIT => X"3C55"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n658,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n658_5,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n658_6,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_g/n659_s0\: LUT4
generic map (
  INIT => X"3CAA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n659,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n658_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n659_6,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_g/n660_s1\: LUT4
generic map (
  INIT => X"3C55"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n660,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n658_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n660_8,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_g/n661_s0\: LUT4
generic map (
  INIT => X"3CAA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n661,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n661_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n658_6,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_g/n662_s1\: LUT4
generic map (
  INIT => X"3C55"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n662,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n658_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n662_7,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_g/n663_s0\: LUT4
generic map (
  INIT => X"C3AA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n663,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n663_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n657_4,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_g/n664_s0\: LUT3
generic map (
  INIT => X"AC"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n664,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n654,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_c1_d,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_b/n114_s0\: LUT4
generic map (
  INIT => X"A3CC"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n114,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n114_4,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n114_5,
  I2 => I_rgb_b(0),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n114_6);
\rgb2dvi_inst/TMDS8b10b_inst_b/n605_s0\: LUT3
generic map (
  INIT => X"F1"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n605,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_0,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n605_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n605_5);
\rgb2dvi_inst/TMDS8b10b_inst_b/n655_s0\: LUT4
generic map (
  INIT => X"AAC3"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n655,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n655_4,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_c0_d,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_c1_d,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_b/n656_s1\: LUT3
generic map (
  INIT => X"35"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n656,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_c0_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_b/n657_s0\: LUT4
generic map (
  INIT => X"C3AA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n657,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_c0_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n657_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n657_5,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_b/n658_s1\: LUT4
generic map (
  INIT => X"C355"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n658,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_c0_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n658_5,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n655_4,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_b/n659_s0\: LUT4
generic map (
  INIT => X"C3AA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n659,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_c0_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n659_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n655_4,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_b/n660_s1\: LUT4
generic map (
  INIT => X"C355"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n660,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_c0_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n655_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n660_8,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_b/n661_s0\: LUT4
generic map (
  INIT => X"C3AA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n661,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_c0_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n661_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n657_4,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_b/n662_s1\: LUT4
generic map (
  INIT => X"C355"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n662,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_c0_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n655_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n662_7,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_b/n663_s0\: LUT4
generic map (
  INIT => X"C3AA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n663,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_c0_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n663_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n657_4,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_b/n664_s0\: LUT3
generic map (
  INIT => X"CA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n664,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_c0_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n654,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit_0_s13\: LUT3
generic map (
  INIT => X"69"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_0,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(7),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_0_19);
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit_1_s14\: LUT4
generic map (
  INIT => X"6992"
)
port map (
  F => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(1),
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_22,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_23,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_24);
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit_2_s15\: LUT3
generic map (
  INIT => X"0E"
)
port map (
  F => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(2),
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_7,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_5,
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(3));
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit_3_s11\: LUT3
generic map (
  INIT => X"40"
)
port map (
  F => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(3),
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_23,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_5,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_3);
\rgb2dvi_inst/TMDS8b10b_inst_r/n402_s3\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n402,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(2));
\rgb2dvi_inst/TMDS8b10b_inst_r/n401_s3\: LUT3
generic map (
  INIT => X"78"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n401,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(3));
\rgb2dvi_inst/TMDS8b10b_inst_r/n400_s2\: LUT4
generic map (
  INIT => X"7F80"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n400,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(3),
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(4));
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_0_s13\: LUT4
generic map (
  INIT => X"6996"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_0,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(3),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(5),
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(7));
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_2_s15\: LUT4
generic map (
  INIT => X"B27D"
)
port map (
  F => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(2),
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_24,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_25);
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_3_s11\: LUT3
generic map (
  INIT => X"40"
)
port map (
  F => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(3),
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_25,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1_25,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1);
\rgb2dvi_inst/TMDS8b10b_inst_g/n402_s3\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n402,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(2));
\rgb2dvi_inst/TMDS8b10b_inst_g/n401_s3\: LUT3
generic map (
  INIT => X"78"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n401,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(3));
\rgb2dvi_inst/TMDS8b10b_inst_g/n400_s2\: LUT4
generic map (
  INIT => X"7F80"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n400,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(3),
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(4));
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_0_s13\: LUT4
generic map (
  INIT => X"6996"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_0,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(3),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(5),
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(7));
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_2_s15\: LUT4
generic map (
  INIT => X"F74D"
)
port map (
  F => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(2),
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_22,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_23,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_2);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_3_s11\: LUT3
generic map (
  INIT => X"08"
)
port map (
  F => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(3),
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_2,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_22,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_23);
\rgb2dvi_inst/TMDS8b10b_inst_b/n402_s3\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n402,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(2));
\rgb2dvi_inst/TMDS8b10b_inst_b/n401_s3\: LUT3
generic map (
  INIT => X"78"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n401,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(3));
\rgb2dvi_inst/TMDS8b10b_inst_b/n400_s2\: LUT4
generic map (
  INIT => X"7F80"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n400,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(3),
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(4));
\rgb2dvi_inst/TMDS8b10b_inst_b/n580_s1\: LUT4
generic map (
  INIT => X"5C00"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n580,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n580_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n580_7,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n605,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_b/n579_s1\: LUT4
generic map (
  INIT => X"AC00"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n579,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n579_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n579_7,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n605,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_b/n578_s1\: LUT4
generic map (
  INIT => X"CA00"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n578,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n578_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n578_7,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n605,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_g/n580_s1\: LUT4
generic map (
  INIT => X"5C00"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n580,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n580_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n580_7,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n605,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_g/n579_s1\: LUT4
generic map (
  INIT => X"AC00"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n579,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n579_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n579_7,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n605,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_g/n578_s1\: LUT4
generic map (
  INIT => X"C500"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n578,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n578_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n578_7,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n605,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_r/n580_s1\: LUT4
generic map (
  INIT => X"C500"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n580,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n580_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n580_7,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n605,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_r/n579_s1\: LUT4
generic map (
  INIT => X"A300"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n579,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n579_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n579_7,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n605,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_r/n578_s1\: LUT4
generic map (
  INIT => X"C500"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n578,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n578_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n578_7,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n605,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d);
\rgb2dvi_inst/TMDS8b10b_inst_r/n655_s2\: LUT2
generic map (
  INIT => X"7"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n655,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n658_6);
\rgb2dvi_inst/TMDS8b10b_inst_r/n114_s1\: LUT4
generic map (
  INIT => X"8000"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n114_5,
  I0 => I_rgb_r(0),
  I1 => I_rgb_r(1),
  I2 => I_rgb_r(2),
  I3 => I_rgb_r(4));
\rgb2dvi_inst/TMDS8b10b_inst_r/n114_s2\: LUT3
generic map (
  INIT => X"DB"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n114_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n114_15,
  I1 => I_rgb_r(7),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n114_9);
\rgb2dvi_inst/TMDS8b10b_inst_r/n114_s3\: LUT4
generic map (
  INIT => X"71EF"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n114_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n114_10,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n114_11,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n114_12,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n114_6);
\rgb2dvi_inst/TMDS8b10b_inst_r/n605_s1\: LUT4
generic map (
  INIT => X"4114"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n605_4,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_8,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_22,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_23);
\rgb2dvi_inst/TMDS8b10b_inst_r/n605_s2\: LUT4
generic map (
  INIT => X"007D"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n605_5,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_22,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_23,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_24);
\rgb2dvi_inst/TMDS8b10b_inst_r/n605_s3\: LUT4
generic map (
  INIT => X"0001"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n605_6,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(3),
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(4));
\rgb2dvi_inst/TMDS8b10b_inst_r/n605_s4\: LUT4
generic map (
  INIT => X"DDF4"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n605_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_22,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_3,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_23);
\rgb2dvi_inst/TMDS8b10b_inst_r/n628_s1\: LUT4
generic map (
  INIT => X"0100"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n628,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(4),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_6,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_7);
\rgb2dvi_inst/TMDS8b10b_inst_r/n628_s2\: LUT3
generic map (
  INIT => X"10"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n628_5,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_5,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_7,
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(4));
\rgb2dvi_inst/TMDS8b10b_inst_r/n657_s1\: LUT4
generic map (
  INIT => X"010E"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n657_4,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n628,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n628_5,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n605,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_r/n657_s2\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n657_5,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(7),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n658_9);
\rgb2dvi_inst/TMDS8b10b_inst_r/n658_s3\: LUT4
generic map (
  INIT => X"0007"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n658_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n605,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n628,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n628_5);
\rgb2dvi_inst/TMDS8b10b_inst_r/n661_s1\: LUT4
generic map (
  INIT => X"6996"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n661_4,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(3),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n663_4);
\rgb2dvi_inst/TMDS8b10b_inst_r/n663_s1\: LUT2
generic map (
  INIT => X"9"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n663_4,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(0),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(1));
\rgb2dvi_inst/TMDS8b10b_inst_g/n114_s1\: LUT3
generic map (
  INIT => X"80"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n114_4,
  I0 => I_rgb_g(1),
  I1 => I_rgb_g(2),
  I2 => I_rgb_g(4));
\rgb2dvi_inst/TMDS8b10b_inst_g/n114_s2\: LUT3
generic map (
  INIT => X"7E"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n114_5,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n114_7,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n114_8,
  I2 => I_rgb_g(7));
\rgb2dvi_inst/TMDS8b10b_inst_g/n114_s3\: LUT4
generic map (
  INIT => X"B2FD"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n114_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n114_9,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n114_10,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n114_8,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n114_5);
\rgb2dvi_inst/TMDS8b10b_inst_g/n605_s1\: LUT4
generic map (
  INIT => X"F3AF"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n605_4,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_0,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_25,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n605_6,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1);
\rgb2dvi_inst/TMDS8b10b_inst_g/n605_s2\: LUT3
generic map (
  INIT => X"01"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n605_5,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(3));
\rgb2dvi_inst/TMDS8b10b_inst_g/n628_s1\: LUT4
generic map (
  INIT => X"4D00"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n628_4,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_24,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_25);
\rgb2dvi_inst/TMDS8b10b_inst_g/n657_s1\: LUT3
generic map (
  INIT => X"14"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n657_4,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n605,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n628);
\rgb2dvi_inst/TMDS8b10b_inst_g/n657_s2\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n657_5,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(7),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n658_5);
\rgb2dvi_inst/TMDS8b10b_inst_g/n658_s2\: LUT4
generic map (
  INIT => X"6996"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n658_5,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(6),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n658_7,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n658_8,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n663_4);
\rgb2dvi_inst/TMDS8b10b_inst_g/n658_s3\: LUT3
generic map (
  INIT => X"07"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n658_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n605,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n628);
\rgb2dvi_inst/TMDS8b10b_inst_g/n663_s1\: LUT2
generic map (
  INIT => X"9"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n663_4,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(0),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(1));
\rgb2dvi_inst/TMDS8b10b_inst_b/n114_s1\: LUT3
generic map (
  INIT => X"80"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n114_4,
  I0 => I_rgb_b(1),
  I1 => I_rgb_b(2),
  I2 => I_rgb_b(4));
\rgb2dvi_inst/TMDS8b10b_inst_b/n114_s2\: LUT3
generic map (
  INIT => X"7E"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n114_5,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n114_7,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n114_8,
  I2 => I_rgb_b(7));
\rgb2dvi_inst/TMDS8b10b_inst_b/n114_s3\: LUT4
generic map (
  INIT => X"B2FD"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n114_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n114_9,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n114_10,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n114_8,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n114_5);
\rgb2dvi_inst/TMDS8b10b_inst_b/n605_s1\: LUT4
generic map (
  INIT => X"C7BC"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n605_4,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_2,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_22,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_23);
\rgb2dvi_inst/TMDS8b10b_inst_b/n605_s2\: LUT4
generic map (
  INIT => X"0001"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n605_5,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(3),
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(4));
\rgb2dvi_inst/TMDS8b10b_inst_b/n628_s1\: LUT4
generic map (
  INIT => X"0EF1"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n628,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_23,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_2,
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(4));
\rgb2dvi_inst/TMDS8b10b_inst_b/n655_s1\: LUT3
generic map (
  INIT => X"CA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n655_4,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n628,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n605);
\rgb2dvi_inst/TMDS8b10b_inst_b/n657_s1\: LUT3
generic map (
  INIT => X"14"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n657_4,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n605,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n628);
\rgb2dvi_inst/TMDS8b10b_inst_b/n657_s2\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n657_5,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(7),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n658_5);
\rgb2dvi_inst/TMDS8b10b_inst_b/n658_s2\: LUT4
generic map (
  INIT => X"6996"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n658_5,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(4),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(5),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(6),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n661_4);
\rgb2dvi_inst/TMDS8b10b_inst_b/n659_s1\: LUT4
generic map (
  INIT => X"6996"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n659_4,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(4),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(5),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n661_4);
\rgb2dvi_inst/TMDS8b10b_inst_b/n661_s1\: LUT4
generic map (
  INIT => X"9669"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n661_4,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(0),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(1),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(2),
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(3));
\rgb2dvi_inst/TMDS8b10b_inst_b/n663_s1\: LUT2
generic map (
  INIT => X"9"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n663_4,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(0),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(1));
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit_0_s14\: LUT4
generic map (
  INIT => X"9669"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_0_19,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor,
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(3),
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(5));
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit_1_s15\: LUT4
generic map (
  INIT => X"C3AA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n658_9,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(4),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(5),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_0_19);
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit_1_s16\: LUT3
generic map (
  INIT => X"09"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_22,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(4),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(5),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n661_4);
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit_1_s17\: LUT4
generic map (
  INIT => X"A73C"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_23,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(0),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n660_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_25,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit_1_s18\: LUT4
generic map (
  INIT => X"F96F"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_24,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(7),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_0_19,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n658_9);
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit_3_s12\: LUT3
generic map (
  INIT => X"90"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_3,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor,
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(0));
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_1_s15\: LUT3
generic map (
  INIT => X"14"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_0,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n661_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1_29);
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_2_s16\: LUT4
generic map (
  INIT => X"ACCA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_26,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n658_8,
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(0),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_27);
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_2_s17\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_24,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_28,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_29);
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_2_s18\: LUT4
generic map (
  INIT => X"5FCC"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_25,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_30,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_29,
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(0),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_28);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_1_s15\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(4),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_24);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_1_s16\: LUT4
generic map (
  INIT => X"1441"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_22,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_0,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor,
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(7),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n658_5);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_1_s17\: LUT4
generic map (
  INIT => X"E11E"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_23,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(0),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(1),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_25,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_26);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_2_s16\: LUT4
generic map (
  INIT => X"CA5C"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_2,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_26,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_2_24,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_2_25);
\rgb2dvi_inst/TMDS8b10b_inst_b/n580_s2\: LUT4
generic map (
  INIT => X"C355"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n580_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n134,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n238,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n239,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_b/n580_s3\: LUT3
generic map (
  INIT => X"AC"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n580_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n366_12,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n535_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n628);
\rgb2dvi_inst/TMDS8b10b_inst_b/n579_s2\: LUT4
generic map (
  INIT => X"C355"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n579_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n133,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n579_8,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n237,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_b/n579_s3\: LUT3
generic map (
  INIT => X"53"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n579_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n365_12,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n534_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n628);
\rgb2dvi_inst/TMDS8b10b_inst_b/n578_s2\: LUT4
generic map (
  INIT => X"AAC3"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n578_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n578_11,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n534_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n533_6,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n628);
\rgb2dvi_inst/TMDS8b10b_inst_b/n578_s3\: LUT4
generic map (
  INIT => X"AAC3"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n578_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n578_9,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n133,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n132,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_g/n580_s2\: LUT4
generic map (
  INIT => X"C355"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n580_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n134,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n238,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n239,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_g/n580_s3\: LUT3
generic map (
  INIT => X"AC"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n580_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n366_12,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n535_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n628);
\rgb2dvi_inst/TMDS8b10b_inst_g/n579_s2\: LUT4
generic map (
  INIT => X"C355"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n579_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n133,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n579_8,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n237,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_g/n579_s3\: LUT3
generic map (
  INIT => X"53"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n579_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n365_12,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n534_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n628);
\rgb2dvi_inst/TMDS8b10b_inst_g/n578_s2\: LUT4
generic map (
  INIT => X"C3AA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n578_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n578_11,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n365_12,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n364_12,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n628);
\rgb2dvi_inst/TMDS8b10b_inst_g/n578_s3\: LUT4
generic map (
  INIT => X"55C3"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n578_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n578_9,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n133,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n132,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_r/n580_s2\: LUT4
generic map (
  INIT => X"3335"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n580_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n535_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n366_12,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n628,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n628_5);
\rgb2dvi_inst/TMDS8b10b_inst_r/n580_s3\: LUT4
generic map (
  INIT => X"3CAA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n580_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n134,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n238,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n239,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_r/n579_s2\: LUT4
generic map (
  INIT => X"C355"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n579_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n133,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n579_8,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n237,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_r/n579_s3\: LUT4
generic map (
  INIT => X"CCCA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n579_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n534_6,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n365_12,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n628,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n628_5);
\rgb2dvi_inst/TMDS8b10b_inst_r/n578_s2\: LUT4
generic map (
  INIT => X"CCC5"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n578_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n578_15,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n578_14,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n628,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n628_5);
\rgb2dvi_inst/TMDS8b10b_inst_r/n578_s3\: LUT4
generic map (
  INIT => X"55C3"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n578_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n578_10,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n133,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n132,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_r/n114_s5\: LUT4
generic map (
  INIT => X"6996"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n114_9,
  I0 => I_rgb_r(3),
  I1 => I_rgb_r(5),
  I2 => I_rgb_r(6),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n114_13);
\rgb2dvi_inst/TMDS8b10b_inst_r/n114_s6\: LUT4
generic map (
  INIT => X"7EE8"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n114_10,
  I0 => I_rgb_r(0),
  I1 => I_rgb_r(1),
  I2 => I_rgb_r(2),
  I3 => I_rgb_r(4));
\rgb2dvi_inst/TMDS8b10b_inst_r/n114_s7\: LUT2
generic map (
  INIT => X"8"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n114_11,
  I0 => I_rgb_r(3),
  I1 => I_rgb_r(5));
\rgb2dvi_inst/TMDS8b10b_inst_r/n114_s8\: LUT4
generic map (
  INIT => X"D44D"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n114_12,
  I0 => I_rgb_r(6),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n114_13,
  I2 => I_rgb_r(3),
  I3 => I_rgb_r(5));
\rgb2dvi_inst/TMDS8b10b_inst_r/n605_s5\: LUT4
generic map (
  INIT => X"6FF9"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n605_8,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(7),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n658_9,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_0_19);
\rgb2dvi_inst/TMDS8b10b_inst_r/n658_s4\: LUT4
generic map (
  INIT => X"9669"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n658_7,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(2),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(3),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(4),
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(5));
\rgb2dvi_inst/TMDS8b10b_inst_r/n660_s3\: LUT2
generic map (
  INIT => X"9"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n660_6,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(3),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(4));
\rgb2dvi_inst/TMDS8b10b_inst_g/n114_s4\: LUT4
generic map (
  INIT => X"9669"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n114_7,
  I0 => I_rgb_g(3),
  I1 => I_rgb_g(5),
  I2 => I_rgb_g(6),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n114_11);
\rgb2dvi_inst/TMDS8b10b_inst_g/n114_s5\: LUT4
generic map (
  INIT => X"7887"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n114_8,
  I0 => I_rgb_g(3),
  I1 => I_rgb_g(5),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n114_9,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n114_10);
\rgb2dvi_inst/TMDS8b10b_inst_g/n114_s6\: LUT4
generic map (
  INIT => X"D44D"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n114_9,
  I0 => I_rgb_g(6),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n114_11,
  I2 => I_rgb_g(3),
  I3 => I_rgb_g(5));
\rgb2dvi_inst/TMDS8b10b_inst_g/n114_s7\: LUT4
generic map (
  INIT => X"7EE8"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n114_10,
  I0 => I_rgb_g(0),
  I1 => I_rgb_g(1),
  I2 => I_rgb_g(2),
  I3 => I_rgb_g(4));
\rgb2dvi_inst/TMDS8b10b_inst_g/n605_s3\: LUT3
generic map (
  INIT => X"96"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n605_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_28,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_29,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2);
\rgb2dvi_inst/TMDS8b10b_inst_g/n658_s4\: LUT2
generic map (
  INIT => X"9"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n658_7,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(2),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(3));
\rgb2dvi_inst/TMDS8b10b_inst_g/n658_s5\: LUT2
generic map (
  INIT => X"9"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n658_8,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(4),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(5));
\rgb2dvi_inst/TMDS8b10b_inst_g/n660_s3\: LUT2
generic map (
  INIT => X"9"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n660_6,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(3),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(4));
\rgb2dvi_inst/TMDS8b10b_inst_b/n114_s4\: LUT4
generic map (
  INIT => X"9669"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n114_7,
  I0 => I_rgb_b(3),
  I1 => I_rgb_b(5),
  I2 => I_rgb_b(6),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n114_11);
\rgb2dvi_inst/TMDS8b10b_inst_b/n114_s5\: LUT4
generic map (
  INIT => X"7887"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n114_8,
  I0 => I_rgb_b(3),
  I1 => I_rgb_b(5),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n114_9,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n114_10);
\rgb2dvi_inst/TMDS8b10b_inst_b/n114_s6\: LUT4
generic map (
  INIT => X"D44D"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n114_9,
  I0 => I_rgb_b(6),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n114_11,
  I2 => I_rgb_b(3),
  I3 => I_rgb_b(5));
\rgb2dvi_inst/TMDS8b10b_inst_b/n114_s7\: LUT4
generic map (
  INIT => X"7EE8"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n114_10,
  I0 => I_rgb_b(0),
  I1 => I_rgb_b(1),
  I2 => I_rgb_b(2),
  I3 => I_rgb_b(4));
\rgb2dvi_inst/TMDS8b10b_inst_b/n660_s3\: LUT2
generic map (
  INIT => X"9"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n660_6,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(3),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(4));
\rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit_1_s19\: LUT4
generic map (
  INIT => X"63FA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_cnt_one_9bit_1_25,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(0),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(1),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n660_6);
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_2_s19\: LUT4
generic map (
  INIT => X"9669"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_26,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor,
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(3),
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(4));
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_2_s20\: LUT4
generic map (
  INIT => X"9669"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_27,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(1),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(3),
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(6));
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_2_s21\: LUT4
generic map (
  INIT => X"C95F"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_28,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(0),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n658_7,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_30,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n658_8);
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_2_s22\: LUT4
generic map (
  INIT => X"5AC3"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_29,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_31,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor,
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(1),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n660_6);
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_2_s23\: LUT2
generic map (
  INIT => X"9"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_30,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_1_s18\: LUT4
generic map (
  INIT => X"A33A"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_24,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_27,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(5),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(6),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n661_4);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_1_s19\: LUT4
generic map (
  INIT => X"63F5"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_25,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(0),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n660_6);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_1_s20\: LUT4
generic map (
  INIT => X"8241"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_26,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(4),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(5),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n661_4);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_2_s17\: LUT3
generic map (
  INIT => X"5C"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_2_24,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(1),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(0));
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_2_s18\: LUT4
generic map (
  INIT => X"C355"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_2_25,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(0),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(2),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n660_6);
\rgb2dvi_inst/TMDS8b10b_inst_b/n579_s4\: LUT2
generic map (
  INIT => X"8"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n579_8,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n238,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n239);
\rgb2dvi_inst/TMDS8b10b_inst_b/n578_s5\: LUT4
generic map (
  INIT => X"07F8"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n578_9,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n238,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n239,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n237,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n236);
\rgb2dvi_inst/TMDS8b10b_inst_g/n579_s4\: LUT2
generic map (
  INIT => X"8"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n579_8,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n238,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n239);
\rgb2dvi_inst/TMDS8b10b_inst_g/n578_s5\: LUT4
generic map (
  INIT => X"F807"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n578_9,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n238,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n239,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n237,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n236);
\rgb2dvi_inst/TMDS8b10b_inst_r/n579_s4\: LUT2
generic map (
  INIT => X"8"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n579_8,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n238,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n239);
\rgb2dvi_inst/TMDS8b10b_inst_r/n578_s6\: LUT4
generic map (
  INIT => X"F807"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n578_10,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n238,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n239,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n237,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n236);
\rgb2dvi_inst/TMDS8b10b_inst_r/n114_s9\: LUT4
generic map (
  INIT => X"9669"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n114_13,
  I0 => I_rgb_r(0),
  I1 => I_rgb_r(1),
  I2 => I_rgb_r(2),
  I3 => I_rgb_r(4));
\rgb2dvi_inst/TMDS8b10b_inst_g/n114_s8\: LUT4
generic map (
  INIT => X"9669"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n114_11,
  I0 => I_rgb_g(0),
  I1 => I_rgb_g(1),
  I2 => I_rgb_g(2),
  I3 => I_rgb_g(4));
\rgb2dvi_inst/TMDS8b10b_inst_b/n114_s8\: LUT4
generic map (
  INIT => X"9669"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n114_11,
  I0 => I_rgb_b(0),
  I1 => I_rgb_b(1),
  I2 => I_rgb_b(2),
  I3 => I_rgb_b(4));
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_2_s24\: LUT2
generic map (
  INIT => X"9"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_31,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(0),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(2));
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_1_s21\: LUT3
generic map (
  INIT => X"69"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_27,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(1),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor,
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(3));
\rgb2dvi_inst/TMDS8b10b_inst_b/n662_s3\: LUT3
generic map (
  INIT => X"69"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n662_7,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(2),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(0),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(1));
\rgb2dvi_inst/TMDS8b10b_inst_g/n660_s4\: LUT3
generic map (
  INIT => X"96"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n660_8,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(3),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(4),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n662_7);
\rgb2dvi_inst/TMDS8b10b_inst_r/n114_s10\: LUT4
generic map (
  INIT => X"956A"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n114_15,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n114_10,
  I1 => I_rgb_r(3),
  I2 => I_rgb_r(5),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n114_12);
\rgb2dvi_inst/TMDS8b10b_inst_b/n660_s4\: LUT3
generic map (
  INIT => X"96"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n660_8,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(3),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(4),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n662_7);
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_1_s18\: LUT3
generic map (
  INIT => X"69"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1_25,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_28,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_2_29);
\rgb2dvi_inst/TMDS8b10b_inst_g/n661_s2\: LUT4
generic map (
  INIT => X"6996"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n661_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(2),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(3),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n663_4);
\rgb2dvi_inst/TMDS8b10b_inst_r/n660_s4\: LUT3
generic map (
  INIT => X"96"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n660_8,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(3),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(4),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n662_7);
\rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit_1_s22\: LUT4
generic map (
  INIT => X"6996"
)
port map (
  F => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(1),
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(4),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_24,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_22,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_1_23);
\rgb2dvi_inst/TMDS8b10b_inst_g/n662_s3\: LUT3
generic map (
  INIT => X"69"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n662_7,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(2),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(0),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(1));
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_1_s19\: LUT4
generic map (
  INIT => X"EB14"
)
port map (
  F => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(1),
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_0,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n661_6,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1_29,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1_25);
\rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit_1_s20\: LUT4
generic map (
  INIT => X"9669"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_cnt_one_9bit_1_29,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(6),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(7),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(4),
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(5));
\rgb2dvi_inst/TMDS8b10b_inst_g/n659_s2\: LUT3
generic map (
  INIT => X"96"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n659_6,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(4),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(5),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n661_6);
\rgb2dvi_inst/TMDS8b10b_inst_r/n662_s3\: LUT3
generic map (
  INIT => X"69"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n662_7,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(2),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(0),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(1));
\rgb2dvi_inst/TMDS8b10b_inst_r/n659_s2\: LUT4
generic map (
  INIT => X"6996"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n659_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(0),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(1),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n658_7);
\rgb2dvi_inst/TMDS8b10b_inst_r/n658_s5\: LUT4
generic map (
  INIT => X"6996"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n658_9,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(6),
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(0),
  I2 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(1),
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n658_7);
\rgb2dvi_inst/TMDS8b10b_inst_g/n655_s3\: LUT4
generic map (
  INIT => X"FFD5"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n655,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n605,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n628);
\rgb2dvi_inst/TMDS8b10b_inst_r/n628_s3\: LUT4
generic map (
  INIT => X"ABAA"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n628_7,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n628,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_5,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n605_7,
  I3 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(4));
\rgb2dvi_inst/TMDS8b10b_inst_b/n628_s2\: LUT4
generic map (
  INIT => X"0E00"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n628_6,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_cnt_one_9bit_0,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n605_4,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n605_5,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n628);
\rgb2dvi_inst/TMDS8b10b_inst_r/n581_s2\: LUT4
generic map (
  INIT => X"A088"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n581,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n571,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n274,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n605);
\rgb2dvi_inst/TMDS8b10b_inst_g/n581_s2\: LUT4
generic map (
  INIT => X"A088"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n581,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n571,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n274,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n605);
\rgb2dvi_inst/TMDS8b10b_inst_b/n581_s2\: LUT4
generic map (
  INIT => X"A088"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n581,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_de_d,
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n571,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n274,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n605);
\rgb2dvi_inst/TMDS8b10b_inst_r/n654_s2\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n622,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(0),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_r/n654_s1\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n645,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/din_d\(0),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n628_7);
\rgb2dvi_inst/TMDS8b10b_inst_g/n654_s2\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n622,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(0),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_g/n654_s1\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n645,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_g/din_d\(0),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_g_n628);
\rgb2dvi_inst/TMDS8b10b_inst_b/n654_s2\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n622,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(0),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_sel_xnor);
\rgb2dvi_inst/TMDS8b10b_inst_b/n654_s1\: LUT2
generic map (
  INIT => X"6"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n645,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_b/din_d\(0),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_b_n628_6);
\rgb2dvi_inst/TMDS8b10b_inst_r/n578_s7\: LUT4
generic map (
  INIT => X"9669"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n578_15,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_r_n533,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(3),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n534_7,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n534_6);
\rgb2dvi_inst/TMDS8b10b_inst_g/n578_s6\: LUT4
generic map (
  INIT => X"6996"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_g_n578_11,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_g_n533,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt_one_9bit\(3),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_g_n534_7,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_g_n534_6);
\rgb2dvi_inst/TMDS8b10b_inst_r/n578_s8\: LUT4
generic map (
  INIT => X"6996"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_r_n578_14,
  I0 => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt_one_9bit\(3),
  I1 => rgb2dvi_inst_TMDS8b10b_inst_r_n364,
  I2 => rgb2dvi_inst_TMDS8b10b_inst_r_n365_11,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_r_n365_12);
\rgb2dvi_inst/TMDS8b10b_inst_b/n578_s6\: LUT4
generic map (
  INIT => X"9669"
)
port map (
  F => rgb2dvi_inst_TMDS8b10b_inst_b_n578_11,
  I0 => rgb2dvi_inst_TMDS8b10b_inst_b_n364,
  I1 => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt_one_9bit\(3),
  I2 => rgb2dvi_inst_TMDS8b10b_inst_b_n365_11,
  I3 => rgb2dvi_inst_TMDS8b10b_inst_b_n365_12);
\rgb2dvi_inst/n36_s2\: INV
port map (
  O => rgb2dvi_inst_n36,
  I => I_rst_n);
\rgb2dvi_inst/TMDS8b10b_inst_b/n403_s5\: INV
port map (
  O => rgb2dvi_inst_TMDS8b10b_inst_b_n403,
  I => \rgb2dvi_inst/TMDS8b10b_inst_b/cnt\(1));
\rgb2dvi_inst/TMDS8b10b_inst_g/n403_s5\: INV
port map (
  O => rgb2dvi_inst_TMDS8b10b_inst_g_n403,
  I => \rgb2dvi_inst/TMDS8b10b_inst_g/cnt\(1));
\rgb2dvi_inst/TMDS8b10b_inst_r/n403_s5\: INV
port map (
  O => rgb2dvi_inst_TMDS8b10b_inst_r_n403,
  I => \rgb2dvi_inst/TMDS8b10b_inst_r/cnt\(1));
GND_s3: GND
port map (
  G => GND_0);
VCC_s3: VCC
port map (
  V => VCC_0);
GSR_0: GSR
port map (
  GSRI => VCC_0);
end beh;
