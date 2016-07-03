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

    signal clock_16        : std_logic;
    signal clock_25        : std_logic;
    signal clock_32        : std_logic;
    signal IRSTn           : std_logic;
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
    
    signal RamA            : std_logic_vector(18 downto 0);
    signal RamCE           : std_logic;
    signal RamWR           : std_logic;
    signal ExternWE        : std_logic;
    signal ExternA         : std_logic_vector (16 downto 0);
    signal ExternDin       : std_logic_vector (7 downto 0);
    signal ExternDout      : std_logic_vector (7 downto 0);
    
    signal nARD            : std_logic;
    signal nAWR            : std_logic;
    signal AVRA0           : std_logic;
    signal AVRInt          : std_logic;
    signal AVRDataIn       : std_logic_vector (7 downto 0);
    signal AVRDataOut      : std_logic_vector (7 downto 0);

    signal PL8Data         : std_logic_vector (7 downto 0);
    signal PL8Enable       : std_logic;

    signal LED1n           : std_logic;
    signal LED2n           : std_logic;

    signal SelectBFFE      : std_logic;
    signal SelectBFFF      : std_logic;
    
    signal RegBFFE         : std_logic_vector (7 downto 0);
    signal RegBFFF         : std_logic_vector (7 downto 0);

    signal WriteProt       : std_logic;                     -- Write protects #A000, #C000-#FFFF
    signal OSInRam         : std_logic;                     -- #C000-#FFFF in RAM
    signal ExRamBank       : std_logic_vector (1 downto 0); -- #4000-#7FFF bank select
    signal RomLatch        : std_logic_vector (3 downto 0); -- #A000-#AFFF bank select

    signal ioport          : std_logic_vector (7 downto 0);


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
        CImplSDDOS        => false,
        CImplGraphicsExt  => true,
        CImplSoftChar     => true,
        CImplSID          => true,
        CImplVGA80x40     => true,
        CImplHWScrolling  => true,
        CImplMouse        => true,
        CImplUart         => true,
        CImplDoubleVideo  => true,
        MainClockSpeed    => 16000000,
        DefaultBaud       => 115200          
     )
     port map (
        clk_vga           => clock_25,
        clk_16M00         => clock_16,
        clk_32M00         => clock_32,
        ps2_clk           => ps2_kbd_clk,
        ps2_data          => ps2_kbd_data,
        ps2_mouse_clk     => ps2_mse_clk,
        ps2_mouse_data    => ps2_mse_data,
        ERSTn             => hard_reset_n,
        IRSTn             => IRSTn,
        red               => red(3 downto 1),
        green             => green(3 downto 1),
        blue              => blue(3 downto 1),
        vsync             => vsync,
        hsync             => hsync,
        RamCE             => open,
        RomCE             => open,
        phi2              => phi2,
        ExternWE          => ExternWE,
        ExternA           => ExternA,
        ExternDin         => ExternDin,
        ExternDout        => ExternDout,        
        audiol            => audioL,
        audioR            => audioR,
        SDMISO            => '0',
        SDSS              => open,
        SDCLK             => open,
        SDMOSI            => open,
        uart_RxD          => uart_RxD,
        uart_TxD          => uart_TxD,
        LED1              => open,
        LED2              => open,
        charSet           => DIP(0),
        Joystick1         => JOYSTICK1,
        Joystick2         => JOYSTICK2
    );  

    red(0)     <= '0';
    green(0)   <= '0';
    blue(0)    <= '0';
    
    LED1       <= not LED1n;
    LED2       <= not LED2n;

--------------------------------------------------------
-- RAM/ROM
--------------------------------------------------------
    
    -------------------------------------------------
    -- BFFE and BFFF registers
    --
    -- See http://stardot.org.uk/forums/viewtopic.php?f=44&t=9341
    --
    -- The following are currently un-implemented:
    --
    -- - BFFE bit 6 (turbo mode)
    --   as F1..F4 already allow 1/2/4/8MHz to be selected
    --
    -- - BFFE bit 3 (#C000-#FFFF bank select)
    --   as there is insufficient space for a second ROM bank
    --   unless switch from the SoftAVR to the real AVR
    --
    -------------------------------------------------
    SelectBFFE <= '1' when ExternA(15 downto 0) = "1011111111111110" else '0';
    SelectBFFF <= '1' when ExternA(15 downto 0) = "1011111111111111" else '0';
    
    RomLatchProcess : process (hard_reset_n, IRSTn, clock_16)
    begin
        if hard_reset_n = '0' OR IRSTn = '0' then
            RegBFFE(7 downto 0) <= "10000000";
            RegBFFF(7 downto 0) <= "00000000";
        elsif rising_edge(clock_16) then
            if SelectBFFE = '1' and ExternWE = '1' then
                RegBFFE <= ExternDin;
            end if;
            if SelectBFFF = '1' and ExternWE = '1' then
                RegBFFF <= ExternDin;
            end if;
        end if;
    end process;

    WriteProt  <= RegBFFE(7);
    OSInRam    <= RegBFFE(2);
    ExRamBank  <= RegBFFE(1 downto 0);
    RomLatch   <= RegBFFF(3 downto 0);
    
--------------------------------------------------------
-- AtomMMC (maybe push down into core?)
--------------------------------------------------------

    Inst_AVR8: entity work.AVR8 port map(
        clk16M            => clock_16,
        nrst              => IRSTn,
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
        clk               => clock_16,
        enable            => PL8Enable,
        nRST              => IRSTn,
        RW                => not ExternWE,
        Addr              => ExternA(2 downto 0),
        DataIn            => ExternDin,
        DataOut           => PL8Data,
        AVRDataIn         => AVRDataIn,
        AVRDataOut        => AVRDataOut,
        nARD              => nARD,
        nAWR              => nAWR,
        AVRA0             => AVRA0,
        AVRINTOut         => AVRInt,
        AtomIORDOut       => open,
        AtomIOWROut       => open
    );
    
--------------------------------------------------------
-- Clock Generation
--------------------------------------------------------
    
    inst_dcm4 : entity work.dcm4 port map(
        CLKIN_IN  => clk_32M00,
        CLK0_OUT  => clock_32,
        CLKFX_OUT => clock_25
    );

    inst_dcm5 : entity work.dcm5 port map(
        CLKIN_IN  => clk_32M00,
        CLKFX_OUT => clock_16
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

    -- Mapping to External SRAM...
    
    -- 0x00000 - Atom #A000 Bank 0
    -- 0x01000 - Atom #A000 Bank 1
    -- 0x02000 - Atom #A000 Bank 2
    -- 0x03000 - Atom #A000 Bank 3
    -- 0x04000 - Atom #A000 Bank 4
    -- 0x05000 - Atom #A000 Bank 5
    -- 0x06000 - Atom #A000 Bank 6
    -- 0x07000 - Atom #A000 Bank 7
    -- 0x08000 - BBC #6000 Bank 0 (ExtROM1)
    -- 0x09000 - BBC #6000 Bank 1 (ExtROM1)
    -- 0x0A000 - BBC #6000 Bank 2 (ExtROM1)
    -- 0x0B000 - BBC #6000 Bank 3 (ExtROM1)
    -- 0x0C000 - BBC #6000 Bank 4 (ExtROM1)
    -- 0x0D000 - BBC #6000 Bank 5 (ExtROM1)
    -- 0x0E000 - BBC #6000 Bank 6 (ExtROM1)
    -- 0x0F000 - BBC #6000 Bank 7 (ExtROM1)
    -- 0x10000 - Atom Basic (DskRomEn=1)
    -- 0x11000 - Atom FP (DskRomEn=1)
    -- 0x12000 - Atom MMC (DskRomEn=1)
    -- 0x13000 - Atom Kernel (DskRomEn=1)
    -- 0x14000 - Atom Basic (DskRomEn=0)
    -- 0x15000 - Atom FP (DskRomEn=0)
    -- 0x16000 - unused
    -- 0x17000 - Atom Kernel (DskRomEn=0)
    -- 0x18000 - unused
    -- 0x19000 - BBC #7000 (ExtROM2)
    -- 0x1A000 - BBC Basic 1/4
    -- 0x1B000 - unused
    -- 0x1C000 - BBC Basic 2/4
    -- 0x1D000 - BBC Basic 3/4
    -- 0x1E000 - BBC Basic 4/4
    -- 0x1F000 - BBC MOS 3.0

    -- currently only the following are implemented:
    -- Atom #A000 banks 0..7
    -- Atom Basic, FP, MMC, Kernel (DskRomEn=1)
    
    RamCE      <= '1' when ExternA(15 downto 14) = "11"                   else
                  '1' when ExternA(15 downto 12) = "1010"                 else
                  '1' when ExternA(15) = '0'                              else
                  '0';

    RamWR      <= '0' when ExternA(15) = '1' and WriteProt = '1' else ExternWE;

    RamA       <= "000" & RomLatch  & ExternA(11 downto 0) when ExternA(15 downto 12) = "1010" else
                  "001" & "00"      & ExternA(13 downto 0) when ExternA(15 downto 14) = "11"   else
                  "100" & ExRamBank & ExternA(13 downto 0) when ExternA(15 downto 14) = "01"   else                  
                  "101" & ExternA(15 downto 0);        

    MemProcess : process (clock_16)
    begin
        if rising_edge(clock_16) then
            RAM_A      <= RamA;
            RAM_nCS    <= not RamCE;
            RAM_nOE    <= not ((not RamWR) and RamCE);
            RAM_nWE    <= not (RamWR and RamCE and phi2);
            RAM_Din    <= ExternDin;
       end if;
    end process;            
    
    PL8Enable  <= '1' when ExternA(15 downto 8) = "10110100" else '0';
    
    ExternDout <= PL8Data  when PL8Enable  = '1' else
                  RegBFFE  when SelectBFFE = '1' else 
                  RegBFFF  when SelectBFFF = '1' else 
                  RAM_Dout;

end behavioral;


