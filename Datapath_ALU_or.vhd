library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity or_gen is
	generic ( N : integer := 32);
	port (	A	: in	std_logic_vector(N-1 downto 0);
			B	: in	std_logic_vector(N-1 downto 0);
			C	: out	std_logic_vector(N-1 downto 0));
end or_gen;

architecture Structural of or_gen is
begin
	ORs: for i in 0 to N-1 generate
		OR_i: C(i) <= A(i) or B(i);
	end generate;
end Structural;
