library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.BMEpar.all;

entity PP_COMPUTE is
	port (  a		: IN	std_logic_vector(nbit_a-1 downto 0);
			b		: IN	std_logic_vector(nbit_b-1 downto 0);
			PP_port	: OUT	PP_array);
end PP_COMPUTE;

architecture arch of PP_COMPUTE is
	
	component CA2
		port (  input	: IN	std_logic_vector(nbit_a-1 downto 0);
				output	: OUT	std_logic_vector(nbit_a-1 downto 0));
	end component;
	
	component PP_i_block
		port (	booth_enc	: IN	std_logic_vector(nbit_enc-1 downto 0);
				zero		: IN	std_logic_vector(nbit_pp-1 downto 0);
				A_pos		: IN	std_logic_vector(nbit_pp-1 downto 0);
				A_neg		: IN	std_logic_vector(nbit_pp-1 downto 0);
				A_posx2		: IN	std_logic_vector(nbit_pp-1 downto 0);
				A_negx2		: IN	std_logic_vector(nbit_pp-1 downto 0);
				PP_i		: OUT	std_logic_vector(nbit_pp-1 downto 0));
	end component;
	
	signal zero, A_pos, A_posx2, A_neg, A_negx2 : std_logic_vector(nbit_pp-1 downto 0);
	signal ca2_a : std_logic_vector(nbit_a-1 downto 0);
	
	signal B_exp : std_logic_vector(nbit_b+1 downto 0); 

begin
    zero    <= (others =>'0');
    A_pos   <= a(nbit_a-1) & a;           --sign expansion of +a
    A_posx2 <= a & '0';                   -- +a multiplyed by 2
    A_negx2 <= ca2_a & '0';               -- -a multiplyed by 2
    A_neg   <= ca2_a(nbit_a-1) & ca2_a;   --sign expansion of -a

    B_exp <= b(nbit_b-1) & b & '0';

    CA2_0: CA2 port map (a, ca2_a);
    
    PP_gen : for i in 0 to pp-1 generate
		PP_i: PP_i_block port map (B_exp( 2*i+2 downto 2*i), zero, A_pos, A_neg, A_posx2, A_negx2, PP_port(i));
    end generate;
	
end arch;