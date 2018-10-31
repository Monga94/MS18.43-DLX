LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

PACKAGE logarithm IS
	FUNCTION log2_N (x : NATURAL) RETURN NATURAL;
END;

PACKAGE BODY logarithm IS
	FUNCTION log2_N (x : NATURAL) RETURN NATURAL IS
		VARIABLE count: NATURAL := 0;
		VARIABLE n : NATURAL := 1;
	BEGIN
		WHILE n < x LOOP
			n := n*2;
			count := count+1;
		END LOOP;
	RETURN count;
	END FUNCTION;
END PACKAGE BODY;