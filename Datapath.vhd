library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity Datapath is
	generic(Nbit : 		integer := 32;
			Addr_bit:	integer := 5)
	port (	CLK: 			in	std_logic;
			RST:			in	std_logic;
			Opcode:			out std_logic_vector(OP_CODE_SIZE downto 0); --to CU
			Func:			out std_logic_vector(FUNC_SIZE downto 0); --to CU
			--Fetch Stage
			F_IR_EN:      	in	std_logic;
			F_NPC_EN:     	in	std_logic;
			F_PC_EN:		in	std_logic;
			IMem_Instr:		in	std_logic_vector(Nbit-1 downto 0);
			IMem_Addr:		out std_logic_vector(Nbit-1 downto 0);
			--Decode Stage
			D_RF_RD1:		in	std_logic;
			D_RF_RD2:		in	std_logic;
			D_RF_WR:		in	std_logic;
			D_REG_EN:		in	std_logic;	
			D_IMM_Sel:		in	std_logic;
			D_Rd_Sel:		in	std_logic;
			--Execution Stage
			E_REG_EN:		in	std_logic;
			E_MuxA_Sel:		in	std_logic;
			E_MuxB_Sel:		in	std_logic;
			E_ALU_Conf:		in	AluOp;
			E_BrCond:		in	std_logic_vector(2 downto 0);
			E_Taken:		out std_logic;
			--Memory Stage
			M_REG_EN:		in	std_logic;
			DMem_DataOut:	in	std_logic_vector(Nbit-1 downto 0);
			DMem_DataIn:	out std_logic_vector(Nbit-1 downto 0);
			DMem_Addr:		out std_logic_vector(Nbit-1 downto 0);
			--Writeback Stage
			WB_Mux_sel:		in	std_logic);
end Datapath;
            	
architecture Structural of Datapath is
	signal FtoD_NPC,FtoD_instr									: std_logic_vector(Nbit-1 downto 0);
	signal DtoE_NPC,DtoE_DataA,DtoE_DataB,DtoE_imm				: std_logic_vector(Nbit-1 downto 0);
	signal EtoM_DataALU,EtoM_DataB								: std_logic_vector(Nbit-1 downto 0);
	signal MtoW_DataMem,MtoW_DataALU							: std_logic_vector(Nbit-1 downto 0);
	signal WtoD_WRdata											: std_logic_vector(Nbit-1 downto 0);
	signal DtoE_WRaddr,EtoM_WRaddr,MtoD_WRaddr					: std_logic_vector(Addr_bit-1 downto 0);
	
	component FetchUnit is
		generic(Nbit: integer := 32);
		port(	CLK: 			in	std_logic;
				RST:			in	std_logic;
				IR_EN:      	in	std_logic;
				NPC_EN:     	in	std_logic;
				PC_EN:			in	std_logic;
				--AddIn_Mux:		in	std_logic_vector(Nbit-1 downto 0);
				IMem_Instr:		in	std_logic_vector(Nbit-1 downto 0);
				InstrToDecode:	out std_logic_vector(Nbit-1 downto 0);
				NPCToDecode:	out std_logic_vector(Nbit-1 downto 0);			
				IMem_Addr:		out std_logic_vector(Nbit-1 downto 0);
				Opcode:			out std_logic_vector(OP_CODE_SIZE downto 0);
				Func:			out std_logic_vector(FUNC_SIZE downto 0));
	end component;
	
	component DecodeUnit is
		generic(Nbit:		integer := 32;
				Addr_bit:	integer := 10);
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
				WB_Addr:		in	std_logic_vector(Addr_bit-1 downto 0);
				DataA:			out std_logic_vector(Nbit-1 downto 0);
				DataB:			out std_logic_vector(Nbit-1 downto 0);
				DataIMM:		out std_logic_vector(Nbit-1 downto 0);
				NPCOut:			out std_logic_vector(Nbit-1 downto 0);
				Wr_Addr_D:		out std_logic_vector(Addr_bit-1 downto 0));
	end component;
	
	component ExecutionUnit is 
		generic(Nbit:		integer := 32;
				Addr_bit:	integer := 10);
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
				Wr_Addr_D:		in	std_logic_vector(Addr_bit-1 downto 0);
				ALU_Out:		out std_logic_vector(Nbit-1 downto 0);	
				DataBtoDMem:	out std_logic_vector(Nbit-1 downto 0);
				Wr_Addr_E:		out std_logic_vector(Addr_bit-1 downto 0);	
				Taken:			out std_logic);
	end component;
	
	component MemoryUnit is
		generic(Nbit:		integer := 32;
				Addr_bit:	integer := 10);
		port(	CLK: 			in	std_logic;
				RST:			in	std_logic;
				REG_EN_M:		in	std_logic;
				--Branch_taken:	in	std_logic;
				DataIn_DMem:	in	std_logic_vector(Nbit-1 downto 0);
				DataIn_ALU:		in	std_logic_vector(Nbit-1 downto 0);
				DataIn_RegB:	in	std_logic_vector(Nbit-1 downto 0);
				WR_Addr_E:		in	std_logic_vector(Addr_bit-1 downto 0);
				DataOut_Load:	out std_logic_vector(Nbit-1 downto 0);
				DataOut_Branch:	out std_logic_vector(Nbit-1 downto 0);
				WB_Address:		out std_logic_vector(Addr_bit-1 downto 0);
				DataOut_Store:	out std_logic_vector(Nbit-1 downto 0);
				Addr_DMem:		out	std_logic_vector(Nbit-1 downto 0));	
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
		generic map(Nbit)
		port map(	CLK 			=> CLK,
					RST				=> RST,
					IR_EN      		=> F_IR_EN,
					NPC_EN     		=> F_NPC_EN,
					PC_EN			=> F_PC_EN,
					IMem_Instr		=> IMem_Instr,
					InstrToDecode	=> FtoD_instr,
					NPCToDecode		=> FtoD_NPC,
					IMem_Addr		=> IMem_Addr,
					Opcode			=> Opcode,
					Func			=> Func);
				 
	DU: DecodeUnit
		generic map(Nbit, Addr_bit)
		port map(	CLK				=> CLK,
		            RST				=> RST,
		            RF_RD1			=> D_RF_RD1,
		            RF_RD2			=> D_RF_RD2,
		            RF_WR			=> D_RF_WR,
		            REG_EN_D		=> D_REG_EN,
		            MuxIMM_Sel		=> D_IMM_Sel,
		            MuxRd_Sel		=> MuxRd_Sel,
		            InstrToDecode	=> FtoD_instr,
		            NPC	 			=> FtoD_NPC,
		            WB_Data			=> WtoD_WRdata,
		            WB_Addr			=> MtoD_WRaddr,
		            DataA			=> DtoE_DataA,
		            DataB			=> DtoE_DataB,
		            DataIMM			=> DtoE_imm,
		            NPCOut			=> DtoE_NPC,
		            Wr_Addr_D		=> DtoE_WRaddr);
					
	EXU: ExecutionUnit
		generic map(Nbit, Addr_bit)
		port map(	CLK				=> CLK,
		            RST	    		=> RST,
		            REG_EN_E		=> E_REG_EN,
		            MuxA_Sel		=> E_MuxA_Sel,
		            MuxB_Sel		=> E_MuxB_Sel,
		            ALU_Config		=> E_ALU_Conf,
		            Condition		=> E_BrCond,
		            NPC_In:			=> DtoE_NPC,
		            DataA			=> DtoE_DataA,
		            DataB			=> DtoE_DataB,
		            DataIMM			=> DtoE_imm,
		            Wr_Addr_D		=> DtoE_WRaddr,
		            ALU_Out			=> EtoM_DataALU,
		            DataBtoDMem		=> EtoM_DataB,
		            Wr_Addr_E		=> EtoM_WRaddr,
		            Taken			=> E_Taken);
					
	MEMU: MemoryUnit
		generic map(Nbit, Addr_bit)
		port map(	CLK 			=> CLK,
		            RST				=> RST,
		            REG_EN_M		=> M_REG_EN,
		            DataIn_DMem		=> DMem_DataOut,
		            DataIn_ALU		=> EtoM_DataALU,
		            DataIn_RegB		=> EtoM_DataB,
		            WR_Addr_E		=> EtoM_WRaddr,
		            DataOut_Load	=> MtoW_DataMem,
		            DataOut_Branch	=> MtoW_DataALU,
		            WB_Address		=> MtoD_WRaddr,
		            DataOut_Store	=> DMem_DataIn,
		            Addr_DMem		=> DMem_Addr);
					
	WBU: WritebackUnit
		generic map(Nbit)
		port map(	CLK				=> CLK,
		            RST				=> RST,
		            WBMux_sel		=> WB_Mux_sel,
		            DataIn_DMem		=> MtoW_DataMem,
		            DataIn_ALU		=> MtoW_DataALU,
		            WB_DataOut		=> WtoD_WRdata);
				
end Structural;
