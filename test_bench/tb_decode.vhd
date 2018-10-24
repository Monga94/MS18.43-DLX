library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use WORK.myStuff.all;

entity tb_decode is
end tb_decode;

architecture test of tb_decode is

signal Clock,Rst,Read1,Read2,Write1,En,MuxI,MuxRd : std_logic;
signal Instruction,NPC,WB_D : std_logic_vector(31 downto 0);
signal WB_ADD,Wr_Addr_D : std_logic_vector(Addr_bit-1 downto 0)

component DecodeUnit is
		generic(Nbit:		integer := 32;
				Addr_bit:	integer := 5);
		port(	CLK:			in	std_logic;
				RST:			in	std_logic;
				RF_RD1:			in	std_logic;
				RF_RD2:			in	std_logic;
				RF_WR:			in	std_logic;
				REG_EN_D:		in	std_logic;	
				MuxIMM_Sel:		in	std_logic;
				MuxRd_Sel:		in	std_logic;
				InstrToDecode:	in	std_logic_vector(Nbit-1 downto 0);
				NPCin:		 	in	std_logic_vector(Nbit-1 downto 0);
				WB_Data:		in	std_logic_vector(Nbit-1 downto 0);
				WB_Addr:		in	std_logic_vector(Addr_bit-1 downto 0);
				DataA:			out std_logic_vector(Nbit-1 downto 0);
				DataB:			out std_logic_vector(Nbit-1 downto 0);
				DataIMM:		out std_logic_vector(Nbit-1 downto 0);
				NPCout:			out std_logic_vector(Nbit-1 downto 0);
				Wr_Addr_D:		out std_logic_vector(Addr_bit-1 downto 0));
end component;



begin
	DUT : DecodeUnit
		port map(Clock,Rst,Read1,Read2,Write1,En,MuxI,MuxRd,Instruction,NPC,WB_D,WB_ADD,Wr_Addr_D);
	Test_P : process
		Rst <= '0';
		Instruction <= "00000000000000000000000000000000";
		NPC 		<= "00000000000000000000000000000001";
		WB_D		<= "00000000000000000000000000000000";
		WB_ADD		<= "00000000000000000000000000000000";
		wait for 5 ns;
		Rst <= '1';
		Instruction <= "00000000000000000000000000000000";
		wait;


	PCLOCK : process(Clock)
	begin
		Clock <= not(Clock) after 5 ns;	
	end process;

end test;