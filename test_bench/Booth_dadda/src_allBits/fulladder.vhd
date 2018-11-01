library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fulladder is
	port (	a, b	: in	std_logic;
			cin		: in	std_logic;
			S		: out	std_logic;
			cout	: out	std_logic);
end fulladder;

architecture behavioral of fulladder is
begin

	S <= a XOR b XOR cin;
	cout <= (a AND b) OR (cin AND a) OR (cin AND b);
	
end behavioral;