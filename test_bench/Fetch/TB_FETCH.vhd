library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use WORK.myStuff.all;


entity TB_FETCH is
end TB_FETCH;

architecture Test of TB_FETCH is

	signal Clock,Rst,En_Reg : std_logic;
	signal IMem_to_fetch,Instruction,NPC 	: std_logic_vector(Nbit-1 downto 0);
	signal PC								: std_logic_vector(Iram_bit-1 downto 0);
	signal Opcode : std_logic_vector(5 downto 0);
	signal Func : std_logic_vector(10 downto 0);

	component FetchUnit is
		generic(Nbit:		integer := 32;
				Iram_bit:	integer := 10);
		port(	CLK: 			in	std_logic;
				RST:			in	std_logic;
				IR_EN:      	in	std_logic;
				NPC_EN:     	in	std_logic;
				PC_EN:			in	std_logic;
				--AddIn_Mux:		in	std_logic_vector(Nbit-1 downto 0);
				IMem_Instr:		in	std_logic_vector(Nbit-1 downto 0);
				InstrToDecode:	out std_logic_vector(Nbit-1 downto 0);
				NPCToDecode:	out std_logic_vector(Nbit-1 downto 0);			
				IMem_Addr:		out std_logic_vector(Iram_bit-1 downto 0);
				Opcode:			out std_logic_vector(OP_CODE_SIZE-1 downto 0);
				Func:			out std_logic_vector(FUNC_SIZE-1 downto 0));
	end component;

	component IRAM is
		generic (	RAM_DEPTH	: integer := 10;
					I_SIZE		: integer := 32);
		port (	Rst  : in  std_logic;
				Addr : in  std_logic_vector(RAM_DEPTH - 1 downto 0);
				Dout : out std_logic_vector(I_SIZE - 1 downto 0));
	end component;


begin

	DUT : FetchUnit
		generic map(Nbit,IRAM_DEPTH)
		port map(Clock,Rst,En_Reg,En_Reg,En_Reg,IMem_to_fetch,Instruction,NPC,PC,Opcode,Func);
	RAM : IRAM
		generic map(IRAM_DEPTH,Nbit)
		port map(Rst,PC,Instruction);
	TEST_P : process
	begin
		Rst <= '0';
		wait for 20 ns;
		Rst <= '1';
		En_Reg <= '1';
		wait for 1 ms;
		Rst <= '0';
		wait;
end process;
	PCLOCK : process(Clock)
	begin
		Clock <= not(Clock) after 5 ns;	
	end process;
	
	
end Test;