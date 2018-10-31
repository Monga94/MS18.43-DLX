library ieee; 
use ieee.std_logic_1164.all;

entity genP is
	port (	G1:		In	std_logic;
			P1:		In	std_logic;
			G0:		In	std_logic;
			P0:		In	std_logic;
			Pout:	Out	std_logic;
			Gout:	Out	std_logic);
end genP; 

architecture BEHAVIORAL of genP is

begin

	Pout <= P1 and P0;
	Gout <= G1 or (P1 and G0);

end BEHAVIORAL;