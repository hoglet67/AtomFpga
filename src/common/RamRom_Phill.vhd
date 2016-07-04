--------------------------------------------------------------------------------
-- Copyright (c) 2016 David Banks
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    
-- \   \   \/    
--  \   \         
--  /   /         Filename  : RamRom_Phill
-- /___/   /\     Timestamp : 04/07/2016
-- \   \  /  \ 
--  \___\/\___\ 
--
--Design Name: RamRom_Phill

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity RamRom_Phill is
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
end RamRom_Phill;

architecture behavioral of RamRom_Phill is
    
    signal BFFE_Enable : std_logic;
    signal BFFF_Enable : std_logic;    
    signal RegBFFE     : std_logic_vector (7 downto 0);
    signal RegBFFF     : std_logic_vector (7 downto 0);

    signal RamCE       : std_logic;    
    signal RomCE       : std_logic;    

    signal ExtRAMEN1   : std_logic; -- SwitchLatch[0] on Phill's board
    signal ExtRAMEN2   : std_logic; -- SwitchLatch[1] on Phill's board
    signal DskRAMEN    : std_logic; -- SwitchLatch[1] on Phill's board, not currently used in AtomFPGA
    signal DskROMEN    : std_logic; -- SwitchLatch[2] on Phill's board
    signal BeebMode    : std_logic; -- SwitchLatch[3] on Phill's board
    signal RomLatch    : std_logic_vector (4 downto 0);    

    signal Addr6000RAM : std_logic;
    signal Addr6000ROM : std_logic;
    signal Addr7000RAM : std_logic;
    signal Addr7000ROM : std_logic;
    signal AddrA000RAM : std_logic;
    signal AddrA000ROM : std_logic;

begin


    Addr6000ROM <= '1' when cpu_addr(15 downto 12) = "0110" and (BeebMode = '1' and (RomLatch /= "00000" or ExtRAMEN1 = '0'))
                       else '0';

    Addr6000RAM <= '1' when cpu_addr(15 downto 12) = "0110" and (BeebMode = '0' or (RomLatch = "00000" and ExtRAMEN1 = '1'))
                       else '0';

    Addr7000ROM <= '1' when cpu_addr(15 downto 12) = "0111" and (BeebMode = '1' and ExtRAMEN2 = '0')
                       else '0';

    Addr7000RAM <= '1' when cpu_addr(15 downto 12) = "0111" and (BeebMode = '0' or ExtRAMEN2 = '1')
                       else '0';
        
    AddrA000ROM <= '1' when cpu_addr(15 downto 12) = "1010" and (BeebMode = '1' or RomLatch /= "00000" or ExtRAMEN1 = '0')
                       else '0';

    AddrA000RAM <= '1' when cpu_addr(15 downto 12) = "1010" and (BeebMode = '0' and RomLatch = "00000" and ExtRAMEN1 = '1')
                       else '0';

    RamCE       <= '1' when cpu_addr(15 downto 12) < "0110" or Addr6000RAM = '1' or Addr7000RAM = '1' or AddrA000RAM = '1'
                       else '0';
                   
    RomCE       <= '1' when cpu_addr(15 downto 14) = "11"   or Addr6000ROM = '1' or Addr7000ROM = '1' or AddrA000ROM = '1'
                       else '0';

    ExternCE    <= RamCE or RomCE;

    ExternWE    <= cpu_we and RamCE;
    
    ExternDin   <= cpu_dout;

    cpu_din     <= RegBFFE when BFFE_Enable = '1' else 
                   RegBFFF when BFFF_Enable = '1' else 
                   ExternDout;

    -------------------------------------------------
    -- External address decoding
    --
    -- external address bus is 18..0 (512KB)
    -- bit 18 is always zero 
    -- bit 17 selects between ROM (0) and RAM (1)
    -- bits 16..0 select with 128KB block
    -------------------------------------------------

    ExternA  <=

        -- 0x6000 comes from ROM address 0x08000-0x0F000 in Beeb Mode (Ext ROM 1)
        ( "0001" & RomLatch(2 downto 0) & cpu_addr(11 downto 0)) when Addr6000ROM = '1' else
    
        -- 0x6000 is 4K remappable RAM bank mapped to 0x6000
        ( "01" & ExtRAMEN1 & cpu_addr(15 downto 0)) when Addr6000RAM = '1' else
        
        -- 0x7000 comes from ROM address 0x19000 in Beeb Mode (Ext ROM 2)
        ( "0011001" & cpu_addr(11 downto 0)) when Addr7000ROM = '1' else
    
        -- 0x7000 is 4K remappable RAM bank mapped to 0x7000
        ( "01" & ExtRAMEN2 & cpu_addr(15 downto 0)) when Addr7000RAM = '1' else

        -- 0xA000 remappable RAM bank at 0x7000 re-mapped to 0xA000
        ( "0100111" & cpu_addr(11 downto 0)) when AddrA000RAM = '1' else
        
        -- 0xA000 is bank switched by ROM Latch in Atom Mode
        -- 5 bits of RomLatch are used here, to allow any of the 32 pages of FLASH to A000 for in system programming
        ( "00" & RomLatch & cpu_addr(11 downto 0)) when AddrA000ROM = '1' and BeebMode = '0' else

        -- 0xA000 comes from ROM address 0x0A000 in Beeb Mode
        ( "0011010" & cpu_addr(11 downto 0)) when AddrA000ROM = '1' and BeebMode = '1' else

        -- 0xC000-0xFFFF comes from ROM address 0x1C000-0x1FFFF in Beeb Mode
        ( "001" & cpu_addr(15 downto 0)) when cpu_addr(15 downto 14) = "11" and BeebMode = '1' else
        
        -- 0xC000-0xFFFF comes from ROM address 0x10000-0x17FFF in Atom Mode (2x 16K banks selected SwitchLatch[2])
        ( "0010" & DskROMEN & cpu_addr(13 downto 0)) when cpu_addr(15 downto 14) = "11" and BeebMode = '0' else
             
        -- RAM
        ( "010" & cpu_addr);


    -------------------------------------------------
    -- RAM/ROM Board Registers
    -------------------------------------------------
    
    BFFE_Enable <= '1' when cpu_addr(15 downto 0) = "1011111111111110" else '0';
    BFFF_Enable <= '1' when cpu_addr(15 downto 0) = "1011111111111111" else '0';
    
    RomLatchProcess : process (reset_n, clock)
    begin
        if reset_n = '0' then
            RegBFFE <= (others => '0');
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

    ExtRAMEN1 <= RegBFFE(0);
    ExtRAMEN2 <= RegBFFE(1);
    DskRAMEN  <= RegBFFE(1); -- currently unused
    DskROMEN  <= RegBFFE(2);
    BeebMode  <= RegBFFE(3);
    RomLatch  <= RegBFFF(4 downto 0);
    
end behavioral;


