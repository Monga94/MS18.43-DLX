library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity ExecutionUnit is 
	generic(Nbit: 		integer := 32;
			Addr_bit:	integer := 5);
	port(	CLK:			in	std_logic;
			RST:		    in	std_logic;
			REG_EN_E:		in	std_logic;
			MuxA_Sel:		in	std_logic;
			MuxB_Sel:		in	std_logic;
			ALU_Config:		in	AluOp;
			Sign:			in	std_logic;
			Condition:		in	std_logic_vector(2 downto 0);
			NPC_In:		    in	std_logic_vector(Nbit-1 downto 0);
			DataA:			in	std_logic_vector(Nbit-1 downto 0);
			DataB:		    in	std_logic_vector(Nbit-1 downto 0);
			DataIMM:		in	std_logic_vector(Nbit-1 downto 0);
			Wr_Addr_D:		in	std_logic_vector(Addr_bit-1 downto 0);
			ALU_Out:		out std_logic_vector(Nbit-1 downto 0);
			DataBtoDMem:	out std_logic_vector(Nbit-1 downto 0);
			Wr_Addr_E:		out std_logic_vector(Addr_bit-1 downto 0);
			Taken:			out std_logic);
end ExecutionUnit;

architecture Behavioural of ExecutionUnit is
	signal Op1,Op2,ALU_res	: std_logic_vector(Nbit-1 downto 0);
	
	component D_Reg_generic
		generic (N: integer := 32);
		port (	D:		in	std_logic_vector(N-1 downto 0);
				CLK:	in	std_logic;
				RESET:	in	std_logic;
				ENABLE:	in	std_logic;
				Q:		out	std_logic_vector(N-1 downto 0));
	end component;
	
	component MUX21_GENERIC
		generic (N: integer := 32);
		port (	A:	in	std_logic_vector(N-1 downto 0) ;
				B:	in	std_logic_vector(N-1 downto 0);
				S:	in	std_logic;
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;
	
	component ALU is
		generic ( N : integer := 32);
		port (	FUNC			: in	AluOp;
				Sign			: in	std_logic;
				DATA1, DATA2	: in 	std_logic_vector(N-1 downto 0);
				OUTALU			: out 	std_logic_vector(N-1 downto 0);
				Cout			: out  	std_logic);
	end component;

begin
	
	MUXA: MUX21_GENERIC
		generic map(Nbit)
		port map(NPC_In,DataA,MuxA_Sel,Op1);
	MUXB: MUX21_GENERIC
		generic map(Nbit)
		port map(DataB,DataIMM,MuxB_Sel,Op2);
	ALUnit: ALU
		generic map(Nbit)
		port map(ALU_Config,Sign,Op1,Op2,ALU_res,open);
	REGALU: D_Reg_generic
		generic map(Nbit)
		port map(ALU_res,CLK,RST,REG_EN_E,ALU_Out);
	REGB: D_Reg_generic
		generic map(Nbit)
		port map(DataB,CLK,RST,REG_EN_E,DataBtoDMem);
	REGWR: D_Reg_generic
		generic map(Addr_bit)
		port map(Wr_Addr_D,CLK,RST,REG_EN_E,Wr_Addr_E);
	
end Behavioural; 