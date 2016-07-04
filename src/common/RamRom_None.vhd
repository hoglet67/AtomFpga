--------------------------------------------------------------------------------
-- Copyright (c) 2016 David Banks
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    
-- \   \   \/    
--  \   \         
--  /   /         Filename  : RamRom_None
-- /___/   /\     Timestamp : 04/07/2016
-- \   \  /  \ 
--  \___\/\___\ 
--
--Design Name: RamRom_None

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity RamRom_None is
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
end RamRom_None;

architecture behavioral of RamRom_None is
    
    signal RamCE       : std_logic;    
    signal RomCE       : std_logic;    
    
begin

    RamCE       <= '1' when cpu_addr(15) = '0'              else
                   '0';
                   
    RomCE       <= '1' when cpu_addr(15 downto 14) = "11"   else
                   '1' when cpu_addr(15 downto 12) = "1010" else
                   '0';

    ExternCE    <= RamCE or RomCE;

    ExternWE    <= cpu_we and RamCE;

    ExternA     <= "000" & cpu_addr(15 downto 0);        
    
    ExternDin   <= cpu_dout;

    cpu_din     <= ExternDout;
    
end behavioral;


