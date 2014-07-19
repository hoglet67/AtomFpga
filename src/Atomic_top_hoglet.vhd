--------------------------------------------------------------------------------
-- Copyright (c) 2014 David Banks
--
-- based on work by Alan Daly. Copyright(c) 2009. All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    
-- \   \   \/    
--  \   \         
--  /   /         Filename  : Atomic_top_hoglet.vhf
-- /___/   /\     Timestamp : 03/04/2014 19:27:00
-- \   \  /  \ 
--  \___\/\___\ 
--
--Design Name: Atomic_top_hoglet
--Device: spartan3E

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Atomic_top_hoglet is
    port (clk_32M00 : in  std_logic;
           ps2_clk  : in  std_logic;
           ps2_data : in  std_logic;
           ps2_mouse_clk  : inout  std_logic;
           ps2_mouse_data : inout  std_logic;
           ERSTn    : in  std_logic;
           red      : out std_logic_vector (2 downto 2);
           green    : out std_logic_vector (2 downto 1);
           blue     : out std_logic_vector (2 downto 2);
           vsync    : out std_logic;
           hsync    : out std_logic;
           audiol   : out std_logic;
           audioR   : out std_logic;
           RAMCEn   : out std_logic;
           RAMOEn   : out std_logic;
           RAMWRn   : out std_logic;
           ROMCEn   : out std_logic;
           ROMOEn   : out std_logic;
           ROMWRn   : out std_logic;
           ExternA  : out std_logic_vector (16 downto 0);
           ExternD  : inout std_logic_vector (7 downto 0);
           SDMISO   : in  std_logic;
           SDSS     : out std_logic;
           SDCLK    : out std_logic;
           SDMOSI   : out std_logic;
           RxD      : in  std_logic;
           TxD      : out std_logic;
           LED1     : out std_logic;
           LED2     : out std_logic
           );
end Atomic_top_hoglet;

architecture behavioral of Atomic_top_hoglet is

    component dcm4
        port (
            CLKIN_IN   : in  std_logic;
            CLK0_OUT  : out std_logic;
            CLK0_OUT1 : out std_logic;
            CLK2X_OUT : out std_logic
        ); 
    end component;

    component dcm5
        port (
            CLKIN_IN   : in  std_logic;
            CLK0_OUT  : out std_logic;
            CLK0_OUT1 : out std_logic;
            CLK2X_OUT : out std_logic
        ); 
    end component;
 
    component Atomic_core
        generic (
            CImplSDDOS       : boolean;
            CImplGraphicsExt : boolean;
            CImplSoftChar    : boolean;
            CImplSID         : boolean;
            CImplVGA80x40    : boolean;
            CImplHWScrolling : boolean;
            CImplMouse       : boolean;
            CImplUart        : boolean;
            MainClockSpeed   : integer;
            DefaultBaud      : integer
        );
        port (
            clk_vga : in  std_logic;
            clk_16M00 : in  std_logic;
            clk_32M00 : in  std_logic;
            ps2_clk   : in  std_logic;
            ps2_data  : in  std_logic;
            ps2_mouse_clk : inout    std_logic;
            ps2_mouse_data : inout    std_logic;
            ERSTn     : in  std_logic;
            IRSTn     : out std_logic;
            SDMISO    : in  std_logic;
            red       : out std_logic_vector(2 downto 0);
            green     : out std_logic_vector(2 downto 0);
            blue      : out std_logic_vector(2 downto 0);
            vsync     : out std_logic;
            hsync     : out std_logic;
            RamCE     : out std_logic;
            RomCE     : out std_logic;
            ExternWE  : out std_logic;
            ExternA   : out std_logic_vector (16 downto 0);
            ExternDin : out std_logic_vector (7 downto 0);
            ExternDout: in  std_logic_vector (7 downto 0);
            audiol    : out std_logic;
            audioR    : out std_logic;
            SDSS      : out std_logic;
            SDCLK     : out std_logic;
            SDMOSI    : out std_logic;
            uart_RxD  : in  std_logic;
            uart_TxD  : out std_logic;
            LED1      : out   std_logic;        
            LED2      : out   std_logic
            );
    end component;
   
    component AtomPL8
        port (
            clk         : in std_logic;
            enable      : in std_logic;
            nRST        : in std_logic;
            RW          : in std_logic;
            Addr        : in std_logic_vector(2 downto 0);
            DataIn      : in std_logic_vector(7 downto 0);
            nARD        : in std_logic;
            nAWR        : in std_logic;
            AVRA0       : in std_logic;    
            AVRDataIn   : in std_logic_vector(7 downto 0);      
            AVRDataOut  : OUT std_logic_vector(7 downto 0);      
            DataOut     : OUT std_logic_vector(7 downto 0);
            AVRINTOut   : OUT std_logic;
            AtomIORDOut : out std_logic;
            AtomIOWROut : out std_logic
        );
    end component;

    component AVR8
        port(
            clk16M    : in std_logic;
            nrst      : in std_logic;
            portain   : in std_logic_vector(7 downto 0);
            portaout  : out std_logic_vector(7 downto 0);
            portbin   : in std_logic_vector(7 downto 0);
            portbout  : out std_logic_vector(7 downto 0);
            portc     : inout std_logic_vector(7 downto 0);
            portdin   : in std_logic_vector(7 downto 0);
            portdout  : out std_logic_vector(7 downto 0);
            porte     : inout std_logic_vector(7 downto 0);
            portf     : inout std_logic_vector(7 downto 0);
            spi_mosio : out std_logic;
            spi_scko  : out std_logic;
            spi_cs_n  : out std_logic;
            spi_misoi : in std_logic;
            rxd       : in std_logic;    
            txd       : out std_logic
        );
    end component;

    signal clk_vga : std_logic;
    signal clk_16M00 : std_logic;
    signal IRSTn     : std_logic;

    signal RamCE     : std_logic;
    signal RomCE     : std_logic;
    signal ExternWE  : std_logic;
    signal ExternDin : std_logic_vector (7 downto 0);
    signal ExternDout: std_logic_vector (7 downto 0);
    
    signal nARD     : std_logic;
    signal nAWR     : std_logic;
    signal AVRA0    : std_logic;
    signal AVRInt   : std_logic;
    signal AVRDataIn  : std_logic_vector (7 downto 0);
    signal AVRDataOut  : std_logic_vector (7 downto 0);

    signal Addr  : std_logic_vector (16 downto 0);
    signal PL8Data  : std_logic_vector (7 downto 0);
    signal PL8Enable: std_logic;
    signal cpuclken     : std_logic;
    
    signal BFFE_Enable : std_logic;
    signal BFFF_Enable : std_logic;
    
    signal RomJumpers  : std_logic_vector (7 downto 0);
    signal RomLatch  : std_logic_vector (7 downto 0);
    
    signal ExtRAMEN : std_logic; -- SwitchLatch[0] on Phill's board
    signal DskRAMEN : std_logic; -- SwitchLatch[1] on Phill's board, not currently used in AtomFPGA
    signal DskROMEN : std_logic; -- SwitchLatch[2] on Phill's board
    signal BeebMode : std_logic; -- SwitchLatch[3] on Phill's board

    signal Addr7000RAM : std_logic;
    signal Addr7000ROM : std_logic;
    signal AddrA000RAM : std_logic;
    signal AddrA000ROM : std_logic;

    signal avr_TxR : std_logic;
    
    signal uart_RxD : std_logic;
    signal uart_TxD : std_logic;     
    
begin

    inst_dcm4 : dcm4 port map(
        CLKIN_IN  => clk_32M00,
        CLK0_OUT  => clk_vga,
        CLK0_OUT1 => open,
        CLK2X_OUT => open);

    inst_dcm5 : dcm5 port map(
        CLKIN_IN  => clk_32M00,
        CLK0_OUT  => clk_16M00,
        CLK0_OUT1 => open,
        CLK2X_OUT => open);
    
    inst_Atomic_core : Atomic_core
    generic map (
        CImplSDDOS => false,
        CImplGraphicsExt => true,
        CImplSoftChar    => true,
        CImplSID         => true,
        CImplVGA80x40    => true,
        CImplHWScrolling => true,
        CImplMouse       => true,
        CImplUart        => true,
        MainClockSpeed   => 16000000,
        DefaultBaud      => 115200          
     )
     port map(
        clk_vga   => clk_vga,
        clk_16M00 => clk_16M00,
        clk_32M00 => clk_32M00,
        ps2_clk   => ps2_clk,
        ps2_data  => ps2_data,
        ps2_mouse_clk   => ps2_mouse_clk,
        ps2_mouse_data  => ps2_mouse_data,
        ERSTn     => ERSTn,
        IRSTn     => IRSTn,
        red(2)   => red(2),
        red(1 downto 0)    => open,
        green(2 downto 1) => green(2 downto 1),
        green(0)  => open,
        blue(2)  => blue(2),
        blue(1 downto 0) => open,
        vsync     => vsync,
        hsync     => hsync,
        RamCE     => open,
        RomCE     => open,
        ExternWE  => ExternWE,
        ExternA   => Addr,
        ExternDin => ExternDin,
        ExternDout=> ExternDout,        
        audiol    => audiol,
        audioR    => audioR,
        SDMISO    => '0',
        SDSS      => open,
        SDCLK     => open,
        SDMOSI    => open,
        uart_RxD  => uart_RxD,
        uart_TxD  => uart_TxD,
        LED1      => open,
        LED2      => open
        );  

    Inst_AVR8: AVR8 PORT MAP(
        clk16M      => clk_16M00,
        nrst        => IRSTn,
        portain     => AVRDataOut,
        portaout    => AVRDataIn,

        portbin(0)  => '0',
        portbin(1)  => '0',
        portbin(2)  => '0',
        portbin(3)  => '0',
        portbin(4)  => AVRInt,
        portbin(5)  => '0',
        portbin(6)  => '0',
        portbin(7)  => '0',
        
        portbout(0)  => nARD,
        portbout(1)  => nAWR,
        portbout(2)  => open,
        portbout(3)  => AVRA0,
        portbout(4)  => open,
        portbout(5)  => open,
        portbout(6)  => LED1,
        portbout(7)  => LED2,

        portdin      => (others => '0'),
        portdout(0)  => open,
        portdout(1)  => open,
        portdout(2)  => open,
        portdout(3)  => open,
        portdout(4)  => SDSS,
        portdout(5)  => open,
        portdout(6)  => open,
        portdout(7)  => open,

        spi_mosio    => SDMOSI,
        spi_scko     => SDCLK,
        spi_misoi    => SDMISO,
     
        rxd          => RxD,
        txd          => avr_TxR
    );
    
    Inst_AtomPL8: AtomPL8 port map(
        clk => clk_16M00,
        enable => PL8Enable,
        nRST => IRSTn,
        RW => not ExternWE,
        Addr => Addr(2 downto 0),
        DataIn => ExternDin,
        DataOut => PL8Data,
        AVRDataIn => AVRDataIn,
        AVRDataOut => AVRDataOut,
        nARD => nARD,
        nAWR => nAWR,
        AVRA0 => AVRA0,
        AVRINTOut => AVRInt,
        AtomIORDOut => open,
        AtomIOWROut => open
    );

    Addr7000ROM <= '1' when Addr(15 downto 12) = "0111" and (BeebMode = '1' and ExtRAMEN = '0')
                       else '0';

    Addr7000RAM <= '1' when Addr(15 downto 12) = "0111" and (BeebMode = '0' or ExtRAMEN = '1')
                       else '0';
        
    AddrA000ROM <= '1' when Addr(15 downto 12) = "1010" and (BeebMode = '1' or RomLatch(4 downto 0) /= "00000" or ExtRAMEN = '0')
                       else '0';

    AddrA000RAM <= '1' when Addr(15 downto 12) = "1010" and (BeebMode = '0' and RomLatch(4 downto 0) = "00000" and ExtRAMEN = '1')
                       else '0';
    
    RamCE       <= '1' when Addr(15 downto 12) < "0111" or Addr7000RAM = '1' or AddrA000RAM = '1'
                       else '0';

    RomCE       <= '1' when Addr(15 downto 14) = "11" or Addr7000ROM = '1' or AddrA000ROM = '1'
                       else '0';
           
    RAMWRn     <= not (ExternWE and RamCE);
    RAMOEn     <= not ((not ExternWE) and RamCE);

    ROMWRn     <= not (ExternWE and RomCE);
    ROMOEn     <= not ((not ExternWE) and RomCE);

    ExternD    <= ExternDin when ExternWE = '1' else "ZZZZZZZZ";
    
    PL8Enable  <= '1' when Addr(15 downto 8) = "10110100" else '0';
    
    ExternDout <= PL8Data when PL8Enable = '1' else
                  RomJumpers when BFFE_Enable = '1' else 
                  RomLatch when BFFF_Enable = '1' else 
                  ExternD;

    -------------------------------------------------
    -- External address decoding
    -------------------------------------------------

    ExternA  <=

        -- 0x7000 comes from ROM address 0x09000 in Beeb Mode (Ext ROM 2)
        ( "01001" & Addr(11 downto 0)) when Addr7000ROM = '1' else
    
        -- 0x7000 is 4K remappable RAM bank mapped to 0x7000
        (ExtRAMEN & Addr(15 downto 0)) when Addr7000RAM = '1' else

        -- 0xA000 remappable RAM bank at 0x7000 re-mapped to 0xA000
        ( "00111" & Addr(11 downto 0)) when AddrA000RAM = '1' else
        
        -- 0xA000 is bank switched by ROM Latch in Atom Mode
        -- 5 bits of RomLatch are used here, to allow any of the 32 pages of FLASH to A000 for in system programming
        ( RomLatch(4 downto 0) & Addr(11 downto 0)) when AddrA000ROM = '1' and BeebMode = '0' else

        -- 0xA000 comes from ROM address 0x0A000 in Beeb Mode
        ( "01010" & Addr(11 downto 0)) when AddrA000ROM = '1' and BeebMode = '1' else

        -- 0xC000-0xFFFF comes from ROM address 0x0C000-0x0FFFF in Beeb Mode
        ( "0" & Addr(15 downto 0)) when Addr(15 downto 14) = "11" and BeebMode = '1' else
        
        -- 0xC000-0xFFFF comes from ROM address 0x10000-0x17FFF in Atom Mode (2x 16K banks selected SwitchLatch[2])
        ( "10" & DskROMEN & Addr(13 downto 0)) when Addr(15 downto 14) = "11" and BeebMode = '0' else
             
        -- RAM
        Addr;

    -------------------------------------------------
    -- ROM Latch and Jumpers
    -------------------------------------------------
    BFFE_Enable <= '1' when Addr(15 downto 0) = "1011111111111110" else '0';
    BFFF_Enable <= '1' when Addr(15 downto 0) = "1011111111111111" else '0';

    ExtRAMEN <= RomJumpers(0);
    DskRAMEN <= RomJumpers(1); -- currently unused
    DskROMEN <= RomJumpers(2);
    BeebMode <= RomJumpers(3);
        
    RomLatchProcess : process (ERSTn, IRSTn, clk_16M00)
    begin
        if ERSTn = '0' then
            RomJumpers <= "00000000";
            RomLatch   <= "00000000";
        elsif rising_edge(clk_16M00) then
            if BFFE_Enable = '1' and ExternWE = '1' then
                RomJumpers <= ExternDin;
            end if;
            if BFFF_Enable = '1' and ExternWE = '1' then
                RomLatch   <= ExternDin;
            end if;
        end if;
    end process;
    
    uart_RxD <= RxD;
    -- Idle state is high, logically OR the active low signals
    TxD <= uart_TxD and avr_TxR;
    
    
end behavioral;


