library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity ExecutionUnit is 
	port(	CLK:			in std_logic;
			RST:		    in std_logic;
			REG_EN:			in std_logic;
			MuxA_Sel:		in std_logic;
			MuxB_Sel:		in std_logic;
			ALU_Config:		in AluOp;
			Condition:		in std_logic_vector(2 downto 0);
			NPC_In:		    in std_logic_vector(Nbit-1 downto 0);
			DataA:			in std_logic_vector(Nbit-1 downto 0);
			DataB:		    in std_logic_vector(Nbit-1 downto 0);
			DataIMM:		in std_logic_vector(Nbit-1 downto 0);	
			NPCOut:			out std_logic_vector(Nbit-1 downto 0);
			ALU_Out:		out std_logic_vector(Nbit-1 downto 0);	
			DataBtoDMem:	out std_logic_vector(Nbit-1 downto 0);	
			Taken:			out std_logic;
end ExecutionUnit;

architecture Behavioural of ExecutionUnit is
	
	signal Op1,Op2,ALU_res: std_logic_vector(Nbit-1 downto 0);
	signal Equal,Less,Great: std_logic;
	component D_Reg_generic
		generic (N: integer := 32);
		port (	D:		in	std_logic_vector(N-1 downto 0);
				CLK:	in	std_logic;
				RESET:	in	std_logic;
				ENABLE:	in	std_logic;
				Q:		out	std_logic_vector(N-1 downto 0));
	end component;
	
	component MUX21_GENERIC
		generic ( N: integer := 32);
		port (	A:	in	std_logic_vector(N-1 downto 0) ;
				B:	in	std_logic_vector(N-1 downto 0);
				S:	in	std_logic;
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;
	
	component ALU
		generic ( N : integer := 32);
		port ( FUNC			: in	AluOp;
			   DATA1, DATA2	: in 	std_logic_vector(N-1 downto 0);
			   OUTALU		: out 	std_logic_vector(N-1 downto 0));
	end component;
	
	component Comparator 
		generic ( Nbit : integer := 32);
		port(	DATA1,DATA2:	in 	std_logic_vector(Nbit-1 downto 0);
				EQ,LT,GT:		out std_logic);

	begin
	
	MUXA: MUX21_GENERIC
		port map(DataA,DataIMM,MuxA_Sel,Op1);
	MUXB: MUX21_GENERIC
		port map(DataB,NPC_In,MuxB_Sel,Op2);
	ALU: ALU
		port map(ALU_Config,Op1,Op2,ALU_res);
	REGALU: D_Reg_generic
		port map(ALU_res,CLK,RST,REG_EN,ALU_Out);
	REGNPC: D_Reg_generic
		generic map();
		port map(NPC_In,CLK,RST,REG_EN,NPCOut);
	COMP: Comparator
		generic map();
		port map(DataA,NPC_In,Equal,Less,Great);
		-- 000 EQ
		-- 001 NEQ
		-- 010 GT
		-- 011 GE
		-- 100 LT
		-- 101 LE
			
	process(Condition,Equal,Less,Great)
		begin
			case Condition is
				when "000" =>	Taken <= Equal;
				when "001" =>	Taken <= NOT(Equal);
				when "010" =>	Taken <= Great;
                when "011" =>	Taken <= Great OR Equal;
                when "100" =>	Taken <= Less;
                when "101" =>	Taken <= Less OR Equal;
				when others => 	Taken <= '0';
			end case;
	end process;
end Behavioural; 