library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AtomFpga_TangNano9K is
    generic (
        CImplCpu65c02      : boolean := false;
        CImplDVIGowin      : boolean := false;
        CImplDVIOpenSource : boolean := true;
        CImplSDDOS         : boolean := false;
        CImplAtoMMC2       : boolean := true;
        CImplSID           : boolean := true;
        -- Options that use the GPIO outputs, select just one
        CImplVGA           : boolean := true;
        CImplTrace         : boolean := false;
        CImplDbgPsram      : boolean := false
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
        gpio            : out   std_logic_vector(10 downto 0);
        -- Flash
        flash_cs        : out   std_logic;
        flash_ck        : out   std_logic;
        flash_si        : out   std_logic;
        flash_so        : in    std_logic;
        -- Magic ports for PSRAM to be inferred
        O_psram_ck      : out   std_logic_vector(1 downto 0);
        O_psram_ck_n    : out   std_logic_vector(1 downto 0);
        IO_psram_rwds   : inout std_logic_vector(1 downto 0);
        IO_psram_dq     : inout std_logic_vector(15 downto 0);
        O_psram_reset_n : out   std_logic_vector(1 downto 0);
        O_psram_cs_n    : out   std_logic_vector(1 downto 0)
    );
end AtomFpga_TangNano9K;

architecture behavioral of AtomFpga_TangNano9K is

    signal clock_16        : std_logic;
    signal clock_25        : std_logic;
    signal clock_125       : std_logic;
    signal clock_32        : std_logic;
    signal clock_96        : std_logic;
    signal clock_96_p      : std_logic;

    signal ext_reset_n     : std_logic;
    signal powerup_reset_n : std_logic;
    signal delayed_reset_n : std_logic;
    signal hard_reset_n    : std_logic;
    signal reset           : std_logic;
    signal led1            : std_logic;
    signal led2            : std_logic;

    -- Signals used for VGA video from the core
    signal red             : std_logic_vector(2 downto 0);
    signal green           : std_logic_vector(2 downto 0);
    signal blue            : std_logic_vector(2 downto 0);
    signal vsync           : std_logic;
    signal hsync           : std_logic;
    signal blank           : std_logic;

    -- Signals used for DVI/HDMI
    signal rgb_r           : std_logic_vector(7 downto 0);
    signal rgb_g           : std_logic_vector(7 downto 0);
    signal rgb_b           : std_logic_vector(7 downto 0);
    signal rgb_hs          : std_logic;
    signal rgb_vs          : std_logic;
    signal rgb_de          : std_logic;
    signal ctrl            : std_logic_vector(1 downto 0);
    signal encoded_r       : std_logic_vector(9 downto 0);
    signal encoded_g       : std_logic_vector(9 downto 0);
    signal encoded_b       : std_logic_vector(9 downto 0);
    signal serialized_c    : std_logic;
    signal serialized_r    : std_logic;
    signal serialized_g    : std_logic;
    signal serialized_b    : std_logic;

    -- Signals used by the external bus interface (i.e. RAM and ROM)
    signal ExternCE        : std_logic;
    signal ExternWE        : std_logic;
    signal ExternA         : std_logic_vector (18 downto 0);
    signal ExternDin       : std_logic_vector (7 downto 0);
    signal ExternDout      : std_logic_vector (7 downto 0);

    -- Signals used for tracing 6502 activity (CImplDebug)
    signal phi2            : std_logic;
    signal sync            : std_logic;
    signal rnw             : std_logic;
    signal data            : std_logic_vector (7 downto 0);

    -- Signals for the SPI FLASH bootstrap
    signal bootstrap_busy  : std_logic;

    -- Signals for the internal side of the PS Ram
    signal psram_phi2      : std_logic;
    signal psram_phi2d     : std_logic;
    signal psram_ce        : std_logic;
    signal psram_we        : std_logic;
    signal psram_read      : std_logic;
    signal psram_write     : std_logic;
    signal psram_busy      : std_logic;
    signal psram_addr      : std_logic_vector(21 downto 0);
    signal psram_din       : std_logic_vector(15 downto 0);
    signal psram_dout      : std_logic_vector(15 downto 0);
    signal psram_din8      : std_logic_vector(7 downto 0);
    signal psram_dout8     : std_logic_vector(7 downto 0);

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
            DYN_SDIV_SEL => 6,
            PSDA_SEL => "0100" -- CLKOUTP 90 degree phase shift
        )
        port map (
            CLKIN    => clock_27,
            CLKOUT   => clock_96,
            CLKOUTD  => clock_16,
            CLKOUTP  => clock_96_p,
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

    --------------------------------------------------------
    -- Power Up Reset Generation
    --------------------------------------------------------

    powerup_reset_n <= btn1_n;
    ext_reset_n     <= btn2_n;
    O_psram_reset_n <= powerup_reset_n & powerup_reset_n;

    -- On power up, wait for the psram controller to initialize before bootstrapping SPI flash
    process(clock_16)
    begin
        if rising_edge(clock_16) then
            if powerup_reset_n = '0' then
                delayed_reset_n <= '0';
            elsif psram_busy = '0' then
                delayed_reset_n <= '1';
            end if;
        end if;
    end process;

    -- On power up, wait for the flash bootstrap to complete before releasing the core
    hard_reset_n <= delayed_reset_n and not bootstrap_busy;

    --------------------------------------------------------
    -- PSRAM
    --------------------------------------------------------

    ram : entity work.PsramController
        generic map (
            FREQ => 96_000_000,
            LATENCY => 4
        )
        port map (
            clk           => clock_96,
            clk_p         => clock_96_p, -- phase-shifted clock for driving O_psram_ck
            resetn        => powerup_reset_n,
            read          => psram_read,
            write         => psram_write,
            addr          => psram_addr, -- Byte address to read / write
            din           => psram_din,  -- Data word to write
            dout          => psram_dout, -- Last read data. Read is always word-based.
            busy          => psram_busy, -- 1 while an operation is in progress, TODO: IGORNED FOR NOW
            byte_write    => '1',        -- When writing, only write one byte instead of the whole word.
                                         -- addr[0]==1 means we write the upper half of din. lower half otherwise.

            -- HyperRAM physical interface. Gowin interface is for 2 dies.
            -- We currently only use the first die (4MB).
            O_psram_ck    => O_psram_ck,
            IO_psram_rwds => IO_psram_rwds,
            IO_psram_dq   => IO_psram_dq,
            O_psram_cs_n  => O_psram_cs_n
            );

    process(clock_96)
    begin
        if rising_edge(clock_96) then
            psram_phi2d <= psram_phi2;
            if psram_phi2d = '0' and psram_phi2 = '1' and psram_ce = '1' and psram_we = '0' then
                psram_read <= '1';
            else
                psram_read <= '0';
            end if;
            if psram_phi2d = '0' and psram_phi2 = '1' and psram_ce = '1' and psram_we = '1' then
                psram_write <= '1';
            else
                psram_write <= '0';
            end if;
        end if;
    end process;

    psram_din   <= psram_din8 & psram_din8;
    psram_dout8 <= psram_dout(15 downto 8) when psram_addr(0) = '1' else psram_dout(7 downto 0);

    boot : entity work.bootstrap
    port map (
        clock           => clock_16,

        -- initiate bootstrap
        powerup_reset_n => delayed_reset_n,

        -- high when FLASH is being copied to SRAM, can be used by user as active high reset
        bootstrap_busy  => bootstrap_busy,

        -- start address of user data in FLASH
        user_address    => (others => '0'),

        -- interface from Atom core
        RAM_Phi2        => phi2,
        RAM_CE          => ExternCE,
        RAM_WE          => ExternWE,
        RAM_A           => ExternA,
        RAM_Din         => ExternDin,
        RAM_Dout        => ExternDout,

        -- interface to the PSRAM
        PSRAM_Phi2      => psram_phi2,
        PSRAM_CE        => psram_ce,
        PSRAM_WE        => psram_we,
        PSRAM_A         => psram_addr,
        PSRAM_Din       => psram_din8,
        PSRAM_Dout      => psram_dout8,

        -- interface to external FLASH
        FLASH_CS        => flash_cs,
        FLASH_CK        => flash_ck,
        FLASH_SI        => flash_si,
        FLASH_SO        => flash_so
        );

    inst_AtomFpga_Core : entity work.AtomFpga_Core
    generic map (
        CImplCpu65c02           => CImplCpu65c02,
        CImplSDDOS              => CImplSDDOS,
        CImplAtoMMC2            => CImplAtoMMC2,
        CImplGraphicsExt        => true,
        CImplSoftChar           => false,
        CImplSID                => CImplSID,
        CImplVGA80x40           => true,
        CImplHWScrolling        => true,
        CImplMouse              => true,
        CImplUart               => false,
        CImplDoubleVideo        => false,
        CImplRamRomNone         => false,
        CImplRamRomPhill        => false,
        CImplRamRomAtom2015     => true,
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
        powerup_reset_n     => hard_reset_n,
        ext_reset_n         => ext_reset_n,
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

        reset <= not powerup_reset_n;
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

    psram: if (CImplDbgPsram) generate
        -- PSRAM debugging
        gpio <= phi2 & sync & rnw & powerup_reset_n & delayed_reset_n & psram_ce & psram_read & psram_write & psram_busy & IO_psram_rwds(0) & IO_psram_dq(0);
    end generate;

    vga: if (CImplVGA) generate
        -- VGA output to the GPIO bus
        gpio <= vsync & hsync & red(2) & blue & red(1 downto 0) & green;
    end generate;

end behavioral;
