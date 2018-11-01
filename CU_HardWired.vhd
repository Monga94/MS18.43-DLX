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
			D_Rd_Sel	: out std_logic;								-- input selection of write address 0=Itype 1=Rtype
			-- EXECUTE STAGE OUTPUTS									
			E_REG_EN	: out std_logic;								-- enables the pipeline registers
			E_MuxA_Sel	: out std_logic_vector(1 downto 0);				-- input selection of the first multiplexer 00=NPC 01=A 10='0' 11='-1'
			E_MuxB_Sel	: out std_logic;								-- input selection of the second multiplexer 0=B 1=IMM
			E_ALU_Conf	: out std_logic_vector(SelALU-1 downto 0);		-- alu control word
			E_Signed	: out std_logic;								-- signed operation identifier 0=unsigned 1=signed
			--E_BrCond	: out std_logic_vector(2 downto 0);				-- condition for branching and jumping
			-- MEMORY STAGE OUTPUTS							
			M_REG_EN	: out std_logic;								-- enables the pipeline registers
			DMem_CS		: out std_logic;								-- enables the memory
			DMem_RD		: out std_logic;								-- select read/write mode 1=READ 0=WRITE
			DMem_WS		: out std_logic_vector(1 downto 0)				-- select type of load/store 00=Byte 01=HalfWord 10=Word
			DMem_Sign	: out std_logic									-- equal to E_signed - needed for data extraction
			-- WRITEBACK STAGE OUTPUTS							
			WB_Mux_sel	: out std_logic;								-- input selection of the multiplexer 0=mem 1=aluout
			D_RF_WR		: out std_logic);								-- enables the write port of the register file
end DLX_CU_HW;

architecture Implementation of DLX_CU_HW is
	type op_array is array (integer range 0 to OP_NUMB - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
	signal cw_array : op_array := (	"111 111001 10101 100000 11", --ADD  --order of control signal is like the following one (not the same as in port declaration)
									"111 111001 10100 100000 11", --ADDU
									"111 111001 10101 100000 11", --SUB	
									"111 111001 10100 100000 11", --SUBU			
									"111 111001 10100 100000 11", --AND               
									"111 111001 10100 100000 11", --OR  
									"111 111001 10100 100000 11", --XOR
									"111 111001 10100 100000 11", --SLL
									"111 111001 10100 100000 11", --SRL
									"111 111001 10101 100000 11", --SRA
									"111 111001 10101 100000 11", --SGT
									"111 111001 10100 100000 11", --SGTU
									"111 111001 10101 100000 11", --SGE
									"111 111001 10100 100000 11", --SGEU
									"111 111001 10101 100000 11", --SEQ
									"111 111001 10101 100000 11", --SLE
									"111 111001 10100 100000 11", --SLEU
									"111 111001 10101 100000 11", --SLT
									"111 111001 10100 100000 11", --SLTU
									"111 111001 10101 100000 11", --SNE
									"111 111001 10101 100000 11", --MULT		///

									"111 110010 10111 100000 11", --ADDI	
									"111 110000 10110 100000 11", --ADDUI		    
									"111 110010 10111 100000 11", --SUBI   
									"111 110000 10110 100000 11", --SUBUI          
									"111 110000 10110 100000 11", --ANDI             
									"111 110000 10110 100000 11", --ORI
									"111 110000 10110 100000 11", --XORI
									"111 110000 10110 100000 11", --SLLI
									"111 110000 10110 100000 11", --SRLI
									"111 110000 10111 100000 11", --SRAI
									"111 110010 10111 100000 11", --SGTI
									"111 110000 10110 100000 11", --SGTUI
									"111 110010 10111 100000 11", --SGEI
									"111 110000 10110 100000 11", --SGEUI
									"111 110010 10111 100000 11", --SEQI
									"111 110010 10111 100000 11", --SLEI
									"111 110000 10110 100000 11", --SLEUI
									"111 110010 10111 100000 11", --SLTI
									"111 110000 10110 100000 11", --SLTUI
									"111 110010 10111 100000 11", --SNEI

									"                          ", --BEQZ
									"                          ", --BNEZ
									"                          ", --J
									"                          ", --JR
									"                          ", --JAL
									"                          ", --JALR
									"111 101100 11010 100000 11", --LHI
									
									"111 110010 10111 111100 01", --LW
									"111 110010 10111 111001 01", --LB
									"111 110010 10111 111000 01", --LBU
									"111 110010 10111 111011 01", --LH
									"111 110010 10111 111010 01", --LHU
									"111 111010 10111 010100 00", --SW
									"111 111010 10111 010000 00", --SB
									"111 111010 10111 010010 00", --SH
									"0000000000000");--NOP
									
	signal cw : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_array
	
	
	-- control word is shifted to the correct stage
	signal F_cw : std_logic_vector(CW_SIZE - 1 downto 0); -- first stage
	signal D_cw : std_logic_vector(CW_SIZE - 1 - F_CTRL downto 0); -- second stage
	signal E_cw : std_logic_vector(CW_SIZE - 1 - F_CTRL - D_CTRL downto 0); -- third stage
	signal M_cw : std_logic_vector(CW_SIZE - 1 - F_CTRL - D_CTRL - E_CTRL downto 0); -- fourth stage
	signal W_cw : std_logic_vector(CW_SIZE - 1 - F_CTRL - D_CTRL - E_CTRL - M_CTRL downto 0); -- fifth stage
	
	signal aluOpcode_i : aluOp := IDLE; -- ALUOP defined in package
	signal aluOpcode1 : aluOp := IDLE;
	signal aluOpcode2 : aluOp := IDLE;
	signal aluOpcode3 : aluOp := IDLE;
	
	begin
  
	cw <= cw_array(conv_integer(OPCODE));
	
	-- FIRST PIPE STAGE OUTPUTS			--order here is the same as in cw_array
	F_IR_EN		<=	F_cw();
	F_NPC_EN	<=	F_cw();
	F_PC_EN		<=	F_cw();
	
	-- SECOND PIPE STAGE OUTPUTS
	D_RF_RD1	<=	D_cw();
	D_RF_RD2	<=	D_cw();
	D_REG_EN	<=	D_cw();
	D_IMM_Sel	<=	D_cw();
	D_Rd_Sel	<=	D_cw();
	
	-- THIRD PIPE STAGE OUTPUTS	
	E_REG_EN	<=	E_cw();
	E_MuxA_Sel	<=	E_cw();
	E_MuxB_Sel	<=	E_cw();
	E_ALU_Conf	<=	aluOpcode3;
	E_Signed	<=	E_cw();
	--E_BrCond	<=	E_cw();
	
	-- FOURTH PIPE STAGE OUTPUTS
	M_REG_EN	<=	M_cw();
	DMem_CS		<=	M_cw();
	DMem_RD		<=	M_cw();
	DMem_WS		<=	M_cw();
	DMem_Sign	<=	M_cw();
	
	-- FIFTH PIPE STAGE OUTPUTS
	WB_Mux_sel	<=	W_cw();
	D_RF_WR		<=	W_cw();
	
	
	-- process to pipeline control words
	CW_PIPE: process (Clk, Rst)
	begin  -- process Clk			
		if Clk'event and Clk = '0' then  		-- rising clock edge
			if Rst = '0' then					-- synchronous reset (active low)
				F_cw <= '1' & (others => '0');
				D_cw <= '1' & (others => '0');
				E_cw <= '1' & (others => '0');
				M_cw <= '1' & (others => '0');
				W_cw <= '1' & (others => '0');
				
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
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SLL))	=>
						cw <= CW_RTYPE_SLL;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SRL))	=>
						cw <= CW_RTYPE_SRL;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SRA))	=>
						cw <= CW_RTYPE_SRA;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_ADD))	=>
						cw <= CW_RTYPE_ADD;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_ADDU)) =>
						cw <= CW_RTYPE_ADDU;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SUB))	=>
						cw <= CW_RTYPE_SUB;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SUBU)) =>
						cw <= CW_RTYPE_SUBU;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_AND))	=>
						cw <= CW_RTYPE_AND;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_OR)) 	=>
						cw <= CW_RTYPE_OR;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_XOR))	=>
						cw <= CW_RTYPE_XOR;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SEQ))	=>
						cw <= CW_RTYPE_SEQ;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SNE))	=>
						cw <= CW_RTYPE_SNE;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SLT))	=>
						cw <= CW_RTYPE_SLT;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SGT))	=>
						cw <= CW_RTYPE_SGT;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SLE))	=>
						cw <= CW_RTYPE_SLE;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SGE))	=>
						cw <= CW_RTYPE_SGE;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SLTU)) =>
						cw <= CW_RTYPE_SLTU;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SGTU)) =>
						cw <= CW_RTYPE_SGTU;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SLEU)) =>
						cw <= CW_RTYPE_SLEU;
						aluOpcode_i <= ;
					when conv_integer(unsigned(RTYPE_SGEU)) =>
						cw <= CW_RTYPE_SGEU;
						aluOpcode_i <= ;
					when others => 
						cw <= (others => '0');
						aluOpcode_i <= ;
				end case;
			when conv_integer(unsigned(JTYPE_J))	 =>
				cw <= CW_JTYPE_J;
				aluOpcode_i <= ;	
			when conv_integer(unsigned(JTYPE_JAL))	 =>
				cw <= CW_JTYPE_JAL;
				aluOpcode_i <= ;
			when conv_integer(unsigned(JTYPE_JR))	 =>
				cw <= CW_JTYPE_JR;
				aluOpcode_i <= ;
			when conv_integer(unsigned(JTYPE_JALR))	 =>
				cw <= CW_JTYPE_JALR;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_BEQZ))	 =>
				cw <= CW_ITYPE_BEQZ;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_BNEZ))	 =>
				cw <= CW_ITYPE_BNEZ;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_ADDI))	 =>
				cw <= CW_ITYPE_ADDI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_ADDUI)) =>
				cw <= CW_ITYPE_ADDUI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SUBI))  =>
				cw <= CW_ITYPE_SUBI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SUBUI)) =>
				cw <= CW_ITYPE_SUBUI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_ANDI))  =>
				cw <= CW_ITYPE_ANDI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_ORI))	 =>
				cw <= CW_ITYPE_ORI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_XORI))	 =>
				cw <= CW_ITYPE_XORI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_LHI))	 =>
				cw <= CW_ITYPE_LHI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SLLI))	 =>
				cw <= CW_ITYPE_SLLI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_NOP))	 =>
				cw <= CW_ITYPE_NOP;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SRLI))	 =>
				cw <= CW_ITYPE_SRLI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SRAI))	 =>
				cw <= CW_ITYPE_SRAI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SEQI))	 =>
				cw <= CW_ITYPE_SEQI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SNEI))	 =>
				cw <= CW_ITYPE_SNEI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SLTI))	 =>
				cw <= CW_ITYPE_SLTI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SGTI))	 =>
				cw <= CW_ITYPE_SGTI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SLEI))	 =>
				cw <= CW_ITYPE_SLEI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SGEI))	 =>
				cw <= CW_ITYPE_SGEI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_LB))	 =>
				cw <= CW_ITYPE_LB;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_LH))	 =>
				cw <= CW_ITYPE_LH;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_LW))	 =>
				cw <= CW_ITYPE_LW;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_LBU))	 =>
				cw <= CW_ITYPE_LBU;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_LHU))	 =>
				cw <= CW_ITYPE_LHU;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SB))	 =>
				cw <= CW_ITYPE_SB;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SH))	 =>
				cw <= CW_ITYPE_SH;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SW))	 =>
				cw <= CW_ITYPE_SW;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SLTUI)) =>
				cw <= CW_ITYPE_SLTUI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SGTUI)) =>
				cw <= CW_ITYPE_SGTUI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SLEUI)) =>
				cw <= CW_ITYPE_SLEUI;
				aluOpcode_i <= ;
			when conv_integer(unsigned(ITYPE_SGEUI)) =>
				cw <= CW_ITYPE_SGEUI;
				aluOpcode_i <= ;			
			when others => 
				cw <= (others => '0');
				aluOpcode_i <= ALU_NOPop;
		end case;
	end process ALU_OP_CODE_P;
	
	
end Implementation;