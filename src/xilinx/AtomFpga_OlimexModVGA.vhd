--------------------------------------------------------------------------------
-- Copyright (c) 2009 Alan Daly.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    
-- \   \   \/    
--  \   \         
--  /   /         Filename  : AtomFpga_OlimexModVGA.vhd
-- /___/   /\     Timestamp : 02/03/2013 06:17:50
-- \   \  /  \ 
--  \___\/\___\ 
--
--Design Name: AtomFpga_OlimexModVGA
--Device: spartan3A
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AtomFpga_OlimexModVGA is
    port (clk_25M00 : in    std_logic;
          ps2_clk   : in    std_logic;
          ps2_data  : in    std_logic;
          ERSTn     : in    std_logic;
          red       : out   std_logic_vector (2 downto 0);
          green     : out   std_logic_vector (2 downto 0);
          blue      : out   std_logic_vector (2 downto 0);
          vsync     : out   std_logic;
          hsync     : out   std_logic;
          CE1       : out   std_logic;
          RAMWRn    : out   std_logic;
          RAMOEn    : out   std_logic;
          RamA      : out   std_logic_vector (15 downto 0);
          RamD      : inout std_logic_vector (15 downto 0);
          audiol    : out   std_logic;
          audioR    : out   std_logic;
          FLASH_CS  : out   std_logic;                     -- Active low FLASH chip select
          FLASH_SI  : out   std_logic;                     -- Serial output to FLASH chip SI pin
          FLASH_CK  : out   std_logic;                     -- FLASH clock
          FLASH_SO  : in    std_logic;                     -- Serial input from FLASH chip SO
          SDMISO    : in    std_logic;
          SDSS      : out   std_logic;
          SDCLK     : out   std_logic;
          SDMOSI    : out   std_logic);
end AtomFpga_OlimexModVGA;

architecture behavioral of AtomFpga_OlimexModVGA is
    
    signal clock_16        : std_logic;
    signal clock_25        : std_logic;
    signal clock_32        : std_logic;
    signal Phi2            : std_logic;
    signal powerup_reset_n : std_logic;
    signal hard_reset_n    : std_logic;     
    signal reset_counter   : std_logic_vector(15 downto 0);

    signal RAM_A           : std_logic_vector(18 downto 0);
    signal RAM_Din         : std_logic_vector(7 downto 0);
    signal RAM_Dout        : std_logic_vector(7 downto 0);
    signal RAM_nWE         : std_logic;
    signal RAM_nOE         : std_logic;
    signal RAM_nCS         : std_logic;

    signal ExternCE        : std_logic;
    signal ExternWE        : std_logic;
    signal ExternA         : std_logic_vector(18 downto 0);
    signal ExternDin       : std_logic_vector(7 downto 0);
    signal ExternDout      : std_logic_vector(7 downto 0);

-----------------------------------------------
-- Bootstrap ROM Image from SPI FLASH into SRAM
-----------------------------------------------

    -- TODO: The user_ values below are a hack
    -- specifying 030000/008000 did not work, although it should!
    -- there seems to be something different about the way the AT45DB041D is addressed
    -- but that's not obvious in the data sheet
    -- https://www.adestotech.com/wp-content/uploads/doc3595.pdf

    -- start address of user data in FLASH as obtained from bitmerge.py
    constant user_address  : std_logic_vector(23 downto 0) := x"000000";

    -- lenth of user data in FLASH = 32KB (8x 4KB ROM) images
    constant user_length   : std_logic_vector(23 downto 0) := x"038000";

    -- high when FLASH is being copied to SRAM, can be used by user as active high reset
    signal bootstrap_busy  : std_logic;

begin

    inst_dcm2 : entity work.dcm2 port map(
        CLKIN_IN  => clk_25M00,
        CLK0_OUT  => clock_16,
        CLK0_OUT1 => open,
        CLK2X_OUT => open);

    inst_dcm3 : entity work.dcm3 port map (
        CLKIN_IN  => clock_16,
        CLK0_OUT  => clock_32,
        CLK0_OUT1 => open,
        CLK2X_OUT => open);
    
    inst_AtomFpga_Core : entity work.AtomFpga_Core
    generic map (
        CImplSDDOS          => true,
        CImplAtoMMC2        => false,
        CImplGraphicsExt    => false,
        CImplSoftChar       => false,
        CImplSID            => true,
        CImplVGA80x40       => false,
        CImplHWScrolling    => false,
        CImplMouse          => false,
        CImplUart           => false,
        CImplDoubleVideo    => false,        
        CImplRamRomNone     => true,
        CImplRamRomPhill    => false,
        CImplRamRomAtom2015 => false,
        MainClockSpeed      => 16000000,
        DefaultBaud         => 115200          
    )
    port map(
        clk_vga             => clk_25M00,
        clk_16M00           => clock_16,
        clk_32M00           => clock_32,
        ps2_clk             => ps2_clk,
        ps2_data            => ps2_data,
        ps2_mouse_clk       => open,
        ps2_mouse_data      => open,
        ERSTn               => hard_reset_n,
        IRSTn               => open,
        red                 => red,
        green               => green,
        blue                => blue,
        vsync               => vsync,
        hsync               => hsync,
        Phi2                => Phi2,
        ExternCE            => ExternCE,
        ExternWE            => ExternWE,
        ExternA             => ExternA,
        ExternDin           => ExternDin,
        ExternDout          => ExternDout,
        audiol              => audiol,
        audioR              => audioR,
        SDMISO              => SDMISO,
        SDSS                => SDSS,
        SDCLK               => SDCLK,
        SDMOSI              => SDMOSI,
        uart_RxD            => '1',
        uart_TxD            => open,
        avr_RxD             => '1',
        avr_TxD             => open,
        LED1                => open,
        LED2                => open,
        charSet             => '0'
    );

--------------------------------------------------------
-- Power Up Reset Generation
--------------------------------------------------------

    -- On the Duo the external reset signal is not asserted on power up
    -- This internal counter forces power up reset to happen
    -- This is needed by the GODIL to initialize some of the registers
    ResetProcess : process (clock_16)
    begin
        if rising_edge(clock_16) then
            if (reset_counter(reset_counter'high) = '0') then
                reset_counter <= reset_counter + 1;
            end if;
            powerup_reset_n <= ERSTn and reset_counter(reset_counter'high);
        end if;
    end process;

   -- extend the version seen by the core to hold the 6502 reset during bootstrap
   hard_reset_n <= powerup_reset_n and not bootstrap_busy;

--------------------------------------------------------
-- BOOTSTRAP SPI FLASH to SRAM
--------------------------------------------------------

    inst_bootstrap: entity work.bootstrap
    generic map (
        gated_write     => false,
        user_length     => user_length
    )
    port map(
        clock           => clock_16,
        powerup_reset_n => powerup_reset_n,
        bootstrap_busy  => bootstrap_busy,
        user_address    => user_address,
        RAM_nOE         => RAM_nOE,
        RAM_nWE         => RAM_nWE,
        RAM_nCS         => RAM_nCS,
        RAM_A           => RAM_A,
        RAM_Din         => RAM_Din,
        RAM_Dout        => RAM_Dout,
        SRAM_nOE        => RamOEn,
        SRAM_nWE        => RamWRn,
        SRAM_nCS        => CE1,        
        SRAM_A(20 downto 16) => open,
        SRAM_A(15 downto 0) => RamA,
        SRAM_D          => RamD(7 downto 0),
        FLASH_CS        => FLASH_CS,
        FLASH_SI        => FLASH_SI,
        FLASH_CK        => FLASH_CK,
        FLASH_SO        => FLASH_SO
    );

    RamD(15 downto 8) <= (others => 'Z');
    
    MemProcess : process (clock_16)
    begin
        if rising_edge(clock_16) then
            RAM_A      <= ExternA xor ("000" & x"8000");
            RAM_nCS    <= not ExternCE;
            RAM_nOE    <= not ((not ExternWE) and ExternCE);
            RAM_nWE    <= not (ExternWE and ExternCE and phi2);
            RAM_Din    <= ExternDin;
       end if;
    end process;
    
    ExternDout <= RAM_Dout;
    
end behavioral;


