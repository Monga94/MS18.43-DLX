library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use WORK.constants.all; -- libreria WORK user-defined

entity mux51_generic is
	generic (	N: integer:= 4;
				DELAY_MUX: Time:= 0 ns);
		
	port (		A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				C:	In	std_logic_vector(N-1 downto 0);
				D:	In	std_logic_vector(N-1 downto 0);
				E:	In	std_logic_vector(N-1 downto 0);
				S:	In	std_logic_vector(2 downto 0);
				Y:	Out	std_logic_vector(N-1 downto 0));
end mux51_generic;


architecture BEHAVIORAL of MUX21_GENERIC is

begin
	pmux: process(A,B,S)
	
	begin
	
		case S is
			when "001" => Y <= B;
			when "010" => Y <= C;
			when "011" => Y <= D;
			when "100" => Y <= E;
			when others => Y <= A;
		end case;
		
	end process;

end BEHAVIORAL;


configuration CFG_MUX21_GENERIC_BEHAVIORAL of MUX21_GENERIC is
	for BEHAVIORAL
	end for;
end CFG_MUX21_GENERIC_BEHAVIORAL;


