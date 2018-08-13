library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity Datapath is
	generic ( Nbit : integer := 32)
	port (	CLK:		in	std_logic;
			OPCODE:		out std_logic_vector(OP_CODE_SIZE - 1 downto 0);	
			FUNC:		out std_logic_vector(FUNC_SIZE - 1 downto 0); 	
			IRAM_EN:	in std_logic;
			RST:		in std_logic;
			IR_EN:      in std_logic;
			NPC_EN:     in std_logic;
			DEC_EN:     in std_logic;
			RF_RD1:     in std_logic;
			RF_RD2:     in std_logic;
			EXEC_EN:	in std_logic;
			MUXA_SEL:   in std_logic;
			MUXB_SEL:   in std_logic;
			ALU_SEL:    in std_logic;
			MEM_EN:     in std_logic;
			MEM_RD_WRn: in std_logic;
			RF_WR:		in std_logic;
			OUTDP:		out std_logic_vector(Nbit-1 downto 0);
end DatapathWB_Sel	;
            	
architecture Structural of Datapath is
	
	component D_Reg_generic
		generic (N: integer := 8);
		port (	D:		in	std_logic_vector(N-1 downto 0);
				CLK:	in	std_logic;
				RESET:	in	std_logic;
				ENABLE:	in	std_logic;
				Q:		out	std_logic_vector(N-1 downto 0));
	end component;
	
	component MUX21_GENERIC
		generic ( N: integer := 8);
		port (	A:	in	std_logic_vector(N-1 downto 0) ;
				B:	in	std_logic_vector(N-1 downto 0);
				S:	in	std_logic;
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;
	
	component ALU
		generic ( N : integer := 32);
		port ( FUNC			: in	AluOp;
			   DATA1, DATA2	: in 	std_logic_vector(N-1 downto 0);
			   OUTALU		: out 	std_logic_vector(N-1 downto 0));
	end component;
	
	component register_file_gen
		generic (	Nbit:	integer := 64;
					Nreg:	integer := 32);
		port 	( 	CLK: 		in std_logic;
					RESET: 		in std_logic;
					ENABLE: 	in std_logic;
					WR: 		in std_logic;
					RD1: 		in std_logic;
					RD2: 		in std_logic;
					ADD_WR: 	in std_logic_vector(log2_N(Nreg)-1 downto 0);
					ADD_RD1: 	in std_logic_vector(log2_N(Nreg)-1 downto 0);
					ADD_RD2: 	in std_logic_vector(log2_N(Nreg)-1 downto 0);
					DATAIN: 	in std_logic_vector(Nbit-1 downto 0);
					OUT1: 		out std_logic_vector(Nbit-1 downto 0);
					OUT2: 		out std_logic_vector(Nbit-1 downto 0));
	end component;
	
	component DRAM 
		generic (	B: integer:=8;
					L: integer:=10);
		port (	Data_In		: in	std_logic_vector(B-1 downto 0);
				Address		: in	std_logic_vector(L-1 downto 0);
				RD			: in	std_logic;
				CS			: in	std_logic;
				Data_Out	: out	std_logic_vector(B-1 downto 0));
	end component;
	
	component RCA_gen is 
		generic ( N: integer := 8);
		port (	A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				Ci:	In	std_logic;
				S:	Out	std_logic_vector(N-1 downto 0);
				Co:	Out	std_logic);
	end component;
	
	signal 	I_QUEUE : std_logic_vector(31 downto 0);
	signal	IN_PC,IN_NPC,OUT_PC,OUT_IRAM,OUT_COND,OUT1,OUT2,OUTA,OUT_ALU,OUTB,OUTDP,OUT_MUX_A,
			OUT_MUX_B,OUT_MUX_MEM,OUT_NPC,OUT_PC,OUT_REG_ALU : std_logic_vector();
	signal 	FETCH,JMP_EN,COUT_NPC :	std_logic;
	signal 	MUX3_SEL,MUX4_SEL : std_logic_vector(1 downto 0);
	signal 	FOUR_SIG : std_logic_vector();
	
begin
	PC:	D_Reg_generic
						generic map();
						port map(IN_PC,CLK,RST,FETCH,OUT_PC);
	IRAM: DRAM
						generic map();
						port map(I_QUEUE,OUT_PC,FETCH,IRAM_EN,OUT_IRAM);
	IR: D_Reg_generic
						generic map();
						port map(OUT_IRAM,CLK,RST,FETCH,OUT_IR);
	ADDER: RCA_gen
						generic map();
						port map(OUT_PC,FOUR_SIG,'0',IN_NPC,COUT_NPC);
	NPC: D_Reg_generic
						generic map();
						port map(IN_NPC,CLK,RST,FETCH,OUT_NPC);
	IMM: D_Reg_generic	
						generic map();
						port map(OUT_IR,CLK,RST,FETCH,OUT_IMM);
	RF: register_file_gen 	
						generic map();
						port map(CLK,RST,DEC_EN,RF_WR,RF_RD1,RF_RD2,OUT_ALU,OUT_IR(),OUT_IR(),OUTDP,OUT1,OUT2);
	REGA: D_Reg_generic	
						generic map();
						port map(OUT1,CLK,RST,DEC_EN,OUTA);
	REGB: D_Reg_generic	
						generic map();
						port map(OUT2,CLK,RST,DEC_EN,OUTB);
	MUX1: MUX21_GENERIC	
						generic map();
						port map(OUTA,OUT_NPC,MUXA_SEL,OUT_MUX_A);
	MUX2: MUX21_GENERIC	
						generic map();
						port map(OUTB,OUT_IMM,MUXB_SEL,OUT_MUX_B);
	ALU: ALU	
						generic map();
						port map(ALU_SEL,OUT_MUX_A,OUT_MUX_B,OUT_ALU);
	REGALUOUT: D_Reg_generic	
						generic map();
						port map(OUT_ALU,CLK,RST,EXEC_EN,OUT_REG_ALU);
	MUX4: MUX21_GENERIC
						generic map();
						port map(OUT_COND,OUT_NPC,MUX4_SEL,IN_PC);
	MUX_CTRL: MUX21_GENERIC
						generic map();
						port map(OUT_COND,'0',JMP_EN,OUT_MUX_MEM);
	MEM: DRAM
						generic map();
						port map(OUTB,OUT_REG_ALU,MEM_RD_WRn,MEM_EN,MEMOUT);
	MUX3: MUX21_GENERIC	
						generic map();
						port map(MEMOUT,OUT_REG_ALU,MUX3_SEL,OUT_MUX_MEM);
	REGMEM: D_Reg_generic	
						generic map();
						port map(OUT_MUX_MEM,CLK,RST,EN_REG_MEM,OUTDP);
	

end Structural;
