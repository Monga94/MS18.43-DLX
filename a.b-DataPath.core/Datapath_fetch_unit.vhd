library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity FetchUnit is
	generic(Nbit: integer := 32);
	port(	CLK: 			in	std_logic;
			RST:			in	std_logic;
			IR_EN:      	in	std_logic;
			NPC_EN:     	in	std_logic;
			PC_EN:			in	std_logic;
			--AddIn_Mux:		in	std_logic_vector(Nbit-1 downto 0);
			IMem_Instr:		in	std_logic_vector(Nbit-1 downto 0);			
			IMem_Addr:		out std_logic_vector(Nbit-1 downto 0);
			InstrToDecode:	out std_logic_vector(Nbit-1 downto 0);
			NPCToDecode:	out std_logic_vector(Nbit-1 downto 0);
			Opcode:			out std_logic_vector(5 downto 0);
			Func:			out std_logic_vector(10 downto 0));
	end FetchUnit;
	
architecture Behavioral of FetchUnit is
	signal FOUR_SIG,PCToAdder,AdderToNPC: std_logic_vector(31 downto 0);
	
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
		port (	A:	in	std_logic_vector(N-1 downto 0) ;
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
	
	FOUR_SIG <= "0x0001";
	
	Opcode <= IMem_Instr(31 downto 26);
	Func <= IMem_Instr(10 downto 0);
	
	PC:	D_Reg_generic
		generic map(Nbit);
		port map(AdderToNPC,CLK,RST,PC_EN,PCToAdder);	
	IR: D_Reg_generic
		generic map(Nbit);
		port map(IMem_Instr,CLK,RST,IR_EN,InstrToDecode);
	ADDER: RCA_gen
		generic map(Nbit);
		port map(PCToAdder,FOUR_SIG,'0',AdderToNPC,open);
	NPC: D_Reg_generic
		generic map(Nbit);
		port map(AdderToNPC,CLK,RST,NPC_EN,NPC_Addr);
		
	IMem_Addr <= PCToAdder;

end Behavioral; 