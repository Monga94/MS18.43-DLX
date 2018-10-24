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
    constant OP_CODE_SIZE	: integer := 6;                                     		-- OPCODE field size
    constant FUNC_SIZE		: integer := 11;                                    		-- FUNC field size
	constant OP_NUMB		: integer := 27;											-- Number Of Operations that can be executed
	constant F_CTRL			: integer := 3;
	constant D_CTRL			: integer := 5;
	constant E_CTRL			: integer := 4;
	constant M_CTRL			: integer := 3;
	constant WB_CTRL		: integer := 2;
	constant CW_SIZE		: integer := F_CTRL+D_CTRL+E_CTRL+M_CTRL+WB_CTRL;			-- Control Word Size
	
	constant NopALU			: integer := 16;

-- R-Type instruction -> OPCODE field
    constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";		-- for ADD, SUB, AND, OR register-to-register operation
	
-- R-Type instructions -> FUNC field
    constant RTYPE_NOP		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";	-- r,0x00
    constant RTYPE_SLL		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000100";	-- r,0x04
    constant RTYPE_SRL		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000110";	-- r,0x06
    constant RTYPE_SRA		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000111";	-- r,0x07
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
	--constant RTYPE_MULT		: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001110";	-- r,0x0e
	
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
	subtype AluOp is std_logic_vector(log2_N(NopALU)-1 downto 0);
	--(ADD, SUB, BITAND, BITOR, BITXOR, FUNCLSL, FUNCLSR, FUNCRL, FUNCRR, FUNCASR, NOP);
	
-- Alu Output select codes
	constant ALU_ADDop		: AluOp := "0000";
	constant ALU_SUBop		: AluOp := "0001";
	constant ALU_ANDop		: AluOp := "0010";
	constant ALU_ORop		: AluOp := "0011";
	constant ALU_XORop		: AluOp := "0100";
	constant ALU_SLLop		: AluOp := "0101";
	constant ALU_SRLop		: AluOp := "0110";
	constant ALU_SRAop		: AluOp := "0111";
	constant ALU_RORop		: AluOp := "1000";
	constant ALU_ROLop		: AluOp := "1001";
	constant ALU_AeqBop		: AluOp := "1010";
	constant ALU_AneBop		: AluOp := "1011";
	constant ALU_AgtBop		: AluOp := "1100";
	constant ALU_AgeBop		: AluOp := "1101";
	constant ALU_AltBop		: AluOp := "1110";
	constant ALU_AleBop		: AluOp := "1111";
	
	constant ALU_NOPop		: AluOp := "0000";
	-- constant ALU_ADDop		: AluOp := "0000";
	-- constant ALU_ADDop		: AluOp := "0000";
	-- constant ALU_ADDop		: AluOp := "0000";

end myStuff;

