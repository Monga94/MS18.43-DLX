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
			Rst			: in  std_logic;												-- Active Low
			-- FETCH STAGE OUTPUTS							
			F_PC_EN		: out std_logic;												-- enables the PC register
			F_NPC_EN	: out std_logic;												-- enables the NPC register
			F_IR_EN		: out std_logic;												-- enables the instruction register
			-- DECODE STAGE OUTPUTS							
			D_REG_EN	: out std_logic;												-- enables the register file and the pipeline registers
			D_RF_RD1	: out std_logic;												-- enables the read port 1 of the register file
			D_RF_RD2	: out std_logic;												-- enables the read port 2 of the register file
			D_IMM_Sel	: out std_logic;												-- input selection of immediate type 0=unsigned 1=signed
			D_Rd_Sel	: out std_logic;												-- input selection of write address 0=Itype 1=Rtype
			-- EXECUTE STAGE OUTPUTS													
			E_REG_EN	: out std_logic;												-- enables the pipeline registers
			E_MuxA_Sel	: out std_logic;												-- input selection of the first multiplexer 0=NPC 1=A
			E_MuxB_Sel	: out std_logic;												-- input selection of the second multiplexer 0=B 1=IMM
			E_ALU_Conf	: out AluOp;													-- alu control word
			E_Signed	: out std_logic;												-- signed operation identifier 0=unsigned 1=signed
			--E_BrCond	: out std_logic_vector(2 downto 0);								-- condition for branching and jumping
			-- MEMORY STAGE OUTPUTS							
			M_REG_EN	: out std_logic;												-- enables the pipeline registers
			DMem_RD		: out std_logic;												-- select read/write mode 1=READ 0=WRITE
			DMem_CS		: out std_logic;												-- enables the memory
			-- WRITEBACK STAGE OUTPUTS							
			WB_Mux_sel	: out std_logic;												-- input selection of the multiplexer 0=mem 1=aluout
			D_RF_WR		: out std_logic);												-- enables the write port of the register file
end DLX_CU_HW;

architecture Implementation of DLX_CU_HW is
	type op_array is array (integer range 0 to OP_NUMB - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
	signal cw_array : op_array := (	"111 11101 1101 100 11", --ADD  --order of control signal is like the following one (not the same as in port declaration)
									"111 11101 1100 100 11", --ADDU
									"111 11101 1101 100 11", --SUB	
									"111 11101 1100 100 11", --SUBU			
									"111 11101 1100 100 11", --AND               
									"111 11101 1100 100 11", --OR  
									"111 11101 1100 100 11", --XOR
									"111 11101 1100 100 11", --SLL
									"111 11101 1100 100 11", --SRL
									"111 11101 1101 100 11", --SRA
									"111 11101 1101 100 11", --SGT
									"111 11101 1100 100 11", --SGTU
									"111 11101 1101 100 11", --SGE
									"111 11101 1100 100 11", --SGEU
									"111 11101 1101 100 11", --SEQ
									"111 11101 1101 100 11", --SLE
									"111 11101 1100 100 11", --SLEU
									"111 11101 1101 100 11", --SLT
									"111 11101 1100 100 11", --SLTU
									"111 11101 1101 100 11", --SNE
									"111 11101 1101 100 11", --MULT		///
									
									"111 11010 1111 100 11", --ADDI	
									"111 11000 1110 100 11", --ADDUI		    
									"111 11010 1111 100 11", --SUBI   
									"111 11000 1110 100 11", --SUBUI          
									"111 11000 1110 100 11", --ANDI             
									"111 11000 1110 100 11", --ORI
									"111 11000 1110 100 11", --XORI
									"111 11000 1110 100 11", --SLLI
									"111 11000 1110 100 11", --SRLI
									"111 11000 1111 100 11", --SRAI
									"111 11010 1111 100 11", --SGTI
									"111 11000 1110 100 11", --SGTUI
									"111 11010 1111 100 11", --SGEI
									"111 11000 1110 100 11", --SGEUI
									"111 11010 1111 100 11", --SEQI
									"111 11010 1111 100 11", --SLEI
									"111 11000 1110 100 11", --SLEUI
									"111 11010 1111 100 11", --SLTI
									"111 11000 1110 100 11", --SLTUI
									"111 11010 1111 100 11", --SNEI
									
									"-------------", --BEQZ
									"-------------", --BNEZ
									"-------------", --J
									"-------------", --JR
									"-------------", --JAL
									"-------------", --JALR
									
									"                     ", --LW
									"                     ", --LB
									"                     ", --LBU
									"                     ", --LH
									"                     ", --LHI
									"                     ", --LHU
									"                     ", --SW
									"                     ", --SB
									"                     ", --SH
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
	DMem_RD		<=	M_cw();
	DMem_CS		<=	M_cw();
	
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
		case OPCODE is
	        --case of R type requires analysis of FUNC
			when RTYPE =>
				case FUNC is
					when RTYPE_NOP	=> 
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SLL	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SRL	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SRA	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_ADD	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_ADDU =>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SUB	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SUBU =>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_AND	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_OR 	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_XOR	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SEQ	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SNE	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SLT	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SGT	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SLE	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SGE	=>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SLTU =>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SGTU =>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SLEU =>
						cw <= ;
						aluOpcode_i <= ;
					when RTYPE_SGEU =>
						cw <= ;
						aluOpcode_i <= ;
					when others => 
						cw <= ;
						aluOpcode_i <= ;
				end case;
			when JTYPE_J	 =>
				cw <= ;
				aluOpcode_i <= ;	
			when JTYPE_JAL	 =>
				cw <= ;
				aluOpcode_i <= ;
			when JTYPE_JR	 =>
				cw <= ;
				aluOpcode_i <= ;
			when JTYPE_JALR	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_BEQZ	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_BNEZ	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_ADDI	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_ADDUI =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SUBI  =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SUBUI =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_ANDI  =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_ORI	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_XORI	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_LHI	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SLLI	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_NOP	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SRLI	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SRAI	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SEQI	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SNEI	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SLTI	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SGTI	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SLEI	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SGEI	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_LB	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_LH	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_LW	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_LBU	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_LHU	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SB	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SH	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SW	 =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SLTUI =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SGTUI =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SLEUI =>
				cw <= ;
				aluOpcode_i <= ;
			when ITYPE_SGEUI =>
				cw <= ;
				aluOpcode_i <= ;			
			when others => 
				cw <= (others => '0');
				aluOpcode_i <= ALU_NOPop;
		end case;
	end process ALU_OP_CODE_P;
	
	
end Implementation;