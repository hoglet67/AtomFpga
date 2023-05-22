--Copyright (C)2014-2023 Gowin Semiconductor Corporation.
--All rights reserved.
--File Title: IP file
--GOWIN Version: V1.9.9 Beta
--Part Number: GW1NR-LV9QN88PC6/I5
--Device: GW1NR-9
--Device Version: C
--Created Time: Wed May 10 18:21:02 2023

library IEEE;
use IEEE.std_logic_1164.all;

entity dpram_8k is
    port (
        douta: out std_logic_vector(7 downto 0);
        doutb: out std_logic_vector(7 downto 0);
        clka: in std_logic;
        ocea: in std_logic;
        cea: in std_logic;
        reseta: in std_logic;
        wrea: in std_logic;
        clkb: in std_logic;
        oceb: in std_logic;
        ceb: in std_logic;
        resetb: in std_logic;
        wreb: in std_logic;
        ada: in std_logic_vector(12 downto 0);
        dina: in std_logic_vector(7 downto 0);
        adb: in std_logic_vector(12 downto 0);
        dinb: in std_logic_vector(7 downto 0)
    );
end dpram_8k;

architecture Behavioral of dpram_8k is

    signal dpb_inst_0_douta_w: std_logic_vector(13 downto 0);
    signal dpb_inst_0_doutb_w: std_logic_vector(13 downto 0);
    signal dpb_inst_1_douta_w: std_logic_vector(13 downto 0);
    signal dpb_inst_1_doutb_w: std_logic_vector(13 downto 0);
    signal dpb_inst_2_douta_w: std_logic_vector(13 downto 0);
    signal dpb_inst_2_doutb_w: std_logic_vector(13 downto 0);
    signal dpb_inst_3_douta_w: std_logic_vector(13 downto 0);
    signal dpb_inst_3_doutb_w: std_logic_vector(13 downto 0);
    signal gw_gnd: std_logic;
    signal dpb_inst_0_BLKSELA_i: std_logic_vector(2 downto 0);
    signal dpb_inst_0_BLKSELB_i: std_logic_vector(2 downto 0);
    signal dpb_inst_0_ADA_i: std_logic_vector(13 downto 0);
    signal dpb_inst_0_DIA_i: std_logic_vector(15 downto 0);
    signal dpb_inst_0_ADB_i: std_logic_vector(13 downto 0);
    signal dpb_inst_0_DIB_i: std_logic_vector(15 downto 0);
    signal dpb_inst_0_DOA_o: std_logic_vector(15 downto 0);
    signal dpb_inst_0_DOB_o: std_logic_vector(15 downto 0);
    signal dpb_inst_1_BLKSELA_i: std_logic_vector(2 downto 0);
    signal dpb_inst_1_BLKSELB_i: std_logic_vector(2 downto 0);
    signal dpb_inst_1_ADA_i: std_logic_vector(13 downto 0);
    signal dpb_inst_1_DIA_i: std_logic_vector(15 downto 0);
    signal dpb_inst_1_ADB_i: std_logic_vector(13 downto 0);
    signal dpb_inst_1_DIB_i: std_logic_vector(15 downto 0);
    signal dpb_inst_1_DOA_o: std_logic_vector(15 downto 0);
    signal dpb_inst_1_DOB_o: std_logic_vector(15 downto 0);
    signal dpb_inst_2_BLKSELA_i: std_logic_vector(2 downto 0);
    signal dpb_inst_2_BLKSELB_i: std_logic_vector(2 downto 0);
    signal dpb_inst_2_ADA_i: std_logic_vector(13 downto 0);
    signal dpb_inst_2_DIA_i: std_logic_vector(15 downto 0);
    signal dpb_inst_2_ADB_i: std_logic_vector(13 downto 0);
    signal dpb_inst_2_DIB_i: std_logic_vector(15 downto 0);
    signal dpb_inst_2_DOA_o: std_logic_vector(15 downto 0);
    signal dpb_inst_2_DOB_o: std_logic_vector(15 downto 0);
    signal dpb_inst_3_BLKSELA_i: std_logic_vector(2 downto 0);
    signal dpb_inst_3_BLKSELB_i: std_logic_vector(2 downto 0);
    signal dpb_inst_3_ADA_i: std_logic_vector(13 downto 0);
    signal dpb_inst_3_DIA_i: std_logic_vector(15 downto 0);
    signal dpb_inst_3_ADB_i: std_logic_vector(13 downto 0);
    signal dpb_inst_3_DIB_i: std_logic_vector(15 downto 0);
    signal dpb_inst_3_DOA_o: std_logic_vector(15 downto 0);
    signal dpb_inst_3_DOB_o: std_logic_vector(15 downto 0);

    --component declaration
    component DPB
        generic (
            READ_MODE0: in bit := '0';
            READ_MODE1: in bit := '0';
            WRITE_MODE0: in bit_vector := "00";
            WRITE_MODE1: in bit_vector := "00";
            BIT_WIDTH_0: in integer :=16;
            BIT_WIDTH_1: in integer :=16;
            BLK_SEL_0: in bit_vector := "000";
            BLK_SEL_1: in bit_vector := "000";
            RESET_MODE: in string := "SYNC";
            INIT_RAM_00: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_01: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_02: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_03: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_04: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_05: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_06: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_07: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_08: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_09: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_0A: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_0B: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_0C: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_0D: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_0E: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_0F: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_10: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_11: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_12: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_13: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_14: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_15: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_16: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_17: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_18: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_19: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_1A: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_1B: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_1C: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_1D: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_1E: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_1F: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_20: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_21: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_22: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_23: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_24: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_25: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_26: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_27: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_28: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_29: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_2A: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_2B: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_2C: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_2D: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_2E: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_2F: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_30: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_31: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_32: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_33: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_34: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_35: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_36: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_37: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_38: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_39: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_3A: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_3B: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_3C: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_3D: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_3E: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
            INIT_RAM_3F: in bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
        );
        port (
            DOA: out std_logic_vector(15 downto 0);
            DOB: out std_logic_vector(15 downto 0);
            CLKA: in std_logic;
            OCEA: in std_logic;
            CEA: in std_logic;
            RESETA: in std_logic;
            WREA: in std_logic;
            CLKB: in std_logic;
            OCEB: in std_logic;
            CEB: in std_logic;
            RESETB: in std_logic;
            WREB: in std_logic;
            BLKSELA: in std_logic_vector(2 downto 0);
            BLKSELB: in std_logic_vector(2 downto 0);
            ADA: in std_logic_vector(13 downto 0);
            DIA: in std_logic_vector(15 downto 0);
            ADB: in std_logic_vector(13 downto 0);
            DIB: in std_logic_vector(15 downto 0)
        );
    end component;

begin
    gw_gnd <= '0';

    dpb_inst_0_BLKSELA_i <= gw_gnd & gw_gnd & gw_gnd;
    dpb_inst_0_BLKSELB_i <= gw_gnd & gw_gnd & gw_gnd;
    dpb_inst_0_ADA_i <= ada(12 downto 0) & gw_gnd;
    dpb_inst_0_DIA_i <= gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & dina(1 downto 0);
    dpb_inst_0_ADB_i <= adb(12 downto 0) & gw_gnd;
    dpb_inst_0_DIB_i <= gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & dinb(1 downto 0);
    douta(1 downto 0) <= dpb_inst_0_DOA_o(1 downto 0) ;
    dpb_inst_0_douta_w(13 downto 0) <= dpb_inst_0_DOA_o(15 downto 2) ;
    doutb(1 downto 0) <= dpb_inst_0_DOB_o(1 downto 0) ;
    dpb_inst_0_doutb_w(13 downto 0) <= dpb_inst_0_DOB_o(15 downto 2) ;
    dpb_inst_1_BLKSELA_i <= gw_gnd & gw_gnd & gw_gnd;
    dpb_inst_1_BLKSELB_i <= gw_gnd & gw_gnd & gw_gnd;
    dpb_inst_1_ADA_i <= ada(12 downto 0) & gw_gnd;
    dpb_inst_1_DIA_i <= gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & dina(3 downto 2);
    dpb_inst_1_ADB_i <= adb(12 downto 0) & gw_gnd;
    dpb_inst_1_DIB_i <= gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & dinb(3 downto 2);
    douta(3 downto 2) <= dpb_inst_1_DOA_o(1 downto 0) ;
    dpb_inst_1_douta_w(13 downto 0) <= dpb_inst_1_DOA_o(15 downto 2) ;
    doutb(3 downto 2) <= dpb_inst_1_DOB_o(1 downto 0) ;
    dpb_inst_1_doutb_w(13 downto 0) <= dpb_inst_1_DOB_o(15 downto 2) ;
    dpb_inst_2_BLKSELA_i <= gw_gnd & gw_gnd & gw_gnd;
    dpb_inst_2_BLKSELB_i <= gw_gnd & gw_gnd & gw_gnd;
    dpb_inst_2_ADA_i <= ada(12 downto 0) & gw_gnd;
    dpb_inst_2_DIA_i <= gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & dina(5 downto 4);
    dpb_inst_2_ADB_i <= adb(12 downto 0) & gw_gnd;
    dpb_inst_2_DIB_i <= gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & dinb(5 downto 4);
    douta(5 downto 4) <= dpb_inst_2_DOA_o(1 downto 0) ;
    dpb_inst_2_douta_w(13 downto 0) <= dpb_inst_2_DOA_o(15 downto 2) ;
    doutb(5 downto 4) <= dpb_inst_2_DOB_o(1 downto 0) ;
    dpb_inst_2_doutb_w(13 downto 0) <= dpb_inst_2_DOB_o(15 downto 2) ;
    dpb_inst_3_BLKSELA_i <= gw_gnd & gw_gnd & gw_gnd;
    dpb_inst_3_BLKSELB_i <= gw_gnd & gw_gnd & gw_gnd;
    dpb_inst_3_ADA_i <= ada(12 downto 0) & gw_gnd;
    dpb_inst_3_DIA_i <= gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & dina(7 downto 6);
    dpb_inst_3_ADB_i <= adb(12 downto 0) & gw_gnd;
    dpb_inst_3_DIB_i <= gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & gw_gnd & dinb(7 downto 6);
    douta(7 downto 6) <= dpb_inst_3_DOA_o(1 downto 0) ;
    dpb_inst_3_douta_w(13 downto 0) <= dpb_inst_3_DOA_o(15 downto 2) ;
    doutb(7 downto 6) <= dpb_inst_3_DOB_o(1 downto 0) ;
    dpb_inst_3_doutb_w(13 downto 0) <= dpb_inst_3_DOB_o(15 downto 2) ;

    dpb_inst_0: DPB
        generic map (
            READ_MODE0 => '0',
            READ_MODE1 => '0',
            WRITE_MODE0 => "10",
            WRITE_MODE1 => "10",
            BIT_WIDTH_0 => 2,
            BIT_WIDTH_1 => 2,
            RESET_MODE => "SYNC",
            BLK_SEL_0 => "000",
            BLK_SEL_1 => "000",
            -- Fill the first 0.5K with random characters for that authentic boot
            INIT_RAM_00 => X"71A67176F399C38EB2010AAA9C270247E1CAEA583EED4191DFB1A23E725BCC21",
            INIT_RAM_01 => X"AADCE81412C1FE921BD77DA370960F49FF1C403619894EC0673427997059B67E",
            INIT_RAM_02 => X"B21AC9905D532DE18BA68828BE0936D05E2BFA85031976A9E3B40E98134736A3",
            INIT_RAM_03 => X"DAE48D468711BA74B01239099DF421A9CC83560B5B9C741FFC83006ED8638C60"
        )
        port map (
            DOA => dpb_inst_0_DOA_o,
            DOB => dpb_inst_0_DOB_o,
            CLKA => clka,
            OCEA => ocea,
            CEA => cea,
            RESETA => reseta,
            WREA => wrea,
            CLKB => clkb,
            OCEB => oceb,
            CEB => ceb,
            RESETB => resetb,
            WREB => wreb,
            BLKSELA => dpb_inst_0_BLKSELA_i,
            BLKSELB => dpb_inst_0_BLKSELB_i,
            ADA => dpb_inst_0_ADA_i,
            DIA => dpb_inst_0_DIA_i,
            ADB => dpb_inst_0_ADB_i,
            DIB => dpb_inst_0_DIB_i
        );

    dpb_inst_1: DPB
        generic map (
            READ_MODE0 => '0',
            READ_MODE1 => '0',
            WRITE_MODE0 => "10",
            WRITE_MODE1 => "10",
            BIT_WIDTH_0 => 2,
            BIT_WIDTH_1 => 2,
            RESET_MODE => "SYNC",
            BLK_SEL_0 => "000",
            BLK_SEL_1 => "000",
            INIT_RAM_00 => X"F1D56D803991F22E7FA097479B0186D2A50497DA7C2338B6D809EA453BF914C2",
            INIT_RAM_01 => X"685010F64ACC3D03CD1C1F32C6B57DC5B5AD350917273377C86F00135312166D",
            INIT_RAM_02 => X"B97BE350F8183C4DD325E3548B451B4ECE906D647A1FE0D945320A46621637ED",
            INIT_RAM_03 => X"8F542DAE676E6A3E0D329DACDE974357DFDB8EB0587F194BCB91530E27AE2CE7"
        )
        port map (
            DOA => dpb_inst_1_DOA_o,
            DOB => dpb_inst_1_DOB_o,
            CLKA => clka,
            OCEA => ocea,
            CEA => cea,
            RESETA => reseta,
            WREA => wrea,
            CLKB => clkb,
            OCEB => oceb,
            CEB => ceb,
            RESETB => resetb,
            WREB => wreb,
            BLKSELA => dpb_inst_1_BLKSELA_i,
            BLKSELB => dpb_inst_1_BLKSELB_i,
            ADA => dpb_inst_1_ADA_i,
            DIA => dpb_inst_1_DIA_i,
            ADB => dpb_inst_1_ADB_i,
            DIB => dpb_inst_1_DIB_i
        );

    dpb_inst_2: DPB
        generic map (
            READ_MODE0 => '0',
            READ_MODE1 => '0',
            WRITE_MODE0 => "10",
            WRITE_MODE1 => "10",
            BIT_WIDTH_0 => 2,
            BIT_WIDTH_1 => 2,
            RESET_MODE => "SYNC",
            BLK_SEL_0 => "000",
            BLK_SEL_1 => "000",
            INIT_RAM_00 => X"536980567CF48A15EA978087ED6FAC2427F75F5FB0D631900239E00181BAFED5",
            INIT_RAM_01 => X"15708DA1FA5F1AF602C1256F9EE61E674942CF32F83FDEC9870A7D2B2BC56A39",
            INIT_RAM_02 => X"C50928AF76CE148778EA3A3209BCE12E4E066BDB1D062C7EBB7C4ECC075A61F1",
            INIT_RAM_03 => X"ECE74FC134655D0F92C7055D9E188870245D9019AAF8AFE1264D2C92E6C05562"
        )
        port map (
            DOA => dpb_inst_2_DOA_o,
            DOB => dpb_inst_2_DOB_o,
            CLKA => clka,
            OCEA => ocea,
            CEA => cea,
            RESETA => reseta,
            WREA => wrea,
            CLKB => clkb,
            OCEB => oceb,
            CEB => ceb,
            RESETB => resetb,
            WREB => wreb,
            BLKSELA => dpb_inst_2_BLKSELA_i,
            BLKSELB => dpb_inst_2_BLKSELB_i,
            ADA => dpb_inst_2_ADA_i,
            DIA => dpb_inst_2_DIA_i,
            ADB => dpb_inst_2_ADB_i,
            DIB => dpb_inst_2_DIB_i
        );

    dpb_inst_3: DPB
        generic map (
            READ_MODE0 => '0',
            READ_MODE1 => '0',
            WRITE_MODE0 => "10",
            WRITE_MODE1 => "10",
            BIT_WIDTH_0 => 2,
            BIT_WIDTH_1 => 2,
            RESET_MODE => "SYNC",
            BLK_SEL_0 => "000",
            BLK_SEL_1 => "000",
            INIT_RAM_00 => X"8A803B49690CE8CA09F45F0D5A384177E530EA610382A359601BF72ACDC1628C",
            INIT_RAM_01 => X"E2A4B56CEED7B6FA28516ECB11322B718C797ADAB0BC529BA06BCE4E7B084950",
            INIT_RAM_02 => X"C9EEC0B8D42DDC247E74FED1B760A10D730BD9A533348CC947F60BD161A8E097",
            INIT_RAM_03 => X"2F2CDC2236C8A5743008CDC466D8B1D8103D30F342A71B379365B0504C1D9F68"
        )
        port map (
            DOA => dpb_inst_3_DOA_o,
            DOB => dpb_inst_3_DOB_o,
            CLKA => clka,
            OCEA => ocea,
            CEA => cea,
            RESETA => reseta,
            WREA => wrea,
            CLKB => clkb,
            OCEB => oceb,
            CEB => ceb,
            RESETB => resetb,
            WREB => wreb,
            BLKSELA => dpb_inst_3_BLKSELA_i,
            BLKSELB => dpb_inst_3_BLKSELB_i,
            ADA => dpb_inst_3_ADA_i,
            DIA => dpb_inst_3_DIA_i,
            ADB => dpb_inst_3_ADB_i,
            DIB => dpb_inst_3_DIB_i
        );

end Behavioral; --dpram_8k
