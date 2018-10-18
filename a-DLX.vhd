library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity DLX is 
	generic(); --?
	port(	CLK:	in std_logic;
			RST:	in std_logic);
end DLX;

architecture RTL Of DLX is

	component Datapath is
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
	end component;

	component DLX_CU_HardWired is 
		port(	-- INPUTS
				OPCODE		: in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
				FUNC		: in  std_logic_vector(FUNC_SIZE - 1 downto 0);              
				Clk			: in  std_logic;
				Rst			: in  std_logic;					-- Active Low
				-- FETCH STAGE OUTPUTS
				IR_EN		: out std_logic;					-- enables the instruction register
				NPC_EN		: out std_logic;					-- enables the NPC register
				-- DECODE STAGE OUTPUTS
				DEC_EN		: out std_logic;					-- enables the register file and the pipeline registers
				RF_RD1		: out std_logic;					-- enables the read port 1 of the register file
				RF_RD2		: out std_logic;					-- enables the read port 2 of the register file
				-- EXECUTE STAGE OUTPUTS						
				EXEC_EN		: out std_logic;					-- enables the pipe registers
				MuxA_Sel	: out std_logic;					-- input selection of the first multiplexer 0=A 1=INP1
				MuxB_Sel	: out std_logic;					-- input selection of the second multiplexer 1=B 0=INP2
				Alu_Sel		: out AluOp;						-- alu control bit
				-- MEMORY STAGE OUTPUTS
				MEM_EN		: out std_logic;					-- enables the memory and the pipeline registers
				MEM_RD		: out std_logic;					-- enables the read-out of the memory
				MEM_WR		: out std_logic;					-- enables the write-in of the memory
				-- WRITEBACK STAGE OUTPUTS
				WB_Sel		: out std_logic;					-- input selection of the multiplexer 1=mem 0=aluout
				RF_WR		: out std_logic);					-- enables the write port of the register file
	end component;

	component DRAM is
		generic (	B: integer:=8;
					L: integer:=10);
		port (	Data_In		: in	std_logic_vector(B-1 downto 0);
				address		: in	std_logic_vector(L-1 downto 0);
				rd			: in	std_logic;
				cs			: in	std_logic;
				data_out	: out	std_logic_vector(B-1 downto 0));
	end component;

	component IRAM is
		generic (	RAM_DEPTH	: integer := 48;
					I_SIZE		: integer := 32);
		port (	Rst  : in  std_logic;
				Addr : in  std_logic_vector(log2_N(RAM_DEPTH) - 1 downto 0);
				Dout : out std_logic_vector(I_SIZE - 1 downto 0));
	end component;

begin
	DATAPATH: Datapath
		generic map(32);
		port map(CLK,RST,IR_EN,NPC_EN,PC_EN,IMemToIR_Data,RF_RD1,RF_RD2,REG_EN_DEC,)
	IRAM: IRAM
		generic map();
		port map(RST,PCToIMem,IMemToIR_Data);
	DRAM: DRAM
		generic map();
		port map(DP_DMem,DRamAddress,DMem_DP);






end RTL;