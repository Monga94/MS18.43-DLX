library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity Datapath is
	generic (Nbit : integer := 32)
	port (	CLK: 			in	std_logic;
			RST:			in	std_logic;
			Opcode:			out std_logic_vector(5 downto 0); --to CU
			Func:			out std_logic_vector(10 downto 0); --to CU
			--Fetch Stage
			IR_EN:      	in	std_logic;
			NPC_EN:     	in	std_logic;
			PC_EN:			in	std_logic;
			IMem_Instr:		in	std_logic_vector(Nbit-1 downto 0);
			IMem_Addr:		out std_logic_vector(Nbit-1 downto 0);
			--Decode Stage
			RF_RD1:			in	std_logic;
			RF_RD2:			in	std_logic;
			RF_WR:			in	std_logic;
			REG_EN_D:		in	std_logic;	
			MuxIMM_Sel:		in	std_logic;
			MuxRd_Sel:		in	std_logic;
			--Execution Stage
			REG_EN_E:		in	std_logic;
			MuxA_Sel:		in	std_logic;
			MuxB_Sel:		in	std_logic;
			ALU_Config:		in	AluOp;
			Condition:		in	std_logic_vector(2 downto 0);
			Taken:			out std_logic;
			--Memory Stage
			REG_EN_M:		in	std_logic;
			DMemToLMD:		in	std_logic_vector(Nbit-1 downto 0);
			Addr_DMem:		out std_logic_vector(Nbit-1 downto 0);
			BRegToDMem:		out std_logic_vector(Nbit-1 downto 0);
			--Writeback Stage
			WBMux_sel:		in	std_logic);
end Datapath;
            	
architecture Structural of Datapath is
	
	component FetchUnit is
		generic(Nbit: integer := 32);
		port(	CLK: 			in	std_logic;
				RST:			in	std_logic;
				IR_EN:      	in	std_logic;
				NPC_EN:     	in	std_logic;
				PC_EN:			in	std_logic;
				--AddIn_Mux:		in	std_logic_vector(Nbit-1 downto 0);
				IMem_Instr:		in	std_logic_vector(Nbit-1 downto 0);			
				IMem_Addr:		out std_logic_vector(Nbit-1 downto 0);
				InstrToDecode:	out std_logic_vector(Nbit-1 downto 0);
				NPCToDecode:	out std_logic_vector(Nbit-1 downto 0);
				Opcode:			out std_logic_vector(5 downto 0);
				Func:			out std_logic_vector(10 downto 0));
	end component;
	
	component DecodeUnit is
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
	end component;
	
	component ExecutionUnit is 
		generic(Nbit: integer := 32);
		port(	CLK:			in	std_logic;
				RST:		    in	std_logic;
				REG_EN_E:		in	std_logic;
				MuxA_Sel:		in	std_logic;
				MuxB_Sel:		in	std_logic;
				ALU_Config:		in	AluOp;
				Condition:		in	std_logic_vector(2 downto 0);
				NPC_In:		    in	std_logic_vector(Nbit-1 downto 0);
				DataA:			in	std_logic_vector(Nbit-1 downto 0);
				DataB:		    in	std_logic_vector(Nbit-1 downto 0);
				DataIMM:		in	std_logic_vector(Nbit-1 downto 0);
				Wr_Addr_D		in	std_logic_vector(OP_REG_SIZE-1 downto 0);
				NPCOut:			out std_logic_vector(Nbit-1 downto 0);
				ALU_Out:		out std_logic_vector(Nbit-1 downto 0);	
				DataBtoDMem:	out std_logic_vector(Nbit-1 downto 0);
				Wr_Addr_E:		out std_logic_vector(OP_REG_SIZE-1 downto 0);	
				Taken:			out std_logic);
	end component;
	
	component MemoryUnit is
		generic(Nbit: integer := 32);
		port(	CLK: 			in	std_logic;
				RST:			in	std_logic;
				REG_EN_M:		in	std_logic;
				--Branch_taken:	in	std_logic;
				DataIn_ALU:		in	std_logic_vector(Nbit-1 downto 0);
				DataIn_DMem:	in	std_logic_vector(Nbit-1 downto 0);
				DataIn_RegB:	in	std_logic_vector(Nbit-1 downto 0);
				WR_Addr_E:		out std_logic_vector(OP_REG_SIZE-1 downto 0);
				Addr_DMem:		out	std_logic_vector(Nbit-1 downto 0);
				DataOut_Branch:	out std_logic_vector(Nbit-1 downto 0);
				DataOut_Load:	out std_logic_vector(Nbit-1 downto 0);
				DataOut_Store:	out std_logic_vector(Nbit-1 downto 0);
				WB_Address:		out std_logic_vector(OP_REG_SIZE-1 downto 0));	
	end component;
	
	component WritebackUnit is 
		generic(Nbit: integer := 32);
		port(	CLK:			in	std_logic;
				RST:			in	std_logic;
				WBMux_sel:		in	std_logic;
				DataIn_DMem:	in	std_logic_vector(Nbit-1);
				DataIn_ALU:		in	std_logic_vector(Nbit-1);
				WB_DataOut:		out std_logic_vector(Nbit-1));			
	end component;
	
begin
	FU: FetchUnit
		port map(CLK,RST,IR_EN,NPC_EN,PC_EN,IMemToIR_Data,Branch_Taken_Add,PCToIMem_Add,InstrToDecode,NPCToDecode,Opcode,Func);
	DU: DecodeUnit
		port map(CLK,RST,RF_RD1,RF_RD2,RF_WR,REG_EN_DEC,MuxIMM_Sel,MuxRd_Sel,InstrToDecode,NPCToDecode,WB_DataOut,WB_Address,DataA,DataB,DataIMM,NPCToExec,WR_Addr_DtoE);
	EXU: ExecutionUnit
		port map(CLK,RST,REG_EN_EX,MuxA_Sel,MuxB_Sel,ALU_Config,Condition,NPCToExec,DataA,DataA,DataIMM,WR_Addr_DtoE,NPCToMem,ALU_Out,DataBtoDMem,WR_Addr_EtoM,Branch_taken);
	MEMU: MemoryUnit
		port map(CLK,RST,REG_EN_M,Branch_taken,ALU_Out,DMemToLMD,DataBtoDMem,WR_Addr_EtoM,Addr_DMem,DataOut_ALU,BRegToDMem,WB_Address);
	WBU:
		port map(CLK,RST,WBMux_sel,DataOut_DMem,DataOut_ALU,WB_DataOut)
				
end Structural;
