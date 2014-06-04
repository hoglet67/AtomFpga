--------------------------------------------------------------------------------
-- Copyright (c) 2009 Alan Daly.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    
-- \   \   \/    
--  \   \         
--  /   /         Filename  : Atomic_top.vhf
-- /___/   /\     Timestamp : 02/03/2013 06:17:50
-- \   \  /  \ 
--  \___\/\___\ 
--
--Design Name: Atomic_top
--Device: spartan3A
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Atomic_core is
    generic (
       CImplSDDOS : boolean;
       CImplSID : boolean
    );
    port (clk_12M58 : in    std_logic;
        clk_16M00 : in    std_logic;
        clk_32M00 : in    std_logic;
        ps2_clk   : in    std_logic;
        ps2_data  : in    std_logic;
        ERSTn     : in    std_logic;
        IRSTn     : out   std_logic;
        red       : out   std_logic_vector (2 downto 0);
        green     : out   std_logic_vector (2 downto 0);
        blue      : out   std_logic_vector (2 downto 0);
        vsync     : out   std_logic;
        hsync     : out   std_logic;
        RamCE     : out   std_logic;
        RomCE     : out   std_logic;
        ExternWE  : out   std_logic;
        ExternA   : out   std_logic_vector (16 downto 0);
        ExternDin : out   std_logic_vector (7 downto 0);
        ExternDout: in    std_logic_vector (7 downto 0);
        audiol    : out   std_logic;
        audioR    : out   std_logic;
        SDMISO    : in    std_logic;
        SDSS      : out   std_logic;
        SDCLK     : out   std_logic;
        SDMOSI    : out   std_logic
        );
end Atomic_core;

architecture BEHAVIORAL of Atomic_core is
 
    component T65
        port(
            Mode    : in  std_logic_vector(1 downto 0);
            Res_n   : in  std_logic;
            Enable  : in  std_logic;
            Clk     : in  std_logic;
            Rdy     : in  std_logic;
            Abort_n : in  std_logic;
            IRQ_n   : in  std_logic;
            NMI_n   : in  std_logic;
            SO_n    : in  std_logic;
            DI      : in  std_logic_vector(7 downto 0);          
            R_W_n   : out std_logic;
            Sync    : out std_logic;
            EF      : out std_logic;
            MF      : out std_logic;
            XF      : out std_logic;
            ML_n    : out std_logic;
            VP_n    : out std_logic;
            VDA     : out std_logic;
            VPA     : out std_logic;
            A       : out std_logic_vector(23 downto 0);
            DO      : out std_logic_vector(7 downto 0));
	end component;

    component mc6847
        generic
            (
                T1_VARIANT   : boolean := false;
                CVBS_NOT_VGA : boolean := false);
        port
            (
                clk            : in  std_logic;
                clk_ena        : in  std_logic;
                reset          : in  std_logic;
                da0            : out std_logic;
                videoaddr      : out std_logic_vector (12 downto 0);
                dd             : in  std_logic_vector(7 downto 0);
                hs_n           : out std_logic;
                fs_n           : out std_logic;
                an_g           : in  std_logic;
                an_s           : in  std_logic;
                intn_ext       : in  std_logic;
                gm             : in  std_logic_vector(2 downto 0);
                css            : in  std_logic;
                inv            : in  std_logic;
                red            : out std_logic_vector(7 downto 0);
                green          : out std_logic_vector(7 downto 0);
                blue           : out std_logic_vector(7 downto 0);
                hsync          : out std_logic;
                vsync          : out std_logic;
                hblank         : out std_logic;
                vblank         : out std_logic;
                artifact_en    : in  std_logic;
                artifact_set   : in  std_logic;
                artifact_phase : in  std_logic;
                cvbs           : out std_logic_vector(7 downto 0));
    end component;
    
    component SRAM0x8000
        port (
            clk      : in  std_logic;
            rd_vid   : in  std_logic;
            addr_vid : in  std_logic_vector (12 downto 0);
            Q_vid    : out std_logic_vector (7 downto 0);
            we_uP    : in  std_logic;
            ce       : in  std_logic;
            addr_uP  : in  std_logic_vector (12 downto 0);
            D_uP     : in  std_logic_vector (7 downto 0);
            Q_uP     : out std_logic_vector (7 downto 0));
    end component;

    component I82C55
        port (

            I_ADDR : in  std_logic_vector(1 downto 0);  -- A1-A0
            I_DATA : in  std_logic_vector(7 downto 0);  -- D7-D0
            O_DATA : out std_logic_vector(7 downto 0);
            CS_H   : in  std_logic;
            WR_L   : in  std_logic;
            O_PA   : out std_logic_vector(7 downto 0);
            I_PB   : in  std_logic_vector(7 downto 0);
            I_PC   : in  std_logic_vector(3 downto 0);
            O_PC   : out std_logic_vector(3 downto 0);
            RESET  : in  std_logic;
            ENA    : in  std_logic;
            CLK    : in  std_logic
            );
    end component;

    component keyboard
        port (
            CLOCK      : in  std_logic;
            nRESET     : in  std_logic;
            CLKEN_1MHZ : in  std_logic;
            PS2_CLK    : in  std_logic;
            PS2_DATA   : in  std_logic;
            KEYOUT     : out std_logic_vector(5 downto 0);
            ROW        : in  std_logic_vector(3 downto 0);
            SHIFT_OUT  : out std_logic;
            CTRL_OUT   : out std_logic;
            REPEAT_OUT : out std_logic;
            BREAK_OUT  : out std_logic;
            TURBO      : out std_logic);
    end component;

    component M6522
        port (
            I_RS    : in  std_logic_vector(3 downto 0);
            I_DATA  : in  std_logic_vector(7 downto 0);
            O_DATA  : out std_logic_vector(7 downto 0);
            I_RW_L  : in  std_logic;
            I_CS1   : in  std_logic;
            I_CS2_L : in  std_logic;
            O_IRQ_L : out std_logic;
            I_CA1   : in  std_logic;
            I_CA2   : in  std_logic;
            O_CA2   : out std_logic;
            I_PA    : in  std_logic_vector(7 downto 0);
            O_PA    : out std_logic_vector(7 downto 0);
            I_CB1   : in  std_logic;
            O_CB1   : out std_logic;
            I_CB2   : in  std_logic;
            O_CB2   : out std_logic;
            I_PB    : in  std_logic_vector(7 downto 0);
            O_PB    : out std_logic_vector(7 downto 0);
            I_P2_H  : in  std_logic_vector(1 downto 0);
            RESET_L : in  std_logic;
            ENA_4   : in  std_logic;
            CLK     : in  std_logic
            );
    end component;

    component sid6581
        port(
            clk_1MHz : in std_logic;
            clk32 : in std_logic;
            clk_DAC : in std_logic;
            reset : in std_logic;
            cs : in std_logic;
            we : in std_logic;
            addr : in std_logic_vector(4 downto 0);
            di : in std_logic_vector(7 downto 0);    
            pot_x : in std_logic;
            pot_y : in std_logic;      
            do : out std_logic_vector(7 downto 0);
            audio_out : out std_logic;
            audio_data : out std_logic_vector(17 downto 0)
            );
    end component;

    component SPI_Port
        port (
            nRST    : in  std_logic;
            clk     : in  std_logic;
            enable  : in  std_logic;
            nwe     : in  std_logic;
            address : in  std_logic_vector (2 downto 0);
            datain  : in  std_logic_vector (7 downto 0);
            dataout : out std_logic_vector (7 downto 0);
            MISO    : in  std_logic;
            MOSI    : out std_logic;
            NSS     : out std_logic;
            SPICLK  : out std_logic
            );
    end component;

-------------------------------------------------
-- divide external 32 MHz sid clock by 32
-------------------------------------------------
    signal clk_1M00            : std_logic;
    signal div32             : std_logic_vector (4 downto 0);
-------------------------------------------------
-- cpu signals names
-------------------------------------------------
    signal cpu_R_W_n         : std_logic;
    signal cpu_addr          : std_logic_vector (15 downto 0);
    signal cpu_din           : std_logic_vector (7 downto 0);
    signal cpu_dout          : std_logic_vector (7 downto 0);
    signal cpu_IRQ_n         : std_logic;
--cpu clock and enales
    signal clken_counter     : std_logic_vector (3 downto 0);
    signal cpu_cycle         : std_logic;
    signal cpu_clken         : std_logic;
    signal not_cpu_R_W_n     : std_logic;
---------------------------------------------------
-- VDG signals names
---------------------------------------------------
    signal RSTn              : std_logic;
    signal vdg_da0           : std_logic;
    signal vdg_dd            : std_logic_vector(7 downto 0);
    signal vdg_hs_n          : std_logic;
    signal vdg_fs_n          : std_logic;
    signal vdg_an_g          : std_logic;
    signal vdg_an_s          : std_logic;
    signal vdg_intn_ext      : std_logic;
    signal vdg_gm            : std_logic_vector(2 downto 0);
    signal vdg_css           : std_logic;
    signal vdg_inv           : std_logic;
    -- VGA output
    signal vdg_red           : std_logic_vector(7 downto 0);
    signal vdg_green         : std_logic_vector(7 downto 0);
    signal vdg_blue          : std_logic_vector(7 downto 0);
    signal vdg_hsync         : std_logic;
    signal vdg_vsync         : std_logic;
    signal vdg_hblank        : std_logic;
    signal vdg_vblank        : std_logic;
    -- CVBS output
    signal video_address     : std_logic_vector(12 downto 0);
    signal video_address_t   : std_logic_vector(12 downto 0);
----------------------------------------------------
-- enables
----------------------------------------------------
    signal mc6847_enable     : std_logic;
    signal mc6522_enable     : std_logic;
    signal i8255_enable      : std_logic;
    signal extern_rom_enable : std_logic;
    signal extern_ram_enable : std_logic;
    signal video_ram_enable  : std_logic;
----------------------------------------------------
-- ram/roms
----------------------------------------------------
    signal extern_data       : std_logic_vector(7 downto 0);
    signal video_ram_data    : std_logic_vector(7 downto 0);
----------------------------------------------------
--
----------------------------------------------------
    signal via_clk           : std_logic;
    signal via4_clken        : std_logic;
    signal via1_clken        : std_logic;
    signal cpu_phase         : std_logic_vector(1 downto 0);
    signal mc6522_data       : std_logic_vector(7 downto 0);
    signal mc6522_irq        : std_logic;
    signal mc6522_ca1        : std_logic;
    signal mc6522_ca2        : std_logic;
    signal mc6522_cb1        : std_logic;
    signal mc6522_cb2        : std_logic;
    signal mc6522_porta      : std_logic_vector(7 downto 0);
    signal mc6522_portb      : std_logic_vector(7 downto 0);

    signal i8255_pa_data  : std_logic_vector(7 downto 0);
    signal i8255_pb_data  : std_logic_vector(7 downto 0);
    signal i8255_pb_idata : std_logic_vector(7 downto 0);
    signal i8255_pc_data  : std_logic_vector(7 downto 0);
    signal i8255_pc_idata : std_logic_vector(7 downto 0);
    signal i8255_data     : std_logic_vector(7 downto 0);
    signal i8255_rd       : std_logic;

    signal inpurps2dat : std_logic;
    signal inpurps2clk : std_logic;
    signal ps2dataout  : std_logic_vector(5 downto 0);
    signal key_shift   : std_logic;
    signal key_ctrl    : std_logic;
    signal key_repeat  : std_logic;
    signal key_break   : std_logic;
    signal key_turbo   : std_logic;

    signal dcm12M58 : std_logic;
    
    signal sid_enable : std_logic;
    signal sid_data   : std_logic_vector (7 downto 0);
    signal sid_audio  : std_logic;

    signal spi_enable : std_logic;
    signal spi_data   : std_logic_vector (7 downto 0);
 
--------------------------------------------------------------------
--                   here it begin :)
--------------------------------------------------------------------
begin

---------------------------------------------------------------------
--
---------------------------------------------------------------------
    cpu : T65 port map (
   		Mode           => "00",
		Abort_n        => '1',
		SO_n           => '1',
        Res_n          => RSTn,
        Enable         => cpu_clken,
        Clk            => clk_16M00,
        Rdy            => '1',
        IRQ_n          => cpu_IRQ_n,
        NMI_n          => '1',
        R_W_n          => cpu_R_W_n,
        Sync           => open,
        A(23 downto 16) => open,
        A(15 downto 0) => cpu_addr(15 downto 0),
        DI(7 downto 0) => cpu_din(7 downto 0),
        DO(7 downto 0) => cpu_dout(7 downto 0));
---------------------------------------------------------------------
--
---------------------------------------------------------------------                           
    VDG : mc6847 port map (
        clk            => clk_12M58,
        clk_ena        => '1',
        reset          => '0',
        da0            => vdg_da0,
        videoaddr      => video_address,
        dd             => vdg_dd,
        hs_n           => vdg_hs_n,
        fs_n           => vdg_fs_n,
        an_g           => vdg_an_g,
        an_s           => vdg_an_s,
        intn_ext       => vdg_intn_ext,
        gm             => vdg_gm,
        css            => vdg_css,
        inv            => vdg_inv,
        red            => vdg_red,
        green          => vdg_green,
        blue           => vdg_blue,
        hsync          => vdg_hsync,
        vsync          => vdg_vsync,
        hblank         => vdg_hblank,
        vblank         => vdg_vblank,
        artifact_en    => '0',
        artifact_set   => '0',
        artifact_phase => '0',
        cvbs           => open);                        
        
---------------------------------------------------------------------
--
---------------------------------------------------------------------

    ram8000 : SRAM0x8000 port map(
        clk      => clk_16M00,
        rd_vid   => '1',
        addr_vid => video_address(12 downto 0),
        Q_vid    => vdg_dd,
        we_uP    => not_cpu_R_W_n,
        ce       => video_ram_enable,
        addr_uP  => cpu_addr(12 downto 0),
        D_uP     => cpu_dout(7 downto 0),
        Q_uP     => video_ram_data);
---------------------------------------------------------------------
--
---------------------------------------------------------------------                   
    pia : I82C55 port map(
        I_ADDR => cpu_addr(1 downto 0),  -- A1-A0
        I_DATA => cpu_dout(7 downto 0),  -- D7-D0
        O_DATA => i8255_data,
        CS_H   => i8255_enable,
        WR_L   => cpu_R_W_n,
        O_PA   => i8255_pa_data,
        I_PB   => i8255_pb_idata,
        I_PC   => i8255_pc_idata(7 downto 4),
        O_PC   => i8255_pc_data(3 downto 0),
        RESET  => RSTn,
        ENA    => cpu_clken,
        CLK    => clk_16M00);
---------------------------------------------------------------------
--
---------------------------------------------------------------------                           
    input : keyboard port map(
        CLOCK      => clk_16M00,
        nRESET     => ERSTn,
        CLKEN_1MHZ => cpu_clken,
        PS2_CLK    => inpurps2clk,
        PS2_DATA   => inpurps2dat,
        KEYOUT     => ps2dataout,
        ROW        => i8255_pa_data(3 downto 0),
        SHIFT_OUT  => key_shift,
        CTRL_OUT   => key_ctrl,
        REPEAT_OUT => key_repeat,
        BREAK_OUT  => key_break,
        TURBO      => key_turbo);
      
---------------------------------------------------------------------
--  
---------------------------------------------------------------------
    via : M6522 port map(
        I_RS    => cpu_addr(3 downto 0),
        I_DATA  => cpu_dout(7 downto 0),
        O_DATA  => mc6522_data(7 downto 0),
        I_RW_L  => cpu_R_W_n,
        I_CS1   => mc6522_enable,
        I_CS2_L => '0',
        O_IRQ_L => mc6522_irq,
        I_CA1   => mc6522_ca1,
        I_CA2   => mc6522_ca2,
        O_CA2   => mc6522_ca2,
        I_PA    => mc6522_porta(7 downto 0),
        O_PA    => mc6522_porta(7 downto 0),
        I_CB1   => mc6522_cb1,
        O_CB1   => mc6522_cb1,
        I_CB2   => mc6522_cb2,
        O_CB2   => mc6522_cb2,
        I_PB    => mc6522_portb(7 downto 0),
        O_PB    => mc6522_portb(7 downto 0),
        RESET_L => RSTn,
        I_P2_H  => cpu_phase,
        ENA_4   => via4_clken,
        CLK     => via_clk);                                      
---------------------------------------------------------------------
--
---------------------------------------------------------------------
    -- Pipelined version of address/data/write signals
    process (clk_32M00)
    begin
        if rising_edge(clk_32M00) then
            div32 <= div32 + 1;
        end if;
    end process;

    -- clk_1M00 is derived by dividing clk_32M00 down by 32
    clk_1M00 <= div32(4);

    Inst_sid6581: if CImplSID generate
        Inst_sid6581_comp : component sid6581
            port map (
                clk_1MHz => clk_1M00,
                clk32 => clk_32M00,
                clk_DAC => clk_32M00,
                reset => not RSTn,
                cs => sid_enable,
                we => not_cpu_R_W_n,
                addr => cpu_addr(4 downto 0),
                di => cpu_dout(7 downto 0),
                do => sid_data,
                pot_x => '0',
                pot_y => '0',
                audio_out => sid_audio,
                audio_data => open 
            );
     end generate;

    Inst_spi: if (CImplSDDOS) generate
        Inst_spi_comp : component SPI_Port
            port map (
                nRST    => RSTn,
                clk     => clk_16M00,
                enable  => spi_enable,
                nwe     => cpu_R_W_n,
                address => cpu_addr(2 downto 0),
                datain  => cpu_dout(7 downto 0),
                dataout => spi_data,
                MISO    => SDMISO,
                MOSI    => SDMOSI,
                NSS     => SDSS,
                SPICLK  => SDCLK
            );
    end generate;

---------------------------------------------------------------------
--
---------------------------------------------------------------------

    RSTn          <= ERSTn and key_break;
    IRSTn         <= RSTn;

    mc6522_ca1    <= '1';
    inpurps2clk   <= ps2_clk;
    inpurps2dat   <= ps2_data;
    not_cpu_R_W_n <= not cpu_R_W_n;
    cpu_IRQ_n     <= mc6522_irq;
    --cpu_IRQ_n <= '1';
    vdg_gm        <= i8255_pa_data(7 downto 5) when RSTn='1' else "000";
    vdg_an_g      <= i8255_pa_data(4)  when RSTn='1' else '0';
    vdg_an_s      <= vdg_dd(6);
    vdg_intn_ext  <= vdg_dd(6);
    vdg_inv       <= vdg_dd(7);
    vdg_css       <= i8255_pc_data(3) when RSTn='1' else '0';
    audiol        <= sid_audio;
    audioR        <= i8255_pc_data(2);

    i8255_pc_idata <= vdg_fs_n & key_repeat & "11" & i8255_pc_data (3 downto 0);
    i8255_pb_idata <= key_shift & key_ctrl & ps2dataout;
    

    red(2 downto 0)   <= vdg_red(7) & vdg_red(7) & vdg_red(7);  -- downto 5);
    green(2 downto 0) <= vdg_green(7) & vdg_green(7) & vdg_green(7);  -- downto 5);
    blue(2 downto 0)  <= vdg_blue(7) & vdg_blue(7) & vdg_blue(7);  -- downto 5);
    vsync             <= vdg_vsync;
    hsync             <= vdg_hsync;

-- enables
    process(cpu_addr)
    begin
        -- All regions normally de-selected
        mc6847_enable     <= '0';
        mc6522_enable     <= '0';
        i8255_enable      <= '0';
        extern_ram_enable <= '0';
        extern_rom_enable <= '0';
        video_ram_enable  <= '0';
        sid_enable        <= '0'; 
        spi_enable        <= '0'; 

        case cpu_addr(15 downto 12) is
            when x"0" => extern_ram_enable <= '1';  -- 0x0000 -- 0x03ff is RAM
            when x"1" => extern_ram_enable <= '1';
            when x"2" => extern_ram_enable <= '1';
            when x"3" => extern_ram_enable <= '1';
            when x"4" => extern_ram_enable <= '1';
            when x"5" => extern_ram_enable <= '1';
            when x"6" => extern_ram_enable <= '1';
            when x"7" => extern_ram_enable <= '1';
            when x"8" => video_ram_enable  <= '1';  -- 0x8000 -- 0x9fff is RAM
            when x"9" => video_ram_enable  <= '1';
            when x"A" => extern_rom_enable <= '1';
            when x"B" =>
                if cpu_addr(11 downto 8) = "0000" then     -- 0xb000 8255 PIA  
                    i8255_enable <= '1';
                elsif cpu_addr(11 downto 8) = "1000" then  -- 0xb800 6522 VIA (optional)
                    mc6522_enable <= '1';
                elsif cpu_addr(11 downto 8) = "0100" then
                    spi_enable <= '1';  -- 0xb400 SPI
                elsif cpu_addr(11 downto 5) = "1101110" then
                    sid_enable <= '1';  -- 0xbdc0-0xbddf SID
                end if;
                
            when x"C"   => extern_rom_enable <= '1';
            when x"D"   => extern_rom_enable <= '1';
            when x"E"   => extern_rom_enable <= '1';
            when x"F"   => extern_rom_enable <= '1';
            when others => null;
        end case;

    end process;

    cpu_din <=
        extern_data     when extern_ram_enable = '1' else
        video_ram_data  when video_ram_enable = '1'  else
        i8255_data      when i8255_enable = '1'      else
        mc6522_data     when mc6522_enable = '1'     else
        sid_data        when sid_enable = '1'        else
        spi_data        when spi_enable = '1' and CImplSDDOS else
        extern_data     when spi_enable = '1' and not CImplSDDOS else
        extern_data     when extern_rom_enable = '1' else
        x"f1";          -- un-decoded locations
        
    ExternWE        <= not_cpu_R_W_n;
    RamCE           <= extern_ram_enable;			
    RomCE           <= extern_rom_enable;			
    ExternA         <= '0' & cpu_addr(15 downto 0);
    ExternDin       <= cpu_dout(7 downto 0);
    extern_data     <= ExternDout;
    
--------------------------------------------------------
-- clock enable generator
--------------------------------------------------------
    clk_gen : process(clk_16M00, RSTn)
    begin
        if RSTn = '0' then
            clken_counter <= (others => '0');
        elsif rising_edge(clk_16M00) then
            clken_counter <= clken_counter + 1;
        end if;
    end process;

    process(key_turbo)
    begin
        if key_turbo = '0'then
            cpu_clken <= not (clken_counter(0) or clken_counter(1) or clken_counter(2) or clken_counter(3));  -- on cycle 0
        else
            cpu_clken <= not (clken_counter(0));  -- or clken_counter(1) or clken_counter(2) or clken_counter(3)); -- on cycle 0
        end if;
    end process;

    cpu_phase  <= clken_counter(3) & clken_counter(2);
    via4_clken <= not (clken_counter(0) or clken_counter(1));
    via_clk    <= clk_16M00;
 
end BEHAVIORAL;


