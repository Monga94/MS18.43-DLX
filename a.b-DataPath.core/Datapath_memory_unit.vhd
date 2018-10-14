library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity MemoryUnit 
	generic(Nbit: integer := 32);
	port(	CLK: 			in std_logic;
			RST:			in std_logic;
			LMD_EN:			in std_logic;
			Branch_taken:	in std_logic;
			DataIn_ALU:		in std_logic_vector(Nbit-1 downto 0);
			DataIn_DMem:	in std_logic_vector(Nbit-1 downto 0);
			DataIn_RegB:	in std_logic_vector(Nbit-1 downto 0);
			Add_DMem:		out	std_logic_vector(Nbit-1 downto 0);
			DataOut_Branch:	out std_logic_vector(Nbit-1 downto 0);
			DataOut_Load:	out std_logic_vector(Nbit-1 downto 0);
			DataOut_Store:	out std_logic_vector(Nbit-1 downto 0));	
end MemoryUnit;

architecture Structural of MemoryUnit is
	
	component D_Reg_generic
		generic (N: integer := 32);
		port (	D:		in	std_logic_vector(N-1 downto 0);
				CLK:	in	std_logic;
				RESET:	in	std_logic;
				ENABLE:	in	std_logic;
				Q:		out	std_logic_vector(N-1 downto 0));
	end component;
	
begin
	Add_DMem <= DataIn_ALU;
	DataOut_Store <= DataIn_RegB;
	
	LMD: D_Reg_generic
		generic map(Nbit);
		port map(DataIn_DMem,CLK,RST,LMD_EN,DataOut_Load);
	BRANCH_REG: D_Reg_generic
		generic map(Nbit);
		port map(DataIn_ALU,CLK,RST,LMD_EN,DataOut_Branch);
		
end Structural;