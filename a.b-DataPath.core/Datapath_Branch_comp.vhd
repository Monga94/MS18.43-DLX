library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity Br_Comp is
	generic ( Nbit : integer := 32);
	port(	A:			in 	std_logic_vector(Nbit-1 downto 0);
			Br_cond:	in	std_logic_vector(1 downto 0);
			Taken:		out std_logic);
end Br_Comp;

architecture Structural of Br_Comp is
	signal Temp	: std_logic_vector(Nbit-1 downto 0);

begin
		
	Temp(0) <= A(0);
		
	EqZ: for i in 1 to (Nbit-1) generate
		Temp(i) <= Temp(i-1) or A(i);
	end generate;
		
	Taken <= Br_cond(1) AND (Br_cond(0) XNOR Temp(Nbit-1));
	
end Structural;