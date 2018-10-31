library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity CSAdd is 
	generic ( N: integer := 4);
	port ( 	A, B 	: In	std_logic_vector(N-1 downto 0);	
			Ci		: In	std_logic; 
			S		: Out	std_logic_vector(N-1 downto 0));
end CSAdd;

architecture STRUCTURAL of CSAdd is

	signal S1, S2	 	: std_logic_vector(N-1 downto 0);
    signal Cout0, Cout1 : std_logic;
	
	component RCA_gen
		generic ( N: integer := 4);
		port (	A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				Ci:	In	std_logic;
				S:	Out	std_logic_vector(N-1 downto 0);
				Co:	Out	std_logic);
	end component;
	
	component MUX21_GENERIC
		generic ( N: integer := 4);
		port (	A:	In	std_logic_vector(N-1 downto 0) ;
				B:	In	std_logic_vector(N-1 downto 0);
				S:	In	std_logic;
				Y:	Out	std_logic_vector(N-1 downto 0));
	end component;
	
begin 

	RCA1: RCA_gen 		
				generic map (N)
				port map (A, B, '0', S1, Cout0);
	RCA2: RCA_gen 		
				generic map (N)
				port map (A, B, '1', S2, Cout1);
	MUX: MUX21_GENERIC 	
				generic map (N)
				port map (S1, S2, Ci, S);

end STRUCTURAL;
	