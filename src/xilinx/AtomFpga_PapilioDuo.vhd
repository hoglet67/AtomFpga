--------------------------------------------------------------------------------
-- Copyright (c) 2015 David Banks
--
-- based on work by Alan Daly. Copyright(c) 2009. All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : AtomFpga_PapilioDuo.vhd
-- /___/   /\     Timestamp : 19/04/2015
-- \   \  /  \
--  \___\/\___\
--
--Design Name: AtomFpga_PapilioDuo
--Device: Spartan6 LX9

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AtomFpga_PapilioDuo is
    port (clk_32M00        : in    std_logic;
           ps2_kbd_clk     : in    std_logic;
           ps2_kbd_data    : in    std_logic;
           ps2_mse_clk     : inout std_logic;
           ps2_mse_data    : inout std_logic;
           ERST            : in    std_logic;
           red             : out   std_logic_vector (3 downto 0);
           green           : out   std_logic_vector (3 downto 0);
           blue            : out   std_logic_vector (3 downto 0);
           vsync           : out   std_logic;
           hsync           : out   std_logic;
           audioL          : out   std_logic;
           audioR          : out   std_logic;
           SRAM_nOE        : out   std_logic;
           SRAM_nWE        : out   std_logic;
           SRAM_nCS        : out   std_logic;
           SRAM_A          : out   std_logic_vector (20 downto 0);
           SRAM_D          : inout std_logic_vector (7 downto 0);
           SDMISO          : in    std_logic;
           SDSS            : out   std_logic;
           SDCLK           : out   std_logic;
           SDMOSI          : out   std_logic;
           LED1            : out   std_logic;
           LED2            : out   std_logic;
           ARDUINO_RESET   : out   std_logic;
           SW1             : in    std_logic;
           FLASH_CS        : out   std_logic;                     -- Active low FLASH chip select
           FLASH_SI        : out   std_logic;                     -- Serial output to FLASH chip SI pin
           FLASH_CK        : out   std_logic;                     -- FLASH clock
           FLASH_SO        : in    std_logic;                     -- Serial input from FLASH chip SO
           avr_RxD         : in    std_logic;
           avr_TxD         : out   std_logic;
           uart_RxD        : in    std_logic;
           uart_TxD        : out   std_logic;
           DIP             : in    std_logic_vector (3 downto 0);
           JOYSTICK1       : in    std_logic_vector (7 downto 0);
           JOYSTICK2       : in    std_logic_vector (7 downto 0)
           );
end AtomFpga_PapilioDuo;

architecture behavioral of AtomFpga_PapilioDuo is

    signal clock_25        : std_logic;
    signal clock_32        : std_logic;
    signal powerup_reset_n : std_logic;
    signal hard_reset_n    : std_logic;
    signal reset_counter   : std_logic_vector(9 downto 0);
    signal phi2            : std_logic;

    signal RAM_A           : std_logic_vector(18 downto 0);
    signal RAM_Din         : std_logic_vector(7 downto 0);
    signal RAM_Dout        : std_logic_vector(7 downto 0);
    signal RAM_nWE         : std_logic;
    signal RAM_nOE         : std_logic;
    signal RAM_nCS         : std_logic;

    signal ExternCE        : std_logic;
    signal ExternWE        : std_logic;
    signal ExternA         : std_logic_vector (18 downto 0);
    signal ExternDin       : std_logic_vector (7 downto 0);
    signal ExternDout      : std_logic_vector (7 downto 0);

-----------------------------------------------
-- Bootstrap ROM Image from SPI FLASH into SRAM
-----------------------------------------------

    -- start address of user data in FLASH as obtained from bitmerge.py
    -- this is safely beyond the end of the bitstream
    constant user_address  : std_logic_vector(23 downto 0) := x"060000";

    -- lenth of user data in FLASH = 128KB (32x 4KB ROM) images
    constant user_length   : std_logic_vector(23 downto 0) := x"020000";

    -- high when FLASH is being copied to SRAM, can be used by user as active high reset
    signal bootstrap_busy  : std_logic;

begin

--------------------------------------------------------
-- Atom Fpga Core
--------------------------------------------------------

    inst_AtomFpga_Core : entity work.AtomFpga_Core
    generic map (
        CImplSDDOS              => false,
        CImplAtoMMC2            => true,
        CImplGraphicsExt        => true,
        CImplSoftChar           => true,
        CImplSID                => true,
        CImplVGA80x40           => true,
        CImplHWScrolling        => true,
        CImplMouse              => true,
        CImplUart               => true,
        CImplDoubleVideo        => true,
        CImplRamRomNone         => false,
        CImplRamRomPhill        => true,
        CImplRamRomAtom2015     => false,
        CImplRamRomSchakelKaart => false,
        MainClockSpeed          => 32000000,
        DefaultBaud             => 115200
     )
     port map (
        clk_vga             => clock_25,
        clk_main            => clock_32,
        clk_avr             => clock_32,
        clk_dac             => clock_32,
        clk_32M00           => clock_32,
        ps2_clk             => ps2_kbd_clk,
        ps2_data            => ps2_kbd_data,
        ps2_mouse_clk       => ps2_mse_clk,
        ps2_mouse_data      => ps2_mse_data,
        powerup_reset_n     => powerup_reset_n,
        ext_reset_n         => hard_reset_n,
        int_reset_n         => open,
        red                 => red(3 downto 1),
        green               => green(3 downto 1),
        blue                => blue(3 downto 1),
        vsync               => vsync,
        hsync               => hsync,
        phi2                => phi2,
        ExternCE            => ExternCE,
        ExternWE            => ExternWE,
        ExternA             => ExternA,
        ExternDin           => ExternDin,
        ExternDout          => ExternDout,
        sid_audio           => audiol,
        sid_audio_d         => open,
        atom_audio          => audioR,
        SDMISO              => SDMISO,
        SDSS                => SDSS,
        SDCLK               => SDCLK,
        SDMOSI              => SDMOSI,
        uart_RxD            => uart_RxD,
        uart_TxD            => uart_TxD,
        avr_RxD             => avr_RxD,
        avr_TxD             => avr_TxD,
        LED1                => LED1,
        LED2                => LED2,
        charSet             => DIP(0),
        Joystick1           => JOYSTICK1,
        Joystick2           => JOYSTICK2
    );

    red(0)     <= '0';
    green(0)   <= '0';
    blue(0)    <= '0';

--------------------------------------------------------
-- Clock Generation
--------------------------------------------------------

    inst_dcm4 : entity work.dcm4 port map(
        CLKIN_IN  => clk_32M00,
        CLK0_OUT  => clock_32,
        CLKFX_OUT => clock_25
    );

--------------------------------------------------------
-- Power Up Reset Generation
--------------------------------------------------------

    -- On the Duo the external reset signal is not asserted on power up
    -- This internal counter forces power up reset to happen
    -- This is needed by the GODIL to initialize some of the registers
    ResetProcess : process (clock_32)
    begin
        if rising_edge(clock_32) then
            if (reset_counter(reset_counter'high) = '0') then
                reset_counter <= reset_counter + 1;
            end if;
            powerup_reset_n <= not ERST and reset_counter(reset_counter'high);
        end if;
    end process;

   -- extend the version seen by the core to hold the 6502 reset during bootstrap
   hard_reset_n <= powerup_reset_n and not bootstrap_busy;

--------------------------------------------------------
-- Papilio Duo Misc
--------------------------------------------------------

    ARDUINO_RESET <= SW1;

--------------------------------------------------------
-- BOOTSTRAP SPI FLASH to SRAM
--------------------------------------------------------

    inst_bootstrap: entity work.bootstrap
    generic map (
        user_length     => user_length
    )
    port map(
        clock           => clock_32,
        powerup_reset_n => powerup_reset_n,
        bootstrap_busy  => bootstrap_busy,
        user_address    => user_address,
        RAM_nOE         => RAM_nOE,
        RAM_nWE         => RAM_nWE,
        RAM_nCS         => RAM_nCS,
        RAM_A           => RAM_A,
        RAM_Din         => RAM_Din,
        RAM_Dout        => RAM_Dout,
        SRAM_nOE        => SRAM_nOE,
        SRAM_nWE        => SRAM_nWE,
        SRAM_nCS        => SRAM_nCS,
        SRAM_A          => SRAM_A,
        SRAM_D          => SRAM_D,
        FLASH_CS        => FLASH_CS,
        FLASH_SI        => FLASH_SI,
        FLASH_CK        => FLASH_CK,
        FLASH_SO        => FLASH_SO
    );

    MemProcess : process (clock_32)
    begin
        if rising_edge(clock_32) then
            RAM_A      <= ExternA;
            RAM_nCS    <= not ExternCE;
            RAM_nOE    <= not ((not ExternWE) and ExternCE and phi2);
            RAM_nWE    <= not (ExternWE and ExternCE and phi2);
            RAM_Din    <= ExternDin;
       end if;
    end process;

    ExternDout <= RAM_Dout;

end behavioral;
