library ieee;
use ieee.std_logic_1164.all;
use work.logarithm.all;

package myStuff is
	constant Nbit		: integer := 32;
	constant Nreg		: integer := 32;
	constant IRAM_DEPTH	: integer := 10;
	constant DRAM_DEPTH	: integer := 10;
	constant RF_SIZE	: integer := 5;

-- Control unit input sizes
    constant OP_CODE_SIZE	: integer := 6;                                     			-- OPCODE field size
    constant FUNC_SIZE		: integer := 11;                                    			-- FUNC field size
	constant OP_NUMB		: integer := 27;												-- Number Of Operations that can be executed
	constant F_CTRL			: integer := 3;	
	constant D_CTRL			: integer := 8;	
	constant E_CTRL			: integer := 10;	
	constant M_CTRL			: integer := 6;	
	constant WB_CTRL		: integer := 3;	
	constant CW_SIZE		: integer := F_CTRL+D_CTRL+E_CTRL+M_CTRL+WB_CTRL;				-- Control Word Size
		
	constant NopALU			: integer := 18;	
	constant SelALU			: integer := log2_N(NopALU);	
	
-- R-Type instruction -> OPCODE field	
    constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";				-- for ADD, SUB, AND, OR register-to-register operation
	
-- R-Type instructions -> FUNC field
    constant RTYPE_NOP		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";	-- r,0x00
    constant RTYPE_SLL		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000100";	-- r,0x04
    constant RTYPE_SRL		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000110";	-- r,0x06
    constant RTYPE_SRA		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000111";	-- r,0x07
    constant RTYPE_ROL		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001000";	-- r,0x08
    constant RTYPE_ROR		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001001";	-- r,0x09
	constant RTYPE_MULT		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001110";	-- r,0x0e
	constant RTYPE_ADD		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100000";	-- r,0x20
    constant RTYPE_ADDU		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100001";	-- r,0x21
    constant RTYPE_SUB		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100010";	-- r,0x22
    constant RTYPE_SUBU		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100011";	-- r,0x23
    constant RTYPE_AND		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100100";	-- r,0x24
	constant RTYPE_OR 		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100101";	-- r,0x25
    constant RTYPE_XOR		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100110";	-- r,0x26
    constant RTYPE_SEQ		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101000";	-- r,0x28
    constant RTYPE_SNE		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101001";	-- r,0x29
    constant RTYPE_SLT		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101010";	-- r,0x2a
	constant RTYPE_SGT		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101011";	-- r,0x2b
    constant RTYPE_SLE		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101100";	-- r,0x2c
    constant RTYPE_SGE		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101101";	-- r,0x2d
    constant RTYPE_SLTU		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111010";	-- r,0x3a
    constant RTYPE_SGTU		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111011";	-- r,0x3b
	constant RTYPE_SLEU		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111100";	-- r,0x3c
	constant RTYPE_SGEU		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111101";	-- r,0x3d
	
-- J-Type instructions -> OPCODE field
    constant JTYPE_J		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000010";		-- j,0x02
    constant JTYPE_JAL		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";		-- j,0x03
    constant JTYPE_JR		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010010";		-- jr,0x12
    constant JTYPE_JALR		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010011";		-- jr,0x13
	
-- I-TYPE instructions -> OPCODE field
	constant ITYPE_BEQZ		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000100";		-- b0,0x04
	constant ITYPE_BNEZ		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000101";		-- b0,0x05
	constant ITYPE_ADDI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001000";		-- i,0x08
	constant ITYPE_ADDUI	: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001001";		-- i,0x09
	constant ITYPE_SUBI 	: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001010";		-- i,0x0a
	constant ITYPE_SUBUI	: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001011";		-- i,0x0b
	constant ITYPE_ANDI 	: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001100";		-- i,0x0c
	constant ITYPE_ORI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001101";		-- i,0x0d
	constant ITYPE_XORI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001110";		-- i,0x0e
	constant ITYPE_LHI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001111";		-- i1,0x0f
	constant ITYPE_SLLI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010100";		-- i,0x14
	constant ITYPE_NOP		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010101";		-- n,0x15
	constant ITYPE_SRLI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010110";		-- i,0x16
	constant ITYPE_SRAI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010111";		-- i,0x17
	constant ITYPE_SEQI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011000";		-- i,0x18
	constant ITYPE_SNEI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011001";		-- i,0x19
	constant ITYPE_SLTI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011010";		-- i,0x1a
	constant ITYPE_SGTI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011011";		-- i,0x1b
	constant ITYPE_SLEI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011100";		-- i,0x1c
	constant ITYPE_SGEI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011101";		-- i,0x1d
	constant ITYPE_ROLI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011110";		-- i,0x1e
	constant ITYPE_RORI		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011111";		-- i,0x1f
	constant ITYPE_LB		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100000";		-- l,0x20
	constant ITYPE_LH		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100001";		-- l,0x21
	constant ITYPE_LW		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100011";		-- l,0x23
	constant ITYPE_LBU		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100100";		-- l,0x24
	constant ITYPE_LHU		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100101";		-- l,0x25
	constant ITYPE_SB		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101000";		-- s,0x28
	constant ITYPE_SH		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101001";		-- s,0x29
	constant ITYPE_SW		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101011";		-- s,0x2b
	constant ITYPE_SLTUI	: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111010";		-- i,0x3a
	constant ITYPE_SGTUI	: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111011";		-- i,0x3b
	constant ITYPE_SLEUI	: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111100";		-- i,0x3c
	constant ITYPE_SGEUI	: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111101";		-- i,0x3d
	
-- Alu Possible Operations
	subtype AluOp is std_logic_vector(SelALU-1 downto 0);
	
-- Alu Select codes
	constant ALU_ANDop		: std_logic_vector(SelALU-1 downto 0) := "00000";
	constant ALU_ORop		: std_logic_vector(SelALU-1 downto 0) := "00001";
	constant ALU_XORop		: std_logic_vector(SelALU-1 downto 0) := "00010";
	constant ALU_ADDop		: std_logic_vector(SelALU-1 downto 0) := "00011";
	constant ALU_SUBop		: std_logic_vector(SelALU-1 downto 0) := "00100";
	constant ALU_SLLop		: std_logic_vector(SelALU-1 downto 0) := "00101";
	constant ALU_SRLop		: std_logic_vector(SelALU-1 downto 0) := "00110";
	constant ALU_SRAop		: std_logic_vector(SelALU-1 downto 0) := "00111";
	constant ALU_ROLop		: std_logic_vector(SelALU-1 downto 0) := "01000";
	constant ALU_RORop		: std_logic_vector(SelALU-1 downto 0) := "01001";
	constant ALU_AneBop		: std_logic_vector(SelALU-1 downto 0) := "01010";
	constant ALU_AeqBop		: std_logic_vector(SelALU-1 downto 0) := "01011";
	constant ALU_AgtBop		: std_logic_vector(SelALU-1 downto 0) := "01100";
	constant ALU_AgeBop		: std_logic_vector(SelALU-1 downto 0) := "01101";
	constant ALU_AltBop		: std_logic_vector(SelALU-1 downto 0) := "01110";
	constant ALU_AleBop		: std_logic_vector(SelALU-1 downto 0) := "01111";
	constant ALU_MULTop		: std_logic_vector(SelALU-1 downto 0) := "10000";
	constant ALU_NOPop		: std_logic_vector(SelALU-1 downto 0) := "11111";

-- CW word
																	-- FFFDDDDDDDDEEEEEEEEEEMMMMMMWWW 
																	-- 123123456781234567890123456123
	constant CW_RTYPE_ADD	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010010000100000011"; --ADD 
	constant CW_RTYPE_ADDU	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010000000100000011"; --ADDU
	constant CW_RTYPE_SUB	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010010000100000011"; --SUB	
	constant CW_RTYPE_SUBU	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010000000100000011"; --SUBU	
	constant CW_RTYPE_AND	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010000000100000011"; --AND    
	constant CW_RTYPE_OR 	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010000000100000011"; --OR  
	constant CW_RTYPE_XOR	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010000000100000011"; --XOR
	constant CW_RTYPE_SLL	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010000000100000011"; --SLL
	constant CW_RTYPE_SRL	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010000000100000011"; --SRL
	constant CW_RTYPE_SRA	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010010000100000011"; --SRA
	constant CW_RTYPE_ROL	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010000000100000011"; --ROL
	constant CW_RTYPE_ROR	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010000000100000011"; --ROR
	constant CW_RTYPE_SGT	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010010000100000011"; --SGT
	constant CW_RTYPE_SGTU	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010000000100000011"; --SGTU
	constant CW_RTYPE_SGE	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010010000100000011"; --SGE
	constant CW_RTYPE_SGEU	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010000000100000011"; --SGEU
	constant CW_RTYPE_SEQ	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010010000100000011"; --SEQ
	constant CW_RTYPE_SLE	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010010000100000011"; --SLE
	constant CW_RTYPE_SLEU	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010000000100000011"; --SLEU
	constant CW_RTYPE_SLT	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010010000100000011"; --SLT
	constant CW_RTYPE_SLTU	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010000000100000011"; --SLTU
	constant CW_RTYPE_SNE	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010010000100000011"; --SNE
	constant CW_RTYPE_MULT	: std_logic_vector(CW_SIZE-1 downto 0) := "111111000101010010000100000011"; --MULT	
	constant CW_RTYPE_NOP	: std_logic_vector(CW_SIZE-1 downto 0) := "010100000001000000000000000000"; --NOP
	
	constant CW_ITYPE_ADDI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110010001010110000100000011"; --ADDI		
	constant CW_ITYPE_ADDUI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010100000100000011"; --ADDUI  
	constant CW_ITYPE_SUBI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110010001010110000100000011"; --SUBI   
	constant CW_ITYPE_SUBUI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010100000100000011"; --SUBUI  
	constant CW_ITYPE_ANDI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010100000100000011"; --ANDI 
	constant CW_ITYPE_ORI   : std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010100000100000011"; --ORI
	constant CW_ITYPE_XORI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010100000100000011"; --XORI
	constant CW_ITYPE_SLLI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010100000100000011"; --SLLI
	constant CW_ITYPE_SRLI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010100000100000011"; --SRLI
	constant CW_ITYPE_SRAI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010110000100000011"; --SRAI
	constant CW_ITYPE_ROLI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010100000100000011"; --ROLI
	constant CW_ITYPE_RORI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010100000100000011"; --RORI
	constant CW_ITYPE_SGTI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110010001010110000100000011"; --SGTI
	constant CW_ITYPE_SGTUI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010100000100000011"; --SGTUI
	constant CW_ITYPE_SGEI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110010001010110000100000011"; --SGEI
	constant CW_ITYPE_SGEUI : std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010100000100000011"; --SGEUI
	constant CW_ITYPE_SEQI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110010001010110000100000011"; --SEQI
	constant CW_ITYPE_SLEI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110010001010110000100000011"; --SLEI
	constant CW_ITYPE_SLEUI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010100000100000011"; --SLEUI
	constant CW_ITYPE_SLTI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110010001010110000100000011"; --SLTI
	constant CW_ITYPE_SLTUI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110000001010100000100000011"; --SLTUI
	constant CW_ITYPE_SNEI	: std_logic_vector(CW_SIZE-1 downto 0) := "111110010001010110000100000011"; --SNEI
	
	constant CW_ITYPE_BEQZ  : std_logic_vector(CW_SIZE-1 downto 0) := "111110010000000110101000000000"; --BEQZ
	constant CW_ITYPE_BNEZ  : std_logic_vector(CW_SIZE-1 downto 0) := "111110010000000110111000000000"; --BNEZ
	constant CW_JTYPE_J	    : std_logic_vector(CW_SIZE-1 downto 0) := "111100110000000111001000000000"; --J
	constant CW_JTYPE_JR	: std_logic_vector(CW_SIZE-1 downto 0) := "111010000010000000000000000000"; --JR
	constant CW_JTYPE_JAL	: std_logic_vector(CW_SIZE-1 downto 0) := "111100110001000111001100000111"; --JAL
	constant CW_JTYPE_JALR  : std_logic_vector(CW_SIZE-1 downto 0) := "111110001011000000000100000101"; --JALR
	constant CW_ITYPE_LHI   : std_logic_vector(CW_SIZE-1 downto 0) := "111101100001100100000100000011"; --LHI
	
	constant CW_ITYPE_LW	: std_logic_vector(CW_SIZE-1 downto 0) := "111110010001010110001111100001"; --LW
	constant CW_ITYPE_LB	: std_logic_vector(CW_SIZE-1 downto 0) := "111110010001010110001111001001"; --LB
	constant CW_ITYPE_LBU	: std_logic_vector(CW_SIZE-1 downto 0) := "111110010001010110001111000001"; --LBU
	constant CW_ITYPE_LH	: std_logic_vector(CW_SIZE-1 downto 0) := "111110010001010110001111011001"; --LH
	constant CW_ITYPE_LHU	: std_logic_vector(CW_SIZE-1 downto 0) := "111110010001010110001111010001"; --LHU
	constant CW_ITYPE_SW    : std_logic_vector(CW_SIZE-1 downto 0) := "111111010001010110001010100000"; --SW
	constant CW_ITYPE_SB	: std_logic_vector(CW_SIZE-1 downto 0) := "111111010001010110001010000000"; --SB
	constant CW_ITYPE_SH	: std_logic_vector(CW_SIZE-1 downto 0) := "111111010001010110001010010000"; --SH
	
	constant CW_ITYPE_NOP   : std_logic_vector(CW_SIZE-1 downto 0) := "010100000001000000000000000000"; --NOP
	
end myStuff;                