library ieee;
use ieee.std_logic_1164.all;

package GLOBALS is

	--constant IIR_ORDER : integer := 1; --Filter order
	constant Nbit_int : integer := 15;
	constant Nbit_ext : integer := 13;
	
	constant C01 : std_logic_vector(Nbit_ext-1 downto 0) := "0011010111011";	-- 1723
	constant C11 : std_logic_vector(Nbit_ext-1 downto 0) := "0011111001100";	-- 1996
	constant C20 : std_logic_vector(Nbit_ext-1 downto 0) := "0000001100110";	--  102
	constant C21 : std_logic_vector(Nbit_ext-1 downto 0) := "1111011101110";	-- -274
	
end package;
