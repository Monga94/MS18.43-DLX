library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic


entity mux81_logic is
	port (		A:	In	std_logic;
				B:	In	std_logic;
				C:	In	std_logic;
				D:	In	std_logic;
				E:	In	std_logic;
				F:	In	std_logic;
				G:	In	std_logic;
				H:	In	std_logic;
				S:	In	std_logic_vector(2 downto 0);
				Y:	Out	std_logic);
end mux81_logic;


architecture Structural of mux81_logic is
	signal ABto2, CDto2, EFto2, GHto2	: std_logic;
	signal ABCDto3, EFGHto3				: std_logic;
	
	component MUX21
		Port (	A:	In	std_logic;
				B:	In	std_logic;
				S:	In	std_logic;
				Y:	Out	std_logic);
	end component;

begin
	M11: MUX21
		port map (A,B,S(0),ABto2);
	M12: MUX21
		port map (C,D,S(0),CDto2);
	M13: MUX21
		port map (E,F,S(0),EFto2);
	M14: MUX21
		port map (G,H,S(0),GHto2);
	M21: MUX21
		port map (ABto2,CDto2,S(1),ABCDto3);
	M22: MUX21
		port map (EFto2,GHto2,S(1),EFGHto3);
	M31: MUX21
		port map (ABCDto3,EFGHto3,S(2),Y);

end Structural;




