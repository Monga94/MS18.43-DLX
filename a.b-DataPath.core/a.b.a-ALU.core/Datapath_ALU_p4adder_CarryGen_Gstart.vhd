library ieee; 
use ieee.std_logic_1164.all;

entity Gstart is
	port (	a	:	In	std_logic;
			b	:	In	std_logic;
			Cin	:	In	std_logic;
			Gout:	Out	std_logic);
end Gstart;

architecture BEHAVIORAL of Gstart is

begin

	Gout <= (a and b) or ((a xor b) and Cin);

end BEHAVIORAL;