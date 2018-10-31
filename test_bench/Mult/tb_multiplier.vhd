library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use WORK.myStuff.all;

entity tb_multiplier is
end tb_multiplier;


architecture TEST of tb_multiplier is


  constant numBit : integer := 32;

  --  input	 
  signal A_mp_i : std_logic_vector(numBit-1 downto 0) := (others => '0');
  signal B_mp_i : std_logic_vector(numBit-1 downto 0) := (others => '0');

  -- output
  signal Y_mp_i : std_logic_vector(2*numBit-1 downto 0);


-- MUL component declaration
--
--
	component Boothmul
		generic (	N : 	integer := 32);
		port( 	A,B	: In	std_logic_vector(N-1 downto 0);
				P 	: Out	std_logic_vector((2*N)-1 downto 0));
	end component;

begin

-- MUL instantiation
--
--
	DUT: Boothmul
				generic map (numBit)
				port map (A_mp_i, B_mp_i, Y_mp_i);

-- PROCESS FOR TESTING TEST - COMPLETE CYCLE ---------
  test: process
  begin

    A_mp_i <= "11111000001010001001100000111010";
	B_mp_i <= "11000100101000011111110000000000";
	wait for 50 ns;
	A_mp_i <= "00000011111000001110101100111100";
	B_mp_i <= "11111111111110000000000000000000";
	wait for 50 ns;
	A_mp_i <= "11111111111111111111111111111111";
	B_mp_i <= "11111111111111111111111111111111";
	wait for 50 ns;
    A_mp_i <= "00000000000000000000000000000000";
	B_mp_i <= "11000100101000011111110000000000";
	wait for 50 ns;
	A_mp_i <= "00000011111000001110101100111100";
	B_mp_i <= "00000000000000000000000000000000";
	wait for 50 ns;
	A_mp_i <= "11111111111111111111111111111111";
	B_mp_i <= "00011110000111000001111000000000";
	wait for 50 ns;
    A_mp_i <= "00000000000000000000000000000001";
	B_mp_i <= "00000111111111111110000000000000";
	wait for 50 ns;
	A_mp_i <= "00000000000000000000000000001010";
	B_mp_i <= "00000000000000000000000001100100";

    wait;          
  end process test;


end TEST;
