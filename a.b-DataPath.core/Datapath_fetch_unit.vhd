library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity FetchUnit is
	generic(Nbit:		integer := 32;
			Iram_bit:	integer := 10);
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
	end FetchUnit;
	
architecture Behavioral of FetchUnit is
	signal FOUR_SIG,PCToAdder,AdderToNPC:	std_logic_vector(Iram_bit-1 downto 0);
	signal NPC_input:						std_logic_vector(Nbit-1 downto 0);
	signal JRtoJ_PC,JtoPC:					std_logic_vector(Iram_bit-1 downto 0);
	signal J_Br_Sel:						std_logic;
	
	component D_Reg_generic
		generic (N: integer := 32);
		port (	D:		in	std_logic_vector(N-1 downto 0);
				CLK:	in	std_logic;
				RESET:	in	std_logic;
				ENABLE:	in	std_logic;
				Q:		out	std_logic_vector(N-1 downto 0));
	end component;
	
	component MUX21_GENERIC
		generic (N: integer := 32);
		port (	A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				S:	in	std_logic;
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;
	
	component RCA_gen is 
		generic (N: integer := 8);
		port (	A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				Ci:	In	std_logic;
				S:	Out	std_logic_vector(N-1 downto 0);
				Co:	Out	std_logic);
	end component;
	
begin
	
	FOUR_SIG <= conv_std_logic_vector(1, Iram_bit);
	
	Opcode <= IMem_Instr(31 downto 26);
	Func <= IMem_Instr(10 downto 0);
	
	NPC_input <= (Nbit-1 downto Iram_bit => '0') & AdderToNPC;
	
	J_Br_Sel <= J_Sel OR Br_taken;
	
	MuxJR: MUX21_GENERIC
		generic map(Iram_bit)
		port map(AdderToNPC,Jr_addr,Jr_Sel,JRtoJ_PC);
	MuxJ: MUX21_GENERIC
		generic map(Iram_bit)
		port map(JRtoJ_PC,J_addr,J_Br_Sel,JtoPC);
	PC:	D_Reg_generic
		generic map(Iram_bit)
		port map(AdderToNPC,CLK,RST,PC_EN,PCToAdder);	
	IR: D_Reg_generic
		generic map(Nbit)
		port map(IMem_Instr,CLK,RST,IR_EN,InstrToDecode);
	ADDER: RCA_gen
		generic map(Iram_bit)
		port map(PCToAdder,FOUR_SIG,'0',AdderToNPC,open);
	NPC: D_Reg_generic
		generic map(Nbit)
		port map(NPC_input,CLK,RST,NPC_EN,NPCToDecode);
		
	IMem_Addr <= PCToAdder;

end Behavioral; 