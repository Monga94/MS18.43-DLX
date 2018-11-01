library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.BMEpar.all;

entity PP_i_block is
	port (	booth_enc	: IN	std_logic_vector(nbit_enc-1 downto 0);
			zero		: IN	std_logic_vector(nbit_pp-1 downto 0);
			A_pos		: IN	std_logic_vector(nbit_pp-1 downto 0);
			A_neg		: IN	std_logic_vector(nbit_pp-1 downto 0);
			A_posx2		: IN	std_logic_vector(nbit_pp-1 downto 0);
			A_negx2		: IN	std_logic_vector(nbit_pp-1 downto 0);
			PP_i		: OUT	std_logic_vector(nbit_pp-1 downto 0));
end pp_i_block;

architecture arch of PP_i_block is
  
	component mux5to1 is
		port (  in0		: IN	std_logic_vector(nbit_pp-1 downto 0); --  0
				in1		: IN	std_logic_vector(nbit_pp-1 downto 0); -- +A
				in2		: IN	std_logic_vector(nbit_pp-1 downto 0); -- +2A
				in3		: IN	std_logic_vector(nbit_pp-1 downto 0); -- -A
				in4		: IN	std_logic_vector(nbit_pp-1 downto 0); -- -2A
				output	: OUT	std_logic_vector(nbit_pp-1 downto 0);
				sel		: IN	std_logic_vector(nbit_enc-1 downto 0));
	end component;
	
	component booth_encoder is
		port (	input	: IN	std_logic_vector(nbit_enc-1 downto 0);
				output	: OUT	std_logic_vector(nbit_enc-1 downto 0));
	end component;
	
	signal sel : std_logic_vector(nbit_enc-1 downto 0);
  
begin

	MUX: mux5to1 port map (zero, A_pos, A_posx2, A_neg, A_negx2, PP_i, sel);
	BE:  booth_encoder port map (booth_enc, sel);

end arch;
