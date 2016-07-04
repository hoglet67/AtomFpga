--------------------------------------------------------------------------------
-- Copyright (c) 2016 David Banks
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    
-- \   \   \/    
--  \   \         
--  /   /         Filename  : RamRom_Atom2015
-- /___/   /\     Timestamp : 04/07/2016
-- \   \  /  \ 
--  \___\/\___\ 
--
--Design Name: RamRom_Atom2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity RamRom_Atom2015 is
    port (clock        : in  std_logic;
          reset_n      : in  std_logic;
          -- signals from/to 6502
          cpu_addr     : in  std_logic_vector (15 downto 0);
          cpu_we       : in  std_logic;
          cpu_dout     : in  std_logic_vector (7 downto 0);
          cpu_din      : out std_logic_vector (7 downto 0);
          -- signals from/to external memory system
          ExternCE     : out std_logic;
          ExternWE     : out std_logic;
          ExternA      : out std_logic_vector (18 downto 0);
          ExternDin    : out std_logic_vector (7 downto 0);
          ExternDout   : in  std_logic_vector (7 downto 0)
   );
end RamRom_Atom2015;

architecture behavioral of RamRom_Atom2015 is
    
    signal BFFE_Enable : std_logic;
    signal BFFF_Enable : std_logic;    
    signal RegBFFE  : std_logic_vector (7 downto 0);
    signal RegBFFF  : std_logic_vector (7 downto 0);

    signal WriteProt       : std_logic;                     -- Write protects #A000, #C000-#FFFF
    signal OSInRam         : std_logic;                     -- #C000-#FFFF in RAM
    signal OSRomBank       : std_logic;                     -- bank0 or bank1
    signal ExRamBank       : std_logic_vector (1 downto 0); -- #4000-#7FFF bank select
    signal RomLatch        : std_logic_vector (2 downto 0); -- #A000-#AFFF bank select

begin

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

    -------------------------------------------------
    -- External address decoding
    --
    -- external address bus is 18..0 (512KB)
    -- bit 18 is always zero 
    -- bit 17 selects between ROM (0) and RAM (1)
    -- bits 16..0 select with 128KB block
    -------------------------------------------------

    ExternCE   <= '1' when cpu_addr(15 downto 14) = "11"   else
                  '1' when cpu_addr(15 downto 12) = "1010" else
                  '1' when cpu_addr(15) = '0'              else
                  '0';

    ExternWE   <= '0' when cpu_addr(15 downto 14) = "11" and OsInRam = '0' else
                  '0' when cpu_addr(15) = '1' and WriteProt = '1' else
                  cpu_we;

    ExternA    <= "0010"  & OSRomBank & cpu_addr(13 downto 0) when cpu_addr(15 downto 14) = "11" and OSInRam = '0' else
                  "01111" &             cpu_addr(13 downto 0) when cpu_addr(15 downto 14) = "11" and OSInRam = '1' else
                  "0110"  & RomLatch  & cpu_addr(11 downto 0) when cpu_addr(15 downto 12) = "1010" else
                  "010"   & ExRamBank & cpu_addr(13 downto 0) when cpu_addr(15 downto 14) = "01"   else                  
                  "01110" &             cpu_addr(13 downto 0);        
    
    ExternDin   <= cpu_dout;

    cpu_din     <= RegBFFE when BFFE_Enable = '1' else 
                   RegBFFF when BFFF_Enable = '1' else 
                   ExternDout;

    -------------------------------------------------
    -- RAM/ROM Board Registers
    -------------------------------------------------
    
    BFFE_Enable <= '1' when cpu_addr(15 downto 0) = "1011111111111110" else '0';
    BFFF_Enable <= '1' when cpu_addr(15 downto 0) = "1011111111111111" else '0';
    
    RomLatchProcess : process (reset_n, clock)
    begin
        if reset_n = '0' then
            RegBFFE(5) <= '0';
            RegBFFE(3 downto 0) <= (others => '0');
            RegBFFF <= (others => '0');
        elsif rising_edge(clock) then
            if BFFE_Enable = '1' and cpu_we = '1' then
                RegBFFE <= cpu_dout;
            end if;
            if BFFF_Enable = '1' and cpu_we = '1' then
                RegBFFF <= cpu_dout;
            end if;
        end if;
    end process;
        
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
    -------------------------------------------------    

    WriteProt  <= RegBFFE(7);
    OSRomBank  <= RegBFFE(3);
    OSInRam    <= RegBFFE(2);
    ExRamBank  <= RegBFFE(1 downto 0);
    RomLatch   <= RegBFFF(2 downto 0);
    
end behavioral;


