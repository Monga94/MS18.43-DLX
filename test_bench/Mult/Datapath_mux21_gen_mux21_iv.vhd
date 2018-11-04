library IEEE;
use IEEE.std_logic_1164.all;	--  libreria IEEE con definizione tipi standard logic
use work.myStuff.all; 					-- libreria WORK user-defined

entity IV is
	Port (	A:	In	std_logic;
			Y:	Out	std_logic);
end IV;

architecture BEHAVIORAL of IV is

begin
	Y <= not(A);

end BEHAVIORAL;
