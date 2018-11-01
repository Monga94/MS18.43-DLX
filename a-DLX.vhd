library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity DLX is 
	port(	CLK:	in std_logic;
			RST:	in std_logic);
end DLX;

architecture RTL Of DLX is

	component Datapath is
		generic(Nbit : 		integer := 32;
				Addr_bit:	integer := 5)
		port (	CLK: 			in	std_logic;
				RST:			in	std_logic;
				Opcode:			out std_logic_vector(OP_CODE_SIZE-1 downto 0); --to CU
				Func:			out std_logic_vector(FUNC_SIZE-1 downto 0); --to CU
				--Fetch Stage
				F_PC_EN:		in	std_logic;
				F_NPC_EN:     	in	std_logic;
				F_IR_EN:      	in	std_logic;
				IMem_Instr:		in	std_logic_vector(Nbit-1 downto 0);
				IMem_Addr:		out std_logic_vector(Nbit-1 downto 0);
				--Decode Stage
				D_REG_EN:		in	std_logic;	
				D_RF_RD1:		in	std_logic;
				D_RF_RD2:		in	std_logic;
				D_RF_WR:		in	std_logic;
				D_IMM_Sel:		in	std_logic_vector(1 downto 0);
				D_Rd_Sel:		in	std_logic;
				--Execution Stage
				E_REG_EN:		in	std_logic;
				E_MuxA_Sel:		in	std_logic_vector(1 downto 0);
				E_MuxB_Sel:		in	std_logic;
				E_ALU_Conf:		in	AluOp;
				E_Signed:		in	std_logic;
				--E_BrCond:		in	std_logic_vector(2 downto 0);
				--E_Taken:		out std_logic;
				--Memory Stage
				M_REG_EN:		in	std_logic;
				DMem_DataOut:	in	std_logic_vector(Nbit-1 downto 0);
				DMem_DataIn:	out std_logic_vector(Nbit-1 downto 0);
				DMem_Addr:		out std_logic_vector(Nbit-1 downto 0);
				--Writeback Stage
				WB_Mux_sel:		in	std_logic);
	end component;

	component DLX_CU_HW is 
		port(	-- INPUTS
				OPCODE		: in  std_logic_vector(OP_CODE_SIZE-1 downto 0);
				FUNC		: in  std_logic_vector(FUNC_SIZE-1 downto 0);              
				Clk			: in  std_logic;
				Rst			: in  std_logic;							-- Active Low
				-- FETCH STAGE OUTPUTS                          		
				F_PC_EN		: out std_logic;							-- enables the PC register
				F_NPC_EN	: out std_logic;							-- enables the NPC register
				F_IR_EN		: out std_logic;							-- enables the instruction register
				-- DECODE STAGE OUTPUTS                         		
				D_REG_EN	: out std_logic;							-- enables the register file and the pipeline registers
				D_RF_RD1	: out std_logic;							-- enables the read port 1 of the register file
				D_RF_RD2	: out std_logic;							-- enables the read port 2 of the register file
				D_IMM_Sel	: out std_logic_vector(1 downto 0);			-- input selection of immediate type 00=uimm16 01=imm16 10=lhi_config 11=imm26
				D_Rd_Sel	: out std_logic;							-- input selection of write address 0=Itype 1=Rtype
				-- EXECUTE STAGE OUTPUTS								
				E_REG_EN	: out std_logic;							-- enables the pipeline registers
				E_MuxA_Sel	: out std_logic_vector(1 downto 0);			-- input selection of the first multiplexer 00=NPC 01=A 10='0' 11='-1'
				E_MuxB_Sel	: out std_logic;							-- input selection of the second multiplexer 0=B 1=IMM
				E_ALU_Conf	: out std_logic_vector(SelALU-1 downto 0);	-- alu control word
				E_Signed	: out std_logic;							-- signed operation identifier 0=unsigned 1=signed
				--E_BrCond	: out std_logic_vector(2 downto 0);			-- condition for branching and jumping
				-- MEMORY STAGE OUTPUTS                         		
				M_REG_EN	: out std_logic;							-- enables the pipeline registers
				DMem_CS		: out std_logic;							-- enables the memory
				DMem_RD		: out std_logic;							-- select read/write mode 1=READ 0=WRITE
				DMem_WS		: out std_logic_vector(1 downto 0)			-- select type of load/store 00=Byte 01=HalfWord 10=Word
				DMem_Sign	: out std_logic								-- equal to E_signed - needed for data extraction
				-- WRITEBACK STAGE OUTPUTS                      		
				WB_Mux_sel	: out std_logic;							-- input selection of the multiplexer 0=mem 1=aluout
				D_RF_WR		: out std_logic);							-- enables the write port of the register file
	end component;

	component DRAM is
		generic (	W: integer:=8;
					D: integer:=10);
		port (	Clk			: in	std_logic;
				Rst_n		: in	std_logic;
				Data_In		: in	std_logic_vector(W-1 downto 0);
				Address		: in	std_logic_vector(D-1 downto 0);
				CS			: in	std_logic;
				RD			: in	std_logic;
				WS			: in	std_logic_vector(1 downto 0);
				Sign		: in	std_logic;
				Data_Out	: out	std_logic_vector(W-1 downto 0));
	end component;

	component IRAM is
		generic (	RAM_DEPTH	: integer := 48;
					I_SIZE		: integer := 32);
		port (	Rst  : in  std_logic;
				Addr : in  std_logic_vector(RAM_DEPTH - 1 downto 0);
				Dout : out std_logic_vector(I_SIZE - 1 downto 0));
	end component;

begin
	DATAPATH: Datapath
		generic map(Nbit,RF_SIZE);
		port map(CLK,RST,IR_EN,NPC_EN,PC_EN,IMemToIR_Data,RF_RD1,RF_RD2,REG_EN_DEC,)
	IRAM: IRAM
		generic map(IRAM_DEPTH,Nbit);
		port map(RST,PCToIMem,IMemToIR_Data);
	DRAM: DRAM
		generic map(Nbit,DRAM_DEPTH);
		port map(DP_DMem,DRamAddress,DMem_DP);






end RTL;