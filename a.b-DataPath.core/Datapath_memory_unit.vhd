library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity MemoryUnit 
	generic(Nbit:		integer := 32;
			Addr_bit:	integer := 5);
	port(	CLK: 			in	std_logic;
			RST:			in	std_logic;
			REG_EN_M:		in	std_logic;
			--Branch_taken:	in	std_logic;
			DataIn_DMem:	in	std_logic_vector(Nbit-1 downto 0);
			DataIn_ALU:		in	std_logic_vector(Nbit-1 downto 0);
			DataIn_RegB:	in	std_logic_vector(Nbit-1 downto 0);
			WR_Addr_E:		in	std_logic_vector(Addr_bit-1 downto 0);
			DataOut_Load:	out std_logic_vector(Nbit-1 downto 0);
			DataOut_Branch:	out std_logic_vector(Nbit-1 downto 0);
			WB_Address:		out std_logic_vector(Addr_bit-1 downto 0);
			DataOut_Store:	out std_logic_vector(Nbit-1 downto 0);
			Addr_DMem:		out	std_logic_vector(Nbit-1 downto 0));
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
	Addr_DMem <= DataIn_ALU;
	DataOut_Store <= DataIn_RegB;
	
	LMD: D_Reg_generic
		generic map(Nbit);
		port map(DataIn_DMem,CLK,RST,REG_EN_M,DataOut_Load);
	BRANCH_REG: D_Reg_generic
		generic map(Nbit);
		port map(DataIn_ALU,CLK,RST,REG_EN_M,DataOut_Branch);
	REGWR: D_Reg_generic
		generic map(Addr_bit);
		port map(WR_Addr_E,CLK,RST,REG_EN_M,WB_Address);
		
end Structural;