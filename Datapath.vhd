library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity Datapath is
	generic ( Nbit : integer := 32)
	port (		CLK: 				in std_logic;
				RST:				in std_logic;
				IR_EN:      		in std_logic;
				NPC_EN:     		in std_logic;
				PC_EN:				in std_logic;
				DataIn_IMem
				RF_RD1:			in std_logic;
				RF_RD2:			in std_logic;
				RF_WR:			in std_logic;
				REG_EN_DEC:			in std_logic;
				MuxIMM_Sel:		in std_logic;
				REG_EN_EX:			in std_logic;
				MuxA_Sel:		in std_logic;
				MuxB_Sel:		in std_logic;
				ALU_Config:		in AluOp;
				Condition:		in std_logic_vector(2 downto 0);				
				MEM_EN:			in std_logic;
				MEM_RD_WRn:		in std_logic;
				WB_EN:			in std_logic;
				WBMux_sel:		in std_logic;
				);
	
end Datapath;
            	
architecture Structural of Datapath is
	
	component FetchUnit is
		generic(Nbit: integer := 32);
		port(	CLK: 				in std_logic;
				RST:				in std_logic;
				IR_EN:      		in std_logic;
				NPC_EN:     		in std_logic;
				PC_EN:				in std_logic;
				DataIn_IMem:		in std_logic_vector(Nbit-1 downto 0);
				Branch_Taken_Add:	in std_logic_vector(Nbit-1 downto 0);
				PCDataOut_IMem:		out std_logic_vector(Nbit-1 downto 0);
				InstrToDecode:		out std_logic_vector(Nbit-1 downto 0);
				NPCToDecode: 		out std_logic_vector(Nbit-1 downto 0));
	end component;
	
	component DecodeUnit is
		generic();
		port(	CLK:			in std_logic;
				RST:			in std_logic;
				RF_RD1:			in std_logic;
				RF_RD2:			in std_logic;
				RF_WR:			in std_logic;
				REG_EN:			in std_logic;	
				MuxIMM_Sel:		in std_logic;
				PCDataOut_IMem:	in std_logic_vector(Nbit-1 downto 0);				
				InstrToDecode:	in std_logic_vector(Nbit-1 downto 0);
				NPC:		 	in std_logic_vector(Nbit-1 downto 0);
				DataA:			out std_logic_vector(Nbit-1 downto 0);
				DataB:			out std_logic_vector(Nbit-1 downto 0);
				DataIMM:		out std_logic_vector(Nbit-1 downto 0);
				NPCOut:			out std_logic_vector(Nbit-1 downto 0);
				PCOut:			out std_logic_vector(Nbit-1 downto 0);
				Opcode:			out std_logic_vector(5 downto 0);
				Func:			out std_logic_vector(10 downto 0));
	end component;
	
	component ExecutionUnit is 
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
	end component;
	
	component MemoryUnit 
		generic(Nbit: integer := 32);
		port(	CLK: 			in std_logic;
				RST:			in std_logic;
				MEM_EN:			in std_logic;
				MEM_RD_WRn:		in std_logic;
				DataIn_ALU:		in std_logic_vector(Nbit-1 downto 0);
				DataIn_DMem:	in std_logic_vector(Nbit-1 downto 0);
				Add_DMem:		out	std_logic_vector(Nbit-1 downto 0);
				DataOut_ALU:	out std_logic_vector(Nbit-1 downto 0);
				DataOut_DMem:	out std_logic_vector(Nbit-1 downto 0));	
	end component;
	
	
	component WritebackUnit is 
		generic(Nbit: integer := 32);
		port(	CLK:			in std_logic;
				RST:			in std_logic;
				WB_EN:			in std_logic;
				WBMux_sel:		in std_logic;
				DataIn_DMem:	in std_logic_vector(Nbit-1);
				DataIn_ALU:		in std_logic_vector(Nbit-1);
				WB_DataOut:		out std_logic_vector(Nbit-1));			
	end component;
	
begin
	FU: FetchUnit
		port map(CLK,RST,IR_EN,NPC_EN,PC_EN,DataIn_IMem,Branch_Taken_Add,InstrToDecode,NPCToDecode);
	DU: DecodeUnit
		port map(CLK,RST,RF_RD1,RF_RD2,RF_WR,REG_EN_DEC,MuxIMM_Sel,PCDataOut_IMem,InstrToDecode,NPCToDecode,DataA,DataB,DataIMM,NPC_In,PC,Opcode,Func);
	EXU: ExecutionUnit
		port map(CLK,RST,REG_EN_EX,MuxA_Sel,MuxB_Sel,ALU_Config,Condition,NPC_In,DataA,DataA,DataIMM,NPCOut,ALU_Out,DataBtoDMem,Taken);
	MEMU: MemoryUnit
		port map(CLK,RST,MEM_EN,MEM_RD_WRn,ALU_Out,DataBtoDMem,Add_DMem,DataOut_ALU,DataOut_DMem);
	WBU:
		port map(CLK,RST,WB_EN,WBMux_sel,DataOut_DMem,DataOut_ALU,WB_DataOut)
		
		
end Structural;
