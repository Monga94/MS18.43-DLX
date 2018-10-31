library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic


entity mux81_generic is
	generic (	N: integer:= 32);
	port (		A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				C:	In	std_logic_vector(N-1 downto 0);
				D:	In	std_logic_vector(N-1 downto 0);
				E:	In	std_logic_vector(N-1 downto 0);
				F:	In	std_logic_vector(N-1 downto 0);
				G:	In	std_logic_vector(N-1 downto 0);
				H:	In	std_logic_vector(N-1 downto 0);
				S:	In	std_logic_vector(2 downto 0);
				Y:	Out	std_logic_vector(N-1 downto 0));
end mux81_generic;


architecture Structural of mux81_generic is
	signal ABto2, CDto2, EFto2, GHto2	: std_logic_vector(N-1 downto 0);
	signal ABCDto3, EFGHto3				: std_logic_vector(N-1 downto 0);
	
	component MUX21_GENERIC
		generic (N: integer := 8);
		port (	A:	In	std_logic_vector(N-1 downto 0) ;
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
	M13: MUX21_GENERIC
		generic map (N)
		port map (E,F,S(0),EFto2);
	M14: MUX21_GENERIC
		generic map (N)
		port map (G,H,S(0),GHto2);
	M21: MUX21_GENERIC
		generic map (N)
		port map (ABto2,CDto2,S(1),ABCDto3);
	M22: MUX21_GENERIC
		generic map (N)
		port map (EFto2,GHto2,S(1),EFGHto3);
	M31: MUX21_GENERIC
		generic map (N)
		port map (ABCDto3,EFGHto3,S(2),Y);

end Structural;




