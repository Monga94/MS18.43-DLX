library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package BMEpar is
    constant nbit_a:   integer := 15; --data parallelism input a
    constant nbit_b:   integer := 13; --data parallelism input b --> espandere 0LSb + estendere un MSB
    constant nbit_pp:  integer := 16; --partial products parallelism
    constant pp:       integer := 7;  --number of partial products
    constant nbit_enc: integer := 3;  -- number ou bits from b taken by encoder

    type PP_array is array (pp-1 downto 0) of std_logic_vector(nbit_pp-1 downto 0);
end BMEpar;
