library ieee;
use ieee.std_logic_1164.all;
use work.mystuff.all;

entity DLX is 
	port(	CLK:	in std_logic;
			RST:	in std_logic);
end DLX;

architecture RTL Of DLX is
	signal DPtoCU_opcode																						: std_logic_vector(OP_CODE_SIZE-1 downto 0);
	signal DPtoCU_func																							: std_logic_vector(FUNC_SIZE-1 downto 0);
	signal CUtoDP_Fpc,CUtoDP_Fnpc,CUtoDP_Fir																	: std_logic;
	signal CUtoDP_Den,CUtoDP_Dr1,CUtoDP_Dr2,CUtoDP_Dwr															: std_logic;
	signal CUtoDP_Een,CUtoDP_Esign,CUtoDP_EaddComp																: std_logic;
	signal CUtoDP_Men,CUtoDP_Fjr,CUtoDP_Fj																		: std_logic;
	signal CUtoDP_Dimm,CUtoDP_Drd,CutoDP_EmuxA,CUtoDP_EmuxB,CUtoDP_EbrCond,CutoDP_Wmux							: std_logic_vector(1 downto 0);
	signal CUtoDP_EaluOp																						: AluOp;
	signal DPtoDM_DataIn,DMtoDP_DataOut																			: std_logic_vector(Nbit-1 downto 0);
	signal DPtoDM_Addr																							: std_logic_vector(DRAM_DEPTH-1 downto 0);
	signal CUtoDM_CS,CUtoDM_RD,CUtoDM_Sign																		: std_logic;
	signal CUtoDM_Width																							: std_logic_vector(1 downto 0);
	signal DPtoIM_Addr																							: std_logic_vector(IRAM_DEPTH-1 downto 0);
	signal IMtoDP_Instr																							: std_logic_vector(Nbit-1 downto 0);

	component Datapath is
		generic(Nbit : 		integer := 32;
				Addr_bit:	integer := 5);
		port (	CLK: 			in	std_logic;
				RST:			in	std_logic;
				Opcode:			out std_logic_vector(OP_CODE_SIZE-1 downto 0); --to CU
				Func:			out std_logic_vector(FUNC_SIZE-1 downto 0); --to CU
				--Fetch Stage
				F_PC_EN:		in	std_logic;
				F_NPC_EN:     	in	std_logic;
				F_IR_EN:      	in	std_logic;
				F_Jr_Sel:		in	std_logic;
				F_J_Sel:		in	std_logic;
				IMem_Instr:		in	std_logic_vector(Nbit-1 downto 0);
				IMem_Addr:		out std_logic_vector(IRAM_DEPTH-1 downto 0);
				--Decode Stage
				D_REG_EN:		in	std_logic;	
				D_RF_RD1:		in	std_logic;
				D_RF_RD2:		in	std_logic;
				D_RF_WR:		in	std_logic;
				D_IMM_Sel:		in	std_logic_vector(1 downto 0);
				D_Rd_Sel:		in	std_logic_vector(1 downto 0);
				--Execution Stage
				E_REG_EN:		in	std_logic;
				E_MuxA_Sel:		in	std_logic_vector(1 downto 0);
				E_MuxB_Sel:		in	std_logic_vector(1 downto 0);
				E_ALU_Conf:		in	std_logic_vector(SelALU-1 downto 0);
				E_Signed:		in	std_logic;
				E_BrCond:		in	std_logic_vector(1 downto 0);
				E_AddrComp:		in	std_logic;
				--Memory Stage
				M_REG_EN:		in	std_logic;
				DMem_DataOut:	in	std_logic_vector(Nbit-1 downto 0);
				DMem_DataIn:	out std_logic_vector(Nbit-1 downto 0);
				DMem_Addr:		out std_logic_vector(DRAM_DEPTH-1 downto 0);
				--Writeback Stage
				WB_Mux_sel:		in	std_logic_vector(1 downto 0));
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
				D_Rd_Sel	: out std_logic_vector(1 downto 0);			-- input selection of write address 00=Itype 01=Rtype 10=31 11=0
				F_Jr_Sel	: out std_logic;								-- first input selection of PC 0=continue 1=JumpR
				-- EXECUTE STAGE OUTPUTS								
				E_REG_EN	: out std_logic;							-- enables the pipeline registers
				E_MuxA_Sel	: out std_logic_vector(1 downto 0);			-- input selection of the first multiplexer 00=NPC 01=A 10='0' 11='-1'
				E_MuxB_Sel	: out std_logic_vector(1 downto 0);			-- input selection of the second multiplexer 00=B 01=IMM 10='0' 11='-1'
				E_ALU_Conf	: out std_logic_vector(SelALU-1 downto 0);	-- alu control word
				E_Signed	: out std_logic;							-- signed operation identifier 0=unsigned 1=signed
				F_J_Sel		: out std_logic;							-- input selection of PC 0=continue 1=Jump
				E_BrCond	: out std_logic_vector(1 downto 0);			-- condition for branching 00,01=noBranch 10=BrZ 11=BrNZ
				E_AddrComp	: out std_logic;							-- needed to deactivate overflow 0=standard calc 1=addr calc
				-- MEMORY STAGE OUTPUTS                         		
				M_REG_EN	: out std_logic;							-- enables the pipeline registers
				DMem_CS		: out std_logic;							-- enables the memory
				DMem_RD		: out std_logic;							-- select read/write mode 1=READ 0=WRITE
				DMem_WS		: out std_logic_vector(1 downto 0);			-- select type of load/store 00=Byte 01=HalfWord 10=Word
				DMem_Sign	: out std_logic;							-- equal to E_signed - needed for data extraction
				-- WRITEBACK STAGE OUTPUTS                      		
				WB_Mux_sel	: out std_logic_vector(1 downto 0);			-- input selection of the multiplexer 00=mem 01=aluout 10=PC+8 11=PC+12
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
	DP: Datapath
		generic map(Nbit,RF_SIZE)
		port map(	CLK 			=> CLK,	
					RST				=> RST,
					Opcode			=> DPtoCU_opcode,
					Func		    => DPtoCU_func,
					F_PC_EN	        => CUtoDP_Fpc,
					F_NPC_EN	    => CUtoDP_Fnpc,
					F_IR_EN	        => CUtoDP_Fir,
					F_Jr_Sel		=> CUtoDP_Fjr,
					F_J_Sel			=> CUtoDP_Fj,
					IMem_Instr	    => IMtoDP_Instr,
					IMem_Addr	    => DPtoIM_Addr,
					D_REG_EN	    => CUtoDP_Den,
					D_RF_RD1	    => CUtoDP_Dr1,
					D_RF_RD2	    => CUtoDP_Dr2,
					D_RF_WR	        => CUtoDP_Dwr,
					D_IMM_Sel	    => CUtoDP_Dimm,
					D_Rd_Sel	    => CUtoDP_Drd,
					E_REG_EN	    => CUtoDP_Een,
					E_MuxA_Sel	    => CutoDP_EmuxA,
					E_MuxB_Sel	    => CUtoDP_EmuxB,
					E_ALU_Conf	    => CUtoDP_EaluOp,
					E_Signed	    => CUtoDP_Esign,
					E_BrCond	    => CUtoDP_EbrCond,
					E_AddrComp	    => CUtoDP_EaddComp,
					M_REG_EN	    => CUtoDP_Men,
					DMem_DataOut	=> DMtoDP_DataOut,
					DMem_DataIn	    => DPtoDM_DataIn,
					DMem_Addr	    => DPtoDM_Addr,
					WB_Mux_sel		=> CutoDP_Wmux);
					
	CU: DLX_CU_HW
		port map(	OPCODE		    => DPtoCU_opcode,
					FUNC		    => DPtoCU_func,
					Clk			    => CLK,
					Rst			    => RST,
					F_PC_EN		    => CUtoDP_Fpc,
					F_NPC_EN	    => CUtoDP_Fnpc,
					F_IR_EN		    => CUtoDP_Fir,
					D_REG_EN	    => CUtoDP_Den,
					D_RF_RD1	    => CUtoDP_Dr1,
					D_RF_RD2	    => CUtoDP_Dr2,
					D_IMM_Sel	    => CUtoDP_Dimm,
					D_Rd_Sel	    => CUtoDP_Drd,
					F_Jr_Sel		=> CUtoDP_Fjr,
					E_REG_EN	    => CUtoDP_Een,
					E_MuxA_Sel	    => CutoDP_EmuxA,
					E_MuxB_Sel	    => CUtoDP_EmuxB,
					E_ALU_Conf	    => CUtoDP_EaluOp,
					E_Signed	    => CUtoDP_Esign,
					F_J_Sel			=> CUtoDP_Fj,
					E_BrCond	    => CUtoDP_EbrCond,
					E_AddrComp	    => CUtoDP_EaddComp,
					M_REG_EN	    => CUtoDP_Men,
					DMem_CS		    => CUtoDM_CS,
					DMem_RD		    => CUtoDM_RD,
					DMem_WS		    => CUtoDM_Width,
					DMem_Sign	    => CUtoDM_Sign,
					WB_Mux_sel	    => CutoDP_Wmux,
					D_RF_WR			=> CUtoDP_Dwr);

	DM: DRAM
		generic map(Nbit,DRAM_DEPTH)
		port map(	Clk				=> CLK,
					Rst_n			=> RST,
					Data_In			=> DPtoDM_DataIn,
					Address			=> DPtoDM_Addr,
					CS				=> CUtoDM_CS,
					RD				=> CUtoDM_RD,
					WS				=> CUtoDM_Width,
					Sign			=> CUtoDM_Sign,
					Data_Out		=> DMtoDP_DataOut);
					
	IM: IRAM
		generic map(IRAM_DEPTH,Nbit)
		port map(	Rst  			=> RST,
					Addr 			=> DPtoIM_Addr,
					Dout 			=> IMtoDP_Instr);
					
end RTL;