library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity Boothmul is 
	generic (	N : 	integer := 32);
	port( 	A,B : 	In std_logic_vector(N-1 downto 0);
			P 	: 	Out std_logic_vector((2*N)-1 downto 0));
end Boothmul;

architecture BEHAVIORAL of Boothmul is

	type SignalVector1 is array((N/2)-1 downto 0) of std_logic_vector(2 downto 0);
	type SignalVector2 is array((N/2)-1 downto 0) of std_logic_vector((2*N)-1 downto 0);
	type SignalVector3 is array((N/2) downto 1) of std_logic_vector((2*N)-1 downto 0);
		signal Sel, Ben										: SignalVector1;
		signal Aext1, Aext2, Addend, MinusAExt1, MinusAExt2	: SignalVector2;
		signal Sum											: SignalVector3;
		signal ext											: std_logic_vector(N-1 downto 0);
		signal Co											: std_logic_vector(N/2-1 downto 1);
		
	component mux51_generic is
		generic (	N: integer:= 8);
		port (	A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				C:	In	std_logic_vector(N-1 downto 0);
				D:	In	std_logic_vector(N-1 downto 0);
				E:	In	std_logic_vector(N-1 downto 0);
				S:	In	std_logic_vector(2 downto 0);
				Y:	Out	std_logic_vector(N-1 downto 0));
	end component;
	
	component p4adder is
		generic ( N: integer := 32); -- 4n bits
		port (	A	: in	std_logic_vector(N-1 downto 0);
				B	: in	std_logic_vector(N-1 downto 0);
				Cin	: in	std_logic;
				S	: out	std_logic_vector(N-1 downto 0);
				Cout: out	std_logic);
	end component;
	
	component Boothencoder is
		port( 	B	:	In std_logic_vector(2 downto 0);
				S	:	Out std_logic_vector(2 downto 0));
	end component;
	
	
begin
	
	ext <= (others => A(N-1));
	
	Ben(0) <= B(1 downto 0) & '0';
	Bgen: for i in 1 to (N/2)-1 generate
		Ben(i)(0) <= B(2*i-1);
		Ben(i)(1) <= B(2*i);
		Ben(i)(2) <= B(2*i+1);
	end generate Bgen;	

	Datapath: for i in 0 to N/2-1 generate
		inner1: if i=0 generate	
			Aext1(i) <= ext & A;
			MinusAExt1(i) <= not(Aext1(i))+1;
			Aext2(i) <= Aext1(i)((2*N)-2 downto 0) & '0';
			MinusAExt2(i) <= not(Aext2(i))+1;
			
			En0: 	Boothencoder 	port map 	(Ben(i),Sel(i));
			Mux0:	mux51_generic	generic map (2*N)
									port map 	((others => '0'), Aext1(i), MinusAExt1(i), Aext2(i), MinusAExt2(i), Sel(i), Sum(i+1));							
		end generate inner1;
		inner2: if i>0 generate
			Aext1(i) <= Aext2(i-1)((2*N)-2 downto 0) & '0';
			MinusAExt1(i) <= not(Aext1(i))+1;
			Aext2(i) <= Aext1(i)((2*N)-2 downto 0) & '0';
			MinusAExt2(i) <= not(Aext2(i))+1;
			
			Eni: 	Boothencoder 	port map 	(Ben(i),Sel(i));
			Muxi:	mux51_generic	generic map (2*N)
									port map 	((others => '0'), Aext1(i), MinusAExt1(i), Aext2(i), MinusAExt2(i), Sel(i), Addend(i));
			Addi:	p4adder			generic map	(2*N)
									port map	(Addend(i), Sum(i), '0', Sum(i+1), Co(i));
		end generate inner2;
	end generate Datapath;
	
	P <= Sum(N/2);
	
end BEHAVIORAL;