library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic

entity MUX21_GENERIC is
	generic (N: integer := 8);
	port (	A:	In	std_logic_vector(N-1 downto 0) ;
			B:	In	std_logic_vector(N-1 downto 0);
			S:	In	std_logic;
			Y:	Out	std_logic_vector(N-1 downto 0));
end MUX21_GENERIC;



architecture STRUCTURAL of MUX21_GENERIC is

	component MUX21 is
		port (	A:	In	std_logic;
				B:	In	std_logic;
				S:	In	std_logic;
				Y:	Out	std_logic);
	end component;

begin

	G1: for i in 0 to (N-1) generate
		MUXes: MUX21 
				port map (A(i), B(i), S, Y(i));
	end generate;

end STRUCTURAL;
