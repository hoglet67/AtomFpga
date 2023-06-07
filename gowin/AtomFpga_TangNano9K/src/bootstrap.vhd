--------------------------------------------------------------------------------
-- Copyright (c) 2015 David Banks
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : bootstrap.vhd
-- /___/   /\     Timestamp : 28/07/2015
-- \   \  /  \
--  \___\/\___\
--
--Design Name: bootstrap
--Device: Spartan6 LX9

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity bootstrap is
    generic (
        -- length user data in flash
        user_length    : std_logic_vector(23 downto 0) := x"020000"
    );
    port (
        clock           : in    std_logic;

        -- initiate bootstrap
        powerup_reset_n : in    std_logic;

        -- high when FLASH is being copied to PSRAM, can be used by user as active high reset
        bootstrap_busy  : out   std_logic;

        -- start address of user data in FLASH
        user_address    : in std_logic_vector(23 downto 0);

        -- interface from Atom core
        RAM_STB         : in   std_logic;
        RAM_CE          : in   std_logic;
        RAM_WE          : in   std_logic;
        RAM_A           : in   std_logic_vector (18 downto 0);
        RAM_Din         : in   std_logic_vector (7 downto 0);
        RAM_Dout        : out  std_logic_vector (7 downto 0);

        -- interface to the PSRAM
        PSRAM_STB       : out  std_logic;
        PSRAM_WE        : out  std_logic;
        PSRAM_CE        : out  std_logic;
        PSRAM_A         : out  std_logic_vector (21 downto 0);
        PSRAM_Din       : out  std_logic_vector (7 downto 0);
        PSRAM_Dout      : in   std_logic_vector (7 downto 0);

        -- interface to external FLASH
        FLASH_CS       : out   std_logic; -- Active low FLASH chip select
        FLASH_SI       : out   std_logic; -- Serial output to FLASH chip SI pin
        FLASH_CK       : out   std_logic; -- FLASH clock
        FLASH_SO       : in    std_logic  -- Serial input from FLASH chip SO pin
     );
end;

architecture behavioral of bootstrap is

-- an internal clock enable, avoiding gated clocks
signal clock_en         : std_logic := '0';

--
-- bootstrap signals
--
signal flash_init       : std_logic;     -- when low places FLASH driver in init state
signal flash_done       : std_logic;     -- FLASH init finished when high
signal flash_data       : std_logic_vector(7 downto 0);

-- bootstrap control of PSRAM, these signals connect to PSRAM when boostrap_busy = '1'
signal bs_A             : std_logic_vector(18 downto 0);
signal bs_Din           : std_logic_vector(7 downto 0);
signal bs_CE            : std_logic;
signal bs_WE            : std_logic;
signal bs_STB           : std_logic;

signal bs_busy          : std_logic;

-- for bootstrap state machine
type    BS_STATE_TYPE is (
            INIT, START_READ_FLASH, READ_FLASH, FLASH0, FLASH1, FLASH2, FLASH3, FLASH4, FLASH5, FLASH6, FLASH7,
            WAIT0, WAIT1, WAIT2, WAIT3, WAIT4, WAIT5, WAIT6, WAIT7, WAIT8, WAIT9, WAIT10, WAIT11
        );

signal bs_state : BS_STATE_TYPE := INIT;

begin

    bootstrap_busy        <= bs_busy;

--------------------------------------------------------
-- PSRAM Multiplexor
--------------------------------------------------------

    RAM_Dout              <= PSRAM_Dout; -- pass through

    PSRAM_STB             <= bs_STB  when bs_busy = '1' else RAM_STB;
    PSRAM_CE              <= bs_CE   when bs_busy = '1' else RAM_CE;
    PSRAM_WE              <= bs_WE   when bs_busy = '1' else RAM_WE;
    PSRAM_Din             <= bs_Din  when bs_busy = '1' else RAM_Din;
    PSRAM_A(18 downto  0) <= bs_A    when bs_busy = '1' else RAM_A;
    PSRAM_A(21 downto 19) <= (others =>'0');

--------------------------------------------------------
-- Bootstrap PSRAM from SPI FLASH
--------------------------------------------------------

    -- flash clock enable toggles on alternate cycles
    process(clock)
    begin
        if rising_edge(clock) then
            clock_en <= not clock_en;
        end if;
    end process;

    -- bootstrap state machine
    state_bootstrap : process(clock, powerup_reset_n)
        begin
            if powerup_reset_n = '0' then                         -- external reset pin
                bs_state <= INIT;                                 -- move state machine to INIT state
                bs_busy <= '1';
            elsif rising_edge(clock) then
                bs_STB <= '0';
                if clock_en = '1' then
                    case bs_state is
                        when INIT =>
                            bs_busy <= '1';                       -- indicate bootstrap in progress (holds user in reset)
                            flash_init <= '0';                    -- signal FLASH to begin init
                            bs_A   <= (others => '1');            -- PSRAM address all ones (becomes zero on first increment)
                            bs_CE <= '1';                         -- PSRAM always selected during bootstrap
                            bs_WE <= '0';                         -- PSRAM write enable inactive default state
                            bs_state <= START_READ_FLASH;
                        when START_READ_FLASH =>
                            flash_init <= '1';                    -- allow FLASH to exit init state
                            if flash_done = '0' then              -- wait for FLASH init to begin
                                bs_state <= READ_FLASH;
                            end if;
                        when READ_FLASH =>
                            if flash_done = '1' then              -- wait for FLASH init to complete
                                bs_state <= WAIT0;
                            end if;
                        when WAIT0 =>                             -- wait for the first FLASH byte to be available
                            bs_state <= WAIT1;
                        when WAIT1 =>
                            bs_state <= WAIT2;
                        when WAIT2 =>
                            bs_state <= WAIT3;
                        when WAIT3 =>
                            bs_state <= WAIT4;
                        when WAIT4 =>
                            bs_state <= WAIT5;
                        when WAIT5 =>
                            bs_state <= WAIT6;
                        when WAIT6 =>
                            bs_state <= WAIT7;
                        when WAIT7 =>
                            bs_state <= WAIT8;
                        when WAIT8 =>
                            bs_state <= FLASH0;
                        when WAIT9 =>
                            bs_state <= WAIT10;
                        when WAIT10 =>
                            bs_state <= WAIT11;
                        when WAIT11 =>
                            bs_state <= FLASH0;
                        -- every 8 clock cycles (32M/8 = 2Mhz) we have a new byte from FLASH
                        -- use this ample time to write it to PSRAM, we just have to toggle nWE
                        when FLASH0 =>
                            bs_A <= bs_A + 1;                     -- increment PSRAM address
                            bs_state <= FLASH1;                   -- idle
                        when FLASH1 =>
                            bs_Din( 7 downto 0) <= flash_data;    -- place byte on PSRAM data bus
                            bs_state <= FLASH2;                   -- idle
                        when FLASH2 =>
                            bs_WE <= '1';                         -- PSRAM write enable
                            bs_state <= FLASH3;
                        when FLASH3 =>
                            bs_state <= FLASH4;                   -- idle
                            bs_STB <= '1';                         -- Trigger PSRAM cycle
                        when FLASH4 =>
                            bs_state <= FLASH5;                   -- idle
                        when FLASH5 =>
                            bs_state <= FLASH6;                   -- idle
                        when FLASH6 =>
                            bs_WE <= '0';                         -- PSRAM write disable
                            bs_state <= FLASH7;
                        when FLASH7 =>
                            if "000" & bs_A = user_length then    -- when we've reached end address
                                bs_busy <= '0';                   -- indicate bootsrap is done
                                flash_init <= '0';                -- place FLASH in init state
                                bs_state <= FLASH7;               -- remain in this state until reset
                            else
                                bs_state <= FLASH0;               -- else loop back
                            end if;
                        when others =>                            -- catch all, never reached
                            bs_state <= INIT;
                    end case;
                end if;
            end if;
        end process;

    -- FLASH chip SPI driver
    u_flash : entity work.spi_flash
    generic map (
        IncludeInitState => true
    )
    port map (
        flash_clk   => clock,
        flash_clken => clock_en,
        flash_init  => flash_init,
        flash_addr  => user_address,
        flash_data  => flash_data,
        flash_Done  => flash_done,
        U_FLASH_CK  => FLASH_CK,
        U_FLASH_CS  => FLASH_CS,
        U_FLASH_SI  => FLASH_SI,
        U_FLASH_SO  => FLASH_SO
    );

end behavioral;
