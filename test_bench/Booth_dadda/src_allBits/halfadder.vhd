library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity halfadder is
	port (	a, b	: in	std_logic;
			s, cout	: out	std_logic);
end halfadder;

architecture behavioral of halfadder is
begin

	s <= a xor b;
	cout <= a and b;
	
end behavioral;