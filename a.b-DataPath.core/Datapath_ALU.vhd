library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use WORK.myStuff.all;

entity ALU is
	generic ( N : integer := 32);
	port ( FUNC			: in	AluOp;
		   Cout 		: out  	std_logic;
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
	
	component MUX21_GENERIC
		generic (N: integer := 32);
		port (	A:	in	std_logic_vector(N-1 downto 0) ;
				B:	in	std_logic_vector(N-1 downto 0);
				S:	in	std_logic;
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;
	
	signal Cin:	std_logic;
	signal Mux_sel:	std_logic_vector(1 downto 0);
	
	signal Add_Out: std_logic_vector(N-1 downto 0);
	
begin
	ADDER: p4adder
		port map(DATA1,DATA2,Cin,Add_Out,Cout);
	OR_OP: or_gen
		port map(DATA1,DATA2,Or_Out);
	AND_OP: and_gen
		port map(DATA1,DATA2,And_Out);
	XOR_OP: xor_gen
		port map(DATA1,DATA2,Xor_Out);
	Mux0: MUX21_GENERIC
		port map(Add_Out,Xor_Out,Mux_sel(0),Mux0_Out);
	Mux1: MUX21_GENERIC
		port map(And_Out,Or_Out,Mux_sel(0),Mux1_Out);
	MuxOut: MUX21_GENERIC
		port map(Mux0_Out,Mux1_Out,Mux_sel(1),OUTALU);
		
	process(FUNC)
	
	begin
		
		case conv_integer(unsigned(FUNC)) is
			when 1 => 	Mux_sel <= "00"; --add
						Cin <= '0';
			when 2 =>  	Mux_sel <= "00"; --sub
						Cin <= '1';
			when 3 => 	Mux_sel <= "10"; --and
			when 4 => 	Mux_sel <= "11"; --or
			when others => Mux_sel <= "01"; --xor 
		end case;	
		
	end process;
end Structural;