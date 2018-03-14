LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY IRAM IS
	GENERIC (	B: integer:=8;
				L: integer:=10);
	PORT (	Address		: IN	STD_LOGIC_VECTOR(L-1 DOWNTO 0);
			CS			: IN	STD_LOGIC;
			Data_Out	: OUT	STD_LOGIC_VECTOR(B-1 DOWNTO 0));
END IRAM;

ARCHITECTURE Behavior OF IRAM IS
	SIGNAL Dat : UNSIGNED(L-1 DOWNTO 0) := (OTHERS => '1');
	TYPE Reg_Typ IS ARRAY(0 TO (TO_INTEGER(Dat))) OF STD_LOGIC_VECTOR(B-1 DOWNTO 0);
	
	SIGNAL RegFile_r : Reg_Typ;
	
BEGIN	
	PROCESS(CS, Address, RegFile_r) --READING
	BEGIN
		IF CS = '1' THEN
			Data_Out <= RegFile_r(TO_INTEGER(UNSIGNED(Address)));
		ELSE
			Data_Out <= (OTHERS => 'Z');
		END IF;
	END PROCESS;
END Behavior;