library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SumGen is
	generic ( N: integer := 32); -- 4n bits
	port (	A	: in	std_logic_vector(N-1 downto 0);
			B	: in	std_logic_vector(N-1 downto 0);
			C	: in	std_logic_vector(N/4 downto 0);
			S	: out	std_logic_vector(N-1 downto 0);
			Cout: out	std_logic);
end SumGen;

architecture Structural of SumGen is

	component CSAdd 
		generic ( N: integer := 4);
		port ( 	A, B 	: In	std_logic_vector(N-1 downto 0);	
				Ci		: In	std_logic; 
				S		: Out	std_logic_vector(N-1 downto 0));
	end component;
	
begin

	blocks: for i in 0 to N/4-1 generate
		CSAs: CSAdd port map (A(4*(i+1)-1 downto 4*i), B(4*(i+1)-1 downto 4*i), C(i), S(4*(i+1)-1 downto 4*i));
	end generate;
	Cout <= C(N/4);

end Structural;