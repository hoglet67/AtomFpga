--------------------------------------------------------------------------------
-- Copyright (c) 2019 David Banks
--
-- based on work by Alan Daly. Copyright(c) 2009. All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : AtomFpga_Core
-- /___/   /\     Timestamp : 02/03/2013 06:17:50
-- \   \  /  \
--  \___\/\___\
--
--Design Name: Atomic_top.vhf
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AtomFpga_Core is
    generic (
       CImplCpu65c02           : boolean := false;
       CImplDebugger           : boolean := false;
       CImplSDDOS              : boolean;
       CImplAtoMMC2            : boolean;
       CImplGraphicsExt        : boolean;
       CImplSoftChar           : boolean;
       CImplSID                : boolean;
       CImplVGA80x40           : boolean;
       CImplHWScrolling        : boolean;
       CImplMouse              : boolean;
       CImplUart               : boolean;
       CImplDoubleVideo        : boolean;
       CImplRamRomNone         : boolean;
       CImplRamRomPhill        : boolean;
       CImplRamRomAtom2015     : boolean;
       CImplRamRomSchakelKaart : boolean;
       CImplHDMI               : boolean := false;
       CImplVIA                : boolean := true;
       CImplProfilingCounters  : boolean := false;
       CImplSampleExternData   : boolean := true;
       MainClockSpeed          : integer;
       DefaultBaud             : integer;
       DefaultTurbo            : std_logic_vector(1 downto 0) := "00"
    );
    port (
        -- Clocking
        clk_vga          : in    std_logic;        -- nominally 25.175MHz VGA clock
        clk_main         : in    std_logic;        -- clock for the main system
        clk_avr          : in    std_logic;        -- clock for the AtoMMC AVR
        clk_avr_debug    : in    std_logic := '0'; -- clock for the Debugger AVR (only needed if CImplDebugger true)
        clk_dac          : in    std_logic;        -- fast clock for the 1-bit DAC
        clk_32M00        : in    std_logic;        -- fixed clock, used for SID and casette
        -- Keyboard/mouse
        kbd_pa           : out   std_logic_vector(3 downto 0);
        kbd_pb           : in    std_logic_vector(7 downto 0) := (others => '1');
        kbd_pc           : in    std_logic_vector(6 downto 6) := (others => '1');
        ps2_clk          : in    std_logic;
        ps2_data         : in    std_logic;
        ps2_mouse_clk    : inout std_logic;
        ps2_mouse_data   : inout std_logic;
        -- Resets
        powerup_reset_n  : in    std_logic := '1'; -- power up reset only (optional)
        ext_reset_n      : in    std_logic := '1'; -- external bus reset (optional)
        int_reset_n      : out   std_logic;        -- internal bus reset (e.g. PS/2 break)
        -- HDMI Video
        hdmi_audio_en    : in    std_logic := '0';
        tmds_r           : out   std_logic_vector(9 downto 0);
        tmds_g           : out   std_logic_vector(9 downto 0);
        tmds_b           : out   std_logic_vector(9 downto 0);
        -- VGA Video
        red              : out   std_logic_vector (2 downto 0);
        green            : out   std_logic_vector (2 downto 0);
        blue             : out   std_logic_vector (2 downto 0);
        vsync            : out   std_logic;
        hsync            : out   std_logic;
        blank            : out   std_logic;
        -- External 6502 bus interface
        phi2             : out   std_logic;
        sync             : out   std_logic;
        rnw              : out   std_logic;
        addr             : out   std_logic_vector(15 downto 0);
        rdy              : in    std_logic := '1';
        so               : in    std_logic := '1';
        irq_n            : in    std_logic := '1';
        nmi_n            : in    std_logic := '1';
        -- External Bus/Ram/Rom interface
        ExternBus        : out   std_logic;
        ExternCE         : out   std_logic;
        ExternWE         : out   std_logic;
        ExternA          : out   std_logic_vector (18 downto 0);
        ExternDin        : out   std_logic_vector (7 downto 0);
        ExternDout       : in    std_logic_vector (7 downto 0);
        -- Audio
        sid_audio_d      : out   std_logic_vector (17 downto 0);
        sid_audio        : out   std_logic;
        atom_audio       : out   std_logic;
        mixed_audio      : out   signed(15 downto 0);
        -- SD Card
        SDMISO           : in    std_logic;
        SDSS             : out   std_logic;
        SDCLK            : out   std_logic;
        SDMOSI           : out   std_logic;
        -- Serial
        uart_RxD         : in    std_logic;
        uart_TxD         : out   std_logic;
        avr_RxD          : in    std_logic;
        avr_TxD          : out   std_logic;
        -- Cassette
        cas_in           : in    std_logic := '0';
        cas_out          : out   std_logic;
        -- Misc
        LED1             : out   std_logic;
        LED2             : out   std_logic;
        charSet          : in    std_logic;
        Joystick1        : in    std_logic_vector (7 downto 0) := (others => '1');
        Joystick2        : in    std_logic_vector (7 downto 0) := (others => '1')
        );
end AtomFpga_Core;

architecture BEHAVIORAL of AtomFpga_Core is

    component hdmi is
        generic (
            FREQ: integer;
            FS: integer;
            CTS: integer;
            N: integer
            );
        port (
            I_CLK_PIXEL    : in std_logic;
            I_R            : in std_logic_vector(7 downto 0);
            I_G            : in std_logic_vector(7 downto 0);
            I_B            : in std_logic_vector(7 downto 0);
            I_BLANK        : in std_logic;
            I_HSYNC        : in std_logic;
            I_VSYNC        : in std_logic;
            I_ASPECT_169   : in std_logic;
            I_AUDIO_ENABLE : in std_logic;
            I_AUDIO_PCM_L  : in std_logic_vector(15 downto 0);
            I_AUDIO_PCM_R  : in std_logic_vector(15 downto 0);
            O_RED          : out std_logic_vector(9 downto 0);
            O_GREEN        : out std_logic_vector(9 downto 0);
            O_BLUE         : out std_logic_vector(9 downto 0)
            );
    end component;

    function InitBFFE_Atom2015 return std_logic_vector is
    begin
        if CImplAtoMMC2 then
            -- Use OS ROM Bank 0 (contains AVR AtoMMC)
            return x"00";
        else
            -- Use OS ROM Bank 1 (contains PIC AtoMMC)
            return x"08";
        end if;
    end function;

-------------------------------------------------
-- Clocks and enables
-------------------------------------------------
    signal clk_counter       : std_logic_vector(4 downto 0) := (others => '0');
    signal cpu_cycle         : std_logic;
    signal cpu_clken         : std_logic;
    signal pia_clken         : std_logic;
    signal sample_data       : std_logic;

-------------------------------------------------
-- CPU signals
-------------------------------------------------
    signal powerup_reset_sync   : std_logic;
    signal powerup_reset_n_sync : std_logic;
    signal ext_reset_n_sync     : std_logic;
    signal RST               : std_logic;
    signal RSTn              : std_logic;
    signal cpu_R_W_n         : std_logic;
    signal not_cpu_R_W_n     : std_logic;
    signal cpu_addr          : std_logic_vector (15 downto 0);
    signal cpu_din           : std_logic_vector (7 downto 0);
    signal cpu_dout          : std_logic_vector (7 downto 0);
    signal cpu_IRQ_n         : std_logic;
    signal cpu_NMI_n         : std_logic;
    signal ExternDin1        : std_logic_vector (7 downto 0);
    signal ExternDout1       : std_logic_vector (7 downto 0);

---------------------------------------------------
-- VDG signals
---------------------------------------------------
    signal vdg_fs_n          : std_logic;
    signal vdg_an_g          : std_logic;
    signal vdg_gm            : std_logic_vector(2 downto 0);
    signal vdg_css           : std_logic;
    signal vdg_red           : std_logic;
    signal vdg_green1        : std_logic;
    signal vdg_green0        : std_logic;
    signal vdg_blue          : std_logic;
    signal vdg_hsync         : std_logic;
    signal vdg_vsync         : std_logic;
    signal vdg_blank         : std_logic;

----------------------------------------------------
-- Device enables
----------------------------------------------------
    signal mc6522_enable     : std_logic;
    signal i8255_enable      : std_logic;
    signal ext_ramrom_enable : std_logic;
    signal ext_bus_enable    : std_logic;
    signal video_ram_enable  : std_logic;
    signal reg_enable        : std_logic;
    signal sid_enable        : std_logic;
    signal uart_enable       : std_logic;
    signal counter_enable    : std_logic;
    signal gated_we          : std_logic;
    signal video_ram_we      : std_logic;
    signal reg_we            : std_logic;
    signal sid_we            : std_logic;
    signal uart_we           : std_logic;

----------------------------------------------------
-- External data
----------------------------------------------------
    signal extern_data       : std_logic_vector(7 downto 0);
    signal godil_data        : std_logic_vector(7 downto 0);

----------------------------------------------------
-- 6522 signals
----------------------------------------------------
    signal via4_clken        : std_logic;
    signal via1_clken        : std_logic;
    signal mc6522_data       : std_logic_vector(7 downto 0);
    signal mc6522_irq        : std_logic;
    signal mc6522_ca1        : std_logic;
    signal mc6522_ca2        : std_logic;
    signal mc6522_cb1        : std_logic;
    signal mc6522_cb2        : std_logic;
    signal mc6522_porta      : std_logic_vector(7 downto 0);
    signal mc6522_portb      : std_logic_vector(7 downto 0);

----------------------------------------------------
-- 8255 signals
----------------------------------------------------
    signal i8255_pa_data     : std_logic_vector(7 downto 0);
    signal i8255_pb_idata    : std_logic_vector(7 downto 0);
    signal i8255_pc_data     : std_logic_vector(7 downto 0);
    signal i8255_pc_idata    : std_logic_vector(7 downto 0);
    signal i8255_data        : std_logic_vector(7 downto 0);
    signal i8255_rd          : std_logic;

    signal ps2dataout        : std_logic_vector(5 downto 0);
    signal key_shift         : std_logic;
    signal key_ctrl          : std_logic;
    signal key_repeat        : std_logic;
    signal key_break         : std_logic;
    signal key_escape        : std_logic;
    signal key_turbo         : std_logic_vector(1 downto 0);

    signal cas_divider       : std_logic_vector(15 downto 0);
    signal cas_tone          : std_logic := '0';

    signal turbo             : std_logic_vector(1 downto 0);
    signal turbo_synced      : std_logic_vector(1 downto 0);

----------------------------------------------------
-- AtoMMC signals
----------------------------------------------------

    signal pl8_enable        : std_logic;
    signal pl8_data          : std_logic_vector (7 downto 0);
    signal uart_escape       : std_logic;
    signal uart_break        : std_logic;
    signal nARD              : std_logic;
    signal nAWR              : std_logic;
    signal AVRA0             : std_logic;
    signal AVRInt            : std_logic;
    signal AVRDataIn         : std_logic_vector (7 downto 0);
    signal AVRDataOut        : std_logic_vector (7 downto 0);
    signal ioport            : std_logic_vector (7 downto 0);
    signal LED1n             : std_logic;
    signal LED2n             : std_logic;
    signal avr_TxD_debugger  : std_logic;
    signal avr_TxD_atommc    : std_logic;

----------------------------------------------------
-- Audio Signals
----------------------------------------------------
    signal sid_audio_d_int  : std_logic_vector (17 downto 0);
    signal sid_audio_int    : std_logic;
    signal atom_audio_int   : std_logic;
    signal mixed_audio_int  : signed (15 downto 0);

----------------------------------------------------
-- Profiling Counter Signals
----------------------------------------------------

    signal p_counter_ctrl    : std_logic_vector  (7 downto 0);
    signal p_counter_data    : std_logic_vector  (7 downto 0);
    signal p_divider_latch   : std_logic_vector (31 downto 0);
    signal p_divider_counter : std_logic_vector (31 downto 0);
    signal p_profile_counter : std_logic_vector (31 downto 0);
    signal p_reset           : std_logic;
    signal p_pause           : std_logic;
    signal p_reset_last      : std_logic;

----------------------------------------------------
-- Unused port bits
----------------------------------------------------

    signal portbout_2_unused : std_logic;
    signal portbout_4_unused : std_logic;
    signal portbout_5_unused : std_logic;
    signal portdout_0_unused : std_logic;
    signal portdout_1_unused : std_logic;
    signal portdout_2_unused : std_logic;
    signal portdout_3_unused : std_logic;
    signal portdout_5_unused : std_logic;
    signal portdout_6_unused : std_logic;
    signal portdout_7_unused : std_logic;

--------------------------------------------------------------------
--                   here it begin :)
--------------------------------------------------------------------

begin

---------------------------------------------------------------------
-- 6502 CPU (using a wrapper module
---------------------------------------------------------------------

    cpu : entity work.CpuWrapper
        generic map (
            CImplDebugger => CImplDebugger,
            CImplCpu65c02 => CImplCpu65c02
            )
        port map (
            clk_main  => clk_main,
            clk_avr   => clk_avr_debug,
            cpu_clken => cpu_clken,
            IRQ_n     => cpu_IRQ_n,
            NMI_n     => nmi_n,
            RST_n     => RSTn,
            PRST_n    => powerup_reset_n_sync,
            SO        => So,
            RDY       => Rdy,
            Din       => cpu_din,
            Dout      => cpu_dout,
            R_W_n     => cpu_R_W_n,
            Sync      => Sync,
            Addr      => cpu_addr,
            avr_RxD   => avr_RxD,
            avr_TxD   => avr_TxD_debugger
        );

    not_cpu_R_W_n <= not cpu_R_W_n;

    cpu_IRQ_n     <= irq_n and mc6522_irq when CImplVIA else
                     irq_n;

    cpu_NMI_n     <= nmi_n;

    avr_TxD       <= avr_TxD_debugger and avr_TxD_atommc;

    -- reset logic
    process(clk_main)
    begin
        if rising_edge(clk_main) then
            powerup_reset_n_sync <= powerup_reset_n;
            ext_reset_n_sync     <= ext_reset_n;
            RSTn                 <= key_break and powerup_reset_n_sync and ext_reset_n_sync;
            int_reset_n          <= key_break;
        end if;
    end process;

    powerup_reset_sync <= not powerup_reset_n_sync;
    RST <= not RSTn;

    -- write enables
    gated_we      <= not_cpu_R_W_n;
    uart_we       <= gated_we;
    video_ram_we  <= gated_we and video_ram_enable;
    reg_we        <= gated_we;
    sid_we        <= gated_we;

    -- external bus
    rnw           <= cpu_R_W_n;
    addr          <= cpu_addr;

---------------------------------------------------------------------
-- Atom GODIL Video adapter
---------------------------------------------------------------------
    Inst_AtomGodilVideo : entity work.AtomGodilVideo
        generic map (
           CImplGraphicsExt => CImplGraphicsExt,
           CImplSoftChar    => CImplSoftChar,
           CImplSID         => CImplSID,
           CImplVGA80x40    => CImplVGA80x40,
           CImplHWScrolling => CImplHWScrolling,
           CImplMouse       => CImplMouse,
           CImplUart        => CImplUart,
           CImplDoubleVideo => CImplDoubleVideo,
           MainClockSpeed   => MainClockSpeed,
           DefaultBaud      => DefaultBaud
        )
        port map (
            clock_vga => clk_vga,
            clock_main => clk_main,
            clock_sid_32Mhz => clk_32M00,
            clock_sid_dac => clk_dac,
            reset => RST,
            reset_vid => powerup_reset_sync,
            din => cpu_dout,
            dout => godil_data,
            addr => cpu_addr(12 downto 0),
            CSS => vdg_css,
            AG => vdg_an_g,
            GM => vdg_gm,
            nFS => vdg_fs_n,
            ram_we => video_ram_we,
            reg_cs => reg_enable,
            reg_we => reg_we,
            sid_cs => sid_enable,
            sid_we => sid_we,
            sid_audio => sid_audio_int,
            sid_audio_d => sid_audio_d_int,
            PS2_CLK => ps2_mouse_clk,
            PS2_DATA => ps2_mouse_data,
            uart_cs => uart_enable,
            uart_we => uart_we,
            uart_RxD => uart_RxD,
            uart_TxD => uart_TxD,
            uart_escape => uart_escape,
            uart_break => uart_break,
            final_red => vdg_red,
            final_green1 => vdg_green1,
            final_green0 => vdg_green0,
            final_blue => vdg_blue,
            final_vsync => vdg_vsync,
            final_hsync => vdg_hsync,
            final_blank => vdg_blank,
            charSet => charSet
            );

    -- Simple audio mixer
    process(atom_audio_int, sid_audio_d_int)
        variable tmp : std_logic_vector(15 downto 0);
    begin
        -- Atom Audio is a single bit
        if (atom_audio_int = '1') then
            tmp := x"1000";
        else
            tmp := x"EFFF";
        end if;
        -- SID output is 18-bit unsigned
        if CImplSID then
            tmp := tmp + sid_audio_d_int(17 downto 2) - x"8000";
        end if;
        mixed_audio_int <= signed(tmp);
    end process;

    -- external ouputs
    red(2 downto 0)   <= vdg_red & vdg_red & vdg_red;
    green(2 downto 0) <= vdg_green1 & vdg_green0 & vdg_green0;
    blue(2 downto 0)  <= vdg_blue & vdg_blue & vdg_blue;
    vsync             <= vdg_vsync;
    hsync             <= vdg_hsync;
    blank             <= vdg_blank;
    sid_audio_d       <= sid_audio_d_int;
    sid_audio         <= sid_audio_int;
    atom_audio        <= atom_audio_int;
    mixed_audio       <= mixed_audio_int;


--------------------------------------------------------
-- HDMI
--------------------------------------------------------

    GenHDMI: if CImplHDMI generate
        signal hdmi_red   : std_logic_vector(7 downto 0);
        signal hdmi_green : std_logic_vector(7 downto 0);
        signal hdmi_blue  : std_logic_vector(7 downto 0);
        signal hdmi_hsync : std_logic;
        signal hdmi_vsync : std_logic;
        signal hdmi_blank : std_logic;
        signal hdmi_audio : std_logic_vector (15 downto 0);
    begin
        hdmi_red   <= vdg_red & vdg_red & vdg_red & "00000";
        hdmi_green <= vdg_green1 & vdg_green0 & vdg_green0 & "00000";
        hdmi_blue  <= vdg_blue & vdg_blue & vdg_blue & "00000";
        hdmi_blank <= vdg_blank;
        hdmi_hsync <= vdg_hsync;
        hdmi_vsync <= vdg_vsync;
        hdmi_audio <= std_logic_vector(mixed_audio_int);

        inst_hdmi : hdmi
            generic map (
                FREQ => 25200000,  -- pixel clock frequency
                FS   => 48000,     -- audio sample rate - should be 32000, 44100 or 48000
                CTS  => 25200,     -- CTS = Freq(pixclk) * N / (128 * Fs)
                N    => 6144       -- N = 128 * Fs /1000,  128 * Fs /1500 <= N <= 128 * Fs /300
                --FS   => 32000,   -- audio sample rate - should be 32000, 44100 or 48000
                --CTS  => 27000,   -- CTS = Freq(pixclk) * N / (128 * Fs)
                --N    => 4096     -- N = 128 * Fs /1000,  128 * Fs /1500 <= N <= 128 * Fs /300
                )
            port map (
                -- clocks
                I_CLK_PIXEL      => clk_vga,
                -- components
                I_R              => hdmi_red,
                I_G              => hdmi_green,
                I_B              => hdmi_blue,
                I_BLANK          => hdmi_blank,
                I_HSYNC          => hdmi_hsync,
                I_VSYNC          => hdmi_vsync,
                I_ASPECT_169     => '0',
                -- PCM audio
                I_AUDIO_ENABLE   => hdmi_audio_en,
                I_AUDIO_PCM_L    => hdmi_audio,
                I_AUDIO_PCM_R    => hdmi_audio,
                -- TMDS parallel pixel synchronous outputs (serialize LSB first)
                O_RED            => tmds_r,
                O_GREEN          => tmds_g,
                O_BLUE           => tmds_b
                );

    end generate;

    GenNotHDMI: if not CImplHDMI generate
        tmds_r <= (others => '0');
        tmds_g <= (others => '0');
        tmds_b <= (others => '0');
    end generate;

---------------------------------------------------------------------
-- 8255 PIA
---------------------------------------------------------------------

    pia : entity work.I82C55 port map(
        I_ADDR => cpu_addr(1 downto 0),  -- A1-A0
        I_DATA => cpu_dout,  -- D7-D0
        O_DATA => i8255_data,
        CS_H   => i8255_enable,
        WR_L   => cpu_R_W_n,
        O_PA   => i8255_pa_data,
        I_PB   => i8255_pb_idata,
        I_PC   => i8255_pc_idata(7 downto 4),
        O_PC   => i8255_pc_data(3 downto 0),
        RESET  => RSTn,
        ENA    => pia_clken,
        CLK    => clk_main);

    -- Port A
    --   bits 7..4 (output) determine the 6847 graphics mode
    --   bits 3..0 (output) drive the keyboard matrix

    vdg_gm        <= i8255_pa_data(7 downto 5) when RSTn='1' else "000";
    vdg_an_g      <= i8255_pa_data(4)          when RSTn='1' else '0';
    kbd_pa        <= i8255_pa_data(3 downto 0);

    -- Port B
    --   bits 7..0 (input) read the keyboard matrix
    i8255_pb_idata <= (key_shift & key_ctrl & ps2dataout) and (kbd_pb);


    -- Port C
    --    bit 7 (input) FS from the 6847
    --    bit 6 (input) Repeat from the keyboard matrix
    --    bit 5 (input) Cassette input
    --    bit 4 (input) 2.4KHz tone input
    --    bit 3 (output) CSS to the 6847
    --    bit 2 (output) Audio
    --    bit 1 (output) Enable 2.4KHz tone to casette output
    --    bit 0 (output) Cassette output
    vdg_css        <= i8255_pc_data(3) when RSTn='1' else '0';
    atom_audio_int <= i8255_pc_data(2);

    i8255_pc_idata <= vdg_fs_n & (key_repeat and kbd_pc(6)) & cas_in & cas_tone & i8255_pc_data (3 downto 0);

    -- Cassette divider
    -- 32 MHz / 2 / 13 / 16 / 16 = 4807 Hz
    process(clk_32M00)
    begin
        if rising_edge(clk_32M00) then
            if cas_divider = 0 then
                cas_divider <= x"19FF";
                cas_tone    <= not cas_tone;
            else
                cas_divider <= cas_divider - 1;
            end if;
        end if;
    end process;

    -- this is a direct translation of the logic in the atom
    -- (two NAND gates and an inverter)
    cas_out <= not(not((not cas_tone) and i8255_pc_data(1)) and i8255_pc_data(0));

---------------------------------------------------------------------
-- PS/2 Keyboard Emulation
---------------------------------------------------------------------

    input : entity work.keyboard
        generic map (
            DefaultTurbo => DefaultTurbo
        )
        port map (
            CLOCK      => clk_main,
            nRESET     => powerup_reset_n_sync,
            CLKEN_1MHZ => cpu_clken,
            PS2_CLK    => ps2_clk,
            PS2_DATA   => ps2_data,
            KEYOUT     => ps2dataout,
            ROW        => i8255_pa_data(3 downto 0),
            ESC_IN     => uart_escape,
            BREAK_IN   => uart_break,
            SHIFT_OUT  => key_shift,
            CTRL_OUT   => key_ctrl,
            REPEAT_OUT => key_repeat,
            BREAK_OUT  => key_break,
            TURBO      => key_turbo,
            ESC_OUT    => key_escape,
            Joystick1  => Joystick1,
            Joystick2  => Joystick2
        );

---------------------------------------------------------------------
-- 6522 VIA
---------------------------------------------------------------------

    Inst_via: if (CImplVIA) generate

        via : entity work.M6522 port map(
            I_RS    => cpu_addr(3 downto 0),
            I_DATA  => cpu_dout,
            O_DATA  => mc6522_data(7 downto 0),
            I_RW_L  => cpu_R_W_n,
            I_CS1   => mc6522_enable,
            I_CS2_L => '0',
            O_IRQ_L => mc6522_irq,
            I_CA1   => mc6522_ca1,
            I_CA2   => mc6522_ca2,
            O_CA2   => mc6522_ca2,
            I_PA    => mc6522_porta(7 downto 0),
            O_PA    => mc6522_porta(7 downto 0),
            I_CB1   => mc6522_cb1,
            O_CB1   => mc6522_cb1,
            I_CB2   => mc6522_cb2,
            O_CB2   => mc6522_cb2,
            I_PB    => mc6522_portb(7 downto 0),
            O_PB    => mc6522_portb(7 downto 0),
            RESET_L => RSTn,
            I_P2_H  => via1_clken,
            ENA_4   => via4_clken,
            CLK     => clk_main);

        mc6522_ca1    <= '1';

    end generate;

--------------------------------------------------------
-- SDDOS
--------------------------------------------------------

    Inst_spi: if (CImplSDDOS) generate
        Inst_spi_comp : entity work.SPI_Port
            port map (
                nRST    => RSTn,
                clk     => clk_main,
                enable  => pl8_enable,
                nwe     => cpu_R_W_n,
                address => cpu_addr(2 downto 0),
                datain  => cpu_dout,
                dataout => pl8_data,
                MISO    => SDMISO,
                MOSI    => SDMOSI,
                NSS     => SDSS,
                SPICLK  => SDCLK
            );
        LED1 <= '0';
        LED2 <= '0';
    end generate;

--------------------------------------------------------
-- AtomMMC
--------------------------------------------------------

    Inst_atommc2: if (CImplAtoMMC2) generate

        Inst_AVR8: entity work.AVR8
        generic map(
            CDATAMEMSIZE      => 4096,
            CPROGMEMSIZE      => 9216,
            FILENAME          => "avr_progmem_atommc2.data",
            CImplPORTA        => TRUE,
            CImplPORTB        => TRUE,
            CImplPORTD        => TRUE,
            CImplPORTE        => TRUE,
            CImplUART         => TRUE,
            CImplSPI          => TRUE,
            CImplExtIRQ       => TRUE
        )
        port map(
            clk16M            => clk_avr,
            nrst              => RSTn,
            portain           => AVRDataOut,
            portaout          => AVRDataIn,

            portbin(0)        => '0',
            portbin(1)        => '0',
            portbin(2)        => '0',
            portbin(3)        => '0',
            portbin(4)        => AVRInt,
            portbin(5)        => '0',
            portbin(6)        => '0',
            portbin(7)        => '0',

            portbout(0)       => nARD,
            portbout(1)       => nAWR,
            portbout(2)       => portbout_2_unused,
            portbout(3)       => AVRA0,
            portbout(4)       => portbout_4_unused,
            portbout(5)       => portbout_5_unused,
            portbout(6)       => LED1n,
            portbout(7)       => LED2n,

            portdin           => (others => '0'),
            portdout(0)       => portdout_0_unused,
            portdout(1)       => portdout_1_unused,
            portdout(2)       => portdout_2_unused,
            portdout(3)       => portdout_3_unused,
            portdout(4)       => SDSS,
            portdout(5)       => portdout_5_unused,
            portdout(6)       => portdout_6_unused,
            portdout(7)       => portdout_7_unused,

            -- FUDLR
            portein           => ioport,
            porteout          => open,

            spi_mosio         => SDMOSI,
            spi_scko          => SDCLK,
            spi_misoi         => SDMISO,

            rxd               => avr_RxD,
            txd               => avr_TxD_atommc
            );

        ioport <= "111" & Joystick1(5) & Joystick1(0) & Joystick1(1) & Joystick1(2) & Joystick1(3);

        Inst_AtomPL8: entity work.AtomPL8 port map(
            clk               => clk_main,
            enable            => pl8_enable,
            nRST              => RSTn,
            RW                => cpu_R_W_n,
            Addr              => cpu_addr(2 downto 0),
            DataIn            => cpu_dout,
            DataOut           => pl8_data,
            AVRDataIn         => AVRDataIn,
            AVRDataOut        => AVRDataOut,
            nARD              => nARD,
            nAWR              => nAWR,
            AVRA0             => AVRA0,
            AVRINTOut         => AVRInt,
            AtomIORDOut       => open,
            AtomIOWROut       => open
            );

        LED1       <= not LED1n;
        LED2       <= not LED2n;

    end generate;

    Inst_not_atommc2: if not CImplAtoMMC2 generate

        avr_TxD_atommc <= '1';

    end generate;

---------------------------------------------------------------------
-- No SD Filesystem
---------------------------------------------------------------------

    Inst_no_atommc2: if ((not CImplSDDOS) and (not CImplAtoMMC2)) generate

        SDCLK      <= '1';
        SDSS       <= '1';
        SDMOSI     <= '1';
        LED1       <= '0';
        LED2       <= '0';

    end generate;

---------------------------------------------------------------------
-- Ram Rom board functionality
---------------------------------------------------------------------

    GenSampleData : if CImplSampleExternData generate
        process(clk_main)
        begin
            if rising_edge(clk_main) then
                if sample_data = '1' then
                    ExternDout1 <= ExternDout;
                end if;
            end if;
        end process;
    end generate;

    GenNotSampleData : if not CImplSampleExternData generate
        ExternDout1 <= ExternDout;
    end generate;

    Inst_RamRomNone: if (CImplRamRomNone) generate
        Inst_RamRomNone_comp: entity work.RamRom_None
            port map(
                clock        => clk_main,
                reset_n      => RSTn,
                -- signals from/to 6502
                cpu_addr     => cpu_addr,
                cpu_we       => not_cpu_R_W_n,
                cpu_dout     => cpu_dout,
                cpu_din      => extern_data,
                -- signals from/to external memory system
                ExternCE     => ExternCE,
                ExternWE     => ExternWE,
                ExternA      => ExternA,
                ExternDin    => ExternDin1,
                ExternDout   => ExternDout1
                );
        turbo <= key_turbo;
    end generate;

    Inst_RamRomPhill: if (CImplRamRomPhill) generate
        Inst_RamRomPhill_comp: entity work.RamRom_Phill
            port map(
                clock        => clk_main,
                reset_n      => RSTn,
                -- signals from/to 6502
                cpu_addr     => cpu_addr,
                cpu_we       => not_cpu_R_W_n,
                cpu_dout     => cpu_dout,
                cpu_din      => extern_data,
                -- signals from/to external memory system
                ExternCE     => ExternCE,
                ExternWE     => ExternWE,
                ExternA      => ExternA,
                ExternDin    => ExternDin1,
                ExternDout   => ExternDout1
                );
        turbo <= key_turbo;
    end generate;


    Inst_RamRomAtom2015: if (CImplRamRomAtom2015) generate
        Inst_RamRomAtom2015_comp: entity work.RamRom_Atom2015
            generic map(
                InitBFFE     => InitBFFE_Atom2015,
                InitBFFF     => x"00"
            )
            port map(
                clock        => clk_main,
                reset_n      => RSTn,
                -- signals from/to 6502
                cpu_addr     => cpu_addr,
                cpu_we       => not_cpu_R_W_n,
                cpu_dout     => cpu_dout,
                cpu_din      => extern_data,
                -- signals from/to external memory system
                ExternCE     => ExternCE,
                ExternWE     => ExternWE,
                ExternA      => ExternA,
                ExternDin    => ExternDin1,
                ExternDout   => ExternDout1,
                -- turbo mode control
                turbo_in     => key_turbo,
                turbo_out    => turbo
                );
    end generate;

    Inst_RamRomSchakelKaart: if (CImplRamRomSchakelKaart) generate
        Inst_RamRomSchakelKaart_comp: entity work.RamRom_SchakelKaart
            port map(
                clock        => clk_main,
                reset_n      => RSTn,
                -- signals from/to 6502
                cpu_addr     => cpu_addr,
                cpu_we       => not_cpu_R_W_n,
                cpu_dout     => cpu_dout,
                cpu_din      => extern_data,
                -- signals from/to external memory system
                ExternCE     => ExternCE,
                ExternWE     => ExternWE,
                ExternA      => ExternA,
                ExternDin    => ExternDin1,
                ExternDout   => ExternDout1
                );
        turbo <= key_turbo;
    end generate;

    ExternDin <= ExternDin1 when cpu_R_W_n = '0' else cpu_din;

---------------------------------------------------------------------
-- Profiling Counters
---------------------------------------------------------------------

    Inst_ProfilingCounters: if (CImplProfilingCounters) generate

        p_reset <= p_counter_ctrl(0);
        p_pause <= p_counter_ctrl(1);

        process(clk_main)
        begin
            if rising_edge(clk_main) then
                -- Detect falling edge of reset
                p_reset_last <= p_reset;
                if (p_reset_last = '1' and p_reset = '0') or (p_pause = '0' and p_divider_counter = 0) then
                    -- Reload the divider on falling edge of reset, or when it reaches 0
                    p_divider_counter <= p_divider_latch - 1;
                elsif p_pause = '0' then
                    -- Otherwise decrent divider if not paused
                    p_divider_counter <= p_divider_counter - 1;
                end if;
                -- Clock main counter when divider reaches 0
                if p_divider_counter = 0 and p_reset = '0' and p_pause = '0' then
                    p_profile_counter <= p_profile_counter + 1;
                end if;
                -- CPU Writes to Counter Registers
                if cpu_clken = '1' and counter_enable = '1' and cpu_R_W_n = '0' then
                    case cpu_addr(3 downto 0) is
                        when x"0" => p_counter_ctrl <= cpu_dout;
                        when x"4" => p_divider_latch(7 downto 0)     <= cpu_dout;
                        when x"5" => p_divider_latch(15 downto 8)    <= cpu_dout;
                        when x"6" => p_divider_latch(23 downto 16)   <= cpu_dout;
                        when x"7" => p_divider_latch(31 downto 24)   <= cpu_dout;
                        when x"8" => p_profile_counter(7 downto 0)   <= cpu_dout;
                        when x"9" => p_profile_counter(15 downto 8)  <= cpu_dout;
                        when x"A" => p_profile_counter(23 downto 16) <= cpu_dout;
                        when x"B" => p_profile_counter(31 downto 24) <= cpu_dout;
                        when others => null;
                    end case;
                end if;
                -- CPU Reads from Counter Registers
                case cpu_addr(3 downto 0) is
                    when x"0" => p_counter_data <= p_counter_ctrl;
                    when x"4" => p_counter_data <= p_divider_latch(7 downto 0);
                    when x"5" => p_counter_data <= p_divider_latch(15 downto 8);
                    when x"6" => p_counter_data <= p_divider_latch(23 downto 16);
                    when x"7" => p_counter_data <= p_divider_latch(31 downto 24);
                    when x"8" => p_counter_data <= p_profile_counter(7 downto 0);
                    when x"9" => p_counter_data <= p_profile_counter(15 downto 8);
                    when x"A" => p_counter_data <= p_profile_counter(23 downto 16);
                    when x"B" => p_counter_data <= p_profile_counter(31 downto 24);
                    when others => p_counter_data <= x"00";
                end case;
            end if;
        end process;
    end generate;

---------------------------------------------------------------------
-- Device enables
---------------------------------------------------------------------

    process(cpu_addr)
    begin
        -- All regions normally de-selected
        mc6522_enable     <= '0';
        i8255_enable      <= '0';
        video_ram_enable  <= '0';
        sid_enable        <= '0';
        pl8_enable        <= '0';
        reg_enable        <= '0';
        uart_enable       <= '0';
        counter_enable    <= '0';
        ext_ramrom_enable <= '0';
        ext_bus_enable    <= '0';

        case cpu_addr(15 downto 12) is
            when x"0" => ext_ramrom_enable <= '1';  -- 0x0000 -- 0x03ff is RAM
            when x"1" => ext_ramrom_enable <= '1';
            when x"2" => ext_ramrom_enable <= '1';
            when x"3" => ext_ramrom_enable <= '1';
            when x"4" => ext_ramrom_enable <= '1';
            when x"5" => ext_ramrom_enable <= '1';
            when x"6" => ext_ramrom_enable <= '1';
            when x"7" => ext_ramrom_enable <= '1';
            when x"8" => video_ram_enable  <= '1';  -- 0x8000 -- 0x9fff is RAM
            when x"9" => video_ram_enable  <= '1';
            when x"A" => ext_ramrom_enable <= '1';
            when x"B" =>
                if cpu_addr(11 downto 4)          = x"00" then -- 0xB00x 8255 PIA
                    i8255_enable <= '1';
                elsif cpu_addr(11 downto 3) & "000" = x"400" then -- 0xB400-0xB407 AtoMMC/SPI
                    if CImplSDDOS or CImplAtoMMC2 then
                        pl8_enable <= '1';
                    else
                        ext_bus_enable <= '1';
                    end if;
                elsif cpu_addr(11 downto 4)       = x"80" then -- 0xB80x 6522 VIA
                    if CImplVIA then
                        mc6522_enable <= '1';
                    else
                        ext_bus_enable <= '1';
                    end if;
                elsif cpu_addr(11 downto 4)       = x"DA" then -- 0xBDAx Profiling Counters
                    if CImplProfilingCounters then
                        counter_enable <= '1';
                    else
                        ext_bus_enable <= '1';
                    end if;
                elsif cpu_addr(11 downto 4)       = x"DB" then -- 0xBDBx UART
                    if CImplUart then
                        uart_enable <= '1';
                    else
                        ext_bus_enable <= '1';
                    end if;
                elsif cpu_addr(11 downto 5) & '0' = x"DC" then -- 0xBDCx, 0xBDDx SID
                    if CImplSID then
                        sid_enable <= '1';
                    else
                        ext_bus_enable <= '1';
                    end if;
                elsif cpu_addr(11 downto 5) & '0' = x"DE" then -- 0xBDEx, 0xBDFx GODIL Registers
                    reg_enable <= '1';
                elsif cpu_addr(11 downto 2) & "00"= x"FFC" then -- 0xBFFC-BFFF RomLatch
                    ext_ramrom_enable <= '1';
                elsif cpu_addr(11 downto 7)  /=  "11011"  then -- any non-mapped 0xBxxx address is deemed external
                    ext_bus_enable <= '1';                     -- apart from 0xBD80-0xBDFF which are deemed reserved
                end if;
            when x"C"   => ext_ramrom_enable <= '1';
            when x"D"   => ext_ramrom_enable <= '1';
            when x"E"   => ext_ramrom_enable <= '1';
            when x"F"   => ext_ramrom_enable <= '1';
            when others => null;
        end case;

    end process;

    -- External bus enable
    ExternBus <= ext_bus_enable;

---------------------------------------------------------------------
-- CPU data input multiplexor
---------------------------------------------------------------------

    cpu_din <=
        godil_data      when video_ram_enable = '1'                else
        i8255_data      when i8255_enable = '1'                    else
        mc6522_data     when mc6522_enable = '1'                   else
        godil_data      when sid_enable = '1'  and CImplSID        else
        godil_data      when uart_enable = '1' and CImplUart       else
        godil_data      when reg_enable = '1'                      else -- TODO add CImpl constraint
        pl8_data        when pl8_enable = '1'  and CImplSDDOS      else
        pl8_data        when pl8_enable = '1'  and CImplAtoMMC2    else
        extern_data     when ext_ramrom_enable = '1'               else
        extern_data     when ext_bus_enable = '1'                  else
        p_counter_data  when counter_enable = '1' and CImplProfilingCounters else
        x"f1";          -- un-decoded locations

--------------------------------------------------------
-- Clock enable generator
--------------------------------------------------------

    process(clk_main)
        variable mask4        : std_logic_vector(4 downto 0);
        variable limit        : integer;
        variable phi2l        : integer;
        variable phi2h        : integer;
        variable sampl        : integer;
    begin
        -- Don't include reset here, so 6502 continues to be clocked during reset
        if rising_edge(clk_main) then
            -- Counter:
            --   main_clock = 32MHz
            --      1MHz 0..31
            --      2MHz 0..15
            --      4MHz 0..7
            --      8MHz 0..3

            --   main_clock = 16MHz
            --      1MHz 0..15
            --      2MHz 0..7
            --      4MHz 0..3
            --      8MHz not supported

            -- Work out optimal timing
            --   mask4  - mask to give a 4x speed clock
            --   limit  - maximum value of clk_counter so it wraps at 1MHz
            --   phi2l  - when phi2 should go low
            --   phi2h  - when phi2 should go high
            --   sample - when sample_data should asserted

            -- none of the variables are stateful
            if (MainClockSpeed = 32000000) then
                -- 32MHz
                case (turbo_synced) is
                    when "11"   => mask4 := "00000"; limit :=  3; phi2l :=  3; phi2h :=  1; sampl :=  2; -- 8MHz
                    when "10"   => mask4 := "00001"; limit :=  7; phi2l :=  7; phi2h :=  3; sampl :=  6; -- 4MHz
                    when "01"   => mask4 := "00011"; limit := 15; phi2l := 15; phi2h :=  7; sampl := 14; -- 2MHz
                    when others => mask4 := "00111"; limit := 31; phi2l := 31; phi2h := 15; sampl := 30; -- 1MHz
                end case;
            else
                -- 16MHz
                case (turbo_synced) is
                    when "10"   => mask4 := "00000"; limit :=  3; phi2l :=  3; phi2h :=  1; sampl :=  2; -- 4MHz
                    when "01"   => mask4 := "00001"; limit :=  7; phi2l :=  7; phi2h :=  3; sampl :=  6; -- 2MHz
                    when others => mask4 := "00011"; limit := 15; phi2l := 15; phi2h :=  7; sampl := 14; -- 1MHz
                end case;
            end if;

            if clk_counter = limit then
                turbo_synced <= turbo; -- only change the timing at the end of the cycle
                clk_counter <= (others => '0');
            else
                clk_counter <= clk_counter + 1;
            end if;

            -- Assert cpu_clken in cycle 0
            if clk_counter = limit then
                cpu_clken <= '1';
            else
                cpu_clken <= '0';
            end if;

            -- Assert pia_clken in anti-phase with cpu_clken
            if clk_counter = phi2h then
                pia_clken <= '1';
            else
                pia_clken <= '0';
            end if;

            -- Assert via1_clken in cycle 0
            if clk_counter = limit then
                via1_clken <= '1';
            else
                via1_clken <= '0';
            end if;

            -- Assert via4 at 4x the rate of via1
            if (clk_counter and mask4) = (std_logic_vector(to_unsigned(limit,5)) and mask4) then
                via4_clken <= '1';
            else
                via4_clken <= '0';
            end if;

            -- Assert phi2 at the specified times
            if clk_counter = phi2h then
                phi2 <= '1';
            elsif clk_counter = phi2l then
                phi2 <= '0';
            end if;

            -- Assert sample_data at the specified time
            if clk_counter = sampl then
                sample_data <= '1';
            else
                sample_data <= '0';
            end if;

        end if;
    end process;


end BEHAVIORAL;
