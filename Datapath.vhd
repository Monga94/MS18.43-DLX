library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity Datapath is
	generic (Nbit : integer := 32)
	port (	CLK: 			in std_logic;
			RST:			in std_logic;
			Opcode:			out std_logic_vector(5 downto 0); --to CU
			Func:			out std_logic_vector(10 downto 0)); --to CU
			--Fetch Stage
			IR_EN:      	in std_logic;
			NPC_EN:     	in std_logic;
			PC_EN:			in std_logic;
			IMemToIR_Data:	in std_logic_vector(Nbit-1 downto 0);
			PCToIMem_Add:	out std_logic_vector(Nbit-1 downto 0);
			--Decode Stage
			RF_RD1:			in std_logic;
			RF_RD2:			in std_logic;
			RF_WR:			in std_logic;
			REG_EN_DEC:		in std_logic;
			MuxIMM_Sel:		in std_logic;
			--Execution Stage
			REG_EN_EX:		in std_logic;
			MuxA_Sel:		in std_logic;
			MuxB_Sel:		in std_logic;
			ALU_Config:		in AluOp;
			Condition:		in std_logic_vector(2 downto 0);
			--Memory Stage
			LMD_EN:			in std_logic;
			
			DMemToLMD:		in std_logic_vector(Nbit-1 downto 0);
			BRegToDMem:		out std_logic_vector(Nbit-1 downto 0);
			--Writeback Stage
			WB_EN:			in std_logic;
			WBMux_sel:		in std_logic);
end Datapath;
            	
architecture Structural of Datapath is
	
	component FetchUnit is
		generic(Nbit: integer := 32);
		port(	CLK: 				in std_logic;
				RST:				in std_logic;
				IR_EN:      		in std_logic;
				NPC_EN:     		in std_logic;
				PC_EN:				in std_logic;
				IMemToIR_Data:		in std_logic_vector(Nbit-1 downto 0);
				Branch_Taken_Add:	in std_logic_vector(Nbit-1 downto 0);
				PCToIMem_Add:		out std_logic_vector(Nbit-1 downto 0);
				InstrToDecode:		out std_logic_vector(Nbit-1 downto 0);
				NPCToDecode: 		out std_logic_vector(Nbit-1 downto 0));
	end component;
	
	component DecodeUnit is
		generic(Nbit: integer := 32);
		port(	CLK:			in std_logic;
				RST:			in std_logic;
				RF_RD1:			in std_logic;
				RF_RD2:			in std_logic;
				RF_WR:			in std_logic;
				REG_EN:			in std_logic;	
				MuxIMM_Sel:		in std_logic;			
				InstrToDecode:	in std_logic_vector(Nbit-1 downto 0);
				WB_Address:		in std_logic_vector(4 downto 0);
				NPC:		 	in std_logic_vector(Nbit-1 downto 0); --from fetch
				DataA:			out std_logic_vector(Nbit-1 downto 0);
				DataB:			out std_logic_vector(Nbit-1 downto 0);
				DataIMM:		out std_logic_vector(Nbit-1 downto 0);
				NPCOut:			out std_logic_vector(Nbit-1 downto 0); --to exec
				PCOut:			out std_logic_vector(Nbit-1 downto 0);
				Opcode:			out std_logic_vector(5 downto 0); --to CU
				Func:			out std_logic_vector(10 downto 0)); --to CU
	end component;
	
	component ExecutionUnit is 
		generic(Nbit: integer := 32);
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
				DataBtoMemU:	out std_logic_vector(Nbit-1 downto 0);	
				Taken:			out std_logic;
	end component;
	
	entity MemoryUnit 
	generic(Nbit: integer := 32);
	port(	CLK: 			in std_logic;
			RST:			in std_logic;
			LMD_EN:			in std_logic;
			Branch_taken:	in std_logic;
			DataIn_ALU:		in std_logic_vector(Nbit-1 downto 0);
			DataIn_DMem:	in std_logic_vector(Nbit-1 downto 0);
			DataIn_RegB:	in std_logic_vector(Nbit-1 downto 0);
			Add_DMem:		out	std_logic_vector(Nbit-1 downto 0);
			DataOut_Branch:	out std_logic_vector(Nbit-1 downto 0);
			DataOut_Load:	out std_logic_vector(Nbit-1 downto 0);
			DataOut_Store:	out std_logic_vector(Nbit-1 downto 0));	
end MemoryUnit;
	
	component WritebackUnit is 
		generic(Nbit: integer := 32);
		port(	CLK:			in std_logic;
				RST:			in std_logic;
				WB_EN:			in std_logic;
				WBMux_sel:		in std_logic;
				DataIn_DMem:	in std_logic_vector(Nbit-1);
				DataIn_ALU:		in std_logic_vector(Nbit-1);
				WB_DataOut:		out std_logic_vector(Nbit-1);
				WB_Address:		out std_logic_vector(4 downto 0);			
	end component;
	
begin
	FU: FetchUnit
		port map(CLK,RST,IR_EN,NPC_EN,PC_EN,IMemToIR_Data,Branch_Taken_Add,PCToIMem_Add,InstrToDecode,NPCToDecode);
	DU: DecodeUnit
		port map(CLK,RST,RF_RD1,RF_RD2,RF_WR,REG_EN_DEC,MuxIMM_Sel,InstrToDecode,WB_Address,NPCToDecode,DataA,DataB,DataIMM,NPCToExec,PC,Opcode,Func);
	EXU: ExecutionUnit
		port map(CLK,RST,REG_EN_EX,MuxA_Sel,MuxB_Sel,ALU_Config,Condition,NPCToExec,DataA,DataA,DataIMM,NPCToMem,ALU_Out,DataBtoMemU,Branch_taken);
	MEMU: MemoryUnit
		port map(CLK,RST,LMD_EN,Branch_taken,ALU_Out,DataBtoMemU,Add_DMem,DataOut_ALU,BRegToDMem);
	WBU:
		port map(CLK,RST,WB_EN,WBMux_sel,DataOut_DMem,DataOut_ALU,WB_DataOut,WB_Address)
				
end Structural;
