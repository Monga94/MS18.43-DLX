library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.BMEpar.all;

entity CA2 is
	port (	input	: IN	std_logic_vector(nbit_a-1 downto 0);
			output	: OUT	std_logic_vector(nbit_a-1 downto 0));
end CA2;

architecture arch of CA2 is
	signal nota: std_logic_vector(nbit_a-1 downto 0);
	signal one: signed(nbit_a-1 downto 0);
  
begin
	nota <= not(input);
	one <= "000000000000001";
	output <= std_logic_vector(signed(nota) + one);

end arch;
