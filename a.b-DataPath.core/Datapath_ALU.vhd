library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use WORK.myStuff.all;

entity ALU is
	generic ( N : integer := 32);
	port ( FUNC			: in	AluOp;
           DATA1, DATA2	: in 	std_logic_vector(N-1 downto 0);
           OUTALU		: out 	std_logic_vector(N-1 downto 0));
end ALU;

architecture Structural of ALU is

	component and_gen
		generic ( N : integer := 32);
		port (	A	: in	std_logic_vector(N-1 downto 0);
				B	: in	std_logic_vector(N-1 downto 0);
				C	: out	std_logic_vector(N-1 downto 0));
	end component;
	
	component or_gen
		generic ( N : integer := 32);
		port (	A	: in	std_logic_vector(N-1 downto 0);
				B	: in	std_logic_vector(N-1 downto 0);
				C	: out	std_logic_vector(N-1 downto 0));
	end component;
	
	component xor_gen
		generic ( N : integer := 32);
		port (	A	: in	std_logic_vector(N-1 downto 0);
				B	: in	std_logic_vector(N-1 downto 0);
				C	: out	std_logic_vector(N-1 downto 0));
	end component;
	
	component p4adder
		generic ( N: integer := 32); -- 4n bits
		port (	A	: in	std_logic_vector(N-1 downto 0);
				B	: in	std_logic_vector(N-1 downto 0);
				Cin	: in	std_logic;
				S	: out	std_logic_vector(N-1 downto 0);
				Cout: out	std_logic);
	end component;
	
begin
	
	

end Structural;