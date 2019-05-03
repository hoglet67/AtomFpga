--------------------------------------------------------------------------------
-- Copyright (c) 2019 David Banks and Roland Leurs
--
-- based on work by Alan Daly. Copyright(c) 2009. All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : AtomFpga_BeebAdapter.vhd
-- /___/   /\     Timestamp : 21/04/2019
-- \   \  /  \
--  \___\/\___\
--
--Design Name: AtomFpga_BeebAdapter
--Device: Spartan6

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity AtomFpga_BeebAdapter is
    port (
        -- System oscillator
        clk50        : in    std_logic;
        -- BBC 1MHZ Bus
        clke         : in    std_logic;
        rnw          : in    std_logic;
        rst_n        : in    std_logic;
        pgfc_n       : in    std_logic;
        pgfd_n       : in    std_logic;
        bus_addr     : in    std_logic_vector (7 downto 0);
        bus_data     : inout std_logic_vector (7 downto 0);
        bus_data_dir : out   std_logic;
        bus_data_oel : out   std_logic;
        nmi          : out   std_logic;
        irq          : out   std_logic;
        -- SPI DAC
        dac_cs_n     : out   std_logic;
        dac_sck      : out   std_logic;
        dac_sdi      : out   std_logic;
        dac_ldac_n   : out   std_logic;
        -- RAM
        ram_addr     : out   std_logic_vector(18 downto 0);
        ram_data     : inout std_logic_vector(7 downto 0);
        ram_cel      : out   std_logic;
        ram_oel      : out   std_logic;
        ram_wel      : out   std_logic;
        -- Misc
        pmod0        : out   std_logic_vector(7 downto 0);
        pmod1        : out   std_logic_vector(7 downto 0);
        pmod2        : in    std_logic_vector(3 downto 0);
        sw1          : in    std_logic;
        sw2          : in    std_logic;
        led          : out   std_logic
        );

end AtomFpga_BeebAdapter;

architecture behavioral of AtomFpga_BeebAdapter is

    signal vga_red1    : std_logic;
    signal vga_red2    : std_logic;
    signal vga_green1  : std_logic;
    signal vga_green2  : std_logic;
    signal vga_blue1   : std_logic;
    signal vga_blue2   : std_logic;
    signal vga_vsync   : std_logic;
    signal vga_hsync   : std_logic;

    signal ext_addr    : std_logic_vector(18 downto 0);
    signal ext_data    : std_logic_vector(7 downto 0);
    signal cs_ram_n    : std_logic;
    signal cs_rom_n    : std_logic;
    signal cs_via_n    : std_logic;
    signal cs_bus_n    : std_logic;
    signal bus_nrds    : std_logic;
    signal bus_nwds    : std_logic;
    signal bus_phi2    : std_logic;
    signal bus_rnw     : std_logic;
    signal bus_sync    : std_logic;
    signal bus_rst_n   : std_logic;


    signal rom0_data   : std_logic_vector(7 downto 0);
    signal rom1_data   : std_logic_vector(7 downto 0);
    signal rom2_data   : std_logic_vector(7 downto 0);
    signal rom3_data   : std_logic_vector(7 downto 0);
    signal rom_data    : std_logic_vector(7 downto 0);

    signal pb          : std_logic_vector(7 downto 0);
    signal pc          : std_logic_vector(6 downto 6);

begin

    inst_rom0 : entity work.atombasic
        port map (
            CLK => bus_phi2,
            ADDR => ext_addr(11 downto 0),
            DATA => rom0_data
            );

    inst_rom1 : entity work.atomfloat
        port map (
            CLK => bus_phi2,
            ADDR => ext_addr(11 downto 0),
            DATA => rom1_data
            );

    inst_rom2 : entity work.e000
        port map (
            CLK => bus_phi2,
            ADDR => ext_addr(11 downto 0),
            DATA => rom2_data
            );

    inst_rom3 : entity work.atomkernal
        port map (
            CLK => bus_phi2,
            ADDR => ext_addr(11 downto 0),
            DATA => rom3_data
            );

    rom_data <= rom0_data when ext_addr(13 downto 12) = "00" else
                rom1_data when ext_addr(13 downto 12) = "01" else
                rom2_data when ext_addr(13 downto 12) = "10" else
                rom3_data when ext_addr(13 downto 12) = "11" else
                x"00";

    ram_addr <= ext_addr;
    ram_cel  <= cs_ram_n;
    ram_oel  <= bus_nrds;
    ram_wel  <= bus_nwds;

    ram_data <= ext_data when bus_rnw = '0' and cs_ram_n = '0' else
                (others => 'Z');

    ext_data <= ram_data when bus_rnw = '1' and cs_ram_n = '0' else
                rom_data when bus_rnw = '1' and cs_rom_n = '0' else
					 x"B0"    when bus_rnw = '1' and cs_via_n = '0' else
                 (others => 'Z');

	 bus_rst_n <= not SW1;

    inst_AtomFpga_Atom2K18 : entity work.AtomFpga_Atom2K18
        port map(


        -- Clock
        clk_50         => clk50,

        -- External Bus
        bus_a          => ext_addr,
        bus_d          => ext_data,
        bus_blk_b      => open,
        bus_phi2       => bus_phi2,
        bus_rnw        => bus_rnw,
        bus_nrds       => bus_nrds,
        bus_nwds       => bus_nwds,
        bus_sync       => bus_sync,
        bus_nmi_n      => '1',
        bus_irq_n      => '1',
        bus_rst_n      => bus_rst_n,
        bus_rdy        => '1',
        bus_so         => '1',

        -- External device chip selects
        cs_ram_n       => cs_ram_n,
        cs_rom_n       => cs_rom_n,
        cs_via_n       => cs_via_n,
        cs_tube_n      => open,
        cs_buf_n       => cs_bus_n,
        buf_dir        => open,

        -- Video
        vga_red1       => vga_red1,
        vga_red2       => vga_red2,
        vga_green1     => vga_green1,
        vga_green2     => vga_green2,
        vga_blue1      => vga_blue1,
        vga_blue2      => vga_blue2,
        vga_vsync      => vga_vsync,
        vga_hsync      => vga_hsync,

        -- Audio
        audio          => open,
        dac_cs_n       => dac_cs_n,
        dac_sdi        => dac_sdi,
        dac_ldac_n     => dac_ldac_n,
        dac_sck        => dac_sck,

        -- Keyboard
        kbd_pa         => open,
        kbd_pb         => pb,
        kbd_pc         => pc,

        -- Mouse
        ps2_mouse_clk  => open,
        ps2_mouse_data => open,

        -- Cassette
        cas_in         => '0',
        cas_out        => open,

        -- Serial
        serial_tx      => open,
        serial_rx      => '0',

        -- SD Card
        mmc_led_red    => open,
        mmc_led_green  => open,
        mmc_clk        => open,
        mmc_ss         => open,
        mmc_mosi       => open,
        mmc_miso       => '0'
        );

    -- pc(6) linked to ground enables the PS/2 keyboard
    pc(6) <= '0';

    -- pb7 = ps/2 data, pb6 = ps/2 clock
    pb <= pmod2(0) & pmod2(2) & "111111";

    pmod0        <= vga_blue1 & vga_blue2 & "00" & vga_red1 & vga_red2 & "00";
    pmod1        <= bus_rst_n & bus_sync & vga_vsync & vga_hsync & vga_green1 & vga_green2 & "00";
    -- pmod2        <= bus_phi2 & bus_nrds & bus_nwds & bus_rnw & cs_ram_n & cs_rom_n & cs_via_n & cs_bus_n;

	 led          <= not bus_rst_n;

    bus_data     <= (others => 'Z');
    bus_data_dir <= '1';
    bus_data_oel <= '1';
    nmi          <= '0';
    irq          <= '0';

end behavioral;
