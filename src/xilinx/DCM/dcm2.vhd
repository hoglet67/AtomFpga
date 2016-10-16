library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.Vcomponents.all;

entity dcm2 is
    port (CLKIN_IN       : in  std_logic;
          CLK0_OUT       : out std_logic;
          CLKFX_OUT      : out std_logic);
end dcm2;

architecture BEHAVIORAL of dcm2 is
    signal GND_BIT     : std_logic;
    signal CLKIN       : std_logic;
    signal CLKFX       : std_logic;
    signal CLKFX_BUF   : std_logic;
    signal CLK0        : std_logic;
    signal CLK0_BUF    : std_logic;
    signal CLKFB       : std_logic;
begin

    GND_BIT <= '0';
        
    -- CLK0 output buffer
    CLK0_BUFG_INST : BUFG
        port map (I => CLK0, O => CLK0_BUF);
    CLK0_OUT <= CLK0_BUF;
    
    -- CLKFX output buffer
    CLKFX_BUFG_INST : BUFG
        port map (I => CLKFX, O => CLKFX_BUF);
    CLKFX_OUT <= CLKFX_BUF;

    DCM_INST : DCM
        generic map(CLK_FEEDBACK          => "1X",
                    CLKDV_DIVIDE          => 4.0,  -- 16.000 = 25MHz * 16 / 25
                    CLKFX_DIVIDE          => 25,
                    CLKFX_MULTIPLY        => 16,
                    CLKIN_DIVIDE_BY_2     => false,
                    CLKIN_PERIOD          => 40.000,
                    CLKOUT_PHASE_SHIFT    => "NONE",
                    DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
                    DFS_FREQUENCY_MODE    => "LOW",
                    DLL_FREQUENCY_MODE    => "LOW",
                    DUTY_CYCLE_CORRECTION => true,
                    FACTORY_JF            => x"C080",
                    PHASE_SHIFT           => 0,
                    STARTUP_WAIT          => false)
        port map (CLKFB    => CLK0_BUF,
                  CLKIN    => CLKIN_IN,
                  DSSEN    => GND_BIT,
                  PSCLK    => GND_BIT,
                  PSEN     => GND_BIT,
                  PSINCDEC => GND_BIT,
                  RST      => GND_BIT,
                  CLKDV    => open,
                  CLKFX    => CLKFX,
                  CLKFX180 => open,
                  CLK0     => CLK0,
                  CLK2X    => open,
                  CLK2X180 => open,
                  CLK90    => open,
                  CLK180   => open,
                  CLK270   => open,
                  LOCKED   => open,
                  PSDONE   => open,
                  STATUS   => open);

end BEHAVIORAL;
