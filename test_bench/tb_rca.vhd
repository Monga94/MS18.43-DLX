library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; -- we need a conversion to unsigned 

entity TBRCA is 
end TBRCA; 

architecture TEST of TBRCA is
	constant N : integer := 32;

	signal A_i, B_i, S : std_logic_vector(N-1 downto 0);
	signal Ci, Co, Ovf1 : std_logic;


	component Add_gen
		generic ( N: integer := 32); -- 4n bits
		port (	A	: in	std_logic_vector(N-1 downto 0);
				B	: in	std_logic_vector(N-1 downto 0);
				Ci	: in	std_logic;
				S	: out	std_logic_vector(N-1 downto 0);
				Co: out	std_logic;
				OvF1: out std_logic);
	end component;

Begin

	test: process

	begin  -- process test

	A_i          <= "00000000000000000000000000000000";
	B_i          <= "00000000000000000000000000000000";
	Ci		     <= '0';

	wait for 20 ns;

	A_i          <= "11111111111111111111111111111111";
	B_i          <= "00000000000000000000000000000001";
	Ci		     <= '0';

	wait for 20 ns;

	A_i          <= "11111111111111111111111111111111";
	B_i          <= "00000000000000000000000000000000";
	Ci		     <= '1';

	wait for 20 ns;

	A_i          <= "00001111000000000001110000000011";
	B_i          <= "00001001000000000011110000000010";
	Ci		     <= '0';

	wait for 20 ns;

	A_i          <= "11110000001111111100000000000000";
	B_i          <= "11000000000111100100000000000111";
	Ci		     <= '1';

	wait for 20 ns;

	A_i          <= "00000000000000011111111100000000";
	B_i          <= "11111111000000000000011100000011";
	Ci		     <= '0';

	wait for 20 ns;

	A_i          <= "00000111111111111111111110000000";
	B_i          <= "00011000000110000000000100000000";
	Ci		     <= '0';

	wait;
	
	end process test;

-- Instanciate the ADDER without delay in the carry generation
	UADDER1: Add_Gen
		generic map (N)
		port map (A_i(N-1 downto 0), B_i(N-1 downto 0), Ci, S(N-1 downto 0), Co, Ovf1);
	   
end TEST;
