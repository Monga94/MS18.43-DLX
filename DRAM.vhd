LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.mystuff.all;

ENTITY DRAM IS
	GENERIC (	W: integer:=8;
				D: integer:=10);
	PORT (	Clk			: IN	STD_LOGIC;
			Rst_n		: IN	STD_LOGIC;
			Data_In		: IN	STD_LOGIC_VECTOR(W-1 DOWNTO 0);
			Address		: IN	STD_LOGIC_VECTOR(D-1 DOWNTO 0);
			CS			: IN	STD_LOGIC;
			RD			: IN	STD_LOGIC;
			WS			: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
			Sign		: IN	STD_LOGIC;
			Data_Out	: OUT	STD_LOGIC_VECTOR(W-1 DOWNTO 0));
END DRAM;

ARCHITECTURE Behavior OF DRAM IS
	SUBTYPE MemLoc IS NATURAL RANGE 0 TO 2**D-1;
	TYPE Mem_Typ IS ARRAY(MemLoc) OF STD_LOGIC_VECTOR(W/4-1 DOWNTO 0);
	
	SIGNAL Memory : Mem_Typ;
	
BEGIN
	PROCESS(Clk, Rst_n) --WRITING
		VARIABLE Adj_Addr : MemLoc;
	BEGIN
		Adj_Addr := TO_INTEGER(UNSIGNED(Address));
		
		IF Rst_n = '0' THEN
			Memory <= (OTHERS => (OTHERS => '0'));
		ELSE
			IF Clk'EVENT AND Clk = '1' THEN
				IF CS = '1' THEN
					IF RD = '0' THEN
						IF WS = "00" THEN
							Memory(Adj_Addr) <= Data_In(7 DOWNTO 0);
						ELSIF WS = "01" THEN
							Memory(Adj_Addr) <= Data_In(7 DOWNTO 0);
							Memory(Adj_Addr+1) <= Data_In(15 DOWNTO 8);
						ELSIF WS = "10" THEN
							Memory(Adj_Addr) <= Data_In(7 DOWNTO 0);
							Memory(Adj_Addr+1) <= Data_In(15 DOWNTO 8);
							Memory(Adj_Addr+2) <= Data_In(23 DOWNTO 16);
							Memory(Adj_Addr+3) <= Data_In(31 DOWNTO 24);
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(CS, RD, WS, Sign, Address, Memory) --READING
		VARIABLE Adj_Addr : MemLoc;
	BEGIN
		Adj_Addr := TO_INTEGER(UNSIGNED(Address));
		
		IF CS = '1' AND RD = '1' THEN
			IF WS = "00" THEN	
				Data_Out(7 DOWNTO 0) <= Memory(Adj_Addr);
				IF Sign = '0' THEN
					Data_Out(Nbit-1 DOWNTO 8) <= (OTHERS => '0');
				ELSE
					Data_Out(Nbit-1 DOWNTO 8) <= (OTHERS => Memory(Adj_Addr)(7));
				END IF;
			ELSIF WS = "01" THEN	
				Data_Out(7 DOWNTO 0) <= Memory(Adj_Addr);
				Data_Out(15 DOWNTO 8) <= Memory(Adj_Addr+1);
				IF Sign = '0' THEN
					Data_Out(Nbit-1 DOWNTO 16) <= (OTHERS => '0');
				ELSE
					Data_Out(Nbit-1 DOWNTO 16) <= (OTHERS => Memory(Adj_Addr)(15));
				END IF;
			ELSIF WS = "10" THEN	
				Data_Out(7 DOWNTO 0) <= Memory(Adj_Addr);
				Data_Out(15 DOWNTO 8) <= Memory(Adj_Addr+1);
				Data_Out(23 DOWNTO 16) <= Memory(Adj_Addr+2);
				Data_Out(31 DOWNTO 24) <= Memory(Adj_Addr+3);
			END IF;
		ELSE
			Data_Out <= (OTHERS => 'Z');
		END IF;
	END PROCESS;
END Behavior;