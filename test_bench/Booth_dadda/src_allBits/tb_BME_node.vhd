library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_BME_node is
end tb_BME_node;

architecture testing of tb_BME_node is
	signal A	: std_logic_vector(14 downto 0);
	signal B	: std_logic_vector(12 downto 0);
	signal M	: std_logic_vector(27 downto 0);
	
	component BME_node
		port (	A	: in	std_logic_vector(14 downto 0);
				B	: in	std_logic_vector(12 downto 0);
				M	: out	std_logic_vector(27 downto 0));--(14 downto 0));	
	end component;
	
begin

	A <= "000000000000001", "111111111111111" after 50 ns, "000111000011000" after 100 ns, "000000000000011" after 150 ns;
	B <= "0000000100000", "0000000000100" after 50 ns, "0000000000000" after 100 ns, "0000000001000" after 150 ns;
	
	UUT: BME_node port map (A, B, M);
	
end testing;
