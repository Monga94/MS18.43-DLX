library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity Comparator is
		generic ( Nbit : integer := 32);
		port(	DATA1,DATA2:	in 	std_logic_vector(Nbit-1 downto 0);
				EQ,LT,GT:		out std_logic);
end Comparator;

architecture Structural of Comparator is

	signal Sum		: std_logic_vector(Nbit-1 downto 0);
	signal Cout,Z	: std_logic;

	component Add_gen is 
		generic ( N: integer := 32);
		port (	A:			in	std_logic_vector(N-1 downto 0);
				B:			in	std_logic_vector(N-1 downto 0);
				sub:		in	std_logic;
				S:			out	std_logic_vector(N-1 downto 0);
				Co:			out	std_logic;
				Sign_OF:	out std_logic);
	end component;

begin

	SUB: Add_gen
		port map(DATA1,DATA2,'1',Sum,Cout,open);
	Z <= NOT(Sum(0) OR Sum(1) OR Sum(2) OR Sum(3) OR Sum(4) OR Sum(5) OR Sum(6) OR Sum(7) OR Sum(8) OR
				Sum(9) OR Sum(10) OR Sum(11) OR Sum(12) OR Sum(13) OR Sum(14) OR Sum(15) OR Sum(16) OR
				Sum(17) OR Sum(18) OR Sum(19) OR Sum(20) OR Sum(21) OR Sum(22) OR Sum(23) OR Sum(24) OR 
				Sum(25) OR Sum(26) OR Sum(27) OR Sum(28) OR Sum(29) OR Sum(30) OR Sum(31));
	EQ <= Z;
	GT <= Cout AND (NOT Z);
	LT <= NOT Cout;
	
end Structural;

configuration CFG_COMP of Comparator is
	for Structural
		for SUB : Add_gen
			use configuration WORK.CFG_ADDER_RCA;
		end for;
	end for;
end CFG_COMP;