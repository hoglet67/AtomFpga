--------------------------------------------------------------------------------
-- Copyright (c) 2016 David Banks
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    
-- \   \   \/    
--  \   \         
--  /   /         Filename  : RamRom_SchakelKaart
-- /___/   /\     Timestamp : 04/07/2016
-- \   \  /  \ 
--  \___\/\___\ 
--
--Design Name: RamRom_SchakelKaart

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity RamRom_SchakelKaart is
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
end RamRom_SchakelKaart;

architecture behavioral of RamRom_SchakelKaart is
    
    signal BFFF_Enable : std_logic;    
    signal RegBFFF     : std_logic_vector (7 downto 0);
    signal RomLatch    : std_logic_vector (2 downto 0); -- #A000-#AFFF bank select

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
    -- 0x08000 - Unused
    -- 0x09000 - Atom #1000 (BRAN)
    -- 0x0A000 - Unused
    -- 0x0B000 - Unused
    -- 0x0C000 - Atom #C000 (Atom Basic)
    -- 0x0D000 - Atom #D000 (Atom Float patched for BRAN)
    -- 0x0E000 - Atom #E000 (Atom SDDOS)
    -- 0x0F000 - Atom #F000 (Atom Kernel patched)


    ExternCE   <= '1' when cpu_addr(15 downto 14) = "11"   else
                  '1' when cpu_addr(15 downto 12) = "1010" else
                  '1' when cpu_addr(15) = '0'              else
                  '0';

    ExternWE   <= '0' when cpu_addr(15) = '1' else
                  '0' when cpu_addr(15 downto 12) = "0001" else
                  cpu_we;

    ExternA    <= "000"               & cpu_addr(15 downto 0) when cpu_addr(15 downto 14) = "11"   else
                  "0000"  & RomLatch  & cpu_addr(11 downto 0) when cpu_addr(15 downto 12) = "1010" else
                  "0001"              & cpu_addr(14 downto 0) when cpu_addr(15 downto 12) = "0001" else
                  "0100"              & cpu_addr(14 downto 0);        
    
    ExternDin   <= cpu_dout;

    cpu_din     <= RegBFFF when BFFF_Enable = '1' else 
                   ExternDout;

    -------------------------------------------------
    -- RAM/ROM Board Registers
    -------------------------------------------------
    
    BFFF_Enable <= '1' when cpu_addr(15 downto 0) = "1011111111111111" else '0';
    
    RomLatchProcess : process (reset_n, clock)
    begin
        if reset_n = '0' then
            RegBFFF <= (others => '0');
        elsif rising_edge(clock) then
            if BFFF_Enable = '1' and cpu_we = '1' then
                RegBFFF <= cpu_dout;
            end if;
        end if;
    end process;
        
    RomLatch   <= RegBFFF(2 downto 0);
    
end behavioral;


