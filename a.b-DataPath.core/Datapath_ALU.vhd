library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use WORK.myStuff.all;

entity ALU is
	generic ( N : integer := 32);
	port ( FUNC			: in	AluOp;
           DATA1, DATA2	: in 	std_logic_vector(N-1 downto 0);
           OUTALU		: out 	std_logic_vector(N-1 downto 0);
		   Cout 		: out  	std_logic);
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
	
	component SHIFTER_GENERIC is
		generic(N: integer := 32);
		port(	A: in std_logic_vector(N-1 downto 0);
				B: in std_logic_vector(4 downto 0);
				LOGIC_ARITH: in std_logic;	-- 1 = logic, 0 = arith
				LEFT_RIGHT: in std_logic;	-- 1 = left, 0 = right
				SHIFT_ROTATE: in std_logic;	-- 1 = shift, 0 = rotate
				OUTPUT: out std_logic_vector(N-1 downto 0)
	)
	end component;
	
	component Boothmul is 
		generic (	N : 	integer := 16
					logN: 	integer := 4);
		port( 	A,B : 	In std_logic_vector(N-1 downto 0);
				P 	: 	Out std_logic_vector(N+logN downto 0));
	end component;
	
	component mux51_generic is
		generic (	N: integer:= 4);			
		port (	A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				C:	In	std_logic_vector(N-1 downto 0);
				D:	In	std_logic_vector(N-1 downto 0);
				E:	In	std_logic_vector(N-1 downto 0);
				S:	In	std_logic_vector(2 downto 0);
				Y:	Out	std_logic_vector(N-1 downto 0));
	end component;
	
	signal Cin,L_A,L_R,S_R:	std_logic;
	signal Mux_sel:	std_logic_vector(2 downto 0);	
	signal Add_Out,Shift_Out,Mux0_Out,Mux1_Out: std_logic_vector(N-1 downto 0);
	
begin
	ADDER: p4adder
		port map(DATA1,DATA2,Cin,Add_Out,Cout);
	OR_OP: or_gen
		port map(DATA1,DATA2,Or_Out);
	AND_OP: and_gen
		port map(DATA1,DATA2,And_Out);
	XOR_OP: xor_gen
		port map(DATA1,DATA2,Xor_Out);
	Mux: mux51_generic
		port map(Add_Out,And_Out,Or_Out,Xor_Out,Shift_Out,Mux_sel,OUTALU);
	--Mux0: MUX21_GENERIC
	--	port map(Add_Out,Xor_Out,Mux_sel(0),Mux0_Out);
	--Mux1: MUX21_GENERIC
	--	port map(And_Out,Or_Out,Mux_sel(0),Mux1_Out);
	--MuxOut: MUX21_GENERIC
	--	port map(Mux0_Out,Mux1_Out,Mux_sel(1),OUTALU);
	SH_ROT:	SHIFTER_GENERIC
		port map(DATA1,DATA2,L_A,L_R,S_R,Shift_Out);
	MUL: Boothmul
		port map(DATA1,DATA2,Mul_Out);
		
	process(FUNC)
	--(ADD, SUB, BITAND, BITOR, BITXOR, FUNCLSL, FUNCLSR, FUNCRL, FUNCRR, MULT, AgeB, AleB, AneB, NOP);
	begin
		
		case conv_integer(unsigned(FUNC)) is
			when 1 => 	Mux_sel <= "000"; --add
						Cin <= '0';
			when 2 =>  	Mux_sel <= "000"; --sub
						Cin <= '1';
			when 3 => 	Mux_sel <= "001"; --and
			when 4 => 	Mux_sel <= "010"; --or
			when 5 => 	Mux_sel <= "011"; --xor 
			when 6 =>	Mux_sel <= "100";
						L_A <= '1';				--FUNCLSL
						L_R <= '1';
						S_R <= '1';
			when 8 =>	L_A <= '1';				--FUNCLSR
			            L_R <= '0';
			            S_R <= '1';
						Mux_sel <= "100";
			when 9 =>	L_A <= '1';				--FUNCRL
			            L_R <= '1';
			            S_R <= '0';
						Mux_sel <= "100";
			when 10 =>	L_A <= '1';				--FUNCRR
			            L_R <= '0';
			            S_R <= '0';
						Mux_sel <= "100";
			when 11 =>	L_A <= '0';				--FUNCASL
			            L_R <= '1';
			            S_R <= '1';
						Mux_sel <= "100";
			when 12 =>	L_A <= '0';				--FUNCASR
			            L_R <= '1';
			            S_R <= '1';
						Mux_sel <= "100";
			when 13 =>
			when 10 =>
			when 11 =>
		end case;	
		
	end process;
end Structural;