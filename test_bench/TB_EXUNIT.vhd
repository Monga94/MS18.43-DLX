library IEEE;

use IEEE.std_logic_1164.all;
use WORK.myStuff.all;

entity TB_EXUNIT is
end TB_EXUNIT;

architecture Test of TB_EXUNIT is

component ALU is
	generic ( N : integer := 32);
	port ( FUNC			: in	AluOp;
		   Cout 		: out  	std_logic;
           DATA1, DATA2	: in 	std_logic_vector(N-1 downto 0);
           OUTALU		: out 	std_logic_vector(N-1 downto 0));
end component;

signal Func: AluOp;
signal Cout: std_logic;
signal A,B,ALU_Res: std_logic_vector(Nbit-1 downto 0);

begin
	DUT: ALU
		port map(Func,Cout,A,B,ALU_Res);
		
	test: process
	begin
		Func <= ADD;
		A <= "00000000000000000000000000000001";
		B <= "00000000000000000000000000000001";
		wait for 5 ns;
		Func <= SUB;
		wait for 5 ns;
		Func <= BITAND;
		wait for 5 ns;
		Func <= BITOR;
		wait for 5 ns;
		Func <= BITXOR;
		wait for 5 ns;
		Func <= FUNCLSL;
		wait for 5 ns;
		Func <= FUNCLSR;
		wait for 5 ns;
		Func <= FUNCRL;
		wait for 5 ns;
		Func <= FUNCRR;
		wait for 5 ns;
		Func <= FUNCASL;
		wait for 5 ns;
		Func <= FUNCASR;
		wait for 5 ns;
		Func <= ADD;
		wait;
		end process test;
end Test;