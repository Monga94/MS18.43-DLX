library ieee;
use ieee.std_logic_1164.all;

package myStuff is

-- Control unit input sizes
    constant OP_CODE_SIZE : integer := 6;                                              	-- OPCODE field size
    constant FUNC_SIZE    : integer := 11;                                             	-- FUNC field size
	constant OP_NUMB 	  : integer := 27;  											-- Number Of Operations that can be executed
	constant CW_SIZE	  : integer := 13;                               	            -- Control Word Size
	
-- R-Type instruction -> FUNC field
    constant RTYPE_ADD : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000001";    -- ADD R1,R2,R3
    constant RTYPE_SUB : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000010";    -- SUB R1,R2,R3
    constant RTYPE_AND : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000011";    -- AND R1,R2,R3
	constant RTYPE_OR  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000100";    -- OR R1,R2,R3
	
    constant NOP 	   : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";

-- R-Type instruction -> OPCODE field
    constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";          -- for ADD, SUB, AND, OR register-to-register operation

-- I-Type instruction -> OPCODE field
    constant ITYPE_ADDI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000001";    -- ADDI1  R1,R2,INP1
    constant ITYPE_SUBI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000010";    -- SUBI1  R1,R2,INP1
    constant ITYPE_ANDI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";    -- ANDI1  R1,R2,INP1
    constant ITYPE_ORI1   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000100";    -- ORI1   R1,R2,INP1
	constant ITYPE_ADDI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000101";    -- ADDI2  R1,R2,INP2
    constant ITYPE_SUBI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000110";    -- SUBI2  R1,R2,INP2
    constant ITYPE_ANDI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000111";    -- ANDI2  R1,R2,INP2
    constant ITYPE_ORI2   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001000";    -- ORI2   R1,R2,INP2
    constant ITYPE_MOV    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001001";    -- MOV    R1,R2
    constant ITYPE_S_REG1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001010";    -- S_REG1 R1,R2,INP1
    constant ITYPE_S_REG2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001011";    -- S_REG2 R1,R2,INP2
    constant ITYPE_S_MEM2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001100";    -- S_MEM2 R1,R2,INP2
    constant ITYPE_L_MEM1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001101";    -- L_MEM1 R1,R2,INP1
    constant ITYPE_L_MEM2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001110";    -- L_MEM2 R1,R2,INP2
	constant NON_VALID    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001111";    -- IDLE
	
-- Pipe Instructions -> State	
	type AluOp is (ADD, SUB, MULT, BITAND, BITOR, BITXOR, FUNCLSL, FUNCLSR, FUNCRL, FUNCRR, AgeB, AleB, AneB, NOP);

end myStuff;

