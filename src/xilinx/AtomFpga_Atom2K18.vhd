--------------------------------------------------------------------------------
-- Copyright (c) 2020 David Banks and Roland Leurs
--
-- based on work by Alan Daly. Copyright(c) 2009. All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : AtomFpga_Atom2K18.vhd
-- /___/   /\     Timestamp : 13/06/2020
-- \   \  /  \
--  \___\/\___\
--
--Design Name: AtomFpga_Atom2K18
--Device: Spartan6

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity AtomFpga_Atom2K18 is
    generic (
        -- Design identifier, readable after configuration from #BFFB
        DESIGN_NUM     : integer := 0;

        -- Set CImplCpu65c02 to true to use a 65C02 core rather than a 6502
        CImplCpu65c02  : boolean := false;

        -- Set CImplAtoMMC to true to use an internal AtoMMC
        CImplAtoMMC2   : boolean := true;

        -- Set CImplDebugger to true to enable the ICE-6502 Debugger
        CImplDebugger  : boolean := false

        -- NOTE: If CImplAtoMMC2 and CImplDebugger are both true, several
        -- smaller features are disabled to make space in the FPGA:
        --       GODIL: SID and Mouse
        --
        -- If you are not happy with this, then you can experiment with
        -- enabling individual features in the constants section below.
        );
    port (
        -- Clock
        clk_50         : in  std_logic;

        -- External Bus
        bus_a          : out   std_logic_vector(18 downto 0);
        bus_d          : inout std_logic_vector(7 downto 0);
        bus_blk_b      : out   std_logic;
        bus_phi2       : out   std_logic;
        bus_rnw        : out   std_logic;
        bus_nrds       : out   std_logic;
        bus_nwds       : out   std_logic;
        bus_sync       : out   std_logic;
        bus_nmi_n      : in    std_logic;
        bus_irq_n      : in    std_logic;
        bus_rst_n      : inout std_logic;
        bus_rdy        : in    std_logic;
        bus_so         : in    std_logic;

        -- External device chip selects
        cs_ram_n       : out   std_logic;
        cs_rom_n       : out   std_logic;
        cs_via_n       : out   std_logic;
        cs_tube_n      : out   std_logic;
        cs_buf_n       : out   std_logic;
        buf_dir        : out   std_logic;

        -- Video
        vga_red1       : out   std_logic; -- this is the MSB
        vga_red2       : out   std_logic;
        vga_green1     : out   std_logic; -- this is the MSB
        vga_green2     : out   std_logic;
        vga_blue1      : out   std_logic; -- this is the MSB
        vga_blue2      : out   std_logic;
        vga_vsync      : out   std_logic;
        vga_hsync      : out   std_logic;

        -- Audio
        audio          : out   std_logic;
        dac_cs_n       : out   std_logic;
        dac_sdi        : out   std_logic;
        dac_ldac_n     : out   std_logic;
        dac_sck        : out   std_logic;

        -- Keyboard
        kbd_pa         : out   std_logic_vector(3 downto 0);
        kbd_pb         : in    std_logic_vector(7 downto 0);
        kbd_pc         : in    std_logic_vector(6 downto 6);

        -- Mouse
        ps2_mouse_clk  : inout std_logic;
        ps2_mouse_data : inout std_logic;

        -- Cassette
        cas_in         : in    std_logic;
        cas_out        : out   std_logic;

        -- Serial
        serial_tx      : out   std_logic;
        serial_rx      : in    std_logic;

        -- SD Card
        mmc_led_red    : out   std_logic;
        mmc_led_green  : out   std_logic;
        mmc_clk        : out   std_logic;
        mmc_ss         : out   std_logic;
        mmc_mosi       : out   std_logic;
        mmc_miso       : in    std_logic;

        -- LEDs on FPGA Module
        led            : out   std_logic_vector(1 to 8);

        -- Switches on FPGA Module
        sw             : in    std_logic_vector(2 downto 1);

        -- USB Uart on FPGA Module
        avr_tx         : out   std_logic;
        avr_rx         : in    std_logic
        );

end AtomFpga_Atom2K18;

architecture behavioral of AtomFpga_Atom2K18 is

    ------------------------------------------------------
    -- Constants controlling single features
    ------------------------------------------------------

    -- Approx resource usage
    --
    --                         (5,720)   (32)
    --                           LUTs  RamB16
    -- Baseline                  1197       5.5
    -- CImplCpu65C02              -47       1.5
    -- CImplAtoMMC2              1325      11
    -- CImplDebugger             2342      11
    -- CImplVGA80x40              116
    -- CImplSID                   826       2
    -- CImplHWScrolling            90
    -- CImplMouse                 250       1
    -- CImplUart                  167
    -- CImplDoubleVideo           -35       4
    -- CImplVIA                   254
    -- CImplLEDs                  131
    -- CImplProfilingCounters     174
    -- CImplRTC                   173
    -- CImplSAM                   136
    -- CImplPAM                    28
    -- CImplPalette               100
    -- CImplConfig                104

    -- When both AtoMMC2 and Debugger are included, we need to disable other
    -- features to make space
    constant CImplMakeSpace         : boolean := CImplAtoMMC2 and CImplDebugger;

    -- GODIL features
    constant CImplGraphicsExt       : boolean := true;
    constant CImplSoftChar          : boolean := true;
    constant CImplVGA80x40          : boolean := true;
    constant CImplSID               : boolean := not CImplMakeSpace;
    constant CImplHWScrolling       : boolean := true;
    constant CImplMouse             : boolean := not CImplMakeSpace;
    constant CImplUart              : boolean := true;
    constant CImplDoubleVideo       : boolean := true;

    -- Atom2K18 features
    constant CImplVIA               : boolean := true;
    constant CImplLEDs              : boolean := true;
    constant CImplProfilingCounters : boolean := true;
    constant CImplRTC               : boolean := true;
    constant CImplSAM               : boolean := true;
    constant CImplPAM               : boolean := true;
    constant CImplPalette           : boolean := true;
    constant CImplConfig            : boolean := true;

    ------------------------------------------------
    -- Signals
    ------------------------------------------------

    -- Clock generation
    signal clk0            : std_logic;
    signal clk1            : std_logic;
    signal clk2            : std_logic;
    signal clkfb           : std_logic;
    signal clkfb_buf       : std_logic;
    signal clkin_buf       : std_logic;
    signal clock_16        : std_logic;
    signal clock_25        : std_logic;
    signal clock_32        : std_logic;
    signal clock_debugger  : std_logic;

    -- Reset generation
    signal reset_n         : std_logic;
    signal int_reset_n     : std_logic;
    signal ext_reset_n     : std_logic;
    signal powerup_reset_n : std_logic;
    signal reset_counter   : std_logic_vector(9 downto 0);

    -- External bus interface
    signal phi2            : std_logic;
    signal rnw             : std_logic;
    signal sync            : std_logic;
    -- 16 bit address generated by the CPU
    signal cpu_a           : std_logic_vector(15 downto 0);
    -- 19 bit external address generated by the RamRom
    signal extern_a        : std_logic_vector(18 downto 0);
    signal extern_din      : std_logic_vector(7 downto 0);
    signal extern_dout     : std_logic_vector(7 downto 0);
    signal extern_bus      : std_logic;
    signal extern_ce       : std_logic;
    signal extern_we       : std_logic;

    -- Audio mixer and DAC
    constant dacwidth      : integer := 16; -- this needs to match the MCP4822 frame size

    signal atom_audio      : std_logic;
    signal sid_audio       : std_logic_vector(17 downto 0);
    signal cycle           : std_logic_vector(6 downto 0);
    signal audio_l         : std_logic_vector(dacwidth - 1 downto 0);
    signal audio_r         : std_logic_vector(dacwidth - 1 downto 0);
    signal dac_shift_reg_l : std_logic_vector(dacwidth - 1 downto 0);
    signal dac_shift_reg_r : std_logic_vector(dacwidth - 1 downto 0);

    -- Matrix Keyboard
    signal ps2_kbd_enable  : std_logic;
    signal ps2_kbd_clk     : std_logic;
    signal ps2_kbd_data    : std_logic;
    signal int_kbd_pb      : std_logic_vector(7 downto 0);
    signal int_kbd_pc      : std_logic_vector(6 downto 6);

    -- External devices
    signal extern_rom      : std_logic;
    signal extern_ram      : std_logic;
    signal extern_tube     : std_logic;
    signal extern_via      : std_logic;
    signal extern_pam      : std_logic; -- enable for #B1xx
    signal extern_sam_rd   : std_logic; -- enable for #BFF0
    signal extern_sam_wr   : std_logic; -- enable for #BFF1

    -- Internal devices
    signal intern_led      : std_logic;
    signal intern_rtc      : std_logic;
    signal intern_pam_reg0 : std_logic; -- enable for #BFF8
    signal intern_pam_reg1 : std_logic; -- enable for #BFF9
    signal intern_sam_reg  : std_logic; -- enable for #BFF2
    signal intern_palette  : std_logic; -- enable for #BD0x
    signal intern_config   : std_logic; -- enable for #BFFB

    -- Reconfiguration
    signal config_data     : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(DESIGN_NUM, 8));

    -- Colour palette registers
    signal palette_data    : std_logic_vector(7 downto 0);
    signal logical_colour  : std_logic_vector(3 downto 0);
    signal physical_colour : std_logic_vector(5 downto 0);

    type palette_type is array (0 to 15) of std_logic_vector(5 downto 0);

    signal palette : palette_type := (
        0  => "000000",
        1  => "000011",
        2  => "000100",
        3  => "000111",
        4  => "001000",
        5  => "001011",
        6  => "001100",
        7  => "001111",
        8  => "110000",
        9  => "110011",
        10 => "110100",
        11 => "110111",
        12 => "111000",
        13 => "111011",
        14 => "111100",
        15 => "111111"
        );

    -- Video
    signal vga_blank       : std_logic;
    signal hsync_vga       : std_logic;
    signal vsync_vga       : std_logic;
    signal red_vga         : std_logic_vector(2 downto 0);
    signal green_vga       : std_logic_vector(2 downto 0);
    signal blue_vga        : std_logic_vector(2 downto 0);

    -- PAM relayed signals
    signal pam_page        : std_logic_vector(8 downto 0);

    -- SAM related signals
    signal sam_rd_addr     : std_logic_vector(17 downto 0);
    signal sam_rd_next     : std_logic_vector(17 downto 0);
    signal sam_rd_inc      : std_logic;
    signal sam_wr_addr     : std_logic_vector(17 downto 0);
    signal sam_wr_next     : std_logic_vector(17 downto 0);
    signal sam_wr_inc      : std_logic;
    signal sam_empty       : std_logic;
    signal sam_full        : std_logic;
    signal sam_underflow   : std_logic;
    signal sam_overflow    : std_logic;
    signal sam_status      : std_logic_vector(7 downto 0);

    -- Switch debouncing
    signal sw_pressed      : std_logic_vector(2 downto 1);

    -- LED control/ Speedometer
    signal led_ctrl_reg    : std_logic_vector(7 downto 0);
    signal led_data_reg    : std_logic_vector(7 downto 0);
    signal last_sync       : std_logic;
    signal instr_count     : unsigned(15 downto 0);
    signal led_state       : unsigned(3 downto 0);
    signal led_data        : std_logic_vector(7 downto 0);

    -- RTC
    signal rtc_seconds     : std_logic_vector(7 downto 0);
    signal rtc_minutes     : std_logic_vector(7 downto 0);
    signal rtc_hours       : std_logic_vector(7 downto 0);
    signal rtc_day         : std_logic_vector(7 downto 0) := x"01";
    signal rtc_month       : std_logic_vector(7 downto 0) := x"01";
    signal rtc_year        : std_logic_vector(7 downto 0);
    signal rtc_irq_flags   : std_logic_vector(7 downto 0);
    signal rtc_control     : std_logic_vector(7 downto 0);
    signal rtc_10hz        : std_logic_vector(3 downto 0);
    signal rtc_cnt         : std_logic_vector(21 downto 0);
    signal rtc_irq_n       : std_logic := '1';
    signal rtc_data        : std_logic_vector(7 downto 0);

    -- Interrupt logic
    signal irq_n           : std_logic := '1';

    -- Debug mode
    signal remote_access   : std_logic;
    signal debug_mode      : std_logic;

begin

    ------------------------------------------------
    -- Clock generation
    --
    -- from the on-board 50MHz Oscillator
    -- using a PLL for the 16/32 MHz
    -- using a DCM for the 25.175 MHz (approx)
    ------------------------------------------------

    inst_clkin_buf : IBUFG
        port map (
            I => clk_50,
            O => clkin_buf
            );

    inst_PLL : PLL_BASE
        generic map (
            BANDWIDTH            => "OPTIMIZED",
            CLK_FEEDBACK         => "CLKFBOUT",
            COMPENSATION         => "SYSTEM_SYNCHRONOUS",
            DIVCLK_DIVIDE        => 1,
            CLKFBOUT_MULT        => 16,      -- 50 * 16 = 800
            CLKFBOUT_PHASE       => 0.000,
            CLKOUT0_DIVIDE       => 50,      -- 800 / 50 = 16MHz
            CLKOUT0_PHASE        => 0.000,
            CLKOUT0_DUTY_CYCLE   => 0.500,
            CLKOUT1_DIVIDE       => 25,      -- 800 / 25 = 32MHz
            CLKOUT1_PHASE        => 0.000,
            CLKOUT1_DUTY_CYCLE   => 0.500,
            CLKOUT2_DIVIDE       => 31,      -- 800 / 31 = 25.0864MHz
            CLKOUT2_PHASE        => 0.000,
            CLKOUT2_DUTY_CYCLE   => 0.500,
            CLKIN_PERIOD         => 20.000,
            REF_JITTER           => 0.010
            )
        port map (
            -- Output clocks
            CLKFBOUT            => clkfb,
            CLKOUT0             => clk0,
            CLKOUT1             => clk1,
            CLKOUT2             => clk2,
            RST                 => '0',
            -- Input clock control
            CLKFBIN             => clkfb_buf,
            CLKIN               => clkin_buf
            );

    inst_clkfb_buf : BUFG
        port map (
            I => clkfb,
            O => clkfb_buf
            );

    inst_clk0_buf : BUFG
        port map (
            I => clk0,
            O => clock_16
            );

    inst_clk1_buf : BUFG
        port map (
            I => clk1,
            O => clock_32
            );

    inst_clk2_buf : BUFG
        port map (
            I => clk2,
            O => clock_debugger
            );

    inst_DCM : DCM
        generic map (
            CLKFX_MULTIPLY   => 11,
            CLKFX_DIVIDE     => 14,
            CLKIN_PERIOD     => 31.250,
            CLK_FEEDBACK     => "NONE"
            )
        port map (
            CLKIN            => clock_32,
            CLKFB            => '0',
            RST              => '0',
            DSSEN            => '0',
            PSINCDEC         => '0',
            PSEN             => '0',
            PSCLK            => '0',
            CLKFX            => clock_25
            );

    --------------------------------------------------------
    -- Reset generation
    --------------------------------------------------------

    -- The external reset signal is not asserted on power up
    -- This internal counter forces power up reset to happen
    -- This is needed by AtomGodilVideo to initialize some of the registers

    process (clock_32)
    begin
        if rising_edge(clock_32) then
            if (reset_counter(reset_counter'high) = '0') then
                reset_counter <= reset_counter + 1;
            end if;
            powerup_reset_n <= reset_counter(reset_counter'high);
            -- logically or the internal and external resets, for use in this file
            -- this is now synchronised to the 32MHz clock
            reset_n <= ext_reset_n and int_reset_n;
        end if;
    end process;

    -- logically or the powerup and bus resets, to pass down to the core
    ext_reset_n <= powerup_reset_n and bus_rst_n;

    -- Drive the external reset low when there's a power up reset, or
    -- when int_reset_n (currently just F10 on the PS/2 keyboard).
    -- Otherwise, it becomes and input (there's a 3K3 external pullup)
    bus_rst_n <= '0' when powerup_reset_n = '0' or int_reset_n = '0' else 'Z';

    ------------------------------------------------
    -- Atom FPGA Core
    ------------------------------------------------

    inst_AtomFpga_Core : entity work.AtomFpga_Core
    generic map (
        CImplCpu65c02           => CImplCpu65c02,
        CImplDebugger           => CImplDebugger,
        CImplSDDOS              => false,
        CImplAtoMMC2            => CImplAtoMMC2,
        CImplGraphicsExt        => CImplGraphicsExt,
        CImplSoftChar           => CImplSoftChar,
        CImplSID                => CImplSID,
        CImplVGA80x40           => CImplVGA80x40,
        CImplHWScrolling        => CImplHWScrolling,
        CImplMouse              => CImplMouse,
        CImplUart               => CImplUart,
        CImplDoubleVideo        => CImplDoubleVideo,
        CImplRamRomNone         => false,
        CImplRamRomPhill        => false,
        CImplRamRomAtom2015     => true,
        CImplRamRomSchakelKaart => false,
        CImplVIA                => CImplVIA,
        CImplProfilingCounters  => CImplProfilingCounters,
        MainClockSpeed          => 32000000,
        DefaultBaud             => 115200
     )
     port map(
        clk_vga             => clock_25,
        clk_main            => clock_32,
        clk_avr             => clock_32,        -- this is the AtoMMC AVR clock
        clk_avr_debug       => clock_debugger,  -- this is the ICE6502 AVR clock
        clk_dac             => clock_32,
        clk_32M00           => clock_32,

        kbd_pa              => kbd_pa,
        kbd_pb              => int_kbd_pb,
        kbd_pc              => int_kbd_pc,

        ps2_clk             => ps2_kbd_clk,
        ps2_data            => ps2_kbd_data,
        ps2_mouse_clk       => ps2_mouse_clk,
        ps2_mouse_data      => ps2_mouse_data,

        powerup_reset_n     => powerup_reset_n,
        ext_reset_n         => ext_reset_n,
        int_reset_n         => int_reset_n,

        red                 => red_vga,
        green               => green_vga,
        blue                => blue_vga,
        vsync               => vsync_vga,
        hsync               => hsync_vga,
        blank               => vga_blank,

        phi2                => phi2,
        sync                => sync,
        rnw                 => rnw,
        rdy                 => bus_rdy,
        so                  => bus_so,
        irq_n               => irq_n,
        nmi_n               => bus_nmi_n,
        addr                => cpu_a,

        ExternBus           => extern_bus,      -- active high external bus select
        ExternCE            => extern_ce,       -- active high Ram/Rom chip select
        ExternWE            => extern_we,       -- active high Ram/Rom write
        ExternA             => extern_a,
        ExternDin           => extern_din,
        ExternDout          => extern_dout,

        sid_audio           => open,
        sid_audio_d         => sid_audio,
        atom_audio          => atom_audio,

        SDMISO              => mmc_miso,
        SDSS                => mmc_ss,
        SDCLK               => mmc_clk,
        SDMOSI              => mmc_mosi,

        uart_RxD            => serial_rx,
        uart_TxD            => serial_tx,

        avr_RxD             => avr_rx,
        avr_TxD             => avr_tx,

        cas_in              => cas_in,
        cas_out             => cas_out,

        LED1                => mmc_led_green,
        LED2                => mmc_led_red,

        charSet             => '1'
        );

    ------------------------------------------------
    -- External bus
    ------------------------------------------------

    -- 22/4/2019
    --
    -- I'm not happy with the design of the external bus interface, for the
    -- following reasons:
    --
    -- 1. extern_we and extern_ce are mediated by the pluggable RAMROM modules
    --    in AtomFpga_Core. This means they are not active when external devices
    --    in Bxxx are accessed.
    --
    -- 2. As a work around, I've exposed the 6502 RNW (rnw) signal directly,
    --    which is probably the right thing to do, as Atom2K18 does have a full
    --    external bus. But it's now confusing as to when to use extern_we and
    --    when to use rnw.
    --
    -- 3. It's not clear how addresses on extern_a correspond to what the CPU
    --    accessed, again because this signal is the output of a RAMROM module.
    --
    -- 4. It seemed wrong to have to add ExternTube and ExternVIA signals to the
    --    AtomFpga_Core. It should have been possible to implement these externally
    --    in the FPGA target specific wrapper. But (3) made this difficult.
    --
    -- 5. The NRDS and NWDS signals are currently generated from the RAMROM
    --    specific extern_ce and extern_we. It would be better if they uses
    --    rnw and ignored extern_ce. But this is more dangerous, so lets
    --    see how the current version works before breaking things more!
    --
    -- What's in place currently will work (I think) for the VIA and Tube, but
    -- will not currently allow any devices to be added to the bus. Need to
    -- talk with Roland about how he thinks the external bus should be mapped
    -- into the Atom address space.
    --
    -- 22/4/2019
    --
    -- Roland's reply:
    --
    -- All addresses from #B000 - #BFFF should be external except for:
    -- #B000 - #B003 (8255)
    -- #B400 - #B403 (AtoMMC)
    -- #B800 - #B80F (6522)
    -- #BD00 - #BDFF (Godil + reserved address space)
    -- #BFF0 - #BFFF (control registers, some addresses are reserved)
    --
    -- 23/4/2019
    --
    -- For consistency, I ended up using a minimum of 16-byte blocks.
    -- This is all implemented in AtomFpga_Core
    --
    -- To answer my concerns above
    -- 1. This is resolved by adding a seperate ExternBus output from the core
    -- 2. I'm happy exposing RNW directly
    -- 3. The RamRom modules should just output the CPU address when not selected
    -- 4. ExternVia and ExternTube replaced with ExternBus
    -- 5. Use ExternCE/ExternWE (for RamRom) and ExternBus/rnw (for Bus)

    bus_phi2    <= phi2;
    bus_rnw     <= rnw;
    bus_sync    <= sync;

    -- Used on the bus to enable I/O devices in a safe manner
    bus_blk_b   <= not extern_bus;

    bus_a       <= "1" & sam_rd_addr                      when extern_sam_rd = '1' and rnw = '1' and CImplSAM else
                   "1" & sam_wr_addr                      when extern_sam_wr = '1' and rnw = '0' and CImplSAM else
                   "00" & pam_page & extern_a(7 downto 0) when extern_pam = '1'                  and CImplPAM else
                   extern_a;

    -- Enable data out of the FPGA onto the 3.3V databus in the following cases:
    -- case 1. all writes from the "core"
    -- case 2. reads that are internal to the "core", when debug mode enables
    -- case 3. reads of the led registers, when debug mode enabled
    -- case 4. reads of the rtc registers, when debug mode enabled
    bus_d       <= extern_din               when phi2 = '1' and rnw = '0'                                                                  else
                   extern_din               when phi2 = '1' and extern_ce = '0' and extern_bus = '0' and debug_mode = '1'                  else
                   led_data                 when phi2 = '1' and intern_led = '1'                     and debug_mode = '1' and CImplLEDs    else
                   rtc_data                 when phi2 = '1' and intern_rtc = '1'                     and debug_mode = '1' and CImplRTC     else
                   palette_data             when phi2 = '1' and intern_palette = '1'                 and debug_mode = '1' and CImplPalette else
                   config_data              when phi2 = '1' and intern_config = '1'                  and debug_mode = '1' and CImplConfig  else
                   sam_status               when phi2 = '1' and intern_sam_reg = '1'                 and debug_mode = '1' and CImplSAM     else
                   pam_page(7 downto 0)     when phi2 = '1' and intern_pam_reg0 = '1'                and debug_mode = '1' and CImplPAM     else
                   "0000000" & pam_page(8)  when phi2 = '1' and intern_pam_reg1 = '1'                and debug_mode = '1' and CImplPAM     else
                   "ZZZZZZZZ";

    bus_nrds    <= '0' when extern_ce  = '1' and extern_we = '0' and phi2 = '1' else -- RamRom
                   '0' when extern_bus = '1' and rnw       = '1' and phi2 = '1' else -- Bus
                   '1';

    bus_nwds    <= '0' when extern_ce  = '1' and extern_we = '1' and phi2 = '1' else -- RamRom
                   '0' when extern_bus = '1' and rnw       = '0' and phi2 = '1' else -- Bus
                   '1';

    -- data back into the Atom Core
    extern_dout <= led_data                when                       intern_led = '1' and CImplLEDs    else
                   rtc_data                when                       intern_rtc = '1' and CImplRTC     else
                   palette_data            when                   intern_palette = '1' and CImplPalette else
                   config_data             when                    intern_config = '1' and CImplConfig  else
                   sam_status              when                   intern_sam_reg = '1' and CImplSAM     else
                   pam_page(7 downto 0)    when                  intern_pam_reg0 = '1' and CImplPAM     else
                   "0000000" & pam_page(8) when                  intern_pam_reg1 = '1' and CImplPAM     else
                   bus_d;

    ------------------------------------------------
    -- Interrupt logic
    ------------------------------------------------

    irq_n <= bus_irq_n and rtc_irq_n;

    ------------------------------------------------
    -- Sequential Access Memory (SAM)
    ------------------------------------------------

    sam_block: if CImplSAM generate

        process(clock_32)
        begin
            if rising_edge(clock_32) then
                if intern_sam_reg = '1' and rnw = '0' and phi2 = '1' then
                    -- a write of '1' to SAM control register bit 0 clears the overflow error
                    if extern_din(0) = '1' then
                        sam_overflow <= '0';
                    end if;
                    -- a write of '1' to SAM control register bit 1 clears the underflow error
                    if extern_din(1) = '1' then
                        sam_underflow <= '0';
                    end if;
                    -- a write of '1' to SAM control register bit 2 resets everything
                    if extern_din(2) = '1' then
                        sam_rd_inc    <= '0';
                        sam_wr_inc    <= '0';
                        sam_rd_addr   <= (others => '0');
                        sam_wr_addr   <= (others => '0');
                        sam_underflow <= '0';
                        sam_overflow  <= '0';
                    end if;
                elsif extern_sam_rd = '1' and rnw = '1' and phi2 = '1' then
                    -- a read from the SAM data register
                    if sam_empty = '0' then
                        sam_rd_inc <= '1';
                    else
                        sam_underflow <= '1';
                    end if;
                elsif extern_sam_wr = '1' and rnw = '0' and phi2 = '1' then
                    -- a write to the SAM data register
                    if sam_full = '0' then
                        sam_wr_inc <= '1';
                    else
                        sam_overflow <= '1';
                    end if;
                elsif phi2 = '0' then
                    -- Handle the update of the SAM addresses as soon as Phi2 goes
                    -- low at the start of the next bus cycle
                    if sam_rd_inc = '1' then
                        sam_rd_addr <= sam_rd_next;
                    end if;
                    if sam_wr_inc = '1' then
                        sam_wr_addr <= sam_wr_next;
                    end if;
                    -- clear the inc flags, so we only increment by one
                    sam_rd_inc <= '0';
                    sam_wr_inc <= '0';
                end if;
            end if;
        end process;

        -- combinatorial logic for full,empty flags
        process(sam_rd_addr, sam_wr_addr)
        begin
            if sam_rd_addr = sam_wr_addr then
                sam_empty <= '1';
            else
                sam_empty <= '0';
            end if;
            if sam_wr_next = sam_rd_addr then
                sam_full <= '1';
            else
                sam_full <= '0';
            end if;
        end process;

        -- combinatorial logic for next rd address
        process(sam_rd_addr)
        begin
            sam_rd_next <= sam_rd_addr + 1;
        end process;

        -- combinatorial logic for next write address
        process(sam_wr_addr)
        begin
            sam_wr_next <= sam_wr_addr + 1;
        end process;

        -- Status byte
        sam_status <= sam_empty & sam_full & "0000" & sam_underflow & sam_overflow;

    end generate;

    ------------------------------------------------
    -- Page Access Memory (PAM)
    ------------------------------------------------

    pam_block: if CImplPAM generate
        process(clock_32)
        begin
            if rising_edge(clock_32) then
                if rnw = '0' and phi2 = '1' then
                    if intern_pam_reg0 = '1' then
                        pam_page(7 downto 0) <= extern_din;
                    end if;
                    if intern_pam_reg1 = '1' then
                        pam_page(8) <= extern_din(0);
                    end if;
                end if;
            end if;
        end process;
    end generate;

    ------------------------------------------------
    -- Internal device chip selects
    ------------------------------------------------

    intern_led      <= '1' when extern_bus = '1' and extern_a(15 downto 4) = x"BFE"  and CImplLEDs    else '0';
    intern_rtc      <= '1' when extern_bus = '1' and extern_a(15 downto 4) = x"BFD"  and CImplRTC     else '0';
    intern_sam_reg  <= '1' when extern_bus = '1' and extern_a(15 downto 0) = x"BFF2" and CImplSAM     else '0';
    intern_pam_reg0 <= '1' when extern_bus = '1' and extern_a(15 downto 0) = x"BFF8" and CImplPAM     else '0';
    intern_pam_reg1 <= '1' when extern_bus = '1' and extern_a(15 downto 0) = x"BFF9" and CImplPAM     else '0';
    intern_palette  <= '1' when extern_bus = '1' and extern_a(15 downto 4) = x"BD0"  and CImplPalette else '0';
    intern_config   <= '1' when extern_bus = '1' and extern_a(15 downto 0) = x"BFFB" and CImplConfig  else '0';

    ------------------------------------------------
    -- External device chip selects
    ------------------------------------------------

    extern_rom    <= '1' when extern_ce  = '1' and extern_a(17) = '0' else
                     '0';

    extern_ram    <= '1' when extern_ce  = '1' and extern_a(17) = '1'                   else
                     '1' when (extern_sam_rd = '1' or extern_sam_wr = '1') and CImplSAM else
                     '1' when extern_pam = '1'                             and CImplPAM else
                     '0';

    extern_via    <= '1' when extern_bus = '1' and extern_a(15 downto 4) = x"B81" else
                     '0';

    extern_tube   <= '1' when extern_bus = '1' and extern_a(15 downto 4) = x"BEE" else
                     '0';

    extern_sam_rd <= '1' when extern_bus = '1' and extern_a(15 downto 0) = x"BFF0" and CImplSAM else
                     '0';

    extern_sam_wr <= '1' when extern_bus = '1' and extern_a(15 downto 0) = x"BFF1" and CImplSAM else
                     '0';

    extern_pam    <= '1' when extern_bus = '1' and extern_a(15 downto 8) = x"B1" and CImplPAM else
                     '0';

    cs_rom_n    <= not(extern_rom);
    cs_ram_n    <= not(extern_ram);
    cs_via_n    <= not(extern_via);
    cs_tube_n   <= not(extern_tube);

    -- A remote access is to a device on the far side of the data buffers
    -- The tube is on the near side of the data buffers, so exclude
    -- The LED and RTC registers are internal to this module, so exclude
    remote_access <= '1' when extern_bus = '1' and extern_tube = '0' and extern_sam_rd = '0' and extern_sam_wr = '0' and extern_pam = '0' and
                              intern_led = '0' and intern_rtc = '0' and intern_palette = '0' and intern_config = '0' and intern_sam_reg = '0' and
                              intern_pam_reg0 = '0' and intern_pam_reg1 = '0' else '0';

    -- In normal mode, enable the data buffers only for remote accesses.
    -- In debug mode, enable the data buffers all the time.
    cs_buf_n    <= '0' when phi2 = '1' and                         debug_mode = '1' else
                   '0' when phi2 = '1' and remote_access = '1' and debug_mode = '0' else
                   '1';

    -- In normal mode, the direction is inward for reads, outward for writes.
    -- In debug mode, the direction is inward for remote reads, outward for everything else.
    buf_dir     <= '1' when remote_access = '1' and rnw = '1' and debug_mode = '1' else
                   '0' when debug_mode = '1' else
                    rnw;
    ------------------------------------------------
    -- Audio mixer
    ------------------------------------------------

    process(atom_audio, sid_audio)
        variable l : std_logic_vector(dacwidth - 1 downto 0);
        variable r : std_logic_vector(dacwidth - 1 downto 0);
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
        if CImplSID then
            l := l + sid_audio(17 downto 2);
            r := r + sid_audio(17 downto 2);
        else
            l := l + x"8000";
            r := r + x"8000";
        end if;
        -- Currently the left and right channels are identical
        audio_l <= l;
        audio_r <= r;
    end process;

    ------------------------------------------------
    -- MCP4822 SPI 12-bit DAC
    --
    -- note: this actually takes 16-bit samples
    ------------------------------------------------

    process(clock_16)
    begin
        if rising_edge(clock_16) then
            cycle <= cycle + 1;
            if (unsigned(cycle(5 downto 0)) < 33) then
                dac_cs_n <= '0';
                dac_sck <= cycle(0);
            else
                dac_cs_n <= '1';
                dac_sck <= '0';
            end if;

            if (cycle(0) = '0') then
                if (unsigned(cycle(5 downto 1)) = 0) then
                    if (cycle(6) = '0') then
                        dac_shift_reg_l <= audio_l;
                        dac_shift_reg_r <= audio_r;
                    end if;
                    dac_sdi <= cycle(6);
                elsif (unsigned(cycle(5 downto 1)) < 4) then
                    dac_sdi <= '1';
                elsif (unsigned(cycle(5 downto 1)) < 16) then
                    if (cycle(6) = '0') then
                        dac_sdi <= dac_shift_reg_l(dacwidth - 1);
                        dac_shift_reg_l <= dac_shift_reg_l(dacwidth - 2 downto 0) & '0';
                    else
                        dac_sdi <= dac_shift_reg_r(dacwidth - 1);
                        dac_shift_reg_r <= dac_shift_reg_r(dacwidth - 2 downto 0) & '0';
                    end if;
                else
                    dac_sdi <= '0';
                end if;
                if (unsigned(cycle(6 downto 1)) = 60) then
                    dac_ldac_n <= '0';
                else
                    dac_ldac_n <= '1';
                end if;
            end if;
        end if;
     end process;

    ------------------------------------------------
    -- Atom Audio
    ------------------------------------------------

    audio <= atom_audio;

    ------------------------------------------------
    -- Keyboard
    ------------------------------------------------

    process(clock_32)
    begin
        if rising_edge(clock_32) then
            if powerup_reset_n = '0' then
                -- PC(7) linked to ground indicates a PS/2 keyboard should be used
                ps2_kbd_enable <= not kbd_pc(6);
            end if;
        end if;
    end process;

    -- Enable/Disable the PS/2 keyboard
    ps2_kbd_clk  <= kbd_pb(6) when ps2_kbd_enable = '1' else '1';
    ps2_kbd_data <= kbd_pb(7) when ps2_kbd_enable = '1' else '1';

    -- Enable/Disable the Matrix keyboard
    int_kbd_pb   <= kbd_pb when ps2_kbd_enable = '0' else (others => '1');
    int_kbd_pc   <= kbd_pc when ps2_kbd_enable = '0' else (others => '1');

    --------------------------------------------------------
    -- LED control / speedometer
    --------------------------------------------------------

    leds_block: if CImplLEDs generate

        inst_debounce1 : entity work.debounce
            generic map (
                counter_size => 20 -- 32ms @ 32MHz
                )
            port map (
                clock   => clock_32,
                button  => sw(1),
                pressed => sw_pressed(1)
                );

        inst_debounce2 : entity work.debounce
            generic map (
                counter_size => 20 -- 32ms @ 32MHz
                )
            port map (
                clock   => clock_32,
                button  => sw(2),
                pressed => sw_pressed(2)
                );

        process(clock_32)
        begin
            if rising_edge(clock_32) then
                -- SW1/2 manually increment/decrement bits 0/1 of the LED control register
                if sw_pressed(1) = '1' then
                    led_ctrl_reg(1 downto 0) <= led_ctrl_reg(1 downto 0) - 1;
                elsif sw_pressed(2) = '1' then
                    led_ctrl_reg(1 downto 0) <= led_ctrl_reg(1 downto 0) + 1;
                end if;
                -- LED control/data registers
                if intern_led = '1' and rnw = '0' and phi2 = '1' then
                    if extern_a(0) = '1' then
                        led_data_reg <= extern_din;
                    else
                        led_ctrl_reg <= extern_din;
                    end if;
                end if;
                -- LED Speedometer
                last_sync <= sync;
                if last_sync = '0' and sync = '1' then
                    instr_count <= instr_count + 1;
                    if instr_count = 0 then
                        if led_state = x"D" then
                            led_state <= (others => '0');
                        else
                            led_state <= led_state + 1;
                        end if;
                    end if;
                end if;
                -- LED driver logic
                case led_ctrl_reg(1 downto 0) is
                    when "01" =>
                        case led_state is
                            when x"0"   => led <= "01000000";
                            when x"1"   => led <= "10000000";
                            when x"2"   => led <= "01000000";
                            when x"3"   => led <= "00100000";
                            when x"4"   => led <= "00010000";
                            when x"5"   => led <= "00001000";
                            when x"6"   => led <= "00000100";
                            when x"7"   => led <= "00000010";
                            when x"8"   => led <= "00000001";
                            when x"9"   => led <= "00000010";
                            when x"A"   => led <= "00000100";
                            when x"B"   => led <= "00001000";
                            when x"C"   => led <= "00010000";
                            when x"D"   => led <= "00100000";
                            when others => led <= "00000000";
                        end case;
                    when "10" =>
                        led <= cpu_a(15 downto 8);
                    when "11" =>
                        led <= cpu_a(7 downto 0);
                    when others =>
                        led <= led_data_reg;
                end case;
            end if;
        end process;

        led_data <= led_ctrl_reg when extern_a(0) = '0' else
                    led_data_reg when extern_a(1) = '1' else
                    x"00";

        -- Enable debug mode (logic analyzer output to data bus)in address mode
        -- (when the LEDs are showing the low or high address bus)
        debug_mode <= led_ctrl_reg(1);
    end generate;

    not_leds_block: if not CImplLEDs generate
        led        <= x"00";
        debug_mode <= '0';
    end generate;

    --------------------------------------------------------
    -- RTC Real Time Clock
    --------------------------------------------------------

    rtc_block: if CImplRTC generate
        process (clock_32)
        begin
            if rising_edge(clock_32) then

                if rtc_control(7) = '0' then
                    if rtc_cnt = 3199999 then
                        rtc_cnt <= (others => '0');
                        rtc_10hz <= rtc_10hz + 1;
                        if  rtc_control(0) = '1' then
                            rtc_irq_flags(0) <= '1';
                            rtc_irq_flags(7) <= '1';
                        end if;
                    else
                        rtc_cnt <= rtc_cnt + 1;
                    end if;
                    if rtc_10hz = 10 then
                        rtc_seconds <= rtc_seconds + 1;
                        rtc_10hz <= x"0";
                        if rtc_control(1) = '1' then
                            rtc_irq_flags(1) <= '1';
                            rtc_irq_flags(7) <= '1';
                        end if;
                    end if;
                    if rtc_seconds = 60 then
                        rtc_minutes <= rtc_minutes + 1;
                        rtc_seconds <= x"00";
                        if rtc_control(2) = '1' then
                            rtc_irq_flags(2) <= '1';
                            rtc_irq_flags(7) <= '1';
                        end if;
                    end if;
                    if rtc_minutes = 60 then
                        rtc_hours <= rtc_hours + 1;
                        rtc_minutes <= x"00";
                        if rtc_control(3) = '1' then
                            rtc_irq_flags(3) <= '1';
                            rtc_irq_flags(7) <= '1';
                        end if;
                    end if;
                    if rtc_hours = 24 then
                        rtc_day <= rtc_day + 1;
                        rtc_hours <= x"00";
                        if rtc_control(4) = '1' then
                            rtc_irq_flags(4) <= '1';
                            rtc_irq_flags(7) <= '1';
                        end if;
                    end if;
                    if (rtc_day = 31 and (rtc_month = 4 or rtc_month = 6 or rtc_month = 9 or rtc_month = 11))
                        or (rtc_day = 30 and rtc_month = 2 and rtc_year(1 downto 0) = "00")
                        or (rtc_day = 29 and rtc_month = 2 and (rtc_year(1) = '1' or rtc_year(0) = '1'))          or (rtc_day = 32) then
                        rtc_month <= rtc_month + 1;
                        rtc_day <= x"01";
                        if rtc_control(5) = '1' then
                            rtc_irq_flags(5) <= '1';
                            rtc_irq_flags(7) <= '1';
                        end if;
                    end if;
                    if rtc_month = 13 then
                        rtc_year <= rtc_year + 1;
                        rtc_month <= x"01";
                        if rtc_control(6) = '1' then
                            rtc_irq_flags(6) <= '1';
                            rtc_irq_flags(7) <= '1';
                        end if;
                    end if;
                end if;

                -- write RTC control/data registers
                if intern_rtc = '1' and rnw = '0' and phi2 = '1' then
                    case extern_a(2 downto 0) is
                        when "000" =>
                            rtc_year <= extern_din;
                        when "001" =>
                            rtc_month <= extern_din;
                        when "010" =>
                            rtc_day <= extern_din;
                        when "011" =>
                            rtc_hours <= extern_din;
                        when "100" =>
                            rtc_minutes <= extern_din;
                        when "101" =>
                            rtc_seconds <= extern_din;
                        when "110" =>
                            rtc_control <= extern_din;
                        when others =>
                            rtc_irq_flags <= x"00";
                    end case;
                end if;

                if reset_n = '0' then
                    rtc_control <= x"00";
                    rtc_irq_flags <= x"00";
                end if;

            end if;

        end process;

        rtc_data <= rtc_year      when extern_a(2 downto 0) = "000" else
                    rtc_month     when extern_a(2 downto 0) = "001" else
                    rtc_day       when extern_a(2 downto 0) = "010" else
                    rtc_hours     when extern_a(2 downto 0) = "011" else
                    rtc_minutes   when extern_a(2 downto 0) = "100" else
                    rtc_seconds   when extern_a(2 downto 0) = "101" else
                    rtc_control   when extern_a(2 downto 0) = "110" else
                    rtc_irq_flags when extern_a(2 downto 0) = "111" else
                    x"00";

        rtc_irq_n <= not(rtc_irq_flags(7));
    end generate;

    not_rtc_block: if not CImplRTC generate
        rtc_data  <= x"00";
        rtc_irq_n <= '1';
    end generate;

    --------------------------------------------------------
    -- Colour palette control
    --------------------------------------------------------

    palette_block: if CImplPalette generate
        process (clock_32)
        begin
            if rising_edge(clock_32) then
                if reset_n = '0' then
                    -- initializing like this mean the palette will be
                    -- implemented with LUTs rather than as a block RAM
                    palette(0)  <= "000000";
                    palette(1)  <= "000011";
                    palette(2)  <= "000100";
                    palette(3)  <= "000111";
                    palette(4)  <= "001000";
                    palette(5)  <= "001011";
                    palette(6)  <= "001100";
                    palette(7)  <= "001111";
                    palette(8)  <= "110000";
                    palette(9)  <= "110011";
                    palette(10) <= "110100";
                    palette(11) <= "110111";
                    palette(12) <= "111000";
                    palette(13) <= "111011";
                    palette(14) <= "111100";
                    palette(15) <= "111111";
                else
                    -- write colour palette registers
                    if intern_palette = '1' and rnw = '0' and phi2 = '1' then
                        palette(conv_integer(extern_a(3 downto 0))) <= extern_din(7 downto 2);
                    end if;
                end if;
            end if;
        end process;

        logical_colour <= red_vga(2) & green_vga(2) & green_vga(1) & blue_vga(2);

        -- Making this a synchronous process should improve the timing
        -- and potentially make the pixels more defined
        process (clock_25)
        begin
            if rising_edge(clock_25) then
                if vga_blank = '1' then
                    physical_colour <= (others => '0');
                else
                    physical_colour <= palette(conv_integer(logical_colour));
                end if;
                -- Also register hsync/vsync so they are correctly
                -- aligned with the colour changes
                vga_hsync <= hsync_vga;
                vga_vsync <= vsync_vga;
            end if;
        end process;

        vga_red2   <= physical_colour(5);
        vga_red1   <= physical_colour(4);
        vga_green2 <= physical_colour(3);
        vga_green1 <= physical_colour(2);
        vga_blue2  <= physical_colour(1);
        vga_blue1  <= physical_colour(0);

        palette_data  <= palette(conv_integer(extern_a(3 downto 0))) & "00";

    end generate;

    not_palette_block: if not CImplPalette generate

        vga_hsync  <= hsync_vga;
        vga_vsync  <= vsync_vga;
        vga_red2   <= red_vga(2);
        vga_red1   <= red_vga(1);
        vga_green2 <= green_vga(2);
        vga_green1 <= green_vga(1);
        vga_blue2  <= blue_vga(2);
        vga_blue1  <= blue_vga(1);

    end generate;

    --------------------------------------------------------
    -- Colour palette control
    --------------------------------------------------------

    config_block: if CImplConfig generate

        process (clock_32)
        begin
            if rising_edge(clock_32) then
                -- write RTC control/data registers
                if intern_config = '1' and rnw = '0' and phi2 = '1' then
                    -- Bit 7 triggers the reconfiguration
                    -- Bits 2..0 specify the design (0..7)
                    config_data <= extern_din;
                end if;
            end if;
        end process;

        Inst_ICAP_core: entity work.ICAP_core port map (
            fastclk     => clock_32,
            design_num  => '0' & config_data(2 downto 0),
            reconfigure => config_data(7),
            powerup     => '0',
            sw_in       => x"0"
            );

    end generate;

end behavioral;
