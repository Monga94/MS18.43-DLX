library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity DLX_CU_HW is 
	port(	-- INPUTS
			OPCODE		: in  std_logic_vector(OP_CODE_SIZE-1 downto 0);
			FUNC		: in  std_logic_vector(FUNC_SIZE-1 downto 0);              
			Clk			: in  std_logic;
			Rst			: in  std_logic;								-- Active Low
			-- FETCH STAGE OUTPUTS							
			F_PC_EN		: out std_logic;								-- enables the PC register
			F_NPC_EN	: out std_logic;								-- enables the NPC register
			F_IR_EN		: out std_logic;								-- enables the instruction register
			-- DECODE STAGE OUTPUTS							
			D_REG_EN	: out std_logic;								-- enables the register file and the pipeline registers
			D_RF_RD1	: out std_logic;								-- enables the read port 1 of the register file
			D_RF_RD2	: out std_logic;								-- enables the read port 2 of the register file
			D_IMM_Sel	: out std_logic_vector(1 downto 0);				-- input selection of immediate type 00=uimm16 01=imm16 10=lhi_config 11=imm26
			D_Rd_Sel	: out std_logic_vector(1 downto 0);				-- input selection of write address 00=Itype 01=Rtype 10=31 11=0
			F_Jr_Sel	: out std_logic;								-- first input selection of PC 0=continue 1=JumpR
			-- EXECUTE STAGE OUTPUTS									
			E_REG_EN	: out std_logic;								-- enables the pipeline registers
			E_MuxA_Sel	: out std_logic_vector(1 downto 0);				-- input selection of the first multiplexer 00=NPC 01=A 10='0' 11='-1'
			E_MuxB_Sel	: out std_logic_vector(1 downto 0);				-- input selection of the second multiplexer 00=B 01=IMM 10='0' 11='-1'
			E_ALU_Conf	: out std_logic_vector(SelALU-1 downto 0);		-- alu control word
			E_Signed	: out std_logic;								-- signed operation identifier 0=unsigned 1=signed
			F_J_Sel		: out std_logic;								-- input selection of PC 0=continue 1=Jump
			E_BrCond	: out std_logic_vector(1 downto 0);				-- condition for branching 00,01=noBranch 10=BrZ 11=BrNZ
			E_AddrComp	: out std_logic;								-- needed to deactivate overflow 0=standard calc 1=addr calc
			-- MEMORY STAGE OUTPUTS							
			M_REG_EN	: out std_logic;								-- enables the pipeline registers
			DMem_CS		: out std_logic;								-- enables the memory
			DMem_RD		: out std_logic;								-- select read/write mode 1=READ 0=WRITE
			DMem_WS		: out std_logic_vector(1 downto 0);				-- select type of load/store 00=Byte 01=HalfWord 10=Word
			DMem_Sign	: out std_logic;								-- equal to E_signed - needed for data extraction
			-- WRITEBACK STAGE OUTPUTS							
			WB_Mux_sel	: out std_logic_vector(1 downto 0);				-- input selection of the multiplexer 00=mem 01=aluout 10=PC+8 11=PC+12
			D_RF_WR		: out std_logic);								-- enables the write port of the register file
end DLX_CU_HW;

architecture Implementation of DLX_CU_HW is

	signal cw : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_array
	
	-- control word is shifted to the correct stage
	signal F_cw : std_logic_vector(CW_SIZE - 1 downto 0); -- first stage
	signal D_cw : std_logic_vector(CW_SIZE - 1 - F_CTRL downto 0); -- second stage
	signal E_cw : std_logic_vector(CW_SIZE - 1 - F_CTRL - D_CTRL downto 0); -- third stage
	signal M_cw : std_logic_vector(CW_SIZE - 1 - F_CTRL - D_CTRL - E_CTRL downto 0); -- fourth stage
	signal W_cw : std_logic_vector(CW_SIZE - 1 - F_CTRL - D_CTRL - E_CTRL - M_CTRL downto 0); -- fifth stage
	
	signal aluOpcode_i : aluOp := ALU_NOPop; -- ALUOP defined in package
	signal aluOpcode1 : aluOp := ALU_NOPop;
	signal aluOpcode2 : aluOp := ALU_NOPop;
	signal aluOpcode3 : aluOp := ALU_NOPop;
	
	begin
	
	-- FIRST PIPE STAGE OUTPUTS			--order here is the same as in cw_array
	F_PC_EN		<=	F_cw(29);
	F_NPC_EN	<=	F_cw(28);
	F_IR_EN		<=	F_cw(27);
	
	-- SECOND PIPE STAGE OUTPUTS
	D_REG_EN	<=	D_cw(26);
	D_RF_RD1	<=	D_cw(25);
	D_RF_RD2	<=	D_cw(24);
	D_IMM_Sel	<=	D_cw(23 downto 22);
	D_Rd_Sel	<=	D_cw(21 downto 20);
	F_Jr_Sel	<=	D_cw(19);
	
	-- THIRD PIPE STAGE OUTPUTS	
	E_REG_EN	<=	E_cw(18);
	E_MuxA_Sel	<=	E_cw(17 downto 16);
	E_MuxB_Sel	<=	E_cw(15 downto 14);
	E_ALU_Conf	<=	aluOpcode3;
	E_Signed	<=	E_cw(13);
	F_J_Sel		<=	E_cw(12);
	E_BrCond	<=	E_cw(11 downto 10);
	E_AddrComp	<=	E_cw(9);
	
	-- FOURTH PIPE STAGE OUTPUTS
	M_REG_EN	<=	M_cw(8);
	DMem_CS		<=	M_cw(7);
	DMem_RD		<=	M_cw(6);
	DMem_WS		<=	M_cw(5 downto 4);
	DMem_Sign	<=	M_cw(3);
	
	-- FIFTH PIPE STAGE OUTPUTS
	WB_Mux_sel	<=	W_cw(2 downto 1);
	D_RF_WR		<=	W_cw(0);
	
	-- first stage combinational outputs

	-- process to pipeline control words
	CW_PIPE: process (Clk, Rst)
	begin  -- process Clk			
		if Clk'event and Clk = '0' then  		-- raising clock edge
			if Rst = '0' then					-- synchronous reset (active low)
				F_cw <= (others => '0');
				D_cw <= (others => '0');
				E_cw <= (others => '0');
				M_cw <= (others => '0');
				W_cw <= (others => '0');
				
				aluOpcode1 <= ALU_NOPop;	
				aluOpcode2 <= ALU_NOPop;
				aluOpcode3 <= ALU_NOPop;		
			else
				F_cw <= cw;
				D_cw <= F_cw(CW_SIZE - 1 - F_CTRL downto 0);
				E_cw <= D_cw(CW_SIZE - 1 - F_CTRL - D_CTRL downto 0);
				M_cw <= E_cw(CW_SIZE - 1 - F_CTRL - D_CTRL - E_CTRL downto 0);
				W_cw <= M_cw(CW_SIZE - 1 - F_CTRL - D_CTRL - E_CTRL - M_CTRL downto 0);
			
				aluOpcode1 <= aluOpcode_i;
				aluOpcode2 <= aluOpcode1;
				aluOpcode3 <= aluOpcode2;
			end if;
		end if;
	end process CW_PIPE;
	
	--purpose: Generation of ALU OpCode
	--type   : combinational
	--inputs : OPCODE,FUNC
	--outputs: aluOpcode, cw
	ALU_OP_CODE_P : process (OPCODE, FUNC)
	begin  -- process ALU_OP_CODE_P
		case conv_integer(unsigned(OPCODE)) is
	        --case of R type requires analysis of FUNC
			when conv_integer(unsigned(RTYPE)) =>
				case conv_integer(unsigned(FUNC)) is
					when conv_integer(unsigned(RTYPE_NOP))	=> 
						cw <= CW_RTYPE_NOP;
						aluOpcode_i <= ALU_NOPop;
					when conv_integer(unsigned(RTYPE_SLL))	=>
						cw <= CW_RTYPE_SLL;
						aluOpcode_i <= ALU_SLLop;
					when conv_integer(unsigned(RTYPE_SRL))	=>
						cw <= CW_RTYPE_SRL;
						aluOpcode_i <= ALU_SRLop;
					when conv_integer(unsigned(RTYPE_SRA))	=>
						cw <= CW_RTYPE_SRA;
						aluOpcode_i <= ALU_SRAop;
					when conv_integer(unsigned(RTYPE_ROL))	=>
						cw <= CW_RTYPE_ROL;
						aluOpcode_i <= ALU_ROLop;
					when conv_integer(unsigned(RTYPE_ROR))	=>
						cw <= CW_RTYPE_ROR;
						aluOpcode_i <= ALU_RORop;
					when conv_integer(unsigned(RTYPE_MULT))	=>
						cw <= CW_RTYPE_MULT;
						aluOpcode_i <= ALU_MULTop;
					when conv_integer(unsigned(RTYPE_ADD))	=>
						cw <= CW_RTYPE_ADD;
						aluOpcode_i <= ALU_ADDop;
					when conv_integer(unsigned(RTYPE_ADDU)) =>
						cw <= CW_RTYPE_ADDU;
						aluOpcode_i <= ALU_ADDop;
					when conv_integer(unsigned(RTYPE_SUB))	=>
						cw <= CW_RTYPE_SUB;
						aluOpcode_i <= ALU_SUBop;
					when conv_integer(unsigned(RTYPE_SUBU)) =>
						cw <= CW_RTYPE_SUBU;
						aluOpcode_i <= ALU_SUBop;
					when conv_integer(unsigned(RTYPE_AND))	=>
						cw <= CW_RTYPE_AND;
						aluOpcode_i <= ALU_ANDop;
					when conv_integer(unsigned(RTYPE_OR)) 	=>
						cw <= CW_RTYPE_OR;
						aluOpcode_i <= ALU_ORop;
					when conv_integer(unsigned(RTYPE_XOR))	=>
						cw <= CW_RTYPE_XOR;
						aluOpcode_i <= ALU_XORop;
					when conv_integer(unsigned(RTYPE_SEQ))	=>
						cw <= CW_RTYPE_SEQ;
						aluOpcode_i <= ALU_AeqBop;
					when conv_integer(unsigned(RTYPE_SNE))	=>
						cw <= CW_RTYPE_SNE;
						aluOpcode_i <= ALU_AneBop;
					when conv_integer(unsigned(RTYPE_SLT))	=>
						cw <= CW_RTYPE_SLT;
						aluOpcode_i <= ALU_AltBop;
					when conv_integer(unsigned(RTYPE_SGT))	=>
						cw <= CW_RTYPE_SGT;
						aluOpcode_i <= ALU_AgtBop;
					when conv_integer(unsigned(RTYPE_SLE))	=>
						cw <= CW_RTYPE_SLE;
						aluOpcode_i <= ALU_AleBop;
					when conv_integer(unsigned(RTYPE_SGE))	=>
						cw <= CW_RTYPE_SGE;
						aluOpcode_i <= ALU_AgeBop;
					when conv_integer(unsigned(RTYPE_SLTU)) =>
						cw <= CW_RTYPE_SLTU;
						aluOpcode_i <= ALU_AltBop;
					when conv_integer(unsigned(RTYPE_SGTU)) =>
						cw <= CW_RTYPE_SGTU;
						aluOpcode_i <= ALU_AgtBop;
					when conv_integer(unsigned(RTYPE_SLEU)) =>
						cw <= CW_RTYPE_SLEU;
						aluOpcode_i <= ALU_AleBop;
					when conv_integer(unsigned(RTYPE_SGEU)) =>
						cw <= CW_RTYPE_SGEU;
						aluOpcode_i <= ALU_AgeBop;
					when others => 
						cw <= CW_RTYPE_NOP;
						aluOpcode_i <= ALU_NOPop;
				end case;
			when conv_integer(unsigned(JTYPE_J))	 =>
				cw <= CW_JTYPE_J;
				aluOpcode_i <= ALU_ADDop;	
			when conv_integer(unsigned(JTYPE_JAL))	 =>
				cw <= CW_JTYPE_JAL;
				aluOpcode_i <= ALU_ADDop;
			when conv_integer(unsigned(JTYPE_JR))	 =>
				cw <= CW_JTYPE_JR;
				aluOpcode_i <= ALU_NOPop;
			when conv_integer(unsigned(JTYPE_JALR))	 =>
				cw <= CW_JTYPE_JALR;
				aluOpcode_i <= ALU_NOPop;
			when conv_integer(unsigned(ITYPE_BEQZ))	 =>
				cw <= CW_ITYPE_BEQZ;
				aluOpcode_i <= ALU_ADDop;
			when conv_integer(unsigned(ITYPE_BNEZ))	 =>
				cw <= CW_ITYPE_BNEZ;
				aluOpcode_i <= ALU_ADDop;
			when conv_integer(unsigned(ITYPE_ADDI))	 =>
				cw <= CW_ITYPE_ADDI;
				aluOpcode_i <= ALU_ADDop;
			when conv_integer(unsigned(ITYPE_ADDUI)) =>
				cw <= CW_ITYPE_ADDUI;
				aluOpcode_i <= ALU_ADDop;
			when conv_integer(unsigned(ITYPE_SUBI))  =>
				cw <= CW_ITYPE_SUBI;
				aluOpcode_i <= ALU_SUBop;
			when conv_integer(unsigned(ITYPE_SUBUI)) =>
				cw <= CW_ITYPE_SUBUI;
				aluOpcode_i <= ALU_SUBop;
			when conv_integer(unsigned(ITYPE_ANDI))  =>
				cw <= CW_ITYPE_ANDI;
				aluOpcode_i <= ALU_ANDop;
			when conv_integer(unsigned(ITYPE_ORI))	 =>
				cw <= CW_ITYPE_ORI;
				aluOpcode_i <= ALU_ORop;
			when conv_integer(unsigned(ITYPE_XORI))	 =>
				cw <= CW_ITYPE_XORI;
				aluOpcode_i <= ALU_XORop;
			when conv_integer(unsigned(ITYPE_LHI))	 =>
				cw <= CW_ITYPE_LHI;
				aluOpcode_i <= ALU_ORop;
			when conv_integer(unsigned(ITYPE_SLLI))	 =>
				cw <= CW_ITYPE_SLLI;
				aluOpcode_i <= ALU_SLLop;
			when conv_integer(unsigned(ITYPE_NOP))	 =>
				cw <= CW_ITYPE_NOP;
				aluOpcode_i <= ALU_NOPop;
			when conv_integer(unsigned(ITYPE_SRLI))	 =>
				cw <= CW_ITYPE_SRLI;
				aluOpcode_i <= ALU_SRLop;
			when conv_integer(unsigned(ITYPE_SRAI))	 =>
				cw <= CW_ITYPE_SRAI;
				aluOpcode_i <= ALU_SRAop;
			when conv_integer(unsigned(ITYPE_SEQI))	 =>
				cw <= CW_ITYPE_SEQI;
				aluOpcode_i <= ALU_AeqBop;
			when conv_integer(unsigned(ITYPE_SNEI))	 =>
				cw <= CW_ITYPE_SNEI;
				aluOpcode_i <= ALU_AneBop;
			when conv_integer(unsigned(ITYPE_SLTI))	 =>
				cw <= CW_ITYPE_SLTI;
				aluOpcode_i <= ALU_AltBop;
			when conv_integer(unsigned(ITYPE_SGTI))	 =>
				cw <= CW_ITYPE_SGTI;
				aluOpcode_i <= ALU_AgtBop;
			when conv_integer(unsigned(ITYPE_SLEI))	 =>
				cw <= CW_ITYPE_SLEI;
				aluOpcode_i <= ALU_AleBop;
			when conv_integer(unsigned(ITYPE_SGEI))	 =>
				cw <= CW_ITYPE_SGEI;
				aluOpcode_i <= ALU_AgeBop;
			when conv_integer(unsigned(ITYPE_ROLI))	 =>
				cw <= CW_ITYPE_ROLI;
				aluOpcode_i <= ALU_ROLop;
			when conv_integer(unsigned(ITYPE_RORI))	 =>
				cw <= CW_ITYPE_RORI;
				aluOpcode_i <= ALU_RORop;
			when conv_integer(unsigned(ITYPE_LB))	 =>
				cw <= CW_ITYPE_LB;
				aluOpcode_i <= ALU_ADDop;
			when conv_integer(unsigned(ITYPE_LH))	 =>
				cw <= CW_ITYPE_LH;
				aluOpcode_i <= ALU_ADDop;
			when conv_integer(unsigned(ITYPE_LW))	 =>
				cw <= CW_ITYPE_LW;
				aluOpcode_i <= ALU_ADDop;
			when conv_integer(unsigned(ITYPE_LBU))	 =>
				cw <= CW_ITYPE_LBU;
				aluOpcode_i <= ALU_ADDop;
			when conv_integer(unsigned(ITYPE_LHU))	 =>
				cw <= CW_ITYPE_LHU;
				aluOpcode_i <= ALU_ADDop;
			when conv_integer(unsigned(ITYPE_SB))	 =>
				cw <= CW_ITYPE_SB;
				aluOpcode_i <= ALU_ADDop;
			when conv_integer(unsigned(ITYPE_SH))	 =>
				cw <= CW_ITYPE_SH;
				aluOpcode_i <= ALU_ADDop;
			when conv_integer(unsigned(ITYPE_SW))	 =>
				cw <= CW_ITYPE_SW;
				aluOpcode_i <= ALU_ADDop;
			when conv_integer(unsigned(ITYPE_SLTUI)) =>
				cw <= CW_ITYPE_SLTUI;
				aluOpcode_i <= ALU_AltBop;
			when conv_integer(unsigned(ITYPE_SGTUI)) =>
				cw <= CW_ITYPE_SGTUI;
				aluOpcode_i <= ALU_AgtBop;
			when conv_integer(unsigned(ITYPE_SLEUI)) =>
				cw <= CW_ITYPE_SLEUI;
				aluOpcode_i <= ALU_AleBop;
			when conv_integer(unsigned(ITYPE_SGEUI)) =>
				cw <= CW_ITYPE_SGEUI;
				aluOpcode_i <= ALU_AgeBop;			
			when others => 
				cw <= CW_ITYPE_NOP;
				aluOpcode_i <= ALU_NOPop;
		end case;
	end process ALU_OP_CODE_P;
	
end Implementation;