library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.logarithm.all;

entity register_file_gen is
	generic (	Nbit:	integer := 64;
				Nreg:	integer := 32);
	port 	( 	CLK: 		in std_logic;
				RESET: 		in std_logic;
				ENABLE: 	in std_logic;
				WR: 		in std_logic;
				RD1: 		in std_logic;
				RD2: 		in std_logic;
				ADD_WR: 	in std_logic_vector(log2_N(Nreg)-1 downto 0);
				ADD_RD1: 	in std_logic_vector(log2_N(Nreg)-1 downto 0);
				ADD_RD2: 	in std_logic_vector(log2_N(Nreg)-1 downto 0);
				DATAIN: 	in std_logic_vector(Nbit-1 downto 0);
				OUT1: 		out std_logic_vector(Nbit-1 downto 0);
				OUT2: 		out std_logic_vector(Nbit-1 downto 0));
end register_file_gen;

architecture BEHAVIORAL of register_file_gen is

        -- suggested structures
    subtype REG_ADDR is natural range 0 to Nreg-1; -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(Nbit-1 downto 0); 
	signal REGISTERS:	REG_ARRAY; 
	constant LogN:		natural := log2_N(Nreg);
	
begin 

	process(CLK, ADD_WR, ADD_RD1, ADD_RD2)
		variable ADDW, ADDR1, ADDR2 : REG_ADDR;
	begin 
		ADDW 	:= to_integer(unsigned(ADD_WR));
		ADDR1 	:= to_integer(unsigned(ADD_RD1));	
		ADDR2 	:= to_integer(unsigned(ADD_RD2));
		if CLK'event and CLK='1' then
			if RESET = '1' then
				for i in 0 to Nreg-1 loop
					REGISTERS(i) <= (others => '0');
				end loop;
				OUT1 <= (others => '0');
				OUT2 <= (others => '0');
			elsif ENABLE = '1' then
				if WR = '1' then
					REGISTERS(ADDW) <= DATAIN;
				end if;
				if RD1 = '1' then
					OUT1 <= REGISTERS(ADDR1);
				end if;
				if RD2 = '1' then
					OUT2 <= REGISTERS(ADDR2);
				end if;
			end if;
		end if;
	end process;

end BEHAVIORAL;