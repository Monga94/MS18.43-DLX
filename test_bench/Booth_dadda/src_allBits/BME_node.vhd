library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.BMEpar.all;

entity BME_node is
	port (	A	: in	std_logic_vector(14 downto 0);
			B	: in	std_logic_vector(12 downto 0);
			M	: out	std_logic_vector(14 downto 0));	
end BME_node;

architecture structural of BME_node is
	signal partial 		: PP_array;
	signal sum1, sum2	: std_logic_vector(27 downto 0);
	signal result		: std_logic_vector(27 downto 0);

	component PP_COMPUTE
		port (  a		: IN	std_logic_vector(nbit_a-1 downto 0);
				b		: IN	std_logic_vector(nbit_b-1 downto 0);
				PP_port	: OUT	PP_array);
	end component;
	
	component dadda_tree_15_13
		port (	A, B, C, D, E, F, G	: in	std_logic_vector(15 downto 0);
				S1, S2				: out	std_logic_vector(27 downto 0));	
	end component;
	
	component SUM_node
		generic (	N: integer := 8;
					O: integer := 0);
		port (	A	: in	std_logic_vector(N-1 downto 0);
				B	: in	std_logic_vector(N-1 downto 0);
				S	: out	std_logic_vector(N-1 downto 0));	
	end component;

begin
	
	part1: PP_COMPUTE		port map (A, B, partial);
	part2: dadda_tree_15_13	port map (partial(0), partial(1), partial(2), partial(3), partial(4), partial(5), partial(6), sum1, sum2);
	part3: SUM_node			generic map (28, 0)
							port map (sum1, sum2, result);
	
	M <= result(26 downto 12);
	
end structural;
