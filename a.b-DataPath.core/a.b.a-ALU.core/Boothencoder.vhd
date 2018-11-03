library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
--use WORK.constants.all; -- libreria WORK user-defined

entity Boothencoder is
	port( 	B	:	In std_logic_vector(2 downto 0);
			S	:	Out std_logic_vector(2 downto 0));
end Boothencoder;

architecture BEHAVIORAL of Boothencoder is

	begin
		encoding: process(B)
		
		begin
			case B is
				when "000"	=>	S <= "000";
				when "001"	=>	S <= "001";
				when "010"	=>	S <= "001";
				when "011"	=>	S <= "011";
				when "100"	=>	S <= "100";
				when "101"	=>	S <= "010";
				when "110"	=>	S <= "010";
				when others	=>	S <= "000";
				end case;
				
		end process;
	
end BEHAVIORAL;