library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity DLX_CU_HardWired is 
	port(	-- INPUTS
			OPCODE		: in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
			FUNC		: in  std_logic_vector(FUNC_SIZE - 1 downto 0);              
			Clk			: in  std_logic;
			Rst			: in  std_logic;					-- Active Low
			-- FIRST PIPE STAGE OUTPUTS
			IR_EN		: out std_logic;					-- enables the instruction register
			NPC_EN		: out std_logic;					-- enables the NPC register
			-- SECOND PIPE STAGE OUTPUTS
			DEC_EN		: out std_logic;					-- enables the register file and the pipeline registers
			RF_RD1		: out std_logic;					-- enables the read port 1 of the register file
			RF_RD2		: out std_logic;					-- enables the read port 2 of the register file
			-- THIRD PIPE STAGE OUTPUTS						
			EXEC_EN		: out std_logic;					-- enables the pipe registers
			MuxA_Sel	: out std_logic;					-- input selection of the first multiplexer 0=A 1=INP1
			MuxB_Sel	: out std_logic;					-- input selection of the second multiplexer 1=B 0=INP2
			Alu_Sel		: out AluOp;						-- alu control bit
			-- FOURTH PIPE STAGE OUTPUTS
			MEM_EN		: out std_logic;					-- enables the memory and the pipeline registers
			MEM_RD		: out std_logic;					-- enables the read-out of the memory
			MEM_WR		: out std_logic;					-- enables the write-in of the memory
			-- FIFTH PIPE STAGE OUTPUTS
			WB_Sel		: out std_logic;					-- input selection of the multiplexer 1=mem 0=aluout
			RF_WR		: out std_logic);					-- enables the write port of the register file
end DLX_CU_HardWired;

architecture Implementation of DLX_CU_HardWired is
	type op_array is array (integer range 0 to OP_NUMB - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
	signal cw_array : op_array := (	"1111110110001", --ADD  --order of control signal is like the following one (not the same as in port declaration)
									"-------------", --ADDU
									"1111110110001", --SUB	
									"-------------", --SUBU			
									"1111110110001", --AND               
									"1111110110001", --OR  
									"1111110110001", --XOR
									"1111110110001", --SLL
									"1111110110001", --SRL
									"-------------", --SRA
									"-------------", --SGT
									"-------------", --SGTU
									"1111110110001", --SGE
									"-------------", --SGEU
									"-------------", --SEQ
									"1111110110001", --SLE
									"-------------", --SLT
									"-------------", --SLTU
									"1111110110001", --SNE
									"-------------", --MULT		///
									
									"1111110010001", --ADDI	
									"-------------", --ADDUI		    
									"1111110010001", --SUBI   
									"-------------", --SUBUI          
									"1111110010001", --ANDI             
									"1111110010001", --ORI
									"1111110010001", --XORI
									"1111110010001", --SLLI
									"1111110010001", --SRLI
									"-------------", --SRAI
									"-------------", --SGTI
									"-------------", --SGTUI
									"1111110010001", --SGEI
									"-------------", --SGEUI
									"-------------", --SEQI
									"1111110010001", --SLEI
									"-------------", --SLTI
									"-------------", --SLTUI
									"1111110010001", --SNEI
									
									"-------------", --BEQZ
									"-------------", --BNEZ
									"-------------", --J
									"-------------", --JR
									"-------------", --JAL
									"-------------", --JALR
									
									"-------------", --LW
									"-------------", --LB
									"-------------", --LBU
									"-------------", --LHI
									"-------------", --LHU
									"-------------", --SW
									"-------------", --SB
									"0000000000000");--NOP
									
	signal cw : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_array
	
	
	-- control word is shifted to the correct stage
	signal cw1 : std_logic_vector(CW_SIZE - 1 downto 0); -- first stage
	signal cw2 : std_logic_vector(CW_SIZE - 3 downto 0); -- second stage
	signal cw3 : std_logic_vector(CW_SIZE - 6 downto 0); -- third stage
	signal cw4 : std_logic_vector(CW_SIZE - 10 downto 0); -- fourth stage
	signal cw5 : std_logic_vector(CW_SIZE - 13 downto 0); -- fifth stage
	
	signal aluOpcode_i : aluOp := IDLE; -- ALUOP defined in package
	signal aluOpcode1 : aluOp := IDLE;
	signal aluOpcode2 : aluOp := IDLE;
	signal aluOpcode3 : aluOp := IDLE;
	
	begin
  
	cw <= cw_array(conv_integer(OPCODE));
	
	-- FIRST PIPE STAGE OUTPUTS			--order here is the same as in cw_array
	IR_EN		<=	cw1(CW_SIZE-1);
	NPC_EN		<=	cw1(CW_SIZE-2);
										-- SECOND PIPE STAGE OUTPUTS
	DEC_EN		<=	cw2(CW_SIZE-3);
	RF_RD1		<=	cw2(CW_SIZE-4);
	RF_RD2		<=	cw2(CW_SIZE-5);
										-- THIRD PIPE STAGE OUTPUTS	
	EXEC_EN		<=	cw3(CW_SIZE-6);
	MuxA_Sel	<=	cw3(CW_SIZE-7);
	MuxB_Sel	<=	cw3(CW_SIZE-8);
	Alu_Sel		<=	aluOpcode3;
										-- FOURTH PIPE STAGE OUTPUTS
	MEM_EN		<=	cw4(CW_SIZE-9);
	MEM_RD		<=	cw4(CW_SIZE-10);
	MEM_WR		<=	cw4(CW_SIZE-11);
										-- FIFTH PIPE STAGE OUTPUTS
	WB_Sel		<=	cw5(CW_SIZE-12);
	RF_WR		<=	cw5(CW_SIZE-13);
	
	-- process to pipeline control words
	CW_PIPE: process (Clk, Rst)
	begin  -- process Clk			
		if Clk'event and Clk = '1' then  		-- rising clock edge
			if Rst = '0' then					-- synchronous reset (active low)
				cw1 <= (others => '0');
				cw2 <= (others => '0');
				cw3 <= (others => '0');
				cw4 <= (others => '0');
				cw5 <= (others => '0');
				
				aluOpcode1 <= IDLE;	
				aluOpcode2 <= IDLE;
				aluOpcode3 <= IDLE;		
			else
				cw1 <= cw;
				cw2 <= cw1(CW_SIZE - 3 downto 0);
				cw3 <= cw2(CW_SIZE - 6 downto 0);
				cw4 <= cw3(CW_SIZE - 9 downto 0);
				cw5 <= cw4(CW_SIZE - 12 downto 0);
			
				aluOpcode1 <= aluOpcode_i;
				aluOpcode2 <= aluOpcode1;
				aluOpcode3 <= aluOpcode2;
			end if;
		end if;
	end process CW_PIPE;	
	
	-- to be modified
	
	--purpose: Generation of ALU OpCode
	--type   : combinational
	--inputs : OPCODE,FUNC
	--outputs: aluOpcode
	ALU_OP_CODE_P : process (OPCODE, FUNC)
	begin  -- process ALU_OP_CODE_P
		case conv_integer(unsigned(OPCODE)) is
	        --case of R type requires analysis of FUNC
			when 0 =>
				case conv_integer(unsigned(FUNC)) is
					when 1 => aluOpcode_i <= ADD; 	
					when 2 => aluOpcode_i <= SUB; 	
					when 3 => aluOpcode_i <= BITAND;
					when 4 => aluOpcode_i <= BITOR; 
					when others => aluOpcode_i <= IDLE;
				end case;
			when 1  => aluOpcode_i <= ADD; 		
			when 2  => aluOpcode_i <= SUB; 		
			when 3  => aluOpcode_i <= BITAND; 	
			when 4  => aluOpcode_i <= BITOR;  	
			when 5  => aluOpcode_i <= ADD; 		
			when 6  => aluOpcode_i <= SUB; 		
			when 7  => aluOpcode_i <= BITAND; 	
			when 8  => aluOpcode_i <= BITOR;  	
			when 9  => aluOpcode_i <= ADD;   	
			when 10 => aluOpcode_i <= BITOR; 	
			when 11 => aluOpcode_i <= BITOR; 	
			when 12 => aluOpcode_i <= ADD; 		
			when 13 => aluOpcode_i <= ADD; 		
			when 14 => aluOpcode_i <= ADD; 		
			when others => aluOpcode_i <= IDLE;
		end case;
	end process ALU_OP_CODE_P;
	
	
end Implementation;