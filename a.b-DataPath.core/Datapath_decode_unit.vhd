library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity DecodeUnit is
		generic(Nbit: integer := 32);
		port(	CLK:			in	std_logic;
				RST:			in	std_logic;
				RF_RD1:			in	std_logic;
				RF_RD2:			in	std_logic;
				RF_WR:			in	std_logic;
				REG_EN_D:		in	std_logic;	
				MuxIMM_Sel:		in	std_logic;
				MuxRd_Sel:		in	std_logic;
				InstrToDecode:	in	std_logic_vector(Nbit-1 downto 0);
				NPC:		 	in	std_logic_vector(Nbit-1 downto 0);
				WB_Data:		in	std_logic_vector(Nbit-1 downto 0);
				WB_Addr:		in	std_logic_vector(OP_REG_SIZE-1 downto 0);
				DataA:			out std_logic_vector(Nbit-1 downto 0);
				DataB:			out std_logic_vector(Nbit-1 downto 0);
				DataIMM:		out std_logic_vector(Nbit-1 downto 0);
				NPCOut:			out std_logic_vector(Nbit-1 downto 0);
				Wr_Addr_D:		out std_logic_vector(OP_REG_SIZE-1 downto 0));
end DecodeUnit;

architecture Structural of DecodeUnit is	
	signal Rs1,Rs2,Rd_Itype,Rd_Rtype				: std_logic_vector(OP_REG_SIZE-1 downto 0);
	signal Extended16to32,Extended16to?,MuxIMM_Out	: std_logic_vector(Nbit-1 downto 0);
	signal WRaddr									: std_logic_vector(OP_REG_SIZE-1 downto 0);
	--signal Offset									: std_logic_vector(15 downto 0); -- not used

	component register_file_gen
		generic (	Nbit:	integer := 32;
					Nreg:	integer := 32);
		port(	CLK: 		in	std_logic;
				RESET: 		in	std_logic;
				ENABLE: 	in	std_logic;
				WR: 		in	std_logic;
				RD1: 		in	std_logic;
				RD2: 		in	std_logic;
				ADD_WR: 	in	std_logic_vector(log2_N(Nreg)-1 downto 0);
				ADD_RD1: 	in	std_logic_vector(log2_N(Nreg)-1 downto 0);
				ADD_RD2: 	in	std_logic_vector(log2_N(Nreg)-1 downto 0);
				DATAIN: 	in	std_logic_vector(Nbit-1 downto 0));
				OUT1: 		out std_logic_vector(Nbit-1 downto 0);
				OUT2: 		out std_logic_vector(Nbit-1 downto 0);
	end component;

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
	
begin
	
	Extended16to32 <= (31 downto 16 => InstrToDecode(15)) &  InstrToDecode(15 downto 0);
	--Extended16to? <= 
	Rs1 <= InstrToDecode(25 downto 21);
	Rs2 <= InstrToDecode(20 downto 16);
	Rd_Itype <= InstrToDecode(20 downto 16);
	Rd_Rtype <= InstrToDecode(15 downto 11);
	
	MUXWR: MUX21_GENERIC
		generic map(Nbit);
		port map(Rd_Itype,Rd_Rtype,MuxRd_Sel,WRaddr);
	REG_FILE: register_file_gen
		generic map(Nbit);
		port map(CLK,RST,RF_WR,RF_RD1,RF_RD2,Rs1,Rs2,WB_Addr,OUT1,OUT2,WB_Data);
	MUXIMM: MUX21_GENERIC
		generic map(Nbit);
		port map(Extended16to32,Extended16to?,MuxIMM_Sel,MuxIMM_Out);
	REGA: D_Reg_generic
		generic map(Nbit);
		port map(OUT1,CLK,RST,REG_EN_D,DataA);
	REGB: D_Reg_generic
		generic map(Nbit);
		port map(OUT2,CLK,RST,REG_EN_D,DataB);
	REGIMM: D_Reg_generic	
		generic map(Nbit);
		port map(MuxIMM_Out,CLK,RST,REG_EN_D,DataIMM);
	REGNPC: D_Reg_generic
		generic map(Nbit);
		port map(NPC,CLK,RST,REG_EN_D,NPCOut);
	REGWR: D_Reg_generic
		generic map(OP_REG_SIZE);
		port map(WRaddr,CLK,RST,REG_EN_D,Wr_Addr_D);
		
end Structural;