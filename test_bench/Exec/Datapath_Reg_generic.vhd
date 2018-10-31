library IEEE;
use IEEE.std_logic_1164.all; 

entity D_Reg_generic is
	Generic (N: integer := 8);
	Port (	D:		In	std_logic_vector(N-1 downto 0);
			CLK:	In	std_logic;
			RESET:	In	std_logic;
			ENABLE:	In	std_logic;
			Q:		Out	std_logic_vector(N-1 downto 0));
end D_Reg_generic;

architecture ASYNC of D_Reg_generic is -- flip flop D with asyncronous reset

begin
	
	PASYNCH: process(CLK,RESET)
	begin
		if RESET='0' then
			Q <= (others => '0');
		elsif CLK'event and CLK='1' then -- positive edge triggered:
			if ENABLE='1' then
				Q <= D;
			end if;
		end if;
	end process;

end ASYNC;


