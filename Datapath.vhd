library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity Datapath is
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
			IMem_Addr:		out std_logic_vector(IRAM_DEPTH+1 downto 0);
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
end Datapath;
            	
architecture Structural of Datapath is
	signal FtoD_NPC,FtoD_instr									: std_logic_vector(Nbit-1 downto 0);
	signal DtoE_NPC,DtoE_DataA,DtoE_DataB,DtoE_imm				: std_logic_vector(Nbit-1 downto 0);
	signal EtoM_DataALU,EtoM_DataB								: std_logic_vector(Nbit-1 downto 0);
	signal MtoW_DataMem,MtoW_DataALU							: std_logic_vector(Nbit-1 downto 0);
	signal WtoD_WRdata											: std_logic_vector(Nbit-1 downto 0);
	signal DtoE_WRaddr,EtoM_WRaddr,MtoD_WRaddr					: std_logic_vector(Addr_bit-1 downto 0);
	signal DtoF_Jraddr,EtoF_Jaddr,EtoW_NPC						: std_logic_vector(Nbit-1 downto 0);
	signal EtoF_Br_taken										: std_logic;
	
	component FetchUnit is
		generic(Nbit:		integer := 32;
				Iram_bit:	integer := 12);
		port(	CLK: 			in	std_logic;
				RST:			in	std_logic;
				IR_EN:      	in	std_logic;
				NPC_EN:     	in	std_logic;
				PC_EN:			in	std_logic;
				Jr_Sel:			in	std_logic;
				J_Sel:			in	std_logic;
				Br_taken:		in	std_logic;
				Jr_addr:		in	std_logic_vector(Iram_bit-1 downto 0);
				J_addr:			in	std_logic_vector(Iram_bit-1 downto 0);
				IMem_Instr:		in	std_logic_vector(Nbit-1 downto 0);
				InstrToDecode:	out std_logic_vector(Nbit-1 downto 0);
				NPCToDecode:	out std_logic_vector(Nbit-1 downto 0);			
				IMem_Addr:		out std_logic_vector(Iram_bit-1 downto 0);
				Opcode:			out std_logic_vector(OP_CODE_SIZE-1 downto 0);
				Func:			out std_logic_vector(FUNC_SIZE-1 downto 0));
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
				MuxIMM_Sel:		in	std_logic_vector(1 downto 0);
				MuxRd_Sel:		in	std_logic_vector(1 downto 0);
				InstrToDecode:	in	std_logic_vector(Nbit-1 downto 0);
				NPCin:		 	in	std_logic_vector(Nbit-1 downto 0);
				WB_Data:		in	std_logic_vector(Nbit-1 downto 0);
				WB_Addr:		in	std_logic_vector(Addr_bit-1 downto 0);
				DataA:			out std_logic_vector(Nbit-1 downto 0);
				DataB:			out std_logic_vector(Nbit-1 downto 0);
				DataIMM:		out std_logic_vector(Nbit-1 downto 0);
				NPCOut:			out std_logic_vector(Nbit-1 downto 0);
				Jr_addr:		out std_logic_vector(Nbit-1 downto 0);
				Wr_Addr_D:		out std_logic_vector(Addr_bit-1 downto 0));
	end component;
	
	component ExecutionUnit is 
		generic(Nbit:		integer := 32;
				Addr_bit:	integer := 10);
		port(	CLK:			in	std_logic;
				RST:		    in	std_logic;
				REG_EN_E:		in	std_logic;
				MuxA_Sel:		in	std_logic_vector(1 downto 0);
				MuxB_Sel:		in	std_logic_vector(1 downto 0);
				ALU_Config:		in	std_logic_vector(SelALU-1 downto 0);
				Sign:			in	std_logic;
				BrCond:			in	std_logic_vector(1 downto 0);
				AddrComp:		in	std_logic;
				NPC_In:		    in	std_logic_vector(Nbit-1 downto 0);
				DataA:			in	std_logic_vector(Nbit-1 downto 0);
				DataB:		    in	std_logic_vector(Nbit-1 downto 0);
				DataIMM:		in	std_logic_vector(Nbit-1 downto 0);
				Wr_Addr_D:		in	std_logic_vector(Addr_bit-1 downto 0);
				NPC_Out:		out std_logic_vector(Nbit-1 downto 0);
				ALU_Out:		out std_logic_vector(Nbit-1 downto 0);	
				DataBtoDMem:	out std_logic_vector(Nbit-1 downto 0);
				J_addr:			out std_logic_vector(Nbit-1 downto 0);
				Wr_Addr_E:		out std_logic_vector(Addr_bit-1 downto 0);	
				Br_taken:		out std_logic);
	end component;
	
	component MemoryUnit is
		generic(Nbit:		integer := 32;
				Addr_bit:	integer := 10);
		port(	CLK: 			in	std_logic;
				RST:			in	std_logic;
				REG_EN_M:		in	std_logic;
				DataIn_DMem:	in	std_logic_vector(Nbit-1 downto 0);
				DataIn_ALU:		in	std_logic_vector(Nbit-1 downto 0);
				DataIn_RegB:	in	std_logic_vector(Nbit-1 downto 0);
				WR_Addr_E:		in	std_logic_vector(Addr_bit-1 downto 0);
				DataOut_Load:	out std_logic_vector(Nbit-1 downto 0);
				DataOut_Branch:	out std_logic_vector(Nbit-1 downto 0);
				WB_Address:		out std_logic_vector(Addr_bit-1 downto 0);
				DataOut_Store:	out std_logic_vector(Nbit-1 downto 0);
				Addr_DMem:		out	std_logic_vector(DRAM_DEPTH-1 downto 0));	
	end component;
	
	component WritebackUnit is 
		generic(Nbit: integer := 32);
		port(	WBMux_sel:		in	std_logic_vector(1 downto 0);
				NPC8:			in	std_logic_vector(Nbit-1 downto 0);
				NPC12:			in	std_logic_vector(Nbit-1 downto 0);
				DataIn_DMem:	in	std_logic_vector(Nbit-1 downto 0);
				DataIn_ALU:		in	std_logic_vector(Nbit-1 downto 0);
				WB_DataOut:		out std_logic_vector(Nbit-1 downto 0));			
	end component;
	
begin
	FU: FetchUnit
		generic map(Nbit,IRAM_DEPTH+2)
		port map(	CLK 			=> CLK,
					RST				=> RST,
					IR_EN      		=> F_IR_EN,
					NPC_EN     		=> F_NPC_EN,
					PC_EN			=> F_PC_EN,
					Jr_Sel			=> F_Jr_Sel,	
					J_Sel	        => F_J_Sel,
					Br_taken		=> EtoF_Br_taken,
					Jr_addr         => DtoF_Jraddr(IRAM_DEPTH+1 downto 0),
					J_addr	        => EtoF_Jaddr(IRAM_DEPTH+1 downto 0),
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
		            MuxRd_Sel		=> D_Rd_Sel,
		            InstrToDecode	=> FtoD_instr,
		            NPCin 			=> FtoD_NPC,
		            WB_Data			=> WtoD_WRdata,
		            WB_Addr			=> MtoD_WRaddr,
		            DataA			=> DtoE_DataA,
		            DataB			=> DtoE_DataB,
		            DataIMM			=> DtoE_imm,
		            NPCOut			=> DtoE_NPC,
					Jr_addr			=> DtoF_Jraddr,
		            Wr_Addr_D		=> DtoE_WRaddr);
					
	EXU: ExecutionUnit
		generic map(Nbit, Addr_bit)
		port map(	CLK				=> CLK,
		            RST	    		=> RST,
		            REG_EN_E		=> E_REG_EN,
		            MuxA_Sel		=> E_MuxA_Sel,
		            MuxB_Sel		=> E_MuxB_Sel,
		            ALU_Config		=> E_ALU_Conf,
					Sign			=> E_Signed,
					BrCond			=> E_BrCond,
					AddrComp		=> E_AddrComp,
		            NPC_In			=> DtoE_NPC,
		            DataA			=> DtoE_DataA,
		            DataB			=> DtoE_DataB,
		            DataIMM			=> DtoE_imm,
		            Wr_Addr_D		=> DtoE_WRaddr,
					NPC_Out			=> EtoW_NPC,
		            ALU_Out			=> EtoM_DataALU,
		            DataBtoDMem		=> EtoM_DataB,
					J_addr			=> EtoF_Jaddr,
		            Wr_Addr_E		=> EtoM_WRaddr,
		            Br_taken		=> EtoF_Br_taken);
					
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
		port map(	WBMux_sel		=> WB_Mux_sel,
					NPC8			=> EtoW_NPC,
					NPC12			=> DtoE_NPC,
		            DataIn_DMem		=> MtoW_DataMem,
		            DataIn_ALU		=> MtoW_DataALU,
		            WB_DataOut		=> WtoD_WRdata);
				
end Structural;
