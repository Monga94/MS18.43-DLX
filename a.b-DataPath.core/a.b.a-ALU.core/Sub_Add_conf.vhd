library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity Add_gen is 
	generic ( N: integer := 32);
	port (	A:			in	std_logic_vector(N-1 downto 0);
			B:			in	std_logic_vector(N-1 downto 0);
			sub:		in	std_logic;
			S:			out	std_logic_vector(N-1 downto 0);
			Co:			out	std_logic;
			Sign_OF:	out std_logic);
end Add_gen;

architecture RCA_struct of Add_gen is
	signal BS, Sum		: std_logic_vector(N-1 downto 0);
	signal Cout			: std_logic;
	signal CarryVector	: std_logic_vector(N-1 downto 0);
	
	component RCA_gen is 
		generic ( N: integer := 8);
		port (	A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				Ci:	In	std_logic;
				S:	Out	std_logic_vector(N-1 downto 0);
				Co:	Out	std_logic);
	end component;
	
	component xor_gen is
		generic ( N : integer := 32);
		port (	A	: in	std_logic_vector(N-1 downto 0);
				B	: in	std_logic_vector(N-1 downto 0);
				C	: out	std_logic_vector(N-1 downto 0));
	end component;

begin
	
	CarryVector <= (others => sub);
	
	SUB: xor_gen
		generic map (N)
		port map (B,CarryVector, BS);
  
	ADDER: RCA_gen
		generic map (N)
		port map (A, BS, sub, Sum, Cout);
		
	Sign_OF <= Cout xor A(N-1) xor BS(N-1) xor Sum(N-1);
	S <= Sum;
	Co <= Cout;

end RCA_struct;

architecture p4_struct of Add_gen is
	signal BS, Sum, CarryVector	: std_logic_vector(N-1 downto 0);
	signal Cout					: std_logic;
   
	component p4adder
		generic ( N: integer := 32); -- 4n bits
		port (	A	: in	std_logic_vector(N-1 downto 0);
				B	: in	std_logic_vector(N-1 downto 0);
				Cin	: in	std_logic;
				S	: out	std_logic_vector(N-1 downto 0);
				Cout: out	std_logic);
	end component;
	
	component xor_gen is
		generic ( N : integer := 32);
		port (	A	: in	std_logic_vector(N-1 downto 0);
				B	: in	std_logic_vector(N-1 downto 0);
				C	: out	std_logic_vector(N-1 downto 0));
	end component;

begin
		
	CarryVector <= (others => sub);
	
	SUB: xor_gen
		generic map (N)
		port map (B, CarryVector, BS);
  
	ADDER: p4adder
		generic map (N)
		port map (A, BS, sub, Sum, Cout);
		
	Sign_OF <= Cout xor A(N-1) xor BS(N-1) xor Sum(N-1);
	S <= Sum;
	Co <= Cout;

end p4_struct;

configuration CFG_ADDER_RCA of Add_gen is
	for RCA_struct
	end for;
end CFG_ADDER_RCA;

configuration CFG_ADDER_P4 of Add_gen is
	for p4_struct
	end for;
end CFG_ADDER_P4;