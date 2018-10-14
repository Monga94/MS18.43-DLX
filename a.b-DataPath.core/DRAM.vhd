LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY DRAM IS
	GENERIC (	B: integer:=8;
				L: integer:=10);
	PORT (	Data_In		: IN	STD_LOGIC_VECTOR(B-1 DOWNTO 0);
			Address		: IN	STD_LOGIC_VECTOR(L-1 DOWNTO 0);
			RD			: IN	STD_LOGIC;
			CS			: IN	STD_LOGIC;
			Data_Out	: OUT	STD_LOGIC_VECTOR(B-1 DOWNTO 0));
END DRAM;

ARCHITECTURE Behavior OF DRAM IS
	SIGNAL Dat : UNSIGNED(L-1 DOWNTO 0) := (OTHERS => '1');
	TYPE Reg_Typ IS ARRAY(0 TO (TO_INTEGER(Dat))) OF STD_LOGIC_VECTOR(B-1 DOWNTO 0);
	
	SIGNAL RegFile_r : Reg_Typ;
	
BEGIN
	PROCESS(CS, RD, Address, Data_In) --WRITING
	BEGIN
		IF CS = '1' THEN
			IF RD = '0' THEN
				RegFile_r(TO_INTEGER(UNSIGNED(Address))) <= Data_In; --scrive dato in ingresso
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(CS, RD, Address, RegFile_r) --READING
	BEGIN
		IF CS = '1' AND RD = '1' THEN
			Data_Out <= RegFile_r(TO_INTEGER(UNSIGNED(Address)));
		ELSE
			Data_Out <= (OTHERS => 'Z');
		END IF;
	END PROCESS;
END Behavior;