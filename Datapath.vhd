library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity Datapath is
	generic ( Nbit : integer := 32)
	port (	)
end Datapath;

architecture Structural of Datapath is
	

	component D_Reg_generic
		generic (N: integer := 8);
		port (	D:		in	std_logic_vector(N-1 downto 0);
				CLK:	in	std_logic;
				RESET:	in	std_logic;
				ENABLE:	in	std_logic;
				Q:		out	std_logic_vector(N-1 downto 0));
	end component;
	
	component MUX21_GENERIC
		generic ( N: integer := 8);
		port (	A:	in	std_logic_vector(N-1 downto 0) ;
				B:	in	std_logic_vector(N-1 downto 0);
				S:	in	std_logic;
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;
	
	a
	component ALU
		generic ( N : integer := 32);
		port ( FUNC			: in	AluOp;
			   DATA1, DATA2	: in 	std_logic_vector(N-1 downto 0);
			   OUTALU		: out 	std_logic_vector(N-1 downto 0));
	end component;
	
	component register_file_gen
		generic (	Nbit:	integer := 64;
					Nreg:	integer := 32);
		port 	( 	CLK: 		in std_logic;
					RESET: 		in std_logic;
					ENABLE: 	in std_logic;
					WR: 		in std_logic;
					RD1: 		in std_logic;
					RD2: 		in std_logic;
					ADD_WR: 	in std_logic_vector(log2_N(Nreg)-1 downto 0);
					ADD_RD1: 	in std_logic_vector(log2_N(Nreg)-1 downto 0);
					ADD_RD2: 	in std_logic_vector(log2_N(Nreg)-1 downto 0);
					DATAIN: 	in std_logic_vector(Nbit-1 downto 0);
					OUT1: 		out std_logic_vector(Nbit-1 downto 0);
					OUT2: 		out std_logic_vector(Nbit-1 downto 0));
	end component;
	
	component RCA_gen
		generic ( N: integer := 8);
		port (	A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				Ci:	In	std_logic;
				S:	Out	std_logic_vector(N-1 downto 0);
				Co:	Out	std_logic);
	end component;
	
begin



end Structural;