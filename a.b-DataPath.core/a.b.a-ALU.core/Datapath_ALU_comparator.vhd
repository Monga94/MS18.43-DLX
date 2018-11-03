library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity Comparator is
	generic ( Nbit : integer := 32);
	port(	Diff:	in 	std_logic_vector(Nbit-1 downto 0);
			Cout:	in	std_logic;
			Sign:	in	std_logic;
			a:		in	std_logic;
			b:		in	std_logic;
			Ne:		out std_logic;
			Eq:		out std_logic;
			Gt:		out std_logic;
			Ge:		out std_logic;
			Lt:		out std_logic;
			Le:		out std_logic);
end Comparator;

architecture Structural of Comparator is

	signal Equal,Grequal,Less	: std_logic;
	signal Temp					: std_logic_vector(Nbit-1 downto 0);

begin
		
	Temp(0) <= Diff(0);
		
	EqT: for i in 1 to (Nbit-1) generate
		Temp(i) <= Temp(i-1) or Diff(i);
	end generate;
		
	Equal <= NOT(Temp(Nbit-1));
	Ne <= NOT(Equal);
	Eq <= Equal;
	
	Grequal <= (Sign AND (Cout XOR a XOR b)) OR (NOT(Sign) AND Cout);
	Gt <= Grequal AND (NOT(Equal));
	Ge <= Grequal;
	
	Less <= (Sign AND (NOT(Cout) XOR a XOR b)) OR (NOT(sign) AND NOT(Cout));
	Lt <= Less;
	Le <= Less OR Equal;
	
end Structural;