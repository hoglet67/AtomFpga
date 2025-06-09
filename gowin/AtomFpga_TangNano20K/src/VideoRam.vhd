library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity VideoRam is

    port (
        clka  : in  std_logic;
        wea   : in  std_logic;
        addra : in  std_logic_vector(12 downto 0);
        dina  : in  std_logic_vector(7 downto 0);
        douta : out std_logic_vector(7 downto 0);
        clkb  : in  std_logic;
        web   : in  std_logic;
        addrb : in  std_logic_vector(12 downto 0);
        dinb  : in  std_logic_vector(7 downto 0);
        doutb : out std_logic_vector(7 downto 0)
        );
end VideoRam;

architecture BEHAVIORAL of VideoRam is

begin

    -- The A and B ports are transposed

    -- Ref: this email I sent to Dominic on 22/5/23:

    -- On the Asteroids issue, I've just pushed a possible fix, but I
    -- have absolutely no idea why it works. The fix was to change the
    -- dual port RAM Write Mode from "Normal" Mode to "Read Before
    -- Write" Mode. I'm actually really surprised this has an effect
    -- on the data that's written. I also found just swapping ports A
    -- and B on the DPRAM also fixed it, which is even weirder.

    -- All the documentation says is: WRITE_MODE It can be used to set
    -- the write mode parameters for B-SRAM Port A/B. The bit width is
    -- 2. If the value is 2'b00, it denotes Normal Mode; if the value
    -- is 2'b01, it denotes Write-through Mode; if the value is 2'b10,
    -- it denotes Read before Write Mode. The default value is
    -- WRITE_MODE0 = 2'b00.

    -- I feel it's likely there Dual Port RAM has some serious
    -- issues. Search for "Unexpected" in the above document and
    -- you'll see what I mean. It's actually really difficult to
    -- understand what the issue is though.

    -- Gowin EDA 1.9.9 doesn't support Read-before-Write mode, so to work
    -- around the asteriod issue we now transpose ports A and B.

    -- It may just be luck that this works!

 ram: entity work.dpram_8k
    port map (
        clkb => clka,
        ceb => '1',
        oceb => '1',
        resetb => '0',
        wreb => wea,
        adb => addra,
        dinb => dina,
        doutb => douta,
        clka => clkb,
        cea => '1',
        ocea => '1',
        reseta => '0',
        wrea => web,
        ada => addrb,
        dina => dinb,
        douta => doutb
        );
 end BEHAVIORAL;
