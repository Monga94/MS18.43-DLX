library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic


entity mux41_generic is
	generic (	N: integer:= 32);
	port (		A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				C:	In	std_logic_vector(N-1 downto 0);
				D:	In	std_logic_vector(N-1 downto 0);
				S:	In	std_logic_vector(1 downto 0);
				Y:	Out	std_logic_vector(N-1 downto 0));
end mux41_generic;


architecture Structural of mux41_generic is
	signal ABto2, CDto2 : std_logic_vector(N-1 downto 0);
	
	component MUX21_GENERIC
		generic (N: integer := 8);
		port (	A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				S:	In	std_logic;
				Y:	Out	std_logic_vector(N-1 downto 0));
	end component;

begin
	M11: MUX21_GENERIC
		generic map (N)
		port map (A,B,S(0),ABto2);
	M12: MUX21_GENERIC
		generic map (N)
		port map (C,D,S(0),CDto2);
	M21: MUX21_GENERIC
		generic map (N)
		port map (ABto2,CDto2,S(1),Y);

end Structural;




