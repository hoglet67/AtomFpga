-- generated with romgen v3.0.1r4 by MikeJ truhy and eD
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

library UNISIM;
  use UNISIM.Vcomponents.all;

entity fpgautils is
  port (
    CLK         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end;

architecture RTL of fpgautils is

  function romgen_str2bv (str : string) return bit_vector is
    variable result : bit_vector (str'length*4-1 downto 0);
  begin
    for i in 0 to str'length-1 loop
      case str(str'high-i) is
        when '0'       => result(i*4+3 downto i*4) := x"0";
        when '1'       => result(i*4+3 downto i*4) := x"1";
        when '2'       => result(i*4+3 downto i*4) := x"2";
        when '3'       => result(i*4+3 downto i*4) := x"3";
        when '4'       => result(i*4+3 downto i*4) := x"4";
        when '5'       => result(i*4+3 downto i*4) := x"5";
        when '6'       => result(i*4+3 downto i*4) := x"6";
        when '7'       => result(i*4+3 downto i*4) := x"7";
        when '8'       => result(i*4+3 downto i*4) := x"8";
        when '9'       => result(i*4+3 downto i*4) := x"9";
        when 'A'       => result(i*4+3 downto i*4) := x"A";
        when 'B'       => result(i*4+3 downto i*4) := x"B";
        when 'C'       => result(i*4+3 downto i*4) := x"C";
        when 'D'       => result(i*4+3 downto i*4) := x"D";
        when 'E'       => result(i*4+3 downto i*4) := x"E";
        when 'F'       => result(i*4+3 downto i*4) := x"F";
        when others    => null;
      end case;
    end loop;
    return result;
  end romgen_str2bv;

  attribute INIT_00 : string;
  attribute INIT_01 : string;
  attribute INIT_02 : string;
  attribute INIT_03 : string;
  attribute INIT_04 : string;
  attribute INIT_05 : string;
  attribute INIT_06 : string;
  attribute INIT_07 : string;
  attribute INIT_08 : string;
  attribute INIT_09 : string;
  attribute INIT_0A : string;
  attribute INIT_0B : string;
  attribute INIT_0C : string;
  attribute INIT_0D : string;
  attribute INIT_0E : string;
  attribute INIT_0F : string;
  attribute INIT_10 : string;
  attribute INIT_11 : string;
  attribute INIT_12 : string;
  attribute INIT_13 : string;
  attribute INIT_14 : string;
  attribute INIT_15 : string;
  attribute INIT_16 : string;
  attribute INIT_17 : string;
  attribute INIT_18 : string;
  attribute INIT_19 : string;
  attribute INIT_1A : string;
  attribute INIT_1B : string;
  attribute INIT_1C : string;
  attribute INIT_1D : string;
  attribute INIT_1E : string;
  attribute INIT_1F : string;
  attribute INIT_20 : string;
  attribute INIT_21 : string;
  attribute INIT_22 : string;
  attribute INIT_23 : string;
  attribute INIT_24 : string;
  attribute INIT_25 : string;
  attribute INIT_26 : string;
  attribute INIT_27 : string;
  attribute INIT_28 : string;
  attribute INIT_29 : string;
  attribute INIT_2A : string;
  attribute INIT_2B : string;
  attribute INIT_2C : string;
  attribute INIT_2D : string;
  attribute INIT_2E : string;
  attribute INIT_2F : string;
  attribute INIT_30 : string;
  attribute INIT_31 : string;
  attribute INIT_32 : string;
  attribute INIT_33 : string;
  attribute INIT_34 : string;
  attribute INIT_35 : string;
  attribute INIT_36 : string;
  attribute INIT_37 : string;
  attribute INIT_38 : string;
  attribute INIT_39 : string;
  attribute INIT_3A : string;
  attribute INIT_3B : string;
  attribute INIT_3C : string;
  attribute INIT_3D : string;
  attribute INIT_3E : string;
  attribute INIT_3F : string;

  component RAMB16_S4
    --pragma translate_off
    generic (
      INIT_00 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_01 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_02 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_03 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_04 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_05 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_06 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_07 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_08 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_09 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0A : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0B : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0C : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0D : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0E : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_0F : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_10 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_11 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_12 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_13 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_14 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_15 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_16 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_17 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_18 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_19 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_1A : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_1B : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_1C : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_1D : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_1E : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_1F : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_20 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_21 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_22 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_23 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_24 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_25 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_26 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_27 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_28 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_29 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_2A : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_2B : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_2C : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_2D : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_2E : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_2F : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_30 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_31 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_32 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_33 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_34 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_35 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_36 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_37 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_38 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_39 : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_3A : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_3B : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_3C : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_3D : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_3E : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000";
      INIT_3F : bit_vector (255 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000"
      );
    --pragma translate_on
    port (
      DO    : out std_logic_vector (3 downto 0);
      ADDR  : in  std_logic_vector (11 downto 0);
      CLK   : in  std_logic;
      DI    : in  std_logic_vector (3 downto 0);
      EN    : in  std_logic;
      SSR   : in  std_logic;
      WE    : in  std_logic 
      );
  end component;

  signal rom_addr : std_logic_vector(11 downto 0);

begin

  p_addr : process(ADDR)
  begin
     rom_addr <= (others => '0');
     rom_addr(11 downto 0) <= ADDR;
  end process;

  rom0 : if true generate
    attribute INIT_00 of inst : label is "C58602C58C46020904602250DD353470A860E951A00BD85051400CD888E4F2F0";
    attribute INIT_01 of inst : label is "2B4831C676439C2613237441FCE45441FC05D345F373E934345FE93734512F60";
    attribute INIT_02 of inst : label is "4E5CCE42143C0E42143C0E4E5CCE42143C0000E541204512C0854A0817676255";
    attribute INIT_03 of inst : label is "603C94501706710035652575155505652108C02108C0000EBE12CCE42143C00E";
    attribute INIT_04 of inst : label is "8514D95860095850955154505FFDF9508A888FDC82085820951B0020400A02E0";
    attribute INIT_05 of inst : label is "88FFDF9D595885A5A0AA6A72958A5A0AA6A7285E035554025455620469524D41";
    attribute INIT_06 of inst : label is "808080808080808080808080808080808080808080808080808080808080088A";
    attribute INIT_07 of inst : label is "8080808080808080808080808080808080808080808080808080808080808080";
    attribute INIT_08 of inst : label is "8080808080808080808080808080808080808080808080808080808080808080";
    attribute INIT_09 of inst : label is "8080808080808080808080808080808080808080808080808080808080808080";
    attribute INIT_0A of inst : label is "3210DCFE89AB01235476BA98EFCDBA98EFCD01235476DCFE89AB674532108080";
    attribute INIT_0B of inst : label is "98BA76542301AB89FEDC1032456710324567AB89FEDC76542301CDEF98BA6745";
    attribute INIT_0C of inst : label is "765498BACDEF45671032FEDCAB89FEDCAB894567103298BACDEF23017654CDEF";
    attribute INIT_0D of inst : label is "DCFE32106745EFCDBA985476012354760123EFCDBA983210674589ABDCFE2301";
    attribute INIT_0E of inst : label is "5652108C0E2CD0D89019D1D8029D3928D890D0D9029D1D02BD392AD293D089AB";
    attribute INIT_0F of inst : label is "0D2D75820D3D85A69686766C0E5D5C5B509A50995D9859975096535554545553";
    attribute INIT_10 of inst : label is "5652108C00203555802545562046D0D419019D1D00551545051E01B0040FDC82";
    attribute INIT_11 of inst : label is "2D005030860A8029D1D02109029D1D94840035152505ADA141404E5371015550";
    attribute INIT_12 of inst : label is "4E500DA7108200582015A0A42143710A036E0269524D21D0D8514D958602D490";
    attribute INIT_13 of inst : label is "108C01ECA0A32300DA71095885A5A0AA6A72958A5A0AA6A72858202582035A0A";
    attribute INIT_14 of inst : label is "EF3710FD082005658201555A0DF2607108204575A0BE120D127F207102108C02";
    attribute INIT_15 of inst : label is "C900ADAEEE7E9DD127F20DA97100ADA4542F21DAE7101099F30A0F9EF980D296";
    attribute INIT_16 of inst : label is "5AAD59FFD2955DA9FFD5955D09FFD59AAD59FFD2955DA9FFD59880C50B088095";
    attribute INIT_17 of inst : label is "FFD4555D09FFD59AAD59FFD2955DA9FFD590035092509808D0A020000D09FFD4";
    attribute INIT_18 of inst : label is "0FCCFED8980C508088096790058C4602888FFDF9D57009353616108D0A822101";
    attribute INIT_19 of inst : label is "185710F00CD888FD0508F40600E9508905F4009508F40600CDF40090002FD001";
    attribute INIT_1A of inst : label is "9A09149000ADA4C000430831C60DA00043041FCE40DA002511045120DAA35C0D";
    attribute INIT_1B of inst : label is "956585800023509150925050989DB988D0982DA981D09509088091B9108B0924";
    attribute INIT_1C of inst : label is "59065850C0008FD0790F40098208582095F4009820F9A00A9956049858000275";
    attribute INIT_1D of inst : label is "8889083041A0F988418410608F4060418C09541208584100557945D901C30759";
    attribute INIT_1E of inst : label is "F03F41C50792F0C5E25B1360792F041FC61A10792F03931216D5055558094545";
    attribute INIT_1F of inst : label is "0393120322BF04F30393120322AC04F203931203226504F10393120322460792";
    attribute INIT_20 of inst : label is "44349059E260261023DDF418A045834100C5E25B10904583410041FC619804F4";
    attribute INIT_21 of inst : label is "F31BA052E3603F44377036045C7F803FD0322A403E2603717E9052E36026103F";
    attribute INIT_22 of inst : label is "31010FD540E2F319503C130E2F314203C130E2F311503C130E2F31B603C130E2";
    attribute INIT_23 of inst : label is "390E552330B512102F49EFD0B5123042F70E2F3136008450E2F31EA046450E2F";
    attribute INIT_24 of inst : label is "DF412400E360531BB02E2605317E00E2605311B0949C9450661210E552330B51";
    attribute INIT_25 of inst : label is "F2B3942908F2DF34401281CB0422E16037F4E97039DF41D101E16037F4E97039";
    attribute INIT_26 of inst : label is "301B010E1608F2535FDD008F23FA2604E2603717FC0DF2B394B80DF2B394BB0D";
    attribute INIT_27 of inst : label is "2E360DF243E203E260DF243F606E260116C13F501E1608F28266037E1605D218";
    attribute INIT_28 of inst : label is "5E0DF413940EF93F200908F2CFF4000CE08F2CFF40006E039312250530001D04";
    attribute INIT_29 of inst : label is "0EF930B1049450EF930B5049450EF9302F0752540EF930100DF413940EF93F20";
    attribute INIT_2A of inst : label is "EBE5FF01E160949C94507FCC97350DF257042F6417550949C945033F2B904945";
    attribute INIT_2B of inst : label is "D0C70A2B80407910B9B004C059D069F4CC9D0D092BDB92AD5929DB928D190E7F";
    attribute INIT_2C of inst : label is "B80B6CB40F0E1EB009B40D4C0400B8050008E1EB00920F97009DAC0D1CDBCC8C";
    attribute INIT_2D of inst : label is "B0C0F4E5BBCA20A01E59D2C65898B6CB90DDC408C501090090900C0014002004";
    attribute INIT_2E of inst : label is "0E5090B08E109F0C70708009109EB0708F09009E60006480B0E10708C0647009";
    attribute INIT_2F of inst : label is "5002C5446880854468A204654888EB00F620E509B0C885000F6B0E5F09080F62";
    attribute INIT_30 of inst : label is "0FE86510FEFEDCBA9800A0CDDA02C835CDD25C5DC7072860E10B0E10BA060E10";
    attribute INIT_31 of inst : label is "09409309209DDDDDDDDDBDDDBBBBBBBBBBB26868F0E2CA2FBB9444EDC78B10C1";
    attribute INIT_32 of inst : label is "096097084095097083094097082093097081092090C09B09A099098097096095";
    attribute INIT_33 of inst : label is "FFFF00708B09C09708A09B09708909A097088099097087098097086097097085";
    attribute INIT_34 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_35 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_36 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_37 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_38 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_39 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_3A of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_3B of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_3C of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_3D of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_3E of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_3F of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
  begin
  inst : RAMB16_S4
      --pragma translate_off
      generic map (
        INIT_00 => romgen_str2bv(inst'INIT_00),
        INIT_01 => romgen_str2bv(inst'INIT_01),
        INIT_02 => romgen_str2bv(inst'INIT_02),
        INIT_03 => romgen_str2bv(inst'INIT_03),
        INIT_04 => romgen_str2bv(inst'INIT_04),
        INIT_05 => romgen_str2bv(inst'INIT_05),
        INIT_06 => romgen_str2bv(inst'INIT_06),
        INIT_07 => romgen_str2bv(inst'INIT_07),
        INIT_08 => romgen_str2bv(inst'INIT_08),
        INIT_09 => romgen_str2bv(inst'INIT_09),
        INIT_0A => romgen_str2bv(inst'INIT_0A),
        INIT_0B => romgen_str2bv(inst'INIT_0B),
        INIT_0C => romgen_str2bv(inst'INIT_0C),
        INIT_0D => romgen_str2bv(inst'INIT_0D),
        INIT_0E => romgen_str2bv(inst'INIT_0E),
        INIT_0F => romgen_str2bv(inst'INIT_0F),
        INIT_10 => romgen_str2bv(inst'INIT_10),
        INIT_11 => romgen_str2bv(inst'INIT_11),
        INIT_12 => romgen_str2bv(inst'INIT_12),
        INIT_13 => romgen_str2bv(inst'INIT_13),
        INIT_14 => romgen_str2bv(inst'INIT_14),
        INIT_15 => romgen_str2bv(inst'INIT_15),
        INIT_16 => romgen_str2bv(inst'INIT_16),
        INIT_17 => romgen_str2bv(inst'INIT_17),
        INIT_18 => romgen_str2bv(inst'INIT_18),
        INIT_19 => romgen_str2bv(inst'INIT_19),
        INIT_1A => romgen_str2bv(inst'INIT_1A),
        INIT_1B => romgen_str2bv(inst'INIT_1B),
        INIT_1C => romgen_str2bv(inst'INIT_1C),
        INIT_1D => romgen_str2bv(inst'INIT_1D),
        INIT_1E => romgen_str2bv(inst'INIT_1E),
        INIT_1F => romgen_str2bv(inst'INIT_1F),
        INIT_20 => romgen_str2bv(inst'INIT_20),
        INIT_21 => romgen_str2bv(inst'INIT_21),
        INIT_22 => romgen_str2bv(inst'INIT_22),
        INIT_23 => romgen_str2bv(inst'INIT_23),
        INIT_24 => romgen_str2bv(inst'INIT_24),
        INIT_25 => romgen_str2bv(inst'INIT_25),
        INIT_26 => romgen_str2bv(inst'INIT_26),
        INIT_27 => romgen_str2bv(inst'INIT_27),
        INIT_28 => romgen_str2bv(inst'INIT_28),
        INIT_29 => romgen_str2bv(inst'INIT_29),
        INIT_2A => romgen_str2bv(inst'INIT_2A),
        INIT_2B => romgen_str2bv(inst'INIT_2B),
        INIT_2C => romgen_str2bv(inst'INIT_2C),
        INIT_2D => romgen_str2bv(inst'INIT_2D),
        INIT_2E => romgen_str2bv(inst'INIT_2E),
        INIT_2F => romgen_str2bv(inst'INIT_2F),
        INIT_30 => romgen_str2bv(inst'INIT_30),
        INIT_31 => romgen_str2bv(inst'INIT_31),
        INIT_32 => romgen_str2bv(inst'INIT_32),
        INIT_33 => romgen_str2bv(inst'INIT_33),
        INIT_34 => romgen_str2bv(inst'INIT_34),
        INIT_35 => romgen_str2bv(inst'INIT_35),
        INIT_36 => romgen_str2bv(inst'INIT_36),
        INIT_37 => romgen_str2bv(inst'INIT_37),
        INIT_38 => romgen_str2bv(inst'INIT_38),
        INIT_39 => romgen_str2bv(inst'INIT_39),
        INIT_3A => romgen_str2bv(inst'INIT_3A),
        INIT_3B => romgen_str2bv(inst'INIT_3B),
        INIT_3C => romgen_str2bv(inst'INIT_3C),
        INIT_3D => romgen_str2bv(inst'INIT_3D),
        INIT_3E => romgen_str2bv(inst'INIT_3E),
        INIT_3F => romgen_str2bv(inst'INIT_3F)
        )
      --pragma translate_on
      port map (
        DO   => DATA(3 downto 0),
        ADDR => rom_addr,
        CLK  => CLK,
        DI   => "0000",
        EN   => '1',
        SSR  => '0',
        WE   => '0'
        );
  end generate;
  rom1 : if true generate
    attribute INIT_00 of inst : label is "4444056C54080AA32080A58A3B5808EBCCED2C0BF1A3BEFF0D13A3BCE85AFAB4";
    attribute INIT_01 of inst : label is "4FA45444BA554450A4543A4444440A4444559A55458A4458A554445BA45443A5";
    attribute INIT_02 of inst : label is "444323554553035545530344432355455300003454524544305CCA334452A444";
    attribute INIT_03 of inst : label is "525445524454FD26882A881A882A881AC32CB2C32CB200034444323554553003";
    attribute INIT_04 of inst : label is "88A858A8A0A88880A888A888ABF8120148497FE4F028AF028AA120AAD26E3323";
    attribute INIT_05 of inst : label is "65BF802FA886888AF1C8600A8A48AF1C8600A8ADD8C8AED8C8A8E0D8E88A858B";
    attribute INIT_06 of inst : label is "71AC9F4235E8538EF92417CABD60DB0671AC9F4235E8538EF92417CABD606A6A";
    attribute INIT_07 of inst : label is "71AC9F4235E8538EF92417CABD60DB0671AC9F4235E8538EF92417CABD60DB06";
    attribute INIT_08 of inst : label is "71AC9F4235E8538EF92417CABD60DB0671AC9F4235E8538EF92417CABD60DB06";
    attribute INIT_09 of inst : label is "71AC9F4235E8538EF92417CABD60DB0671AC9F4235E8538EF92417CABD60DB06";
    attribute INIT_0A of inst : label is "333333333333222222222222222211111111111111110000000000000000DB06";
    attribute INIT_0B of inst : label is "6666666666667777777777777777444444444444444455555555555555553333";
    attribute INIT_0C of inst : label is "8888888888889999999999999999AAAAAAAAAAAAAAAABBBBBBBBBBBBBBBB6666";
    attribute INIT_0D of inst : label is "DDDDDDDDDDDDCCCCCCCCCCCCCCCCFFFFFFFFFFFFFFFFEEEEEEEEEEEEEEEE8888";
    attribute INIT_0E of inst : label is "81AC32CB2F54BB86FF02BBA46008AA008AA6BBAFF02BBA6008AA0089AA92DDDD";
    attribute INIT_0F of inst : label is "2BB85AF02BB85A52525252C82585858580A580A583A580A580A584A583A582A5";
    attribute INIT_10 of inst : label is "81AC32CB26ED8C8AED8C8A8E0D8EBB88BFF02BBA0A888A888AA02A12AD2FE4F0";
    attribute INIT_11 of inst : label is "0A0A2FFD8FDC0D02BBA0A1DFF02BBA88880A888A888AE00454424445FD2882A8";
    attribute INIT_12 of inst : label is "4442200FD2F028AF028AE2355455FD2CD8ECD8E88A8589BBA88A858A8AB0804B";
    attribute INIT_13 of inst : label is "32CB2A04E234542200FD2886888AF1C8600A8A48AF1C8600A8AF028AF028AE23";
    attribute INIT_14 of inst : label is "444FD2FE2F02881AF02882AE244542FD2F02881AE2444424454455FD2C32CB2C";
    attribute INIT_15 of inst : label is "8B0AE0022244444454455005FD26E004455444004FD21F5CFE2E232425224544";
    attribute INIT_16 of inst : label is "AAA85ABF80AA58AABF80AA588ABF80AAA85ABF80AA58AABF80A7204FD9CC209A";
    attribute INIT_17 of inst : label is "BF88AA58AABF80AAA85ABF80AA58AABF80A0A88AA880AFD8FDC0A0AA083ABF88";
    attribute INIT_18 of inst : label is "2FF6BF80A204FD0CC209A3B0AC54080A665BF802FACDBC8A8E8EDDCFDC0A898B";
    attribute INIT_19 of inst : label is "454FD2C1A3BEECFE2FDCFF20FA8BFD0CEAFF22AFDEFF203A3BFF22A0A0AFE2AF";
    attribute INIT_1A of inst : label is "B309A8B0A6E00323333224544420033332244444420033333324544200354454";
    attribute INIT_1B of inst : label is "8A888A2020A88BA88AA88880A2283A2280A2283A2280AFD6CC209A1BFDC309A8";
    attribute INIT_1C of inst : label is "A0D8C8A6CDAEEFE2A32FF22AF028AF028AFF22AF021282F2C8A0D8C8A2028A88";
    attribute INIT_1D of inst : label is "19CFDC0F8BEFFCCC8388B6FDCFF20F8BC0D8C8B1D8CC8B0A88AA888AAF40D8C8";
    attribute INIT_1E of inst : label is "425444440445424445444E8044542544444AA044542445444D7CD8886A0A8886";
    attribute INIT_1F of inst : label is "24454424442103232445442444D503232445442444E5032324454424441F0445";
    attribute INIT_20 of inst : label is "445B4033235255423444454920444454524445444FB044445452544444450323";
    attribute INIT_21 of inst : label is "4444903323525444551035254444425442444EB0323525444B10332352554254";
    attribute INIT_22 of inst : label is "44BF044442454444F04444245444FE04444245444BC044442454445104444245";
    attribute INIT_23 of inst : label is "FE04445452444100545444424449404545245444B203344245444CF033442454";
    attribute INIT_24 of inst : label is "4454430323524442B0323524449B032352444EF0554445524247604445452444";
    attribute INIT_25 of inst : label is "454544BF05444445D03554CE0443235255444452444454780323525544445244";
    attribute INIT_26 of inst : label is "45C60332352544455446905445446003235254449404454544C7044545441304";
    attribute INIT_27 of inst : label is "3235244545CE032352445455203235244444597032352544554E033235244544";
    attribute INIT_28 of inst : label is "810445454424454455740544444525569054444452556004454454555255BB03";
    attribute INIT_29 of inst : label is "2444555A05444244455540544424445519045444244455060445454424454455";
    attribute INIT_2A of inst : label is "4445FF03235255444552544445F104454524544545F405544455255454905444";
    attribute INIT_2B of inst : label is "0DA220AA221F0C1F1C13EA1F1C1F0CFF40ABE88A008AA008FA008AA008EA0454";
    attribute INIT_2C of inst : label is "A72A24AC2E1D9F622AAC2F44E80AA72095CCD9F62640316192CF146F14F04A14";
    attribute INIT_2D of inst : label is "398CDADAAF4AE22B0202F94E82A1A24AC2F74FDCA728098092AB080AE88AE1EA";
    attribute INIT_2E of inst : label is "9D8566F18D92A4AA92FDC8B980BF62FDC7B980BF625AE82AFBF720D803EA393C";
    attribute INIT_2F of inst : label is "05B02E8E8D062EAEA6AE2E8E8D40FF26DC0BD85EA44660D8EDA0DDA4A1186DE0";
    attribute INIT_30 of inst : label is "10000000710000000006F9A2DC0E69E8A5BE8A4BA221A9FBF72FBF72F82F9F72";
    attribute INIT_31 of inst : label is "09809809809FFFFFFFFFAFFFAAAAAAAAAAACCCDDDCAE69DD2566245313232211";
    attribute INIT_32 of inst : label is "B980BFDC8B980BFDC8B980BFDC8B980BFDC8B980B68098098098098098098098";
    attribute INIT_33 of inst : label is "FFFF06FDC8B980BFDC8B980BFDC8B980BFDC8B980BFDC8B980BFDC8B980BFDC8";
    attribute INIT_34 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_35 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_36 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_37 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_38 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_39 of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_3A of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_3B of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_3C of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_3D of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_3E of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
    attribute INIT_3F of inst : label is "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
  begin
  inst : RAMB16_S4
      --pragma translate_off
      generic map (
        INIT_00 => romgen_str2bv(inst'INIT_00),
        INIT_01 => romgen_str2bv(inst'INIT_01),
        INIT_02 => romgen_str2bv(inst'INIT_02),
        INIT_03 => romgen_str2bv(inst'INIT_03),
        INIT_04 => romgen_str2bv(inst'INIT_04),
        INIT_05 => romgen_str2bv(inst'INIT_05),
        INIT_06 => romgen_str2bv(inst'INIT_06),
        INIT_07 => romgen_str2bv(inst'INIT_07),
        INIT_08 => romgen_str2bv(inst'INIT_08),
        INIT_09 => romgen_str2bv(inst'INIT_09),
        INIT_0A => romgen_str2bv(inst'INIT_0A),
        INIT_0B => romgen_str2bv(inst'INIT_0B),
        INIT_0C => romgen_str2bv(inst'INIT_0C),
        INIT_0D => romgen_str2bv(inst'INIT_0D),
        INIT_0E => romgen_str2bv(inst'INIT_0E),
        INIT_0F => romgen_str2bv(inst'INIT_0F),
        INIT_10 => romgen_str2bv(inst'INIT_10),
        INIT_11 => romgen_str2bv(inst'INIT_11),
        INIT_12 => romgen_str2bv(inst'INIT_12),
        INIT_13 => romgen_str2bv(inst'INIT_13),
        INIT_14 => romgen_str2bv(inst'INIT_14),
        INIT_15 => romgen_str2bv(inst'INIT_15),
        INIT_16 => romgen_str2bv(inst'INIT_16),
        INIT_17 => romgen_str2bv(inst'INIT_17),
        INIT_18 => romgen_str2bv(inst'INIT_18),
        INIT_19 => romgen_str2bv(inst'INIT_19),
        INIT_1A => romgen_str2bv(inst'INIT_1A),
        INIT_1B => romgen_str2bv(inst'INIT_1B),
        INIT_1C => romgen_str2bv(inst'INIT_1C),
        INIT_1D => romgen_str2bv(inst'INIT_1D),
        INIT_1E => romgen_str2bv(inst'INIT_1E),
        INIT_1F => romgen_str2bv(inst'INIT_1F),
        INIT_20 => romgen_str2bv(inst'INIT_20),
        INIT_21 => romgen_str2bv(inst'INIT_21),
        INIT_22 => romgen_str2bv(inst'INIT_22),
        INIT_23 => romgen_str2bv(inst'INIT_23),
        INIT_24 => romgen_str2bv(inst'INIT_24),
        INIT_25 => romgen_str2bv(inst'INIT_25),
        INIT_26 => romgen_str2bv(inst'INIT_26),
        INIT_27 => romgen_str2bv(inst'INIT_27),
        INIT_28 => romgen_str2bv(inst'INIT_28),
        INIT_29 => romgen_str2bv(inst'INIT_29),
        INIT_2A => romgen_str2bv(inst'INIT_2A),
        INIT_2B => romgen_str2bv(inst'INIT_2B),
        INIT_2C => romgen_str2bv(inst'INIT_2C),
        INIT_2D => romgen_str2bv(inst'INIT_2D),
        INIT_2E => romgen_str2bv(inst'INIT_2E),
        INIT_2F => romgen_str2bv(inst'INIT_2F),
        INIT_30 => romgen_str2bv(inst'INIT_30),
        INIT_31 => romgen_str2bv(inst'INIT_31),
        INIT_32 => romgen_str2bv(inst'INIT_32),
        INIT_33 => romgen_str2bv(inst'INIT_33),
        INIT_34 => romgen_str2bv(inst'INIT_34),
        INIT_35 => romgen_str2bv(inst'INIT_35),
        INIT_36 => romgen_str2bv(inst'INIT_36),
        INIT_37 => romgen_str2bv(inst'INIT_37),
        INIT_38 => romgen_str2bv(inst'INIT_38),
        INIT_39 => romgen_str2bv(inst'INIT_39),
        INIT_3A => romgen_str2bv(inst'INIT_3A),
        INIT_3B => romgen_str2bv(inst'INIT_3B),
        INIT_3C => romgen_str2bv(inst'INIT_3C),
        INIT_3D => romgen_str2bv(inst'INIT_3D),
        INIT_3E => romgen_str2bv(inst'INIT_3E),
        INIT_3F => romgen_str2bv(inst'INIT_3F)
        )
      --pragma translate_on
      port map (
        DO   => DATA(7 downto 4),
        ADDR => rom_addr,
        CLK  => CLK,
        DI   => "0000",
        EN   => '1',
        SSR  => '0',
        WE   => '0'
        );
  end generate;
end RTL;
