library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AtomFpga_TangNano9K is
    generic (
        CImplCpu65c02      : boolean := false;
        CImplDVIGowin      : boolean := false;
        CImplDVIOpenSource : boolean := true;
        CImplVGA           : boolean := true;
        CImplTrace         : boolean := false
    );
    port (
        clock_27        : in    std_logic;
        btn1_n          : in    std_logic;
        btn2_n          : in    std_logic;
        ps2_clk         : in    std_logic;
        ps2_data        : in    std_logic;
        ps2_mouse_clk   : inout std_logic;
        ps2_mouse_data  : inout std_logic;
        audiol          : out   std_logic;
        audior          : out   std_logic;
        tf_miso         : in    std_logic;
        tf_cs           : out   std_logic;
        tf_sclk         : out   std_logic;
        tf_mosi         : out   std_logic;
        uart_rx         : in    std_logic;
        uart_tx         : out   std_logic;
        led             : out   std_logic_vector (5 downto 0);
        tmds_clk_p      : out   std_logic;
        tmds_clk_n      : out   std_logic;
        tmds_d_p        : out   std_logic_vector(2 downto 0);
        tmds_d_n        : out   std_logic_vector(2 downto 0);
        gpio            : out   std_logic_vector(10 downto 0)
    );
end AtomFpga_TangNano9K;

architecture behavioral of AtomFpga_TangNano9K is

    signal clock_16     : std_logic;
    signal clock_25     : std_logic;
    signal clock_125    : std_logic;
    signal clock_32     : std_logic;

    signal reset        : std_logic;

    signal led1         : std_logic;
    signal led2         : std_logic;

    -- Signals used for VGA video from the core
    signal red          : std_logic_vector(2 downto 0);
    signal green        : std_logic_vector(2 downto 0);
    signal blue         : std_logic_vector(2 downto 0);
    signal vsync        : std_logic;
    signal hsync        : std_logic;
    signal blank        : std_logic;

    -- Signals used for DVI/HDMI
    signal rgb_r        : std_logic_vector(7 downto 0);
    signal rgb_g        : std_logic_vector(7 downto 0);
    signal rgb_b        : std_logic_vector(7 downto 0);
    signal rgb_hs       : std_logic;
    signal rgb_vs       : std_logic;
    signal rgb_de       : std_logic;
    signal ctrl         : std_logic_vector(1 downto 0);
    signal encoded_r    : std_logic_vector(9 downto 0);
    signal encoded_g    : std_logic_vector(9 downto 0);
    signal encoded_b    : std_logic_vector(9 downto 0);
    signal serialized_c : std_logic;
    signal serialized_r : std_logic;
    signal serialized_g : std_logic;
    signal serialized_b : std_logic;

    -- Signals used by the external bus interface (i.e. RAM and ROM)
    signal RomCE        : std_logic;
    signal RamCE1       : std_logic;
    signal RamCE2       : std_logic;
    signal ExternCE     : std_logic;
    signal ExternWE     : std_logic;
    signal ExternA      : std_logic_vector (18 downto 0);
    signal ExternDin    : std_logic_vector (7 downto 0);
    signal ExternDout   : std_logic_vector (7 downto 0);
    signal RamDout1     : std_logic_vector (7 downto 0);
    signal RamDout2     : std_logic_vector (7 downto 0);
    signal RomDout      : std_logic_vector (7 downto 0);

    -- Signals used for tracing 6502 activity (CImplDebug)
    signal phi2         : std_logic;
    signal sync         : std_logic;
    signal rnw          : std_logic;
    signal data         : std_logic_vector (7 downto 0);

    component DVI_TX_Top
        port (
            I_rst_n: in std_logic;
            I_serial_clk: in std_logic;
            I_rgb_clk: in std_logic;
            I_rgb_vs: in std_logic;
            I_rgb_hs: in std_logic;
            I_rgb_de: in std_logic;
            I_rgb_r: in std_logic_vector(7 downto 0);
            I_rgb_g: in std_logic_vector(7 downto 0);
            I_rgb_b: in std_logic_vector(7 downto 0);
            O_tmds_clk_p: out std_logic;
            O_tmds_clk_n: out std_logic;
            O_tmds_data_p: out std_logic_vector(2 downto 0);
            O_tmds_data_n: out std_logic_vector(2 downto 0)
        );
    end component;

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

begin

    pll1 : rPLL
        generic map (
            FCLKIN => "27",
            DEVICE => "GW1NR-9C",
            IDIV_SEL => 8,
            FBDIV_SEL => 31,
            ODIV_SEL => 8,
            DYN_SDIV_SEL => 6
        )
        port map (
            CLKIN    => clock_27,
            CLKOUT   => open,
            CLKOUTD  => clock_16,
            CLKOUTP  => open,
            CLKOUTD3 => clock_32,
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
            DEVICE => "GW1NR-9C",
            IDIV_SEL => 2,
            FBDIV_SEL => 13,
            ODIV_SEL => 4
        )
        port map (
            CLKIN    => clock_27,
            CLKOUT   => clock_125,
            CLKOUTP  => open,
            CLKOUTD  => open,
            CLKOUTD3 => open,
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

    clkdiv5 : CLKDIV
        generic map (
            DIV_MODE => "5",
            GSREN => "false"
        )
        port map (
            RESETN => '1', -- TODO, reset when previous PLL locked
            HCLKIN => clock_125,
            CLKOUT => clock_25,
            CALIB  => '1'
        );

    ram_0000_07ff : entity work.RAM_2K port map(
        clk     => clock_16,
        we_uP   => ExternWE,
        ce      => RamCE1,
        addr_uP => ExternA(10 downto 0),
        D_uP    => ExternDin,
        Q_uP    => RamDout1
    );

    ram_2000_3fff : entity work.RAM_8K port map(
        clk     => clock_16,
        we_uP   => ExternWE,
        ce      => RamCE2,
        addr_uP => ExternA(12 downto 0),
        D_uP    => ExternDin,
        Q_uP    => RamDout2
    );

    rom_c000_ffff : entity work.InternalROM port map(
        CLK     => clock_16,
        ADDR    => ExternA(13 downto 0),
        DATA    => RomDout
    );

    RamCE1 <= '1' when ExternCE = '1' and ExternA(15 downto 11) = "00000" else '0';
    RamCE2 <= '1' when ExternCE = '1' and ExternA(15 downto 13) = "001"   else '0';
    RomCE  <= '1' when ExternCE = '1' and ExternA(15 downto 14) = "11"    else '0';

    ExternDout(7 downto 0) <= RamDout1 when RamCE1 = '1' else
                              RamDout2 when RamCE2 = '1' else
                              RomDout  when RomCE  = '1' else
                              "11110001";

    inst_AtomFpga_Core : entity work.AtomFpga_Core
    generic map (
        CImplCpu65c02           => CImplCpu65c02,
        CImplSDDOS              => true,
        CImplAtoMMC2            => false,
        CImplGraphicsExt        => true,
        CImplSoftChar           => false,
        CImplSID                => true,
        CImplVGA80x40           => true,
        CImplHWScrolling        => true,
        CImplMouse              => true,
        CImplUart               => true,
        CImplDoubleVideo        => false,
        CImplRamRomNone         => true,
        CImplRamRomPhill        => false,
        CImplRamRomAtom2015     => false,
        CImplRamRomSchakelKaart => false,
        MainClockSpeed          => 16000000,
        DefaultBaud             => 115200
    )
    port map(
        -- Clocking
        clk_vga             => clock_25,
        clk_main            => clock_16,
        clk_avr             => clock_16,
        clk_avr_debug       => '0',
        clk_dac             => clock_32,
        clk_32M00           => clock_32,
        -- Keyboard/mouse
        kbd_pa              => open,
        kbd_pb              => (others => '1'),
        kbd_pc              => (others => '1'),
        ps2_clk             => ps2_clk,
        ps2_data            => ps2_data,
        ps2_mouse_clk       => ps2_mouse_clk,
        ps2_mouse_data      => ps2_mouse_data,
        -- Resets
        powerup_reset_n     => btn1_n,
        ext_reset_n         => btn2_n,
        int_reset_n         => open,
        -- Video
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
        ExternCE            => ExternCE,
        ExternWE            => ExternWE,
        ExternA             => ExternA,
        ExternDin           => ExternDin,
        ExternDout          => ExternDout,
        -- Audio
        sid_audio           => audiol,
        sid_audio_d         => open,
        atom_audio          => audior,
        -- SD Card
        SDMISO              => tf_miso,
        SDSS                => tf_cs,
        SDCLK               => tf_sclk,
        SDMOSI              => tf_mosi,
        -- Serial
        uart_RxD            => uart_rx,
        uart_TxD            => uart_tx,
        avr_RxD             => '1',
        avr_TxD             => open,
        -- Cassette
        cas_in              => '0',
        cas_out             => open,
        -- Misc
        LED1                => led1,
        LED2                => led2,
        charSet             => '0',
        Joystick1           => (others => '1'),
        Joystick2           => (others => '1')
    );

    led <= btn2_n & btn2_n & btn2_n & led2 & led2 & btn1_n;

    -- DVI / HDMI output

    rgb_r <= red   & "00000";
    rgb_g <= green & "00000";
    rgb_b <= blue  & "00000";
    rgb_vs <= not vsync;
    rgb_hs <= not hsync;
    rgb_de <= not blank;

    -- This is Gowin's proprietaty (and encrypted) DVI encoder

    dvi_gowin : if (CImplDVIGowin) generate
        dvi_tx1 : DVI_TX_Top
            port map (
                I_rst_n => btn1_n,
                I_serial_clk => clock_125,
                I_rgb_clk => clock_25,
                I_rgb_vs => rgb_vs,
                I_rgb_hs => rgb_hs,
                I_rgb_de => rgb_de,
                I_rgb_r => rgb_r,
                I_rgb_g => rgb_g,
                I_rgb_b => rgb_b,
                O_tmds_clk_p => tmds_clk_p,
                O_tmds_clk_n => tmds_clk_n,
                O_tmds_data_p => tmds_d_p,
                O_tmds_data_n => tmds_d_n
                );
    end generate;

    -- This is an opensource version from here:
    --     https://github.com/fcayci/vhdl-hdmi-out/tree/master

    dvi_open_source : if (CImplDVIOpenSOurce) generate

        -- TODO: The source for this could be made much smaller with some for/generate loops!

        reset <= not btn1_n;
        ctrl  <= rgb_vs & rgb_hs;

        -- Encode vsync, hsync, blanking and rgb data to Transition-minimized differential signaling (TMDS) format.

        tr : entity work.tmds_encoder(rtl)
            port map (
                clk  => clock_25,
                en   => rgb_de,
                ctrl => "00",
                din  => rgb_r,
                dout => encoded_r
                );

        tg : entity work.tmds_encoder(rtl)
            port map (
                clk  => clock_25,
                en   => rgb_de,
                ctrl => "00",
                din  => rgb_g,
                dout => encoded_g
                );

        tb : entity work.tmds_encoder(rtl)
            port map (
                clk  => clock_25,
                en   => rgb_de,
                ctrl => ctrl,
                din  => rgb_b,
                dout => encoded_b
                );

        --  Serialize the three 10-bit TMDS channels to three serialized 1-bit TMDS streams

        ser_b : OSER10
            generic map (
                GSREN => "false",
                LSREN => "true"
                )
            port map(
                PCLK  => clock_25,
                FCLK  => clock_125,
                RESET => reset,
                Q     => serialized_b,
                D0    => encoded_b(0),
                D1    => encoded_b(1),
                D2    => encoded_b(2),
                D3    => encoded_b(3),
                D4    => encoded_b(4),
                D5    => encoded_b(5),
                D6    => encoded_b(6),
                D7    => encoded_b(7),
                D8    => encoded_b(8),
                D9    => encoded_b(9)
                );

        ser_g : OSER10
            generic map (
                GSREN => "false",
                LSREN => "true"
                )
            port map (
                PCLK  => clock_25,
                FCLK  => clock_125,
                RESET => reset,
                Q     => serialized_g,
                D0    => encoded_g(0),
                D1    => encoded_g(1),
                D2    => encoded_g(2),
                D3    => encoded_g(3),
                D4    => encoded_g(4),
                D5    => encoded_g(5),
                D6    => encoded_g(6),
                D7    => encoded_g(7),
                D8    => encoded_g(8),
                D9    => encoded_g(9)
                );

        ser_r : OSER10
            generic map (
                GSREN => "false",
                LSREN => "true"
                )
            port map (
                PCLK  => clock_25,
                FCLK  => clock_125,
                RESET => reset,
                Q     => serialized_r,
                D0    => encoded_r(0),
                D1    => encoded_r(1),
                D2    => encoded_r(2),
                D3    => encoded_r(3),
                D4    => encoded_r(4),
                D5    => encoded_r(5),
                D6    => encoded_r(6),
                D7    => encoded_r(7),
                D8    => encoded_r(8),
                D9    => encoded_r(9)
                );

        ser_c : OSER10
            generic map (
                GSREN => "false",
                LSREN => "true"
                )
            port map (
                PCLK  => clock_25,
                FCLK  => clock_125,
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

    trace: if (CImplTrace) generate
        -- 6502 Decoder tracing to the GPIO bus
        data <= ExternDout when ExternCE = '1' and rnw = '1' else ExternDin;
        gpio <= phi2 & sync & rnw & data;
    end generate;

    vga: if (CImplVGA) generate
        -- VGA output to the GPIO bus
        gpio <= vsync & hsync & red(2) & blue & red(1 downto 0) & green;
    end generate;

end behavioral;
