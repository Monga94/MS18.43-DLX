library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SUM_node is
	generic (	N: integer := 8;
				O: integer := 0);
	port (	A	: in	std_logic_vector(N-1 downto 0);
			B	: in	std_logic_vector(N-1 downto 0);
			S	: out	std_logic_vector(N-1 downto 0));	
end SUM_node;

architecture behavioral of SUM_node is
begin
	process(A, B)
	begin
		if O = 0 then
			S <= std_logic_vector(signed(A) + signed(B));
		else
			S <= std_logic_vector(signed(A) - signed(B));
		end if;
	end process;

end behavioral;
