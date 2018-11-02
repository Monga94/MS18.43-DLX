library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use WORK.myStuff.all;
use work.logarithm.all;

entity ALU is
	generic ( N : integer := 32);
	port (	FUNC			: in	std_logic_vector(SelALU-1 downto 0);
			Sign			: in	std_logic;
			MemOp			: in	std_logic;
			DATA1, DATA2	: in 	std_logic_vector(N-1 downto 0);
			OUTALU			: out 	std_logic_vector(N-1 downto 0));
end ALU;

architecture Structural of ALU is

	signal Sub,Cout,L_A,L_R,S_R									: std_logic;
	signal Comp_Sel,Out_Sel										: std_logic_vector(2 downto 0);	
	signal And_Out,Or_Out,Xor_Out,Add_Out,Shift_Out,Mul_Out,Comp_ext	: std_logic_vector(N-1 downto 0);
	signal AneB,AeqB,AgtB,AgeB,AltB,AleB,Comp_Out				: std_logic;
	signal Sign_OF,Unsign_OF,OvFl,OvFl_Sel						: std_logic;
	signal Over,Add_Ok											: std_logic_vector(N-1 downto 0);
	

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
	
	component Add_gen is 
		generic ( N: integer := 32);
		port (	A:			in	std_logic_vector(N-1 downto 0);
				B:			in	std_logic_vector(N-1 downto 0);
				sub:		in	std_logic;
				S:			out	std_logic_vector(N-1 downto 0);
				Co:			out	std_logic;
				Sign_OF:	out std_logic;
				Unsign_OF:	out std_logic);
	end component;
	
	component SHIFTER_GENERIC is
		generic(N: integer := 32);
		port(	A: in std_logic_vector(N-1 downto 0);
				B: in std_logic_vector(log2_N(N)-1 downto 0);
				LOGIC_ARITH: in std_logic;	-- 1 = logic, 0 = arith
				LEFT_RIGHT: in std_logic;	-- 1 = left, 0 = right
				SHIFT_ROTATE: in std_logic;	-- 1 = shift, 0 = rotate
				OUTPUT: out std_logic_vector(N-1 downto 0));
	end component;
	
	component Comparator 
		generic ( Nbit : integer := 32);
		port(	Diff:	in 	std_logic_vector(Nbit-1 downto 0);
				Cout:	in	std_logic;
				Sign:	in	std_logic;
				Ne:		out std_logic;
				Eq:		out std_logic;
				Gt:		out std_logic;
				Ge:		out std_logic;
				Lt:		out std_logic;
				Le:		out std_logic);
	end component;
	
	component Boothmul is 
	   generic (	N : 	integer := 16);
	   port( 	A,B : 	In std_logic_vector(N-1 downto 0);
			   P 	: 	Out std_logic_vector((2*N)-1 downto 0));
   end component;
	
	component MUX21
		port (	A:	in	std_logic;
				B:	in	std_logic;
				S:	in	std_logic;
				Y:	out	std_logic);
	end component;
	
	component MUX21_GENERIC
		generic (N: integer := 32);
		port (	A:	in	std_logic_vector(N-1 downto 0) ;
				B:	in	std_logic_vector(N-1 downto 0);
				S:	in	std_logic;
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;
	
	component mux81_logic
		port (		A:	In	std_logic;
					B:	In	std_logic;
					C:	In	std_logic;
					D:	In	std_logic;
					E:	In	std_logic;
					F:	In	std_logic;
					G:	In	std_logic;
					H:	In	std_logic;
					S:	In	std_logic_vector(2 downto 0);
					Y:	Out	std_logic);
	end component;
	
	component mux81_generic is
		generic (	N: integer:= 32);			
		port (		A:	In	std_logic_vector(N-1 downto 0);
					B:	In	std_logic_vector(N-1 downto 0);
					C:	In	std_logic_vector(N-1 downto 0);
					D:	In	std_logic_vector(N-1 downto 0);
					E:	In	std_logic_vector(N-1 downto 0);
					F:	In	std_logic_vector(N-1 downto 0);
					G:	In	std_logic_vector(N-1 downto 0);
					H:	In	std_logic_vector(N-1 downto 0);
					S:	In	std_logic_vector(2 downto 0);
					Y:	Out	std_logic_vector(N-1 downto 0));
	end component;
	
begin

	ALU_Brain: process(FUNC)
	--(ADD,SUB,BITAND,BITOR,BITXOR,FUNCLSL,FUNCLSR,FUNCRL,FUNCRR,MULT,FUNCASL,FUNCASR,NOP);
	begin
		Sub <= '0';
		L_A <= '1';
		L_R <= '1';
		S_R <= '1';
		Comp_Sel <= "111";
		Out_Sel <= "111";
		case conv_integer(unsigned(FUNC)) is  
			when conv_integer(unsigned(ALU_ANDop)) 	=>	
								Out_Sel <= "000";	
			when conv_integer(unsigned(ALU_ORop))	=>	
								Out_Sel <= "001";	
			when conv_integer(unsigned(ALU_XORop))	=>	
								Out_Sel <= "010";
			when conv_integer(unsigned(ALU_ADDop))	=>	
								Out_Sel <= "011";   
			when conv_integer(unsigned(ALU_SUBop))	=>	
								Sub <= '1';			
								Out_Sel <= "011"; 	
			when conv_integer(unsigned(ALU_SLLop))	=>	
								L_A <= '1';			
								L_R <= '1';         
								S_R <= '1';         
								Out_Sel <= "100";   
			when conv_integer(unsigned(ALU_SRLop))	=>	
								L_A <= '1';			
								L_R <= '0';         
								S_R <= '1';         
								Out_Sel <= "100";   
			when conv_integer(unsigned(ALU_SRAop))	=>	
								L_A <= '0';			
								L_R <= '0';
								S_R <= '1';
								Out_Sel <= "100";
			when conv_integer(unsigned(ALU_ROLop))	=>	
								L_A <= '1';			
								L_R <= '1';
								S_R <= '0';
								Out_Sel <= "100";
			when conv_integer(unsigned(ALU_RORop))	=>	
								L_A <= '1';			
								L_R <= '0';
								S_R <= '0';
								Out_Sel <= "100";
			when conv_integer(unsigned(ALU_AneBop))	=>	
								Sub <= '1';
								Comp_Sel <= "000";
								Out_Sel <= "101";
			when conv_integer(unsigned(ALU_AeqBop))	=>	
								Sub <= '1';
								Comp_Sel <= "001";
								Out_Sel <= "101";
			when conv_integer(unsigned(ALU_AgtBop))	=>	
								Sub <= '1';
								Comp_Sel <= "010";
								Out_Sel <= "101";
			when conv_integer(unsigned(ALU_AgeBop))	=>	
								Sub <= '1';
								Comp_Sel <= "011";
								Out_Sel <= "101";
			when conv_integer(unsigned(ALU_AltBop))	=>	
								Sub <= '1';
								Comp_Sel <= "100";
								Out_Sel <= "101";
			when conv_integer(unsigned(ALU_AleBop))	=>	
								Sub <= '1';
								Comp_Sel <= "101";
								Out_Sel <= "101";
			when conv_integer(unsigned(ALU_MULTop))	=>	
								Out_Sel <= "110";
			when others								=>	
								Out_Sel <= "111";
		end case;
	end process;
	
	AND_OP: and_gen
		generic map(N)
		port map(DATA1,DATA2,And_Out);
	OR_OP: or_gen
		generic map(N)
		port map(DATA1,DATA2,Or_Out);
	XOR_OP: xor_gen
		generic map(N)
		port map(DATA1,DATA2,Xor_Out);
	ADDER: Add_gen
		generic map(N)
		port map(DATA1,DATA2,Sub,Add_Out,Cout,Sign_OF,Unsign_OF);
	SH_ROT:	SHIFTER_GENERIC
		generic map(N)
		port map(DATA1,DATA2(log2_N(N)-1 downto 0),L_A,L_R,S_R,Shift_Out);
	COMP: Comparator
		generic map(N)
		port map(Add_Out,Cout,Sign,AneB,AeqB,AgtB,AgeB,AltB,AleB);
	MUL: Boothmul
		generic map(N/2)
		port map(DATA1(15 downto 0),DATA2(15 downto 0),Mul_Out);
	MuxComp: mux81_logic
		port map(AneB,AeqB,AgtB,AgeB,AltB,AleB,'0','0',Comp_sel,Comp_Out);
		
	Comp_ext <= (N-1 downto 1 => '0') & Comp_Out;
	
	OF_Detect: MUX21
		port map(Unsign_OF,Sign_OF,Sign,OvFl);
		
	Over <= (Sub XNOR Sign) & (N-2 downto 0 => NOT(Sub));
	OvFl_Sel <= OvFl AND NOT(MemOp);
	
	OF_Manage: MUX21_GENERIC
		generic map(N)
		port map(Add_Out,Over,OvFl_Sel,Add_Ok);
		
	MuxOut: mux81_generic
		generic map(N)
		port map(And_Out,Or_Out,Xor_Out,Add_Ok,Shift_Out,Comp_ext,Mul_Out,(others => '0'),Out_sel,OUTALU);
		
end Structural;

configuration CFG_ALU of ALU is
	for Structural
		for ADDER : Add_gen
			use configuration WORK.CFG_ADDER_P4;
		end for;
	end for;
end CFG_ALU;