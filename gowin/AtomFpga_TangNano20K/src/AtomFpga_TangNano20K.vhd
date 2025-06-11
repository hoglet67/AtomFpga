-- Atom FPGA for the Tang Nano 20K
--
-- Copright (c) 2025 David Banks
-- Copright (c) 2025 Dominic Beesley
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.board_config_pack.all;

-- This is generated dynamically using tclPre
library work;
use work.version_config_pack.all;

-- TODO:
--   Add CImplTrace support
--   32MHz core to allow 8MHz operation (?)
--   Configuration jumpers
--   Other Atom2K18 features (?) SAM/PAM/Palette/RTC/LEDs/Profiling

entity AtomFpga_TangNano20K is
    generic (
        CImplCpu65c02      : boolean := false;
        CImplDebugger      : boolean := G_CONFIG_DEBUGGER;
        CImplDVI           : boolean := false;
        CImplHDMI          : boolean := true;
        CImplSDDOS         : boolean := false;
        CImplAtoMMC2       : boolean := true;
        CImplSID           : boolean := true;
        CImplBootstrap     : boolean := true;
        CImplMonitor       : boolean := true;
        CImplVGA           : boolean := false;
        CImplVGADAC        : boolean := G_CONFIG_VGA;         -- Allows 4 bit R/G/B when we add the palette
        CImplCoProExt      : boolean := not G_CONFIG_VGA;
        CImplI2SAudio      : boolean := true;
        CImplSPDIFAudio    : boolean := true;
        DefaultTurbo       : std_logic_vector(1 downto 0) := "00";
        ResetCounterSize   : integer := 20;
        PRJ_ROOT           : string  := "../../..";
        MOS_NAME           : string  := "/roms/16K_avr.bit";
        SIM                : boolean := false
    );
    port (
        sys_clk         : in    std_logic;     -- 27MHz clock from the oscillator (pin 4)
                                               -- or from the SI5351 CLK0 (pin 10)

        audio_clk       : in    std_logic;     -- 24.576MHz audio clock from the SI5351 CLK1 (pin 11)

        btn1            : in    std_logic;     -- Powerup reset
        btn2            : in    std_logic;     -- Toggle HDMI / DVI modes
        led             : out   std_logic_vector (5 downto 0);
        ws2812_din      : out   std_logic;
        key_conf        : in    std_logic;

        -- Keyboard / Mouse
        ps2_clk         : inout std_logic;
        ps2_data        : inout std_logic;
        ps2_mouse_clk   : inout std_logic;
        ps2_mouse_data  : inout std_logic;

        -- Joystick
        js_clk          : out   std_logic;     -- this is actually just phi2 to save a pin
        js_load_n       : out   std_logic;
        js_data         : in    std_logic;

        -- SD Card
        tf_miso         : in    std_logic;
        tf_cs           : out   std_logic;
        tf_sclk         : out   std_logic;
        tf_mosi         : out   std_logic;

        -- USB UART
        uart_rx         : in    std_logic;
        uart_tx         : out   std_logic;

        -- HDMI
        tmds_clk_p      : out   std_logic;
        tmds_clk_n      : out   std_logic;
        tmds_d_p        : out   std_logic_vector(2 downto 0);
        tmds_d_n        : out   std_logic_vector(2 downto 0);

        -- VGA
        vga_r           : inout std_logic;
        vga_r_n         : inout std_logic;
        vga_g           : inout std_logic;
        vga_g_n         : inout std_logic;
        vga_b           : inout std_logic;
        vga_b_n         : inout std_logic;
        vga_hs          : inout std_logic;
        vga_vs          : inout std_logic;

        -- I2S Audio
        i2s_mclk        : out   std_logic;
        i2s_bclk        : out   std_logic;
        i2s_lrclk       : out   std_logic;
        i2s_din         : out   std_logic;
        pa_en           : in    std_logic;

        -- 1-bit DAC Audio
        audiol          : out   std_logic;
        audior          : out   std_logic;

        -- SPDIF Audio
        audio_spdif     : out   std_logic;

        -- Magic ports for SDRAM to be inferred
        O_sdram_clk     : out   std_logic;
        O_sdram_cke     : out   std_logic;
        O_sdram_cs_n    : out   std_logic;
        O_sdram_cas_n   : out   std_logic;
        O_sdram_ras_n   : out   std_logic;
        O_sdram_wen_n   : out   std_logic;
        IO_sdram_dq     : inout std_logic_vector(31 downto 0);
        O_sdram_addr    : out   std_logic_vector(10 downto 0);
        O_sdram_ba      : out   std_logic_vector(1 downto 0);
        O_sdram_dqm     : out   std_logic_vector(3 downto 0);

        -- SPI Flash (for ROM data)
        flash_cs        : out   std_logic;     -- Active low FLASH chip select
        flash_si        : out   std_logic;     -- Serial output to FLASH chip SI pin
        flash_ck        : out   std_logic;     -- FLASH clock
        flash_so        : in    std_logic      -- Serial input from FLASH chip SO pin
        );
end entity;

architecture rtl of AtomFpga_TangNano20K is

    --------------------------------------------------------
    -- FPGA Primitive Components
    --------------------------------------------------------

    component rPLL
        generic (
            FCLKIN: in string := "100.0";
            DEVICE: in string := "GW1N-4";
            DYN_IDIV_SEL: in string := "false";
            IDIV_SEL: in integer := 0;
            DYN_FBDIV_SEL: in string := "false";
            FBDIV_SEL: in integer := 0;
            DYN_ODIV_SEL: in string := "false";
            ODIV_SEL: in integer := 8;
            PSDA_SEL: in string := "0000";
            DYN_DA_EN: in string := "false";
            DUTYDA_SEL: in string := "1000";
            CLKOUT_FT_DIR: in bit := '1';
            CLKOUTP_FT_DIR: in bit := '1';
            CLKOUT_DLY_STEP: in integer := 0;
            CLKOUTP_DLY_STEP: in integer := 0;
            CLKOUTD3_SRC: in string := "CLKOUT";
            CLKFB_SEL: in string := "internal";
            CLKOUT_BYPASS: in string := "false";
            CLKOUTP_BYPASS: in string := "false";
            CLKOUTD_BYPASS: in string := "false";
            CLKOUTD_SRC: in string := "CLKOUT";
            DYN_SDIV_SEL: in integer := 2
        );
        port (
            CLKOUT: out std_logic;
            LOCK: out std_logic;
            CLKOUTP: out std_logic;
            CLKOUTD: out std_logic;
            CLKOUTD3: out std_logic;
            RESET: in std_logic;
            RESET_P: in std_logic;
            CLKIN: in std_logic;
            CLKFB: in std_logic;
            FBDSEL: in std_logic_vector(5 downto 0);
            IDSEL: in std_logic_vector(5 downto 0);
            ODSEL: in std_logic_vector(5 downto 0);
            PSDA: in std_logic_vector(3 downto 0);
            DUTYDA: in std_logic_vector(3 downto 0);
            FDLY: in std_logic_vector(3 downto 0)
        );
    end component;

    component CLKDIV
        generic (
            DIV_MODE : string := "2";
            GSREN: in string := "false"
        );
        port (
            CLKOUT: out std_logic;
            HCLKIN: in std_logic;
            RESETN: in std_logic;
            CALIB: in std_logic
        );
    end component;

    component OSER10
        generic (
            GSREN : string := "false";
            LSREN : string := "true"
        );
        port (
            Q : out std_logic;
            D0 : in std_logic;
            D1 : in std_logic;
            D2 : in std_logic;
            D3 : in std_logic;
            D4 : in std_logic;
            D5 : in std_logic;
            D6 : in std_logic;
            D7 : in std_logic;
            D8 : in std_logic;
            D9 : in std_logic;
            FCLK : in std_logic;
            PCLK : in std_logic;
            RESET : in std_logic
        );
    end component;

    component ELVDS_OBUF
        port (
            I : in std_logic;
            O : out std_logic;
            OB : out std_logic
        );
    end component;

    component ws2812
        port (
            clk : in std_logic;
            color : in std_logic_vector(23 downto 0);
            data : out std_logic
        );
    end component;

    --------------------------------------------------------
    -- Functions
    --------------------------------------------------------

    --------------------------------------------------------
    -- Version ROM
    --------------------------------------------------------

    type version_rom_type is array(0 to 31) of unsigned(7 downto 0);

    function init_version_rom return version_rom_type is
        variable tmp : version_rom_type;
        variable nibble : unsigned(3 downto 0);
        variable i : integer;
    begin
        -- Git version
        for i in 0 to 7 loop
            nibble := unsigned(G_CONFIG_VERSION(i * 4 + 3 downto i * 4));
            if nibble < 10 then
                tmp(7 - i) := to_unsigned(character'pos('0'), 8) + nibble;
            else
                tmp(7 - i) := to_unsigned(character'pos('A'), 8) + nibble - 10;
            end if;
        end loop;
        -- Git dirty flag
        i := 8;
        if G_CONFIG_DIRTY then
            tmp(i) := to_unsigned(character'pos('?'), 8);
            i := i + 1;
        end if;
        tmp(i) := to_unsigned(character'pos(' '), 8);
        -- VGA vs PiTube
        if G_CONFIG_VGA then
            tmp(i+1) := to_unsigned(character'pos('V'), 8);
            tmp(i+2) := to_unsigned(character'pos('G'), 8);
            tmp(i+3) := to_unsigned(character'pos('A'), 8);
            i := i + 4;
        else
            tmp(i+1) := to_unsigned(character'pos('P'), 8);
            tmp(i+2) := to_unsigned(character'pos('I'), 8);
            tmp(i+3) := to_unsigned(character'pos('T'), 8);
            tmp(i+4) := to_unsigned(character'pos('U'), 8);
            tmp(i+5) := to_unsigned(character'pos('B'), 8);
            tmp(i+6) := to_unsigned(character'pos('E'), 8);
            i := i + 7;
        end if;
        tmp(i) := to_unsigned(character'pos(' '), 8);
        -- NoDebugger vs Debugger
        if not G_CONFIG_DEBUGGER then
            tmp(i+1) := to_unsigned(character'pos('N'), 8);
            tmp(i+2) := to_unsigned(character'pos('O'), 8);
            i := i + 2;
        end if;
        tmp(i+1) := to_unsigned(character'pos('D'), 8);
        tmp(i+2) := to_unsigned(character'pos('E'), 8);
        tmp(i+3) := to_unsigned(character'pos('B'), 8);
        tmp(i+4) := to_unsigned(character'pos('U'), 8);
        tmp(i+5) := to_unsigned(character'pos('G'), 8);
        tmp(i+6) := to_unsigned(character'pos('G'), 8);
        tmp(i+7) := to_unsigned(character'pos('E'), 8);
        tmp(i+8) := to_unsigned(character'pos('R'), 8);
        tmp(i+9) := x"0D";
        i := i + 10;
        while (i < 32) loop
            tmp(i) := x"00";
            i := i + 1;
        end loop;
        return tmp;
    end function;

    signal version_rom : version_rom_type := init_version_rom;
    signal version_rom_byte : std_logic_vector(7 downto 0);

    --------------------------------------------------------
    -- Signals
    --------------------------------------------------------

    signal clock_main      : std_logic; --  16.0 MHz
    signal clock_vga       : std_logic; --  25.2 MHz
    signal clock_hdmi      : std_logic; -- 126.0 MHz
    signal clock_vgadac5   : std_logic; -- 378.0 MHz
    signal clock_vgadac1   : std_logic; --  75.6 MHz
    signal clock_sid       : std_logic; --  32.0 MHz
    signal clock_sdram     : std_logic; --  96.0 MHz
    signal clock_sdram_p   : std_logic; --  96.0 MHz witha 180 degree phase shift
    signal clock_icet65    : std_logic; --  24.0 MHz
    signal spdif_clk       : std_logic; --   6.144MHz SPDIF clock

    signal ext_reset_n     : std_logic;
    signal reset_counter   : std_logic_vector(ResetCounterSize - 1 downto 0) := (others => '0'); -- 32ms
    signal powerup_reset_n : std_logic := '0';
    signal hard_reset_n    : std_logic;
    signal reset_n         : std_logic;
    signal led1            : std_logic;
    signal led2            : std_logic;

    -- Signals used for HDMI video from the core
    signal hdmi_audio_en   : std_logic;
    signal hdmi_tmds_r     : std_logic_vector(9 downto 0);
    signal hdmi_tmds_g     : std_logic_vector(9 downto 0);
    signal hdmi_tmds_b     : std_logic_vector(9 downto 0);

    -- Signals used for DVI video from this module
    signal dvi_tmds_r     : std_logic_vector(9 downto 0);
    signal dvi_tmds_g     : std_logic_vector(9 downto 0);
    signal dvi_tmds_b     : std_logic_vector(9 downto 0);

    -- Signals used for VGA video from the core
    signal red             : std_logic_vector(2 downto 0);
    signal green           : std_logic_vector(2 downto 0);
    signal blue            : std_logic_vector(2 downto 0);
    signal vsync           : std_logic;
    signal hsync           : std_logic;
    signal blank           : std_logic;

    -- Signals for audio
    signal sid_audio       : std_logic;
    signal atom_audio      : std_logic;
    signal audio           : signed(15 downto 0);

    -- Signals used by the external bus interface (i.e. RAM and ROM)
    signal ExternBUS       : std_logic;
    signal ExternCE        : std_logic;
    signal ExternWE        : std_logic;
    signal ExternA         : std_logic_vector (18 downto 0);
    signal ExternDin       : std_logic_vector (7 downto 0);
    signal ExternDout      : std_logic_vector (7 downto 0);
    signal SDRAMDout       : std_logic_vector (7 downto 0);

    -- Signals used for the external Co Processor
    signal ext_tube_ntube  : std_logic;
    signal ext_tube_do     : std_logic_vector(7 downto 0);
    signal ext_tube_ctrl   : std_logic_vector(5 downto 0); -- signals that use the LED output

    -- Signals used for tracing 6502 activity (CImplDebug)
    signal phi2            : std_logic;
    signal sync            : std_logic;
    signal rnw             : std_logic;
    signal data            : std_logic_vector (7 downto 0);

    -- Signals for the memory controller
    signal mem_ready       : std_logic;
    signal mem_strobe      : std_logic;
    signal mem_refresh     : std_logic;

    -- Joystick / Config Shift Register
    signal joystick1       : std_logic_vector(4 downto 0) := (others => '1');
    signal joystick2       : std_logic_vector(4 downto 0) := (others => '1');
    signal jumper          : std_logic_vector(5 downto 0) := (others => '0');
    signal last_phi2       : std_logic := '0';
    signal sr_counter      : unsigned(3 downto 0) := (others => '0');
    signal sr_mirror       : std_logic_vector(15 downto 0) := (others => '0');

    -- LEDs
    signal normal_leds     : std_logic_vector(5 downto 0);
    signal monitor_leds     : std_logic_vector(5 downto 0);

begin

    --------------------------------------------------------
    -- Clock Generation
    --------------------------------------------------------

    pll1 : rPLL
        generic map (
            FCLKIN => "27",
            DEVICE => "GW2AR-18C",
            IDIV_SEL => 8,
            FBDIV_SEL => 31,
            ODIV_SEL => 8,
            DYN_SDIV_SEL => 6,
            PSDA_SEL => "1000" -- CLKOUTP 180 degree phase shift
        )
        port map (
            CLKIN    => sys_clk,       -- 27.0 MHz
            CLKOUT   => clock_sdram,   -- 96.0 MHz
            CLKOUTD  => clock_main,    -- 16.0 MHz
            CLKOUTP  => clock_sdram_p, -- 96.0 MHz / 180 degree phase shift
            CLKOUTD3 => clock_sid,     -- 32.0 MHz
            LOCK     => open,
            RESET    => '0',
            RESET_P  => '0',
            CLKFB    => '0',
            FBDSEL   => (others => '0'),
            IDSEL    => (others => '0'),
            ODSEL    => (others => '0'),
            PSDA     => (others => '0'),
            DUTYDA   => (others => '0'),
            FDLY     => (others => '0')
        );

    pll2 : rPLL
        generic map (
            FCLKIN => "27",
            DEVICE => "GW2AR-18C",
            IDIV_SEL => 0,
            FBDIV_SEL => 13,           -- PLL
            ODIV_SEL => 2
        )
        port map (
            CLKIN    => sys_clk,       --  27.0 MHz
            CLKOUT   => clock_vgadac5, -- 378.0 MHz
            CLKOUTP  => open,
            CLKOUTD  => open,
            CLKOUTD3 => clock_hdmi,    -- 126.0 MHz
            LOCK     => open,
            RESET    => '0',
            RESET_P  => '0',
            CLKFB    => '0',
            FBDSEL   => (others => '0'),
            IDSEL    => (others => '0'),
            ODSEL    => (others => '0'),
            PSDA     => (others => '0'),
            DUTYDA   => (others => '0'),
            FDLY     => (others => '0')
        );

    clkdiv_vga : CLKDIV
        generic map (
            DIV_MODE => "5",
            GSREN => "false"
        )
        port map (
            RESETN => '1',
            HCLKIN => clock_hdmi,      -- 126.0MHz
            CLKOUT => clock_vga,       --  25.2MHz
            CALIB  => '1'
        );

    clkdiv_avr_debug : CLKDIV
        generic map (
            DIV_MODE => "4",
            GSREN => "false"
        )
        port map (
            RESETN => '1',
            HCLKIN => clock_sdram,     -- 96.0MHz
            CLKOUT => clock_icet65,    -- 24.MHz
            CALIB  => '1'
        );

    clkdiv_spdif : CLKDIV
        generic map (
            DIV_MODE => "4",            -- Divide by 4
            GSREN => "false"
        )
        port map (
            RESETN => '1',
            HCLKIN => audio_clk,        -- 24.576MHz audio clock
            CLKOUT => spdif_clk,        --  6.144MHz spdif clock
            CALIB  => '1'
        );

    --------------------------------------------------------
    -- Power Up Reset Generation
    --------------------------------------------------------

    ext_reset_n     <= '1'; -- was not btn2;

    -- The external reset signal is not asserted on power up
    ResetProcess : process (clock_main)
    begin
        if rising_edge(clock_main) then
            if btn1 = '1' then
                reset_counter <= (others => '0');
            elsif (reset_counter(reset_counter'high) = '0') then
                reset_counter <= reset_counter + 1;
            end if;
            powerup_reset_n <= reset_counter(reset_counter'high);
            hard_reset_n <= not (not powerup_reset_n or not mem_ready);
        end if;
    end process;

    --------------------------------------------------------
    -- Atom FPGA Core
    --------------------------------------------------------

    inst_AtomFpga_Core : entity work.AtomFpga_Core
    generic map (
        CImplDebugger           => CImplDebugger,
        CImplCpu65c02           => CImplCpu65c02,
        CImplHDMI               => CImplHDMI,
        CImplSDDOS              => CImplSDDOS,
        CImplAtoMMC2            => CImplAtoMMC2,
        CImplGraphicsExt        => true,
        CImplSoftChar           => true,
        CImplSID                => CImplSID,
        CImplVGA80x40           => true,
        CImplHWScrolling        => true,
        CImplMouse              => true,
        CImplUart               => false,    -- Need a way of switching UART vs AVR
        CImplDoubleVideo        => true,
        CImplRamRomNone         => false,
        CImplRamRomPhill        => false,
        CImplRamRomAtom2015     => true,
        CImplRamRomSchakelKaart => false,
        CImplSampleExternData   => false,
        CImplVIA                => true,
        CImplProfilingCounters  => true,
        MainClockSpeed          => 16000000,
        DefaultBaud             => 115200,
        DefaultTurbo            => DefaultTurbo
    )
    port map(
        -- Clocking
        clk_vga             => clock_vga,    -- 25.2 MHz
        clk_main            => clock_main,   -- 16.0 MHz
        clk_avr             => clock_main,   -- 16.0 MHz
        clk_avr_debug       => clock_icet65, -- 24.0 MHz
        clk_dac             => clock_sid,    -- 32.0 MHz
        clk_32M00           => clock_sid,    -- 32.0 MHz
        -- Keyboard/mouse
        kbd_pa              => open,
        kbd_pb              => (others => '1'),
        kbd_pc              => (others => '1'),
        ps2_clk             => ps2_clk,
        ps2_data            => ps2_data,
        ps2_mouse_clk       => ps2_mouse_clk,
        ps2_mouse_data      => ps2_mouse_data,
        -- Resets
        powerup_reset_n     => hard_reset_n,
        ext_reset_n         => ext_reset_n,
        int_reset_n         => reset_n,
        -- HDMI Video
        hdmi_audio_en       => hdmi_audio_en,
        tmds_r              => hdmi_tmds_r,
        tmds_g              => hdmi_tmds_g,
        tmds_b              => hdmi_tmds_b,
        -- VGA Video
        red                 => red,
        green               => green,
        blue                => blue,
        vsync               => vsync,
        hsync               => hsync,
        blank               => blank,
        -- External 6502 bus interface
        phi2                => phi2,
        sync                => sync,
        rnw                 => rnw,
        -- External Bus/Ram/Rom interface
        ExternBus           => ExternBus,
        ExternCE            => ExternCE,
        ExternWE            => ExternWE,
        ExternA             => ExternA,
        ExternDin           => ExternDin,
        ExternDout          => ExternDout,
        -- Audio
        sid_audio           => sid_audio,
        atom_audio          => atom_audio,
        mixed_audio         => audio,
        -- SD Card
        SDMISO              => tf_miso,
        SDSS                => tf_cs,
        SDCLK               => tf_sclk,
        SDMOSI              => tf_mosi,
        -- Serial
        uart_RxD            => '1',
        uart_TxD            => open,
        avr_RxD             => uart_rx,
        avr_TxD             => uart_tx,
        -- Cassette
        cas_in              => '0',
        cas_out             => open,
        -- Misc
        LED1                => led1,
        LED2                => led2,
        charSet             => '0',
        Joystick1           => "11" & joystick1(4) & "1" & joystick1(3 downto 0),
        Joystick2           => "11" & joystick2(4) & "1" & joystick2(3 downto 0)
    );

    --------------------------------------------------------
    -- DVI
    --------------------------------------------------------

    -- Encode vsync, hsync, blanking and rgb data to Transition-minimized differential signaling (TMDS) format.


    -- This is an opensource version from here:
    --     https://github.com/fcayci/vhdl-hdmi-out/tree/master

    dvi : if (CImplDVI) generate
        signal ctrl         : std_logic_vector(1 downto 0);
        signal rgb_r  : std_logic_vector(7 downto 0);
        signal rgb_g  : std_logic_vector(7 downto 0);
        signal rgb_b  : std_logic_vector(7 downto 0);
        signal rgb_hs : std_logic;
        signal rgb_vs : std_logic;
        signal rgb_de : std_logic;
    begin
        rgb_r <= red   & "00000";
        rgb_g <= green & "00000";
        rgb_b <= blue  & "00000";
        rgb_vs <= not vsync;
        rgb_hs <= not hsync;
        rgb_de <= not blank;
        ctrl  <= rgb_vs & rgb_hs;

        tr : entity work.tmds_encoder(rtl)
            port map (
                clk  => clock_vga,
                en   => rgb_de,
                ctrl => "00",
                din  => rgb_r,
                dout => dvi_tmds_r
                );

        tg : entity work.tmds_encoder(rtl)
            port map (
                clk  => clock_vga,
                en   => rgb_de,
                ctrl => "00",
                din  => rgb_g,
                dout => dvi_tmds_g
                );

        tb : entity work.tmds_encoder(rtl)
            port map (
                clk  => clock_vga,
                en   => rgb_de,
                ctrl => ctrl,
                din  => rgb_b,
                dout => dvi_tmds_b
                );
    end generate;

    --  Serialize the three 10-bit TMDS channels to three serialized 1-bit TMDS streams

    hdmi_and_dvi: if CImplDVI or CImplHDMI generate
        signal reset        : std_logic;
        signal serialized_c : std_logic;
        signal serialized_r : std_logic;
        signal serialized_g : std_logic;
        signal serialized_b : std_logic;
        signal tmds_r       : std_logic_vector(9 downto 0);
        signal tmds_g       : std_logic_vector(9 downto 0);
        signal tmds_b       : std_logic_vector(9 downto 0);
    begin

        reset  <= not powerup_reset_n;
        tmds_r <= hdmi_tmds_r when CImplHDMI else dvi_tmds_r;
        tmds_g <= hdmi_tmds_g when CImplHDMI else dvi_tmds_g;
        tmds_b <= hdmi_tmds_b when CImplHDMI else dvi_tmds_b;

        ser_b : OSER10
            generic map (
                GSREN => "false",
                LSREN => "true"
                )
            port map(
                PCLK  => clock_vga,
                FCLK  => clock_hdmi,
                RESET => reset,
                Q     => serialized_b,
                D0    => tmds_b(0),
                D1    => tmds_b(1),
                D2    => tmds_b(2),
                D3    => tmds_b(3),
                D4    => tmds_b(4),
                D5    => tmds_b(5),
                D6    => tmds_b(6),
                D7    => tmds_b(7),
                D8    => tmds_b(8),
                D9    => tmds_b(9)
                );

        ser_g : OSER10
            generic map (
                GSREN => "false",
                LSREN => "true"
                )
            port map (
                PCLK  => clock_vga,
                FCLK  => clock_hdmi,
                RESET => reset,
                Q     => serialized_g,
                D0    => tmds_g(0),
                D1    => tmds_g(1),
                D2    => tmds_g(2),
                D3    => tmds_g(3),
                D4    => tmds_g(4),
                D5    => tmds_g(5),
                D6    => tmds_g(6),
                D7    => tmds_g(7),
                D8    => tmds_g(8),
                D9    => tmds_g(9)
                );

        ser_r : OSER10
            generic map (
                GSREN => "false",
                LSREN => "true"
                )
            port map (
                PCLK  => clock_vga,
                FCLK  => clock_hdmi,
                RESET => reset,
                Q     => serialized_r,
                D0    => tmds_r(0),
                D1    => tmds_r(1),
                D2    => tmds_r(2),
                D3    => tmds_r(3),
                D4    => tmds_r(4),
                D5    => tmds_r(5),
                D6    => tmds_r(6),
                D7    => tmds_r(7),
                D8    => tmds_r(8),
                D9    => tmds_r(9)
                );

        ser_c : OSER10
            generic map (
                GSREN => "false",
                LSREN => "true"
                )
            port map (
                PCLK  => clock_vga,
                FCLK  => clock_hdmi,
                RESET => reset,
                Q     => serialized_c,
                D0    => '1',
                D1    => '1',
                D2    => '1',
                D3    => '1',
                D4    => '1',
                D5    => '0',
                D6    => '0',
                D7    => '0',
                D8    => '0',
                D9    => '0'
                );

        -- Encode the 1-bit serialized TMDS streams to Low-voltage differential signaling (LVDS) HDMI output pins

        OBUFDS_c : ELVDS_OBUF
            port map (
                I  => serialized_c,
                O  => tmds_clk_p,
                OB => tmds_clk_n
                );

        OBUFDS_b : ELVDS_OBUF
            port map (
                I  => serialized_b,
                O  => tmds_d_p(0),
                OB => tmds_d_n(0)
                );

        OBUFDS_g : ELVDS_OBUF
            port map (
                I  => serialized_g,
                O  => tmds_d_p(1),
                OB => tmds_d_n(1)
                );

        OBUFDS_r : ELVDS_OBUF
            port map (
                I  => serialized_r,
                O  => tmds_d_p(2),
                OB => tmds_d_n(2)
                );

    end generate;

    --------------------------------------------------------
    -- I2S Audio
    --------------------------------------------------------

    -- For the MAX98357A (on the Tang Nano 20K)
    -- and the CS4354 (on the Dock board)

    -- The CS4354 has LRCLK polarity Left=0 Right=1 but the datasheet
    -- is ambiguous as to which of AOUTA/B is Left/Right. On the Tang
    -- Nano 20K PCB I guessed that AOUTA was Left, but this appear to
    -- be wrong. So we swap then here.

    -- This also swaps the polarity for the MAX98357A, but as we'd
    -- like to use this in mono mode (output = L/2 + R/2) then that
    -- shouldn't matter.

    gen_i2s : if CImplI2SAudio generate
        signal tmp : std_logic_vector(19 downto 0);
    begin

        -- Attenuate the speaker output
        process(audio, pa_en)
        begin
            if pa_en = '1' then
                -- Speaker
                tmp <= (3 downto 0 => audio(15)) & std_logic_vector(audio);
            else
                -- Line out
                tmp <= std_logic_vector(audio) & "0000";
            end if;
        end process;

        i2s : entity work.i2s_simple
            generic map (
                ATTENUATE  => 0,         -- No attenuation, allows use of full dynamic range
                CLOCKSPEED => 6144000,   -- SPDIF Clock
                SAMPLERATE => 48000      -- Output sample rate of new audio resampler
                )
            port map (
                clock      => spdif_clk,
                reset_n    => '1',       -- Avoid a nasty click on powerup_reset_n
                audio_l    => tmp,
                audio_r    => tmp,
                i2s_lrclk  => i2s_lrclk,
                i2s_bclk   => i2s_bclk,
                i2s_din    => i2s_din
                );
        i2s_mclk <= audio_clk;
    end generate;

    not_gen_i2s : if not CImplI2SAudio generate
        i2s_mclk   <= 'Z';
        i2s_lrclk  <= 'Z';
        i2s_bclk   <= 'Z';
        i2s_din    <= 'Z';
    end generate;

    --------------------------------------------------------
    -- SPDIF
    --------------------------------------------------------

    -- Note: this block assumes a fixed 48KHz sample rate derived
    -- from an external spdif_clk of 6.144MHz, which must be
    -- locked to the main system clock. This constraint is
    -- satisfied by virtue of the way we configure the MS5351A
    -- clock generator.

    gen_spdif_audio : if CImplSPDIFAudio generate
        signal spdif_in        : std_logic_vector(19 downto 0);
        signal spdif_load      : std_logic;
        signal div64           : unsigned(5 downto 0) := (others => '0');
    begin

        spdif_in <= std_logic_vector(audio) & "0000";

        process(spdif_clk)
        begin
            if rising_edge(spdif_clk) then
                div64 <= div64 + 1;
                if div64 = 0 then
                    spdif_load <= '1';
                else
                    spdif_load <= '0';
                end if;
            end if;
        end process;

        spdif_serialize: entity work.spdif_serializer
            port map (
                clk          => spdif_clk,
                clken        => '1',
                auxAudioBits => (others => '0'),
                sample       => spdif_in,
                load         => spdif_load,
                -- channelA  => channelA, -- not used as we are mono only
                spdifOut     => audio_spdif
                );
    end generate;

    gen_no_spdif_audio : if not CImplSPDIFAudio generate
        audio_spdif <= '0';
    end generate;

    --------------------------------------------------------
    -- Version ROM
    --------------------------------------------------------

    process(clock_main)
    begin
        if rising_edge(clock_main) then
            if ExternA(7 downto 0) < 32 then
                version_rom_byte <= std_logic_vector(version_rom(conv_integer(ExternA(4 downto 0))));
            else
                version_rom_byte <= x"00";
            end if;
        end if;
    end process;

    --------------------------------------------------------
    -- Bus data multiplexor
    --------------------------------------------------------

    ExternDout <= version_rom_byte when ExternBus = '1' and ExternA(15 downto 8) = x"B1" else
                  ext_tube_do      when ext_tube_ntube = '0'                             else
                  SDRAMDout;

    --------------------------------------------------------
    -- SDRAM Memory Controller
    --------------------------------------------------------

    e_mem: entity work.mem_tang_20k
        generic map (
            IncludeMonitor => CImplMonitor,
            IncludeBootStrap => CImplBootstrap,
            SIM => SIM,
            PRJ_ROOT => PRJ_ROOT,
            MOS_NAME => MOS_NAME
        )
        port map (
            RST_n          => powerup_reset_n,
            READY          => mem_ready,
            CLK_96         => clock_sdram,
            CLK_96_p       => clock_sdram_p,
            CLK_48         => clock_main,
            core_rfsh_stb  => mem_refresh,
            core_A_stb     => mem_strobe,
            core_A         => ExternA,
            core_Din       => ExternDin,
            core_Dout      => SDRAMDout,
            core_nCS       => not ExternCE,
            core_nWE       => not (ExternWE and phi2),
            core_nWE_long  => not ExternWE,
            core_nOE       => ExternWE,

            O_sdram_clk    => O_sdram_clk     ,
            O_sdram_cke    => O_sdram_cke     ,
            O_sdram_cs_n   => O_sdram_cs_n    ,
            O_sdram_cas_n  => O_sdram_cas_n   ,
            O_sdram_ras_n  => O_sdram_ras_n   ,
            O_sdram_wen_n  => O_sdram_wen_n   ,
            IO_sdram_dq    => IO_sdram_dq     ,
            O_sdram_addr   => O_sdram_addr    ,
            O_sdram_ba     => O_sdram_ba      ,
            O_sdram_dqm    => O_sdram_dqm     ,

            led            => monitor_leds,

            FLASH_CS       => flash_cs,
            FLASH_SI       => flash_si,
            FLASH_CK       => flash_ck,
            FLASH_SO       => flash_so
        );

    --------------------------------------------------------
    -- VGA outputs (using high speed 1-bit DAC)
    --------------------------------------------------------

    vgadac : if CImplVGADAC generate
        signal vga_r_int : std_logic;
        signal vga_g_int : std_logic;
        signal vga_b_int : std_logic;
    begin

        clkdiv_vgadac : CLKDIV
            generic map (
                DIV_MODE => "5",
                GSREN => "false"
                )
            port map (
                RESETN => '1',
                HCLKIN => clock_vgadac5,      -- 378.0 MHz
                CLKOUT => clock_vgadac1,      --  75.6 MHz
                CALIB  => '1'
                );

        e_vidr:entity work.dac1_oser
            port map (
                rst_i               => not hard_reset_n,
                clk_sample_i        => clock_vga,
                clk_dac_px_i        => clock_vgadac1,
                clk_dac_i           => clock_vgadac5,
                sample_i            => unsigned(red & "0"),
                bitstream_o         => vga_r_int
                );
        e_vidg:entity work.dac1_oser
            port map (
                rst_i               => not hard_reset_n,
                clk_sample_i        => clock_vga,
                clk_dac_px_i        => clock_vgadac1,
                clk_dac_i           => clock_vgadac5,
                sample_i            => unsigned(green & "0"),
                bitstream_o         => vga_g_int
                );
        e_vidb:entity work.dac1_oser
            port map (
                rst_i               => not hard_reset_n,
                clk_sample_i        => clock_vga,
                clk_dac_px_i        => clock_vgadac1,
                clk_dac_i           => clock_vgadac5,
                sample_i            => unsigned(blue & "0"),
                bitstream_o         => vga_b_int
                );

        -- Manually instantiate differential output buffers to avoid
        -- warning about vga_x_n being unused.

        OBUFDS_r : ELVDS_OBUF
            port map (
                I  => vga_r_int,
                O  => vga_r,
                OB => vga_r_n
             );

        OBUFDS_g : ELVDS_OBUF
            port map (
                I  => vga_g_int,
                O  => vga_g,
                OB => vga_g_n
             );

        OBUFDS_b : ELVDS_OBUF
            port map (
                I  => vga_b_int,
                O  => vga_b,
                OB => vga_b_n
             );

        vga_hs <= hsync;

        vga_vs <= vsync;

    end generate;

    --------------------------------------------------------
    -- VGA outputs
    --------------------------------------------------------

    vga : if CImplVGA generate

        OBUFDS_r : ELVDS_OBUF
            port map (
                I  => red(red'high),
                O  => vga_r,
                OB => vga_r_n
             );

        OBUFDS_g : ELVDS_OBUF
            port map (
                I  => green(green'high),
                O  => vga_g,
                OB => vga_g_n
             );

        OBUFDS_b : ELVDS_OBUF
            port map (
                I  => blue(blue'high),
                O  => vga_b,
                OB => vga_b_n
                );

        vga_hs <= hsync;

        vga_vs <= vsync;

    end generate;

    --------------------------------------------------------
    -- External PiTibeDirect
    --------------------------------------------------------

    ext_tube_ntube <= '0' when ExternBus = '1' and ExternA(15 downto 4) = x"BEE" else '1';

    GenCoProExt: if CImplCoProExt generate
    begin

        ext_tube_do  <= vga_g & vga_b_n & vga_vs & vga_hs & vga_r_n & vga_b & vga_g_n & vga_r;

        vga_g   <= ExternDin(7) when rnw = '0' and Phi2 = '1' else 'Z';
        vga_b_n <= ExternDin(6) when rnw = '0' and Phi2 = '1' else 'Z';
        vga_vs  <= ExternDin(5) when rnw = '0' and Phi2 = '1' else 'Z';
        vga_hs  <= ExternDin(4) when rnw = '0' and Phi2 = '1' else 'Z';
        vga_r_n <= ExternDin(3) when rnw = '0' and Phi2 = '1' else 'Z';
        vga_b   <= ExternDin(2) when rnw = '0' and Phi2 = '1' else 'Z';
        vga_g_n <= ExternDin(1) when rnw = '0' and Phi2 = '1' else 'Z';
        vga_r   <= ExternDin(0) when rnw = '0' and Phi2 = '1' else 'Z';

        ext_tube_ctrl(5) <= reset_n;
        ext_tube_ctrl(4) <= ExternA(2);
        ext_tube_ctrl(3) <= ExternA(1);
        ext_tube_ctrl(2) <= ext_tube_ntube;
        ext_tube_ctrl(1) <= rnw;
        ext_tube_ctrl(0) <= ExternA(0);

    end generate;

    GenCoProNotExt: if not CImplCoProExt generate
    begin
        ext_tube_do  <= x"FE";
        ext_tube_ctrl <= (others => '1');
    end generate;

    --------------------------------------------------------
    -- External shift register for joysticks / config links
    --------------------------------------------------------

    process(clock_main)
    begin
        if rising_edge(clock_main) then
            -- external 74LV165A clocked on rising edge, so work here on falling edge
            if phi2 = '0' and last_phi2 = '1' then
                if sr_counter = "1111" then
                    js_load_n <= '0';
                else
                    js_load_n <= '1';
                end if;
                if sr_counter = "0000" then
                    joystick1 <= sr_mirror(12 downto 8);
                    joystick2 <= sr_mirror(4 downto 0);
                    jumper    <= sr_mirror(7 downto 5) & sr_mirror(15 downto 13);
                end if;
                sr_mirror  <= sr_mirror(14 downto 0) & js_data;
                sr_counter <= sr_counter + 1;
            end if;
            mem_strobe  <= phi2 and not last_phi2; -- on the rising edge (middle of the cyle)
            mem_refresh <= last_phi2 and not phi2; -- on the falling edge
            last_phi2   <= phi2;
        end if;
    end process;

    hdmi_audio_en <= jumper(3) or jumper(4);

    --------------------------------------------------------
    -- Outputs/signals whose function depends on the Includes
    --------------------------------------------------------

    js_clk <= phi2;

    normal_leds <= (led1 & led2 & "0000") xor "111111";

    led <= ext_tube_ctrl                      when CImplCoProExt                                  else
           monitor_leds                       when CImplMonitor                                   else
           normal_leds;

    ws2812_din <= '0';

    audiol <= sid_audio;
    audior <= atom_audio;

end architecture;
