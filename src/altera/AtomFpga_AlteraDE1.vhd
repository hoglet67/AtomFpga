-- Acorn Atom FPGA for the Altera/Terasic DE1
--
-- Copright (c) 2016 David Banks
--
-- Based on previous work by Alan Daly
--
-- Copyright (c) 2013 Alan Daly
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice,
--   this list of conditions and the following disclaimer.
--
-- * Redistributions in synthesized form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
--
-- * Neither the name of the author nor the names of other contributors may
--   be used to endorse or promote products derived from this software without
--   specific prior written agreement from the author.
--
-- * License is granted for non-commercial use only.  A fee may not be charged
--   for redistributions as source code or in synthesized/hardware form without
--   specific prior written agreement from the author.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Altera/Terasic DE1 top-level
--
-- (c) 2016 David Banks
-- (C) 2013 Alan Daly

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Generic top-level entity for Altera DE1 board
entity AtomFpga_AlteraDE1 is
port (
    -- Clocks
    CLOCK_24_0  :   in  std_logic;
    CLOCK_24_1  :   in  std_logic;
    CLOCK_27_0  :   in  std_logic;
    CLOCK_27_1  :   in  std_logic;
    CLOCK_50    :   in  std_logic;
    EXT_CLOCK   :   in  std_logic;

    -- Switches
    SW          :   in  std_logic_vector(9 downto 0);
    -- Buttons
    KEY         :   in  std_logic_vector(3 downto 0);

    -- 7 segment displays
    HEX0        :   out std_logic_vector(6 downto 0);
    HEX1        :   out std_logic_vector(6 downto 0);
    HEX2        :   out std_logic_vector(6 downto 0);
    HEX3        :   out std_logic_vector(6 downto 0);
    -- Red LEDs
    LEDR        :   out std_logic_vector(9 downto 0);
    -- Green LEDs
    LEDG        :   out std_logic_vector(7 downto 0);

    -- VGA
    VGA_R       :   out std_logic_vector(3 downto 0);
    VGA_G       :   out std_logic_vector(3 downto 0);
    VGA_B       :   out std_logic_vector(3 downto 0);
    VGA_HS      :   out std_logic;
    VGA_VS      :   out std_logic;

    -- Serial
    UART_RXD    :   in  std_logic;
    UART_TXD    :   out std_logic;

    -- PS/2 Keyboard
    PS2_CLK     :   in  std_logic;
    PS2_DAT     :   in  std_logic;

    -- I2C
    I2C_SCLK    :   inout   std_logic;
    I2C_SDAT    :   inout   std_logic;

    -- Audio
    AUD_XCK     :   out     std_logic;
    AUD_BCLK    :   out     std_logic;
    AUD_ADCLRCK :   out     std_logic;
    AUD_ADCDAT  :   in      std_logic;
    AUD_DACLRCK :   out     std_logic;
    AUD_DACDAT  :   out     std_logic;

    -- SRAM
    SRAM_ADDR   :   out     std_logic_vector(17 downto 0);
    SRAM_DQ     :   inout   std_logic_vector(15 downto 0);
    SRAM_CE_N   :   out     std_logic;
    SRAM_OE_N   :   out     std_logic;
    SRAM_WE_N   :   out     std_logic;
    SRAM_UB_N   :   out     std_logic;
    SRAM_LB_N   :   out     std_logic;

    -- SDRAM
    DRAM_ADDR   :   out     std_logic_vector(11 downto 0);
    DRAM_DQ     :   inout   std_logic_vector(15 downto 0);
    DRAM_BA_0   :   in      std_logic;
    DRAM_BA_1   :   in      std_logic;
    DRAM_CAS_N  :   in      std_logic;
    DRAM_CKE    :   in      std_logic;
    DRAM_CLK    :   in      std_logic;
    DRAM_CS_N   :   in      std_logic;
    DRAM_LDQM   :   in      std_logic;
    DRAM_RAS_N  :   in      std_logic;
    DRAM_UDQM   :   in      std_logic;
    DRAM_WE_N   :   in      std_logic;

    -- Flash
    FL_ADDR     :   out     std_logic_vector(21 downto 0);
    FL_DQ       :   in      std_logic_vector(7 downto 0);
    FL_RST_N    :   out     std_logic;
    FL_OE_N     :   out     std_logic;
    FL_WE_N     :   out     std_logic;
    FL_CE_N     :   out     std_logic;

    -- SD card (SPI mode)
    SD_nCS      :   out     std_logic;
    SD_MOSI     :   out     std_logic;
    SD_SCLK     :   out     std_logic;
    SD_MISO     :   in      std_logic;

    -- GPIO
    GPIO_0      :   inout   std_logic_vector(35 downto 0);
    GPIO_1      :   inout   std_logic_vector(35 downto 0)
    );
end entity;

architecture rtl of AtomFpga_AlteraDE1 is

-------------
-- Signals
-------------

signal clock_16        : std_logic;
signal clock_25        : std_logic;
signal clock_32        : std_logic;

signal led1            : std_logic;
signal led2            : std_logic;

signal Phi2            : std_logic;

signal uart_Rx         : std_logic;
signal uart_Tx         : std_logic;
signal avr_Tx          : std_logic;

signal ExternCE        : std_logic;
signal ExternWE        : std_logic;
signal ExternA         : std_logic_vector (18 downto 0);
signal ExternDin       : std_logic_vector (7 downto 0);
signal ExternDout      : std_logic_vector (7 downto 0);

-- A registered version to allow slow flash to be used
signal ExternA_r       : std_logic_vector (18 downto 0);

signal atom_audio      : std_logic;
signal sid_audio       : std_logic_vector(17 downto 0);
signal audio_l         : std_logic_vector(15 downto 0);
signal audio_r         : std_logic_vector(15 downto 0);
signal powerup_reset_n : std_logic;
signal hard_reset_n    : std_logic;
signal reset_counter   : std_logic_vector(15 downto 0);

signal pll_reset       : std_logic;
signal pll_1_locked    : std_logic;
signal pll_2_locked    : std_logic;

signal is_done         : std_logic;
signal is_error        : std_logic;

function hex_to_seven_seg(hex: std_logic_vector(3 downto 0))
        return std_logic_vector
    is begin
        case hex is
            --                   abcdefg
            when x"0" => return "0111111";
            when x"1" => return "0000110";
            when x"2" => return "1011011";
            when x"3" => return "1001111";
            when x"4" => return "1100110";
            when x"5" => return "1101101";
            when x"6" => return "1111101";
            when x"7" => return "0000111";
            when x"8" => return "1111111";
            when x"9" => return "1101111";
            when x"a" => return "1110111";
            when x"b" => return "1111100";
            when x"c" => return "0111001";
            when x"d" => return "1011110";
            when x"e" => return "1111001";
            when x"f" => return "1110001";
            when others => return "0000000";
        end case;
    end;

begin

--------------------------------------------------------
-- Atom FPGA Core
--------------------------------------------------------

    inst_AtomFpga_Core : entity work.AtomFpga_Core
    generic map (
        CImplSDDOS              => true,
        CImplAtoMMC2            => false,
        CImplGraphicsExt        => true,
        CImplSoftChar           => true,
        CImplSID                => true,
        CImplVGA80x40           => true,
        CImplHWScrolling        => true,
        CImplMouse              => true,
        CImplUart               => true,
        CImplDoubleVideo        => false,
        CImplRamRomNone         => false,
        CImplRamRomPhill        => false,
        CImplRamRomAtom2015     => false,
        CImplRamRomSchakelKaart => true,
        MainClockSpeed          => 16000000,
        DefaultBaud             => 115200
     )
     port map(
        clk_vga             => clock_25,
        clk_main            => clock_16,
        clk_avr             => clock_16,
        clk_dac             => clock_32,
        clk_32M00           => clock_32,
        ps2_clk             => PS2_CLK,
        ps2_data            => PS2_DAT,
        ps2_mouse_clk       => GPIO_1(18),
        ps2_mouse_data      => GPIO_1(19),
        ERSTn               => hard_reset_n,
        IRSTn               => open,
        red                 => VGA_R(3 downto 1),
        green               => VGA_G(3 downto 1),
        blue                => VGA_B(3 downto 1),
        vsync               => VGA_VS,
        hsync               => VGA_HS,
        Phi2                => Phi2,
        ExternCE            => ExternCE,
        ExternWE            => ExternWE,
        ExternA             => ExternA,
        ExternDin           => ExternDin,
        ExternDout          => ExternDout,
        sid_audio           => open,
        sid_audio_d         => sid_audio,
        atom_audio          => atom_audio,
        SDMISO              => SD_MISO,
        SDSS                => SD_nCS,
        SDCLK               => SD_SCLK,
        SDMOSI              => SD_MOSI,
        uart_RxD            => uart_Rx,
        uart_TxD            => uart_Tx,
        avr_RxD             => '1',
        avr_TxD             => avr_Tx,
        LED1                => led1,
        LED2                => led2,
        charSet             => SW(0)
        );

    uart_Rx <= UART_RXD;
    -- Idle state is high, logically OR the active low signals
    UART_TXD <= uart_Tx and avr_Tx;

--------------------------------------------------------
-- Clock Generation
--------------------------------------------------------

    -- 16 MHz master clock and 32MHz SID clock from 24MHz input clock
    pll_1: entity work.pll32
        port map (
            areset         => pll_reset,
            inclk0         => CLOCK_24_0,
            c0             => clock_16,
            c1             => clock_32,
            locked         => pll_1_locked
        );


    -- 25 MHz VGA clock from 50MHz input clock
    pll_2: entity work.pll25
        port map (
            areset         => pll_reset,
            inclk0         => CLOCK_50,
            c0             => clock_25,
            locked         => pll_2_locked
        );

--------------------------------------------------------
-- Power Up Reset Generation
--------------------------------------------------------

    -- PLL is reset by external reset switch
    pll_reset <= not KEY(0);

    -- Generate a reliable power up reset
    reset_gen : process(clock_16)
    begin
        if rising_edge(clock_16) then
            if (reset_counter(reset_counter'high) = '0') then
                reset_counter <= reset_counter + 1;
            end if;
            powerup_reset_n <= reset_counter(reset_counter'high);
        end if;
    end process;

    hard_reset_n <= not (pll_reset or not pll_1_locked or not pll_2_locked or not powerup_reset_n);

--------------------------------------------------------
-- Audio DACs
--------------------------------------------------------

    -- This version assumes only one source is playing at once
    process(atom_audio, sid_audio)
        variable l : std_logic_vector(15 downto 0);
        variable r : std_logic_vector(15 downto 0);
    begin
        -- Atom Audio is a single bit
        if (atom_audio = '1') then
            l := x"1000";
            r := x"1000";
        else
            l := x"EFFF";
            r := x"EFFF";
        end if;
        -- SID output is 18-bit unsigned
        l := l + (sid_audio(17 downto 2) - x"8000");
        r := r + (sid_audio(17 downto 2) - x"8000");
        audio_l <= l;
        audio_r <= r;
    end process;

    i2s : entity work.i2s_intf
        port map (
            CLK         => clock_32,
            nRESET      => hard_reset_n,
            PCM_INL     => open,
            PCM_INR     => open,
            PCM_OUTL    => audio_l,
            PCM_OUTR    => audio_r,
            I2S_MCLK    => AUD_XCK,
            I2S_LRCLK   => AUD_DACLRCK,
            I2S_BCLK    => AUD_BCLK,
            I2S_DOUT    => AUD_DACDAT,
            I2S_DIN     => AUD_ADCDAT
            );

    -- This is to avoid a possible conflict if the codec is in master mode
    AUD_ADCLRCK <= 'Z';

    i2c : entity work.i2c_loader
        generic map (
            log2_divider => 7
            )
        port map (
            CLK         => clock_32,
            nRESET      => hard_reset_n,
            I2C_SCL     => I2C_SCLK,
            I2C_SDA     => I2C_SDAT,
            IS_DONE     => is_done,
            IS_ERROR    => is_error
            );

--------------------------------------------------------
-- Map external memory bus to SRAM/FLASH
--------------------------------------------------------

    -- Hold the ExternA for multiple clock cycles to allow slow FLASH to be used
    -- This is necessary because currently FLASH and SRAM accesses are
    -- interleaved every cycle.
    process(clock_16)
    begin
        if rising_edge(clock_16) then
            if ExternA(17) = '0' then
                ExternA_r <= ExternA;
            end if;
        end if;
    end process;

    -- 0x00000-0x1FFFF -> FLASH
    -- 0x20000-0x3FFFF -> SRAM
    ExternDout <= SRAM_DQ(7 downto 0) when ExternA(17) = '1' else FL_DQ;

    FL_RST_N <= hard_reset_n;
    FL_CE_N <= '0';
    FL_OE_N <= '0';
    FL_WE_N <= '1';
    -- Flash address change every at most every 16 cycles (2MHz)
    -- Use the latched version to maximise access time
	 -- Start at address at 0x100000

    FL_ADDR <= "010000" & ExternA_r(15 downto 0);

    -- SRAM bus
    SRAM_UB_N <= '1';
    SRAM_LB_N <= '0';
    SRAM_CE_N <= '0';
    SRAM_OE_N <= (not ExternCE) or ExternWE;

    -- Gate the WE with clock to provide more address/data hold time
    SRAM_WE_N <= (not ExternCE) or (not ExternWE) or (not Phi2) or (not clock_16);

    SRAM_ADDR <= ExternA(17 downto 0);
    SRAM_DQ(15 downto 8) <= (others => 'Z');
    SRAM_DQ(7 downto 0) <= ExternDin when ExternCE = '1' and ExternWE = '1' and Phi2 = '1' else (others => 'Z');

    -- HEX Displays (active low)
    HEX3 <= hex_to_seven_seg(ExternA(15 downto 12)) xor "1111111";
    HEX2 <= hex_to_seven_seg(ExternA(11 downto  8)) xor "1111111";
    HEX1 <= hex_to_seven_seg(ExternA( 7 downto  4)) xor "1111111";
    HEX0 <= hex_to_seven_seg(ExternA( 3 downto  0)) xor "1111111";

    -- LEDs (active high)
    LEDG(0) <= pll_1_locked;
    LEDG(1) <= pll_2_locked;
    LEDG(7 downto 2) <= (others => '0');
    LEDR(0) <= led1;
    LEDR(1) <= led2;
    LEDR(2) <= is_error;
    LEDR(3) <= not is_done;
    LEDR(9 downto 4) <= (others => '0');

    -- Unused outputs
    DRAM_ADDR <= (others => 'Z');
    DRAM_DQ <= (others => 'Z');
    GPIO_0(35 downto 0) <= (others => 'Z');
    GPIO_1(35 downto 20) <= (others => 'Z');
    GPIO_1(17 downto 0) <= (others => 'Z');

end architecture;
