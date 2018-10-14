library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity RCA_gen is 
	generic ( N: integer := 8);
	port (	A:	In	std_logic_vector(N-1 downto 0);
			B:	In	std_logic_vector(N-1 downto 0);
			Ci:	In	std_logic;
			S:	Out	std_logic_vector(N-1 downto 0);
			Co:	Out	std_logic);
end RCA_gen;

architecture STRUCTURAL of RCA_gen is

	signal CTMP : std_logic_vector(N downto 0);

	component FA
		port (	A:	In	std_logic;
				B:	In	std_logic;
				Ci:	In	std_logic;
				S:	Out	std_logic;
				Co:	Out	std_logic);
	end component; 

begin

	CTMP(0) <= Ci;
	Co <= CTMP(N);
  
	ADDER1: for i in 0 to N-1 generate
		FAI : FA
			port map (A(i), B(i), CTMP(i), S(i), CTMP(i+1)); 
	end generate;

end STRUCTURAL;