--Nbit,active high,asynchronous reset register with enable
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myStuff.all;

entity reg is
    generic(N : integer := 32);
    port( clk 		: in 	std_logic;
          rst_n 	: in 	std_logic;
          enable 	: in 	std_logic;
          data_in 	: in 	std_logic_vector(N-1 downto 0);
          data_out 	: out 	std_logic_vector(N-1 downto 0)); 
end reg;

architecture behavioural of reg is

begin
	reg_proc : process(rst_n,clk)
	begin
		if rst_n = '0' then
			data_out <= (others => '0'); 
		elsif(enable = '1') then
			if(clk'event and clk = '1') then
				data_out <= data_in ;
			end if;
		end if;
	end process;

end behavioural;
