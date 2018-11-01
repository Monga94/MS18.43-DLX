library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.GLOBALS.all;

entity IIR_DF2_BME is
	port (	CLK 	: in std_logic;
			RST_N 	: in std_logic;
			DIN		: in	std_logic_vector(Nbit_ext-1 downto 0);
			VIN		: in	std_logic;
			DOUT	: out	std_logic_vector(Nbit_ext-1 downto 0);
			VOUT	: out	std_logic);
end IIR_DF2_BME;

architecture structural of IIR_DF2_BME is

	component SUM_node
		generic (	N: integer := 8;
					O: integer := 0);
		port (	A	: in	std_logic_vector(N-1 downto 0);
				B	: in	std_logic_vector(N-1 downto 0);
				S	: out	std_logic_vector(N-1 downto 0));	
	end component;

	component BME_node
		port (	A	: in	std_logic_vector(14 downto 0);
				B	: in	std_logic_vector(12 downto 0);
				M	: out	std_logic_vector(14 downto 0));	
	end component;

	component reg
		generic(N : integer := 32);
		port(	clk 		: in 	std_logic;
				rst_n 		: in 	std_logic;
				enable 		: in 	std_logic;
				data_in 	: in 	std_logic_vector(N-1 downto 0);
				data_out 	: out 	std_logic_vector(N-1 downto 0)); 
	end component;


	signal add00_reg00, reg00_mul01, mul01_reg02, reg02_add02 : std_logic_vector(Nbit_int - 1 downto 0);
	signal reg10_add00, mul11_reg12, reg12_add12, add12_reg102, reg102_add02 : std_logic_vector(Nbit_int - 1 downto 0);
	signal mul20_reg10, reg21_mul21, mul21_reg22, reg22_add12 : std_logic_vector(Nbit_int - 1 downto 0);

	signal data_in_ext,data_out_ext : std_logic_vector(Nbit_ext - 1 downto 0);
	signal data_in_comp : std_logic_vector(Nbit_int-Nbit_ext-1 downto 0);
	signal data_in,data_out : std_logic_vector(Nbit_int - 1 downto 0);

	signal ready : std_logic;

begin

	REG00 : reg 		generic map(Nbit_int)
						port map(CLK, RST_N, VIN, add00_reg00, reg00_mul01);
						
	REG02 : reg 		generic map(Nbit_int)
						port map(CLK, RST_N, VIN, mul01_reg02, reg02_add02);
						
	REG10 : reg 		generic map(Nbit_int)
						port map(CLK, RST_N, VIN, mul20_reg10, reg10_add00);
						
	REG12 : reg 		generic map(Nbit_int)
						port map(CLK, RST_N, VIN, mul11_reg12, reg12_add12);
						
	REG102 : reg 		generic map(Nbit_int)
						port map(CLK, RST_N, VIN, add12_reg102, reg102_add02);
						
	REG21 : reg 		generic map(Nbit_int)
						port map(CLK, RST_N, VIN, reg00_mul01, reg21_mul21);
						
	REG22 : reg 		generic map(Nbit_int)
						port map(CLK, RST_N, VIN, mul21_reg22, reg22_add12);
	
	MUL01 : BME_node 	port map(reg00_mul01, C01, mul01_reg02);
		
	MUL11 : BME_node 	port map(reg00_mul01, C11, mul11_reg12);
					 
	MUL20 : BME_node 	port map(reg00_mul01, C20, mul20_reg10);
					 
	MUL21 : BME_node 	port map(reg21_mul21, C21, mul21_reg22);
					 
	ADD00 : SUM_node 	generic map(Nbit_int, 0)
						port map(data_in, reg10_add00, add00_reg00);
					
	ADD02 : SUM_node 	generic map(Nbit_int, 0)
						port map(reg02_add02, reg102_add02, data_out);
					
	ADD12 : SUM_node 	generic map(Nbit_int, 1)
						port map(reg12_add12, reg22_add12, add12_reg102);
					
	REGIN : reg 		generic map(Nbit_ext)
						port map(CLK,RST_N,VIN,DIN,data_in_ext);
				
	REGOUT : reg 		generic map(Nbit_ext)
						port map(CLK,RST_N,VIN,data_out_ext,DOUT);
	
	data_in <= std_logic_vector(resize(signed(data_in_ext), data_in'length));
	data_out_ext <= data_out(Nbit_ext-1 downto 0);

	DOUT_PROC : process(CLK,RST_N)
	
		variable i : integer := 0; --latency
				
	begin
				
		if(RST_N = '0') then
					
			ready <= '0';
			i := 0;
					
		elsif(CLK'event and CLK = '1') then	
				
			if(VIN = '1') then
					
				i := i+1 ;
						
			end if;	
					
			if(i >= 2) then 
					
				ready <= '1';
						
			end if;

		end if;	
					
	end process;
				
	VOUT <= ready ;
	
end structural;
