library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.BMEpar.all;

entity mux5to1 is
	port (	in0		: IN	std_logic_vector(nbit_pp-1 downto 0); --  0
			in1		: IN	std_logic_vector(nbit_pp-1 downto 0); -- +A
			in2		: IN	std_logic_vector(nbit_pp-1 downto 0); -- +2A
			in3		: IN	std_logic_vector(nbit_pp-1 downto 0); -- -A
			in4		: IN	std_logic_vector(nbit_pp-1 downto 0); -- -2A
			output	: OUT	std_logic_vector(nbit_pp-1 downto 0);
			sel		: IN	std_logic_vector(nbit_enc-1 downto 0));
end mux5to1;

architecture arch of mux5to1 is
begin
	mux : process(in1, in2, in3, in4, sel)
	begin
		if sel = "000" then
			output <= in0; -- 0
		elsif sel = "001" then
			output <= in1; -- +A
		elsif sel = "010" then
			output <= in2; -- +2A
		elsif sel = "011" then
			output <= in3; -- -A
		elsif sel = "100" then
			output <= in4; -- -2A
		else
			output <= in0; --default
		end if;    
	end process;

end arch;
