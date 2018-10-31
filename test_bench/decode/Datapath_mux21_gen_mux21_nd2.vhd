library IEEE;
use IEEE.std_logic_1164.all;	-- libreria IEEE con definizione tipi standard logic
use WORK.all;					-- libreria WORK user-defined

entity ND2 is
	port (	A:	In	std_logic;
			B:	In	std_logic;
			Y:	Out	std_logic);
end ND2;


architecture Behavioral of ND2 is

begin
	Y <= not(A and B);

end Behavioral;
