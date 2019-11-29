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
       CImplVIA                : boolean := true;
       CImplProfilingCounters  : boolean := false;
       MainClockSpeed          : integer;
       DefaultBaud             : integer
    );
    port (
        -- Clocking
        clk_vga          : in    std_logic; -- nominally 25.175MHz VGA clock
        clk_main         : in    std_logic; -- clock for the main system
        clk_avr          : in    std_logic; -- clock for the AtoMMC2 AVR
        clk_dac          : in    std_logic; -- fast clock for the 1-bit DAC
        clk_32M00        : in    std_logic; -- fixed clock, used for SID and casette
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
        -- Video
        red              : out   std_logic_vector (2 downto 0);
        green            : out   std_logic_vector (2 downto 0);
        blue             : out   std_logic_vector (2 downto 0);
        vsync            : out   std_logic;
        hsync            : out   std_logic;
        -- External 6502 bus interface
        phi2             : out   std_logic;
        sync             : out   std_logic;
        rnw              : out   std_logic;
        blk_b            : out   std_logic;
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

-------------------------------------------------
-- Clocks and enables
-------------------------------------------------
    signal clk_counter       : std_logic_vector(4 downto 0);
    signal cpu_cycle         : std_logic;
    signal cpu_clken         : std_logic;
    signal pia_clken         : std_logic;
    signal sample_data       : std_logic;

-------------------------------------------------
-- CPU signals
-------------------------------------------------
    signal powerup_reset_n_sync : std_logic;
    signal ext_reset_n_sync     : std_logic;
    signal RSTn              : std_logic;
    signal cpu_R_W_n         : std_logic;
    signal not_cpu_R_W_n     : std_logic;
    signal cpu_addr          : std_logic_vector (15 downto 0);
    signal cpu_din           : std_logic_vector (7 downto 0);
    signal cpu_dout          : std_logic_vector (7 downto 0);
    signal cpu_IRQ_n         : std_logic;
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
    signal vdg_hblank        : std_logic;
    signal vdg_vblank        : std_logic;

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
    signal cas_tone          : std_logic;

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

--------------------------------------------------------------------
--                   here it begin :)
--------------------------------------------------------------------

begin

---------------------------------------------------------------------
-- 6502 CPU (using T65 core)
---------------------------------------------------------------------
    cpu : entity work.T65 port map (
        Mode           => "00",
        Abort_n        => '1',
        SO_n           => so,
        Res_n          => RSTn,
        Enable         => cpu_clken,
        Clk            => clk_main,
        Rdy            => rdy,
        IRQ_n          => cpu_IRQ_n,
        NMI_n          => nmi_n,
        R_W_n          => cpu_R_W_n,
        Sync           => sync,
        A(23 downto 16) => open,
        A(15 downto 0) => cpu_addr(15 downto 0),
        DI(7 downto 0) => cpu_din(7 downto 0),
        DO(7 downto 0) => cpu_dout(7 downto 0));

    not_cpu_R_W_n <= not cpu_R_W_n;
    cpu_IRQ_n     <= irq_n and mc6522_irq when CImplVIA else
                     irq_n;
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

    -- write enables
    gated_we      <= not_cpu_R_W_n;
    uart_we       <= gated_we;
    video_ram_we  <= gated_we and video_ram_enable;
    reg_we        <= gated_we;
    sid_we        <= gated_we;

    -- external bus
    rnw           <= cpu_R_W_n;
    blk_b         <= '0' when cpu_addr(15 downto 12) = x"0" else '1';
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
            reset => not RSTn,
            reset_vid => '0',
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
            sid_audio => sid_audio,
            sid_audio_d => sid_audio_d,
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
            charSet => charSet
            );

    -- external ouputs
    red(2 downto 0)   <= vdg_red & vdg_red & vdg_red;
    green(2 downto 0) <= vdg_green1 & vdg_green0 & vdg_green0;
    blue(2 downto 0)  <= vdg_blue & vdg_blue & vdg_blue;
    vsync             <= vdg_vsync;
    hsync             <= vdg_hsync;

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
    vdg_css       <= i8255_pc_data(3)          when RSTn='1' else '0';
    atom_audio    <= i8255_pc_data(2);

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

    input : entity work.keyboard port map(
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
            CDATAMEMSIZE         => 4096,
            CPROGMEMSIZE         => 10240
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
            portbout(2)       => open,
            portbout(3)       => AVRA0,
            portbout(4)       => open,
            portbout(5)       => open,
            portbout(6)       => LED1n,
            portbout(7)       => LED2n,

            portdin           => (others => '0'),
            portdout(0)       => open,
            portdout(1)       => open,
            portdout(2)       => open,
            portdout(3)       => open,
            portdout(4)       => SDSS,
            portdout(5)       => open,
            portdout(6)       => open,
            portdout(7)       => open,

            -- FUDLR
            portein           => ioport,
            porteout          => open,

            spi_mosio         => SDMOSI,
            spi_scko          => SDCLK,
            spi_misoi         => SDMISO,

            rxd               => avr_RxD,
            txd               => avr_TxD
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

    process(clk_main)
    begin
        if rising_edge(clk_main) then
            if sample_data = '1' then
                ExternDout1 <= ExternDout;
            end if;
        end if;
    end process;

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
                elsif cpu_addr(11 downto 4)       = x"40" then -- 0xB40x AtoMMC/SPI
                    pl8_enable <= '1';
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
                    uart_enable <= '1';
                elsif cpu_addr(11 downto 5) & '0' = x"DC" then -- 0xBDCx, 0xBDDx SID
                    sid_enable <= '1';
                elsif cpu_addr(11 downto 5) & '0' = x"DE" then -- 0xBDEx, 0xBDFx GODIL Registers
                    reg_enable <= '1';
                elsif cpu_addr(11 downto 2) & "00"= x"FFC" then -- 0xBFFC-BFFF RomLatch
                    ext_ramrom_enable <= '1';
                elsif cpu_addr(11 downto 8)      /= x"D"  then -- any non-mapped 0xBxxx address is deemed external
                    ext_bus_enable <= '1';                     -- apart from 0xBDxx which are deemed reserved
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
