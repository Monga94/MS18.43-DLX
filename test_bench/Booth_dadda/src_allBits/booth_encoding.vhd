library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.BMEpar.all;

entity booth_encoder is
	port (	input	: IN	std_logic_vector(nbit_enc-1 downto 0);
			output	: OUT	std_logic_vector(nbit_enc-1 downto 0));
end booth_encoder;

architecture arch of booth_encoder is
begin

	encode : process(input)
	begin
		case(input) is
		
			when "000" => output <= "000"; --0
			when "111" => output <= "000";
			
			when "001" => output <= "001"; --+A
			when "010" => output <= "001";
		
			when "011" => output <= "010"; --+2A
		
			when "101" => output <= "011"; -- -A
			when "110" => output <= "011";
		
			when "100" => output <= "100"; -- -2A
			
			when others => output <= "000"; -- default
		
		end case;
	end process;
end arch;