library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myStuff.all;

entity WritebackUnit is 
	generic(Nbit: integer := 32);
	port(	CLK:			in	std_logic;
			RST:			in	std_logic;
			WBMux_sel:		in	std_logic_vector(1 downto 0);
			NPC8:			in	std_logic_vector(Nbit-1 downto 0);
			NPC12:			in	std_logic_vector(Nbit-1 downto 0);
			DataIn_DMem:	in	std_logic_vector(Nbit-1 downto 0);
			DataIn_ALU:		in	std_logic_vector(Nbit-1 downto 0);
			WB_DataOut:		out std_logic_vector(Nbit-1 downto 0));			
end WritebackUnit;

architecture Structural of WritebackUnit is

	component mux41_generic
		generic (	N: integer:= 32);
		port (		A:	In	std_logic_vector(N-1 downto 0);
					B:	In	std_logic_vector(N-1 downto 0);
					C:	In	std_logic_vector(N-1 downto 0);
					D:	In	std_logic_vector(N-1 downto 0);
					S:	In	std_logic_vector(1 downto 0);
					Y:	Out	std_logic_vector(N-1 downto 0));
	end component;
	
begin

	WB_MUX: mux41_generic 
		generic map(Nbit)
		port map(DataIn_DMem,DataIn_ALU,NPC8,NPC12,WBMux_sel,WB_DataOut);

end Structural;