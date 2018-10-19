library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Boothmul is 
	generic (	N : 	integer := 8
				logN: 	integer := 3);
	port( 	A,B : 	In std_logic_vector(N-1 downto 0);
			P 	: 	Out std_logic_vector(N+logN downto 0));
end Boothmul;

architecture BEHAVIORAL of Boothmul is

	type SignalVector1 is array(logN-1 downto 0) of std_logic_vector(logN-1 downto 0);
	type SignalVector2 is array(logN-1 downto 0) of std_logic_vector(N+logN downto 0);
		signal Ben:						std_logic_vector(logN-1 downto 0);
		signal Sel:						SignalVector1;
		signal ANplusi:					std_logic_vector(N+logN-1 downto 0);
		signal Adouble,Adoubledouble:	std_logic_vector(N+logN downto 0);
		signal count:					integer := 1; 
		signal Addend:					SignalVector2;

	component mux51_generic is
		generic (	N: integer:= 32;
					DELAY_MUX: Time:= 0 ns);
		port (	A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				C:	In	std_logic_vector(N-1 downto 0);
				D:	In	std_logic_vector(N-1 downto 0);
				E:	In	std_logic_vector(N-1 downto 0);
				S:	In	std_logic_vector(3 downto 0);
				Y:	Out	std_logic_vector(N-1 downto 0));
	end component;
	
	component CSAdd is 
	generic (	N : integer := 32);
	port ( 	A, B 	: In	std_logic_vector(N-1 downto 0);	
			Ci		: In	std_logic; 
			S		: Out	std_logic_vector(N-1 downto 0));
	component CSAdd;
	
	component Boothencoder is
	port( 	B	:	In std_logic_vector(3);
			S	:	Out std_logic_vector(3);)
	end Boothencoder;
	
	
	begin
	
	Ben <= B(1 downto 0) & '0';
	
	Encoder: for i in 0 to logN-1 generate
				inner1: if i=0 generate	
							ANplusi(N downto 0) <= A(N-1) & A;
							gensignal1: for j in 1 to logN-1 generate 
											ANplusi(N+j downto 0) <= A(N-1) & ANplusi;
											Adouble <= ANplusi & '0';
							end generate;
							En0: 	Boothencoder 	port map 	(Ben,Sel(i)(logN-1 downto 0));
							Mux0:	mux51_generic	generic map (N+logN);
													port map 	((others <= '0'),ANplusi,-ANplusi,Adouble,-Adouble,Sel(i)(logN-1 downto 0),Addend(i)(N+logN downto 0));							
						end generate inner1;
				inner2:	if i>0 generate	
											Adouble <= Adouble(N+logN-1 downto 0) & '0';
											Adoubledouble <= Adouble(N+logN-1 downto 0) & '0';
							Eni: 	Boothencoder 	port map 	(B((count+2) downto count),Sel(i)(logN-1 downto 0));
							Muxi:	mux51_generic	generic map (N+logN);
													port map 	((others <= '0'),Adouble,-Adouble,Adoubledouble,-Adoubledouble,Sel(i)(logN-1 downto 0),Addend(i)(N+logN downto 0));
							Addi:	CSAdd			generic map	(N+logN);
													port map	(Addend(i-1)(N+logN downto 0),Addend(i)(N+logN downto 0),'0',P);
							count <= count+2;
						end generate inner2;

	
end BEHAVIORAL;