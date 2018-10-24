library IEEE;

use IEEE.std_logic_1164.all;
use WORK.myStuff.all;


entity TB_FETCH is
end TB_FETCH;

architecture Test of TB_FETCH is

constant Nbit := 32;
signal 

component FetchUnit is
	generic(Nbit: integer := 32);
	port(	CLK: 			in	std_logic;
			RST:			in	std_logic;
			IR_EN:      	in	std_logic;
			NPC_EN:     	in	std_logic;
			PC_EN:			in	std_logic;
			--AddIn_Mux:		in	std_logic_vector(Nbit-1 downto 0);
			IMem_Instr:		in	std_logic_vector(Nbit-1 downto 0);
			InstrToDecode:	out std_logic_vector(Nbit-1 downto 0);
			NPCToDecode:	out std_logic_vector(Nbit-1 downto 0);			
			IMem_Addr:		out std_logic_vector(Nbit-1 downto 0);
			Opcode:			out std_logic_vector(OP_CODE_SIZE-1 downto 0);
			Func:			out std_logic_vector(FUNC_SIZE-1 downto 0));
end component;

component IRAM is
	generic (	RAM_DEPTH	: integer := 32;
				I_SIZE		: integer := 32);
	port (	Rst  : in  std_logic;
			Addr : in  std_logic_vector(RAM_DEPTH - 1 downto 0);
			Dout : out std_logic_vector(I_SIZE - 1 downto 0));
end component;


begin









PCLOCK : process(Clock)
	begin
		Clock <= not(Clock) after 0.5 ns;	
	end process;
	
	
end Test;