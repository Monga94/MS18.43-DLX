library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use WORK.myStuff.all;

entity ALU is
	generic ( N : integer := 32);
	port (	FUNC			: in	AluOp;
			Sign			: in	std_logic;
			DATA1, DATA2	: in 	std_logic_vector(N-1 downto 0);
			OUTALU			: out 	std_logic_vector(N-1 downto 0);
			Cout			: out  	std_logic);
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
	
	component Add_gen is 
		generic ( N: integer := 32);
		port (	A:			in	std_logic_vector(N-1 downto 0);
				B:			in	std_logic_vector(N-1 downto 0);
				sub:		in	std_logic;
				S:			out	std_logic_vector(N-1 downto 0);
				Co:			out	std_logic;
				Sign_OF:	out std_logic);
	end component;
	
	component SHIFTER_GENERIC is
		generic(N: integer := 32);
		port(	A: in std_logic_vector(N-1 downto 0);
				B: in std_logic_vector(N-1 downto 0);
				LOGIC_ARITH: in std_logic;	-- 1 = logic, 0 = arith
				LEFT_RIGHT: in std_logic;	-- 1 = left, 0 = right
				SHIFT_ROTATE: in std_logic;	-- 1 = shift, 0 = rotate
				OUTPUT: out std_logic_vector(N-1 downto 0));
	end component;
	
	component Comparator 
		generic (Nbit: integer := 32);
		port(	DATA1,DATA2:	in 	std_logic_vector(Nbit-1 downto 0);
				EQ,LT,GT:		out std_logic);
	end component;
	
	--component Boothmul is 
	--	generic (	N : 	integer := 16
	--				logN: 	integer := 4);
	--	port( 	A,B : 	In std_logic_vector(N-1 downto 0);
	--			P 	: 	Out std_logic_vector(N+logN downto 0));
	--end component;
	
	-- component MUX21_GENERIC
		-- generic (N: integer := 32);
		-- port (	A:	in	std_logic_vector(N-1 downto 0) ;
				-- B:	in	std_logic_vector(N-1 downto 0);
				-- S:	in	std_logic;
				-- Y:	out	std_logic_vector(N-1 downto 0));
	-- end component;
	
	component mux51_generic is
		generic (	N: integer:= 32);			
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
	signal Add_Out,Shift_Out,Mux0_Out,Mux1_Out,Or_Out,And_Out,Xor_Out: std_logic_vector(N-1 downto 0);
	
begin
	ADDER: Add_gen
		port map(DATA1,DATA2,Cin,Add_Out,Cout,open);
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
	--MUL: Boothmul
		--port map(DATA1,DATA2,Mul_Out);
		
	process(FUNC)
	--(ADD,SUB,BITAND,BITOR,BITXOR,FUNCLSL,FUNCLSR,FUNCRL,FUNCRR,MULT,FUNCASL,FUNCASR,NOP);
	begin
		
		case FUNC is
			when ADD		=>	Cin <= '0';				--add
								Mux_sel <= "000";
			when SUB 		=>	Cin <= '1';				--sub
								Mux_sel <= "000";
			when BITAND 	=>	Mux_sel <= "001";		--and
			when BITOR		=>	Mux_sel <= "010";		--or
			when BITXOR 	=>	Mux_sel <= "011";		--xor 
			when FUNCLSL	=>	L_A <= '1';				--FUNCLSL
								L_R <= '1';
								S_R <= '1';
								Mux_sel <= "100";
			when FUNCLSR	=>	L_A <= '1';				--FUNCLSR
								L_R <= '0';
								S_R <= '1';
								Mux_sel <= "100";
			when FUNCRL		=>	L_A <= '1';				--FUNCRL
								L_R <= '1';
								S_R <= '0';
								Mux_sel <= "100";
			when FUNCRR		=>	L_A <= '1';				--FUNCRR
								L_R <= '0';
								S_R <= '0';
								Mux_sel <= "100";
			-- when FUNCASL	=>	L_A <= '0';				--FUNCASL
								-- L_R <= '1';
								-- S_R <= '1';
								-- Mux_sel <= "100";
			when FUNCASR	=>	L_A <= '0';				--FUNCASR
								L_R <= '1';
								S_R <= '1';
								Mux_sel <= "100";
			when others		=>	Cin <= '0'; 			--add
								Mux_sel <= "000";
		end case;	
		
	end process;
end Structural;

configuration CFG_ALU of ALU is
	for Structural
		for ADDER : Add_gen
			use configuration WORK.CFG_ADDER_P4;
		end for;
	end for;
end CFG_ALU;