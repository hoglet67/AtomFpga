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

    signal Addr_us    : unsigned(15 downto 0);
    signal Dout_us    : unsigned(7 downto 0);
    signal Din_us     : unsigned(7 downto 0);
    signal Unused     : std_logic_vector(7 downto 0);

begin

---------------------------------------------------------------------
-- 6502 CPU (using T65 core)
---------------------------------------------------------------------

    nmos: if not CImplCpu65c02 generate
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
            A(23 downto 16) => Unused,
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
    cmos: if CImplCpu65c02 generate
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
