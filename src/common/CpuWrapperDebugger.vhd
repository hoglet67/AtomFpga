library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity CpuWrapper is
    generic (
        CImplDebugger : boolean := false;
        CImplCpu65c02 : boolean := false
    );
    port (
        clk_main  : in    std_logic;
        clk_avr   : in    std_logic;
        cpu_clken : in    std_logic;
        IRQ_n     : in    std_logic;
        NMI_n     : in    std_logic;
        RST_n     : in    std_logic;
        PRST_n    : in    std_logic;
        SO        : in    std_logic;
        RDY       : in    std_logic;
        Din       : in    std_logic_vector(7 downto 0);
        Dout      : out   std_logic_vector(7 downto 0);
        R_W_n     : out   std_logic;
        Sync      : out   std_logic;
        Addr      : out   std_logic_vector(15 downto 0);
        avr_RxD   : in    std_logic;
        avr_TxD   : out   std_logic
        );

end CpuWrapper;

architecture BEHAVIORAL of CpuWrapper is

    signal cpu_clken1 : std_logic;
    signal Addr_us    : unsigned(15 downto 0);
    signal Dout_us    : unsigned(7 downto 0);
    signal Din_us     : unsigned(7 downto 0);

begin

    process(clk_main)
    begin
        if rising_edge(clk_main) then
            cpu_clken1 <= cpu_clken;
        end if;
    end process;

---------------------------------------------------------------------
-- 6502/65C02 CPU (using ICET65 Debugger)
---------------------------------------------------------------------

    debugger_nmos: if CImplDebugger and not CImplCpu65c02 generate
        core : entity work.MOS6502CpuMonCore
            generic map (
                UseT65Core   => true,
                UseAlanDCore => false,
                num_comparators => 8,
                filename     => "avr_progmem_ice6502.data"
                )
            port map (
                clock_avr    => clk_avr,
                busmon_clk   => clk_main,
                busmon_clken => cpu_clken1,
                cpu_clk      => clk_main,
                cpu_clken    => cpu_clken,
                IRQ_n        => IRQ_n,
                NMI_n        => NMI_n,
                Sync         => Sync,
                Addr         => Addr,
                R_W_n        => R_W_n,
                Din          => Din,
                Dout         => Dout,
                SO_n         => SO,
                Res_n        => RST_n,
                Rdy          => RDY,
                trig         => "00",
                avr_RxD      => avr_RxD,
                avr_TxD      => avr_TxD,
                sw_reset_cpu => '0',
                sw_reset_avr => not PRST_n
                );
    end generate;

    debugger_cmos: if CImplDebugger and CImplCpu65c02 generate
        core : entity work.MOS6502CpuMonCore
            generic map (
                UseT65Core   => false,
                UseAlanDCore => true,
                num_comparators => 8,
                filename     => "avr_progmem_ice65c02.data"
                )
            port map (
                clock_avr    => clk_avr,
                busmon_clk   => clk_main,
                busmon_clken => cpu_clken1,
                cpu_clk      => clk_main,
                cpu_clken    => cpu_clken,
                IRQ_n        => IRQ_n,
                NMI_n        => NMI_n,
                Sync         => Sync,
                Addr         => Addr,
                R_W_n        => R_W_n,
                Din          => Din,
                Dout         => Dout,
                SO_n         => SO,
                Res_n        => RST_n,
                Rdy          => RDY,
                trig         => "00",
                avr_RxD      => avr_RxD,
                avr_TxD      => avr_TxD,
                sw_reset_cpu => '0',
                sw_reset_avr => not PRST_n
                );
    end generate;

---------------------------------------------------------------------
-- 6502 CPU (using T65 core)
---------------------------------------------------------------------

    not_debugger_nmos: if not CImplDebugger and not CImplCpu65c02 generate
        cpu : entity work.T65 port map (
            Mode           => "00",
            Abort_n        => '1',
            SO_n           => SO,
            Res_n          => RST_n,
            Enable         => cpu_clken,
            Clk            => clk_main,
            Rdy            => RDY,
            IRQ_n          => IRQ_n,
            NMI_n          => NMI_n,
            R_W_n          => R_W_n,
            Sync           => Sync,
            A(23 downto 16) => open,
            A(15 downto 0) => Addr(15 downto 0),
            DI(7 downto 0) => Din(7 downto 0),
            DO(7 downto 0) => Dout(7 downto 0)
            );
        avr_TxD  <= '1';
    end generate;

---------------------------------------------------------------------
-- 65C02 CPU (using AlanD core)
---------------------------------------------------------------------

    -- TODO: Need to add RDY
    not_debugger_cmos: if not CImplDebugger and CImplCpu65c02 generate
        inst_r65c02: entity work.r65c02 port map (
            reset    => RST_n,
            clk      => clk_main,
            enable   => cpu_clken,
            nmi_n    => NMI_n,
            irq_n    => IRQ_n,
            di       => Din_us,
            do       => Dout_us,
            addr     => Addr_us,
            nwe      => R_W_n,
            sync     => Sync
            );
        Din_us  <= unsigned(Din);
        Dout    <= std_logic_vector(Dout_us);
        Addr    <= std_logic_vector(Addr_us);
        avr_TxD <= '1';
    end generate;

end BEHAVIORAL;
