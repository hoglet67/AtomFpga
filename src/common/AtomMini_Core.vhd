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
--  /   /         Filename  : AtomMini_Core
-- /___/   /\     Timestamp : 02/03/2013 06:17:50
-- \   \  /  \
--  \___\/\___\
--
--Design Name: Atomic_top.vhf
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AtomMini_Core is
    generic (
       CImplAtoMMC2            : boolean := false;
       CImplRamRomNone         : boolean := false;
       CImplRamRomPhill        : boolean := false;
       CImplRamRomAtom2015     : boolean := true;
       CImplRamRomSchakelKaart : boolean := false;
       CImplVIA                : boolean := false;
       CImplSID                : boolean := true;
       CImplProfilingCounters  : boolean := false;
       MainClockSpeed          : integer := 32000000;
       DefaultBaud             : integer := 115200
    );
    port (
        -- Clocking
        clk_main         : in    std_logic; -- clock for the main system
        clk_avr          : in    std_logic; -- clock for the AtoMMC2 AVR
        clk_dac          : in    std_logic; -- fast clock for the 1-bit DAC
        clk_32M00        : in    std_logic; -- fixed clock, used for SID and casette
        -- Resets
        powerup_reset_n  : in    std_logic := '1'; -- power up reset only (optional)
        ext_reset_n      : in    std_logic := '1'; -- external bus reset (optional)
        -- External 6502 bus interface
        phi2             : out   std_logic;
        sync             : out   std_logic;
        rnw              : out   std_logic;
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
        --sid_audio_d      : out   std_logic_vector (17 downto 0);
        sid_audio        : out   std_logic;
        -- SD Card
        SDMISO           : in    std_logic;
        SDSS             : out   std_logic;
        SDCLK            : out   std_logic;
        SDMOSI           : out   std_logic;
        -- Serial
        avr_RxD          : in    std_logic;
        avr_TxD          : out   std_logic;
        -- Misc
        LED1             : out   std_logic;
        LED2             : out   std_logic;
        Joystick         : in    std_logic_vector (7 downto 0) := (others => '1')
        );
end AtomMini_Core;

architecture BEHAVIORAL of AtomMini_Core is

-------------------------------------------------
-- Clocks and enables
-------------------------------------------------
    signal clk_counter       : std_logic_vector(4 downto 0);
    signal cpu_cycle         : std_logic;
    signal cpu_clken         : std_logic;
    signal sample_data       : std_logic;
    signal turbo             : std_logic_vector(1 downto 0);
    signal turbo_synced      : std_logic_vector(1 downto 0);

-------------------------------------------------
-- CPU signals
-------------------------------------------------
    signal RSTn              : std_logic;
    signal cpu_R_W_n         : std_logic;
    signal not_cpu_R_W_n     : std_logic;
    signal cpu_addr          : std_logic_vector (15 downto 0);
    signal cpu_din           : std_logic_vector (7 downto 0);
    signal cpu_dout          : std_logic_vector (7 downto 0);
    signal cpu_IRQ_n         : std_logic;

----------------------------------------------------
-- External
----------------------------------------------------
    signal ext_ramrom_enable : std_logic;
    signal ext_bus_enable    : std_logic;
    signal extern_data       : std_logic_vector(7 downto 0);
    signal ExternDout1       : std_logic_vector (7 downto 0);

----------------------------------------------------
-- 6522 signals
----------------------------------------------------
    signal mc6522_enable     : std_logic;
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
-- AtoMMC signals
----------------------------------------------------

    signal pl8_enable        : std_logic;
    signal pl8_data          : std_logic_vector (7 downto 0);
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

    signal counter_enable    : std_logic;
    signal p_counter_ctrl    : std_logic_vector  (7 downto 0);
    signal p_counter_data    : std_logic_vector  (7 downto 0);
    signal p_divider_latch   : std_logic_vector (31 downto 0);
    signal p_divider_counter : std_logic_vector (31 downto 0);
    signal p_profile_counter : std_logic_vector (31 downto 0);
    signal p_reset           : std_logic;
    signal p_pause           : std_logic;
    signal p_reset_last      : std_logic;


----------------------------------------------------
-- SID Signals
----------------------------------------------------
    signal clk_1M00          : std_logic;
    signal div32             : std_logic_vector (4 downto 0);
    signal sid_enable        : std_logic;
    signal sid_we            : std_logic;
    signal sid_data          : std_logic_vector (7 downto 0);

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
    RSTn          <= powerup_reset_n and ext_reset_n;

    -- write enables
    sid_we        <= not_cpu_R_W_n;

    -- external bus
    rnw           <= cpu_R_W_n;

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

        ioport <= "111" & Joystick(5) & Joystick(0) & Joystick(1) & Joystick(2) & Joystick(3);

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

    Inst_no_atommc2: if (not CImplAtoMMC2) generate

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
                ExternDin    => ExternDin,
                ExternDout   => ExternDout1
                );
        turbo <= "00";
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
                ExternDin    => ExternDin,
                ExternDout   => ExternDout1
                );
        turbo <= "00";
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
                ExternDin    => ExternDin,
                ExternDout   => ExternDout1,
                -- turbo mode control
                turbo_in     => "00",
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
                ExternDin    => ExternDin,
                ExternDout   => ExternDout1
                );
        turbo <= "00";
    end generate;

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
        sid_enable        <= '0';
        pl8_enable        <= '0';
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
            when x"A" => ext_ramrom_enable <= '1';
            when x"B" =>
                if cpu_addr(11 downto 4)       = x"40" then -- 0xB40x AtoMMC/SPI
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
                elsif cpu_addr(11 downto 5) & '0' = x"DC" then -- 0xBDCx, 0xBDDx SID
                    sid_enable <= '1';
                elsif cpu_addr(11 downto 4)       = x"FF" then -- 0xBFFx RomLatch
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

    -----------------------------------------------------------------------------
    -- Optional SID
    -----------------------------------------------------------------------------

    Optional_SID: if CImplSID generate

        Inst_sid6581: entity work.sid6581
            port map (
                clk_1MHz   => clk_1M00,
                clk32      => clk_32M00,
                clk_DAC    => clk_dac,
                reset      => not RSTn,
                cs         => sid_enable,
                we         => sid_we,
                addr       => cpu_addr(4 downto 0),
                di         => cpu_dout,
                do         => sid_data,
                pot_x      => '0',
                pot_y      => '0',
                audio_out  => sid_audio
--                audio_data => sid_audio_d
            );

        -- Clock_Sid_1MHz is derived by dividing down thw 32MHz clock
        process (clk_32M00)
        begin
            if rising_edge(clk_32M00) then
                div32 <= div32 + 1;
            end if;
        end process;
        clk_1M00 <= div32(4);

    end generate;

---------------------------------------------------------------------
-- CPU data input multiplexor
---------------------------------------------------------------------

    cpu_din <=
        mc6522_data     when mc6522_enable = '1' and CImplVia                else
        pl8_data        when pl8_enable = '1'                                else
        sid_data        when sid_enable  = '1' and CimplSID  else
        extern_data     when ext_ramrom_enable = '1'                         else
        extern_data     when ext_bus_enable = '1'                            else
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

            -- Asset cpu_clken in cycle 0
            if clk_counter = limit then
                cpu_clken <= '1';
            else
                cpu_clken <= '0';
            end if;

            -- Asset via1_clken in cycle 0
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

            -- Asset phi2 at the specified times
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
