library vunit_lib;
context vunit_lib.vunit_context;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity test_tb is
    generic (
        runner_cfg : string;
        DefaultTurbo : std_logic_vector(1 downto 0) := "10"
    );
end test_tb;

architecture beh of test_tb is

    signal clock_27       : std_logic := '0';
    signal btn1_n         : std_logic := '0';
    signal btn2_n         : std_logic := '1';
    signal ps2_clk        : std_logic := '1';
    signal ps2_data       : std_logic := '1';
    signal ps2_mouse_clk  : std_logic := '1';
    signal ps2_mouse_data : std_logic := '1';
    signal audiol         : std_logic;
    signal audior         : std_logic;
    signal tf_miso        : std_logic := '1';
    signal tf_cs          : std_logic;
    signal tf_sclk        : std_logic;
    signal tf_mosi        : std_logic;
    signal uart_rx        : std_logic := '1';
    signal uart_tx        : std_logic;
    signal led            : std_logic_vector(5 downto 0);
    signal tmds_clk_p     : std_logic;
    signal tmds_clk_n     : std_logic;
    signal tmds_d_p       : std_logic_vector(2 downto 0);
    signal tmds_d_n       : std_logic_vector(2 downto 0);
    signal gpio           : std_logic_vector(13 downto 0);
    signal trace          : std_logic_vector(15 downto 0);
    signal phi2           : std_logic;

    signal O_psram_ck     : std_logic_vector(1 downto 0);
    signal O_psram_ck_n   : std_logic_vector(1 downto 0);
    signal IO_psram_rwds  : std_logic_vector(1 downto 0);
    signal IO_psram_dq    : std_logic_vector(15 downto 0);
    signal O_psram_reset_n: std_logic_vector(1 downto 0);
    signal O_psram_cs_n   : std_logic_vector(1 downto 0);

begin

    -- Generate the main 27MHz clock
    p_clk : process
    begin
        wait for 18.5 ns;
        clock_27 <= not clock_27;
    end process;

    p_main : process

	-- Generate a power up reset pulse of ~5 CPU clock cycles
    procedure DO_INIT is
    begin
        btn1_n <= '0';
        for i in 1 to 5 loop
            wait until falling_edge(phi2);
        end loop;
        btn1_n <= '1';
    end procedure;

    begin

        test_runner_setup(runner, runner_cfg);

        while test_suite loop
            if run("default") then
                DO_INIT;
                wait for 2 ms;
            end if;
        end loop;

        wait for 3 us;

        test_runner_cleanup(runner); -- Simulation ends here
    end process;


    uut : entity work.AtomFpga_TangNano9K
        generic map (
            CImplCpu65c02      => false,
            CImplDVIGowin      => false,
            CImplDVIOpenSource => true,
            CImplSDDOS         => true,
            CImplAtoMMC2       => false,
            CImplSID           => false,
            CImplUserFlash     => false,
            CImplBootstrap     => false,
            -- Options that use the GPIO outputs, select just one
            CImplVGA           => false,
            CImplTrace         => true,    -- don't change this, as test bench relies on phi2
            CImplDebug         => false,
			DefaultTurbo       => DefaultTurbo,
            ResetCounterSize   => 6
            )
        port map (
            clock_27       => clock_27       ,
            btn1_n         => btn1_n         ,
            btn2_n         => btn2_n         ,
            ps2_clk        => ps2_clk        ,
            ps2_data       => ps2_data       ,
            ps2_mouse_clk  => ps2_mouse_clk  ,
            ps2_mouse_data => ps2_mouse_data ,
            tf_miso        => tf_miso        ,
            tf_cs          => tf_cs          ,
            tf_sclk        => tf_sclk        ,
            tf_mosi        => tf_mosi        ,
            uart_rx        => uart_rx        ,
            uart_tx        => uart_tx        ,
            led            => led            ,
            tmds_clk_p     => tmds_clk_p     ,
            tmds_clk_n     => tmds_clk_n     ,
            tmds_d_p       => tmds_d_p       ,
            tmds_d_n       => tmds_d_n       ,
            gpio           => gpio           ,

            -- Flash (not implemented)
            flash_cs       => open           ,
            flash_ck       => open           ,
            flash_si       => open           ,
            flash_so       => '0'            ,

            -- PSRAM
            O_psram_ck     => O_psram_ck     ,
            O_psram_ck_n   => O_psram_ck_n   ,
            IO_psram_rwds  => IO_psram_rwds  ,
            IO_psram_dq    => IO_psram_dq    ,
            O_psram_reset_n=> O_psram_reset_n,
            O_psram_cs_n   => O_psram_cs_n

            );

    e_psram:entity work.s27kl0642
        generic map (
		    -- 256KB is plenty (128K ROM + 128K RAM)
            MemSize  => x"3FFFF",
			-- 64K x 16 bit ROM image in the current directory
            mem_file_name => "../../../roms/InternalROM.hex"
            )
        port map (
            DQ7      => IO_psram_dq(7),
            DQ6      => IO_psram_dq(6),
            DQ5      => IO_psram_dq(5),
            DQ4      => IO_psram_dq(4),
            DQ3      => IO_psram_dq(3),
            DQ2      => IO_psram_dq(2),
            DQ1      => IO_psram_dq(1),
            DQ0      => IO_psram_dq(0),
            RWDS     => IO_psram_rwds(0),

            CSNeg    => O_psram_cs_n(0),
            CK       => O_psram_ck(0),
            CKn      => O_psram_ck_n(0),
            RESETNeg => O_psram_reset_n(0)
    );


	-- Trace 6502 activity

    trace <= "111111" & gpio(9 downto 0) after 1 ns;
    phi2  <= gpio(10);

    process(gpio)
    begin
        if falling_edge(phi2) then
            write(output, "trace: " & to_hstring(trace) & LF);
       end if;
    end process;

end beh;
