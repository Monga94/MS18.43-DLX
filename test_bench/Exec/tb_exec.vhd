library IEEE;

use IEEE.std_logic_1164.all;
use WORK.myStuff.all;

entity TB_EXUNIT is
end TB_EXUNIT;

architecture Test of TB_EXUNIT is
	
	component ExecutionUnit is 
	generic(Nbit: 		integer := 32;
			Addr_bit:	integer := 5);
	port(	CLK:			in	std_logic;
			RST:		    in	std_logic;
			REG_EN_E:		in	std_logic;
			MuxA_Sel:		in	std_logic;
			MuxB_Sel:		in	std_logic;
			ALU_Config:		in	std_logic_vector(SelALU-1 downto 0);
			Sign:			in	std_logic;
			Condition:		in	std_logic_vector(2 downto 0);
			NPC_In:		    in	std_logic_vector(Nbit-1 downto 0);
			DataA:			in	std_logic_vector(Nbit-1 downto 0);
			DataB:		    in	std_logic_vector(Nbit-1 downto 0);
			DataIMM:		in	std_logic_vector(Nbit-1 downto 0);
			Wr_Addr_D:		in	std_logic_vector(Addr_bit-1 downto 0);
			ALU_Out:		out std_logic_vector(Nbit-1 downto 0);
			DataBtoDMem:	out std_logic_vector(Nbit-1 downto 0);
			Wr_Addr_E:		out std_logic_vector(Addr_bit-1 downto 0);
			Taken:			out std_logic);
	end component;

	signal Func: std_logic_vector(SelALU-1 downto 0);
	signal Condition: std_logic_vector(2 downto 0);
	signal Sign,Clock,Reset,En,Sela,Selb,Taken: std_logic;
	signal A,B,IMM,ALU_Res,NPC,DataBtoDMem: std_logic_vector(Nbit-1 downto 0);
	signal Wr_Addr_D,Wr_Addr_E: std_logic_vector(4 downto 0);

begin
	DUT: ExecutionUnit
		port map(Clock,Reset,En,Sela,Selb,Func,Sign,Condition,NPC,A,B,IMM,Wr_Addr_D,ALU_Res,DataBtoDMem,Wr_Addr_E,Taken);
		
	test: process
	begin
	   Reset <= '0';
	   wait for 4 ns;
	   Reset <= '1';
		En <= '1';
		Sela <= '1';
		Selb <= '0';
		Sign <= '0';
		Func <= ALU_ANDop;
		NPC <= "01000100010001010100100100000001";
		Condition <= "000";
		A <= "00000000000000000100000100000001";
		B <= "00000000000000001000000100000101";
		IMM <= "01000100010001010100100100000001";
		Wr_Addr_D <= "00110";
		wait for 4 ns;
		Func <= ALU_ORop;
		A_mp_i <= "11111000001010001001100000111010";
		B_mp_i <= "11000100101000011111110000000000";
		wait for 4 ns;
		Func <= ALU_XORop;
		wait for 4 ns;
		Func <= ALU_ADDop;
		wait for 4 ns;
		Func <= ALU_SUBop;
		wait for 4 ns;
		Func <= ALU_SLLop;
		wait for 4 ns;
		Func <= ALU_SRLop;
		wait for 4 ns;
		Func <= ALU_SRAop;
		wait for 4 ns;
		Func <= ALU_ROLop;
		wait for 4 ns;
		Func <= ALU_RORop;
		wait for 4 ns;
		Func <= ALU_AneBop;
		wait for 4 ns;
		Func <= ALU_AeqBop;
		wait for 4 ns;
		Func <= ALU_AgtBop;
		wait for 4 ns;
		Func <= ALU_AgeBop;
		wait for 4 ns;
		Func <= ALU_AltBop;
		wait for 4 ns;
		Func <= ALU_AleBop;
		wait for 4 ns;
		Func <= ALU_NOPop;
		wait for 4 ns;
		Func <= ALU_MULTop;
		wait for 4 ns;
		Func <= ALU_ANDop;
		wait;
	end process test;
	
	PCLOCK : process
	begin
		Clock <= '1';
		wait for 2 ns;
		Clock <= '0';
		wait for 2 ns;
	end process;
	
end Test;