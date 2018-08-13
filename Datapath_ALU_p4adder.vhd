library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity p4adder is
	generic ( N: integer := 32); -- 4n bits
	port (	A	: in	std_logic_vector(N-1 downto 0);
			B	: in	std_logic_vector(N-1 downto 0);
			Cin	: in	std_logic;
			S	: out	std_logic_vector(N-1 downto 0);
			Cout: out	std_logic);
end p4adder;

architecture Structural of p4adder is
	signal C : std_logic_vector(N/4 downto 0);

	component CarryGen
		generic (	N: integer := 32);
		port (	A	: in	std_logic_vector(N downto 1);
				B	: in	std_logic_vector(N downto 1);
				Cin	: in	std_logic;
				C	: out	std_logic_vector(N/4 downto 0));
	end component;
	
	component SumGen
		generic ( N: integer := 32); -- 4n bits
		port (	A	: in	std_logic_vector(N-1 downto 0);
				B	: in	std_logic_vector(N-1 downto 0);
				C	: in	std_logic_vector(N/4 downto 0);
				S	: out	std_logic_vector(N-1 downto 0);
				Cout: out	std_logic);
	end component;
	
begin
	Cgen: CarryGen
				generic map (N)
				port map (A, B, Cin, C);
	Sgen: SumGen
				generic map (N)
				port map (A, B, C, S, Cout);
end Structural;