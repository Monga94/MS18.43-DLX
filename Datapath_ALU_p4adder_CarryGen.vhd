library ieee;
use ieee.std_logic_1164.all;
use work.logarithm.all;

entity CarryGen is
	generic (	N: integer := 32);
	port (	A	: in	std_logic_vector(N downto 1);
			B	: in	std_logic_vector(N downto 1);
			Cin	: in	std_logic;
			C	: out	std_logic_vector(N/4 downto 0));
end CarryGen;

architecture Structural of CarryGen is
	constant LogN : natural := log2_N(N); --
	
	type SignalVector is array (0 to LogN) of std_logic_vector(N downto 1);
	
	signal GMat : SignalVector;
	signal PMat : SignalVector;
	
	component Gstart
		port (	a	:	In	std_logic;
				b	:	In	std_logic;
				Cin	:	In	std_logic;
				Gout:	Out	std_logic);
	end component;
	
	component PGblock
		port (	a:	In	std_logic;
				b:	In	std_logic;
				p:	Out	std_logic;
				g:	Out	std_logic);
	end component;
	
	component genG
		port (	G1:		In	std_logic;
				P1:		In	std_logic;
				G0:		In	std_logic;
				Gout:	Out	std_logic);
	end component;
	
	component genP
		port (	G1:		In	std_logic;
				P1:		In	std_logic;
				G0:		In	std_logic;
				P0:		In	std_logic;
				Gout:	Out	std_logic;
				Pout:	Out	std_logic);
	end component;

begin

	row: for i in 0 to LogN generate
		row0: if i = 0 generate
			PGrow: for k in 1 to N generate
				firstPG: if k = 1 generate
					PG0: Gstart port map (A(k), B(k), Cin, GMat(i)(k));
				end generate;
				othersPG: if k > 1 generate
					PGs: PGblock port map (A(k), B(k), PMat(i)(k), GMat(i)(k));
				end generate;
			end generate;
		end generate;
		row12: if i >= 1 and i <= 2 generate
			row21: for k in 1 to N/(2**i) generate
				firstG1: if k = 1 generate
					G1s: genG port map (GMat(i-1)(2**i), PMat(i-1)(2**i), GMat(i-1)(2**(i-1)), GMat(i)(2**i));
				end generate;
				othersP1: if k > 1 generate
					P1s: genP port map (GMat(i-1)(k*(2**i)), PMat(i-1)(k*(2**i)), GMat(i-1)(k*(2**i)-(2**(i-1))), PMat(i-1)(k*(2**i)-(2**(i-1))), GMat(i)(k*(2**i)), PMat(i)(k*(2**i)));
				end generate;
			end generate;
		end generate;
		row38: if i >= 3 generate
			row83: for k in 0 to N/4-1 generate
				blocks: if k rem 2**(i-2) >= 2**(i-3) generate
					firstG2: if k < 2**(i-2) generate
						G2s: genG port map (GMat(i-1)(4*(k+1)), PMat(i-1)(4*(k+1)), GMat(i-1)(2**(i-1)+(k/(2**(i-2)))*2**i), GMat(i)(4*(k+1)));
					end generate;
					othersP: if k >= 2**(i-2) generate
						P2s: genP port map (GMat(i-1)(4*(k+1)), PMat(i-1)(4*(k+1)), GMat(i-1)(2**(i-1)+(k/(2**(i-2)))*2**i), PMat(i-1)(2**(i-1)+(k/(2**(i-2)))*2**i), GMat(i)(4*(k+1)), PMat(i)(4*(k+1)));
					end generate;
				end generate;
				wires: if k rem 2**(i-2) < 2**(i-3) generate
					GMat(i)(4*(k+1)) <= GMat(i-1)(4*(k+1));
					PMat(i)(4*(k+1)) <= PMat(i-1)(4*(k+1));
				end generate;
			end generate;
		end generate;
	end generate;
	finalWires: for k in 1 to N/4 generate
		C(k) <= GMat(LogN)(4*k);
	end generate;
	C(0) <= Cin;

end Structural;