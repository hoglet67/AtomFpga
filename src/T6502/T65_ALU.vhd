library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.T65_Pack.all;

entity T65_ALU is
	port(
		Op      : in std_logic_vector(3 downto 0);
		BusA    : in std_logic_vector(7 downto 0);
		BusB    : in std_logic_vector(7 downto 0);
		P_In    : in std_logic_vector(7 downto 0);
		P_Out   : out std_logic_vector(7 downto 0);
		Q       : out std_logic_vector(7 downto 0)
	);
end T65_ALU;

architecture rtl of T65_ALU is

	-- AddSub variables (temporary signals)
	signal      ADC_Z           : std_logic;
	signal      ADC_C           : std_logic;
	signal      ADC_V           : std_logic;
	signal      ADC_N           : std_logic;
	signal      ADC_Q           : std_logic_vector(7 downto 0);
	signal      SBC_Z           : std_logic;
	signal      SBC_C           : std_logic;
	signal      SBC_V           : std_logic;
	signal      SBC_N           : std_logic;
	signal      SBC_Q           : std_logic_vector(7 downto 0);

begin

	process (P_In, BusA, BusB)
		variable AL : unsigned(6 downto 0);
		variable AH : unsigned(6 downto 0);
		variable C : std_logic;
	begin
		AL := resize(unsigned(BusA(3 downto 0) & P_In(Flag_C)), 7) + resize(unsigned(BusB(3 downto 0) & "1"), 7);
		AH := resize(unsigned(BusA(7 downto 4) & AL(5)), 7) + resize(unsigned(BusB(7 downto 4) & "1"), 7);

-- pragma translate_off
			if is_x(std_logic_vector(AL)) then AL := "0000000"; end if;
			if is_x(std_logic_vector(AH)) then AH := "0000000"; end if;
-- pragma translate_on

		if AL(4 downto 1) = 0 and AH(4 downto 1) = 0 then
			ADC_Z <= '1';
		else
			ADC_Z <= '0';
		end if;

		if AL(5 downto 1) > 9 and P_In(Flag_D) = '1' then
			AL(6 downto 1) := AL(6 downto 1) + 6;
		end if;

		C := AL(6) or AL(5);
		AH := resize(unsigned(BusA(7 downto 4) & C), 7) + resize(unsigned(BusB(7 downto 4) & "1"), 7);

		ADC_N <= AH(4);
		ADC_V <= (AH(4) xor BusA(7)) and not (BusA(7) xor BusB(7));

-- pragma translate_off
			if is_x(std_logic_vector(AH)) then AH := "0000000"; end if;
-- pragma translate_on

		if AH(5 downto 1) > 9 and P_In(Flag_D) = '1' then
			AH(6 downto 1) := AH(6 downto 1) + 6;
		end if;

		ADC_C <= AH(6) or AH(5);

		ADC_Q <= std_logic_vector(AH(4 downto 1) & AL(4 downto 1));
	end process;

	process (Op, P_In, BusA, BusB)
		variable AL : unsigned(6 downto 0);
		variable AH : unsigned(5 downto 0);
		variable C : std_logic;
	begin
		C := P_In(Flag_C) or not Op(0);
		AL := resize(unsigned(BusA(3 downto 0) & C), 7) - resize(unsigned(BusB(3 downto 0) & "1"), 6);
		AH := resize(unsigned(BusA(7 downto 4) & "0"), 6) - resize(unsigned(BusB(7 downto 4) & AL(5)), 6);

-- pragma translate_off
			if is_x(std_logic_vector(AL)) then AL := "0000000"; end if;
			if is_x(std_logic_vector(AH)) then AH := "000000"; end if;
-- pragma translate_on

		if AL(4 downto 1) = 0 and AH(4 downto 1) = 0 then
			SBC_Z <= '1';
		else
			SBC_Z <= '0';
		end if;

		SBC_C <= not AH(5);
		SBC_V <= (AH(4) xor BusA(7)) and (BusA(7) xor BusB(7));
		SBC_N <= AH(4);

		if P_In(Flag_D) = '1' then
			if AL(5) = '1' then
				AL(5 downto 1) := AL(5 downto 1) - 6;
			end if;
			AH := resize(unsigned(BusA(7 downto 4) & "0"), 6) - resize(unsigned(BusB(7 downto 4) & AL(6)), 6);
			if AH(5) = '1' then
				AH(5 downto 1) := AH(5 downto 1) - 6;
			end if;
		end if;

		SBC_Q <= std_logic_vector(AH(4 downto 1) & AL(4 downto 1));
	end process;

	process (Op, P_In, BusA, BusB,
			ADC_Z, ADC_C, ADC_V, ADC_N, ADC_Q,
			SBC_Z, SBC_C, SBC_V, SBC_N, SBC_Q)
		variable Q_t : std_logic_vector(7 downto 0);
	begin
		-- ORA, AND, EOR, ADC, NOP, LD, CMP, SBC
		-- ASL, ROL, LSR, ROR, BIT, LD, DEC, INC
		P_Out <= P_In;
		Q_t := BusA;
		case Op(3 downto 0) is
		when "0000" =>
			-- ORA
			Q_t := BusA or BusB;
		when "0001" =>
			-- AND
			Q_t := BusA and BusB;
		when "0010" =>
			-- EOR
			Q_t := BusA xor BusB;
		when "0011" =>
			-- ADC
			P_Out(Flag_V) <= ADC_V;
			P_Out(Flag_C) <= ADC_C;
			Q_t := ADC_Q;
		when "0101" | "1101" =>
			-- LDA
		when "0110" =>
			-- CMP
			P_Out(Flag_C) <= SBC_C;
		when "0111" =>
			-- SBC
			P_Out(Flag_V) <= SBC_V;
			P_Out(Flag_C) <= SBC_C;
			Q_t := SBC_Q;
		when "1000" =>
			-- ASL
			Q_t := BusA(6 downto 0) & "0";
			P_Out(Flag_C) <= BusA(7);
		when "1001" =>
			-- ROL
			Q_t := BusA(6 downto 0) & P_In(Flag_C);
			P_Out(Flag_C) <= BusA(7);
		when "1010" =>
			-- LSR
			Q_t := "0" & BusA(7 downto 1);
			P_Out(Flag_C) <= BusA(0);
		when "1011" =>
			-- ROR
			Q_t := P_In(Flag_C) & BusA(7 downto 1);
			P_Out(Flag_C) <= BusA(0);
		when "1100" =>
			-- BIT
			P_Out(Flag_V) <= BusB(6);
		when "1110" =>
			-- DEC
			Q_t := std_logic_vector(unsigned(BusA) - 1);
		when "1111" =>
			-- INC
			Q_t := std_logic_vector(unsigned(BusA) + 1);
		when others =>
		end case;

		case Op(3 downto 0) is
		when "0011" =>
			P_Out(Flag_N) <= ADC_N;
			P_Out(Flag_Z) <= ADC_Z;
		when "0110" | "0111" =>
			P_Out(Flag_N) <= SBC_N;
			P_Out(Flag_Z) <= SBC_Z;
		when "0100" =>
		when "1100" =>
			P_Out(Flag_N) <= BusB(7);
			if (BusA and BusB) = "00000000" then
				P_Out(Flag_Z) <= '1';
			else
				P_Out(Flag_Z) <= '0';
			end if;
		when others =>
			P_Out(Flag_N) <= Q_t(7);
			if Q_t = "00000000" then
				P_Out(Flag_Z) <= '1';
			else
				P_Out(Flag_Z) <= '0';
			end if;
		end case;

		Q <= Q_t;
	end process;

end;
