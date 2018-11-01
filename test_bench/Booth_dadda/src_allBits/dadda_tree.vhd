library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dadda_tree_15_13 is
	port (	A, B, C, D, E, F, G	: in	std_logic_vector(15 downto 0);
			S1, S2				: out	std_logic_vector(27 downto 0));	
end dadda_tree_15_13;

architecture Structural of dadda_tree_15_13 is

	component fulladder
		port (	a, b	: in	std_logic;
				cin		: in	std_logic;
				S		: out	std_logic;
				cout	: out	std_logic);
	end component;
	
	component halfadder
		port (	a, b	: in	std_logic;
				s, cout	: out	std_logic);
	end component;
	
	signal sum_half, cout_half	: std_logic_vector(5 downto 1);
	signal sum_full, cout_full	: std_logic_vector(65 downto 1);
	signal negates				: std_logic_vector(10 downto 1);

begin

	negates(1) <= NOT(A(15));
	negates(2) <= NOT(B(15));
	negates(3) <= NOT(C(14));
	negates(4) <= NOT(C(15));
	negates(5) <= NOT(D(15));
	negates(6) <= NOT(D(14));
	negates(7) <= NOT(E(14));
	negates(8) <= NOT(E(15));
	negates(9) <= NOT(F(14));
	negates(10) <= NOT(F(15));

	HA1	:	halfadder port map (A(12),	B(10),	sum_half(1),	cout_half(1));
	HA2	:	halfadder port map (A(8),	B(6),	sum_half(2),	cout_half(2));
	HA3	:	halfadder port map (D(4),	E(2),	sum_half(3),	cout_half(3));
	HA4	:	halfadder port map (A(6),	B(4),	sum_half(4),	cout_half(4));
	HA5	:	halfadder port map (A(4),	B(2),	sum_half(5),	cout_half(5));
	
	FA1	:	fulladder port map (A(13),			B(11),			C(9),			sum_full(1),	cout_full(1));
	FA2	:	fulladder port map (A(14),			B(12),			C(10),			sum_full(2),	cout_full(2));
	FA3	:	fulladder port map (A(15),			B(13),			C(11),			sum_full(3),	cout_full(3));
	FA4	:	fulladder port map (A(15),			B(14),			C(12),			sum_full(4),	cout_full(4));
	FA5	:	fulladder port map (negates(1),		negates(2),		C(13),			sum_full(5),	cout_full(5));
	FA6	:	fulladder port map (A(9),			B(7),			C(5),			sum_full(6),	cout_full(6));
	FA7	:	fulladder port map (A(10),			B(8),			C(6),			sum_full(7),	cout_full(7));
	FA8	:	fulladder port map (A(11),			B(9),			C(7),			sum_full(8),	cout_full(8));
	FA9	:	fulladder port map (D(5),			E(3),			F(1),			sum_full(9),	cout_full(9));
	FA10:	fulladder port map (sum_half(1),	C(8),			D(6),			sum_full(10),	cout_full(10));
	FA11:	fulladder port map (E(4),			F(2),			G(0),			sum_full(11),	cout_full(11));
	FA12:	fulladder port map (cout_half(1),	sum_full(1),	D(7),			sum_full(12),	cout_full(12));
	FA13:	fulladder port map (E(5),			F(3),			G(1),			sum_full(13),	cout_full(13));
	FA14:	fulladder port map (cout_full(1),	sum_full(2),	D(8),			sum_full(14),	cout_full(14));
	FA15:	fulladder port map (E(6),			F(4),			G(2),			sum_full(15),	cout_full(15));
	FA16:	fulladder port map (cout_full(2),	sum_full(3),	D(9),			sum_full(16),	cout_full(16));
	FA17:	fulladder port map (E(7),			F(5),			G(3),			sum_full(17),	cout_full(17));
	FA18:	fulladder port map (cout_full(3),	sum_full(4),	D(10),			sum_full(18),	cout_full(18));
	FA19:	fulladder port map (E(8),			F(6),			G(4),			sum_full(19),	cout_full(19));
	FA20:	fulladder port map (cout_full(4),	sum_full(5),	D(11),			sum_full(20),	cout_full(20));
	FA21:	fulladder port map (E(9),			F(7),			G(5),			sum_full(21),	cout_full(21));
	FA22:	fulladder port map (cout_full(5),	negates(3),		D(12),			sum_full(22),	cout_full(22));
	FA23:	fulladder port map (E(10),			F(8),			G(6),			sum_full(23),	cout_full(23));
	FA24:	fulladder port map (C(14),			negates(4),		D(13),			sum_full(24),	cout_full(24));
	FA25:	fulladder port map (E(11),			F(9),			G(7),			sum_full(25),	cout_full(25));
	FA26:	fulladder port map (E(12),			F(10),			G(8),			sum_full(26),	cout_full(26));
	FA27:	fulladder port map (negates(5),		E(13),			F(11),			sum_full(27),	cout_full(27));
	FA28:	fulladder port map (A(7),			B(5),			C(3),			sum_full(28),	cout_full(28));
	FA29:	fulladder port map (sum_half(2),	C(4),			D(2),			sum_full(29),	cout_full(29));
	FA30:	fulladder port map (cout_half(2),	sum_full(6),	D(3),			sum_full(30),	cout_full(30));
	FA31:	fulladder port map (cout_full(6),	sum_full(7),	sum_half(3),	sum_full(31),	cout_full(31));
	FA32:	fulladder port map (cout_full(7),	cout_half(3),	sum_full(8),	sum_full(32),	cout_full(32));
	FA33:	fulladder port map (cout_full(8),	cout_full(9),	sum_full(10),	sum_full(33),	cout_full(33));
	FA34:	fulladder port map (cout_full(10),	cout_full(11),	sum_full(12),	sum_full(34),	cout_full(34));
	FA35:	fulladder port map (cout_full(12),	cout_full(13),	sum_full(14),	sum_full(35),	cout_full(35));
	FA36:	fulladder port map (cout_full(14),	cout_full(15),	sum_full(16),	sum_full(36),	cout_full(36));
	FA37:	fulladder port map (cout_full(16),	cout_full(17),	sum_full(18),	sum_full(37),	cout_full(37));
	FA38:	fulladder port map (cout_full(18),	cout_full(19),	sum_full(20),	sum_full(38),	cout_full(38));
	FA39:	fulladder port map (cout_full(20),	cout_full(21),	sum_full(22),	sum_full(39),	cout_full(39));
	FA40:	fulladder port map (cout_full(22),	cout_full(23),	sum_full(24),	sum_full(40),	cout_full(40));
	FA41:	fulladder port map (negates(6),		cout_full(24),	cout_full(25),	sum_full(41),	cout_full(41));
	FA42:	fulladder port map (D(14),			cout_full(26),	sum_full(27),	sum_full(42),	cout_full(42));
	FA43:	fulladder port map (cout_full(27),	negates(7),		F(12),			sum_full(43),	cout_full(43));
	FA44:	fulladder port map (E(14),			negates(8),		F(13),			sum_full(44),	cout_full(44));
	FA45:	fulladder port map (A(5),			B(3),			C(1),			sum_full(45),	cout_full(45));
	FA46:	fulladder port map (sum_half(4),	C(2),			D(0),			sum_full(46),	cout_full(46));
	FA47:	fulladder port map (cout_half(4),	sum_full(28),	D(1),			sum_full(47),	cout_full(47));
	FA48:	fulladder port map (cout_full(28),	sum_full(29),	E(0),			sum_full(48),	cout_full(48));
	FA49:	fulladder port map (cout_full(29),	sum_full(30),	E(1),			sum_full(49),	cout_full(49));
	FA50:	fulladder port map (cout_full(30),	sum_full(31),	F(0),			sum_full(50),	cout_full(50));
	FA51:	fulladder port map (cout_full(31),	sum_full(32),	sum_full(9),	sum_full(51),	cout_full(51));
	FA52:	fulladder port map (cout_full(32),	sum_full(33),	sum_full(11),	sum_full(52),	cout_full(52));
	FA53:	fulladder port map (cout_full(33),	sum_full(34),	sum_full(13),	sum_full(53),	cout_full(53));
	FA54:	fulladder port map (cout_full(34),	sum_full(35),	sum_full(15),	sum_full(54),	cout_full(54));
	FA55:	fulladder port map (cout_full(35),	sum_full(36),	sum_full(17),	sum_full(55),	cout_full(55));
	FA56:	fulladder port map (cout_full(36),	sum_full(37),	sum_full(19),	sum_full(56),	cout_full(56));
	FA57:	fulladder port map (cout_full(37),	sum_full(38),	sum_full(21),	sum_full(57),	cout_full(57));
	FA58:	fulladder port map (cout_full(38),	sum_full(39),	sum_full(23),	sum_full(58),	cout_full(58));
	FA59:	fulladder port map (cout_full(39),	sum_full(40),	sum_full(25),	sum_full(59),	cout_full(59));
	FA60:	fulladder port map (cout_full(40),	sum_full(41),	sum_full(26),	sum_full(60),	cout_full(60));
	FA61:	fulladder port map (cout_full(41),	sum_full(42),	G(9),			sum_full(61),	cout_full(61));
	FA62:	fulladder port map (cout_full(42),	sum_full(43),	G(10),			sum_full(62),	cout_full(62));
	FA63:	fulladder port map (cout_full(43),	sum_full(44),	G(11),			sum_full(63),	cout_full(63));
	FA64:	fulladder port map (cout_full(44),	negates(9),		G(12),			sum_full(64),	cout_full(64));
	FA65:	fulladder port map (F(14),			negates(10),	G(13),			sum_full(65),	cout_full(65));
	
	S1 <= G(14) & cout_full(65 downto 45) & cout_half(5) & sum_half(5) & A(3 downto 0);
	S2 <= NOT(G(15)) & NOT(G(14)) & sum_full(65 downto 45) & C(0) & B(1 downto 0) & '0' & '0';

end Structural;
