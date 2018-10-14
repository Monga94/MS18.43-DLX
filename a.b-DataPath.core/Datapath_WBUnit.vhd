library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity WritebackUnit is 
	generic(Nbit: integer := 32);
	port(	CLK:	in std_logic;
			RST:	in std_logic;
			WB_EN:	in std_logic;
			WBMux_sel:	in std_logic;
			DataIn_DMem:	in std_logic_vector(Nbit-1);
			DataIn_ALU:		in std_logic_vector(Nbit-1);
			WB_DataOut:		out std_logic_vector(Nbit-1));			
end WritebackUnit;

architecture Structural of WritebackUnit is

	component MUX21_GENERIC
		generic ( N: integer := 32);
		port (	A:	in	std_logic_vector(N-1 downto 0) ;
				B:	in	std_logic_vector(N-1 downto 0);
				S:	in	std_logic;
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;
	
	component D_Reg_generic
		generic (N: integer := 32);
		port (	D:		in	std_logic_vector(N-1 downto 0);
				CLK:	in	std_logic;
				RESET:	in	std_logic;
				ENABLE:	in	std_logic;
				Q:		out	std_logic_vector(N-1 downto 0));
	end component;
	
begin

	WB_MUX: MUX21_GENERIC 
		generic map();
		port map(DataIn_DMem,DataIn_ALU,WBMux_sel,WBMux_DataOut);
	WB_REG: D_Reg_generic	
		generic map();
		port map(WBMux_DataOut,CLK,RST,WB_EN,WB_DataOut);

end Structural;