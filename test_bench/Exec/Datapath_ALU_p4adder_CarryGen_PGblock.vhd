library ieee; 
use ieee.std_logic_1164.all;

entity PGblock is
	port (	a:	In	std_logic;
			b:	In	std_logic;
			p:	Out	std_logic;
			g:	Out	std_logic);
end PGblock;

architecture BEHAVIORAL of PGblock is

begin

  p <= a xor b;
  g <= a and b;
  
end BEHAVIORAL;