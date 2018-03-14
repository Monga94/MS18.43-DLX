library ieee; 
use ieee.std_logic_1164.all;

entity genG is
	port (	G1:		In	std_logic;
			P1:		In	std_logic;
			G0:		In	std_logic;
			Gout:	Out	std_logic);
end genG;

architecture BEHAVIORAL of genG is

begin

	Gout <= G1 or (P1 and G0);

end BEHAVIORAL;