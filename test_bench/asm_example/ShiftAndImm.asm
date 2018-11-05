addi r1, r0, 42				;r1 = 0000002A
addi r2, r0, 0xAAAAAAAA     ;r2 = AAAAAAAA
nop                         ;
nop                         ;
nop                         ;
nop                         ;
or r3, r1, r2               ;r3 = AAAAAAAA
addi r1, r0, 2              ;r1 = 2
nop                         ;
nop                         ;
nop                         ;
nop                         ;
sll r4, r3, r1              ;r4 = AAAAAAA8
slli r5, r3, 2              ;r5 = AAAAAAA8
nop                         ;
nop                         ;
nop                         ;
nop                         ;
srl r6, r5, r1              ;r6 = 2AAAAAAA
srli r7, r4, 2              ;r7 = 2AAAAAAA
;r6, r7 must be equal       ;
addi r2, r0, 0xF0000000     ;r2 = F0000000
ori r3, r0, 0xF0F0F0F0      ;r3 = F0F0F0F0
addi r1, r0, 5              ;r1 = 5
nop                         ;
nop                         ;
nop                         ;
nop                         ;
sra r8, r3, r1              ;r8 = FF878787
srai r9, r3, 5              ;r9 = FF878787
addi r2, r0, 0xAAAAAAAA		;r2 = AAAAAAAA
addi r1, r0, 3				;r1 = 3
rol r10, r2, r1				;r10 = 55555555
ror r11, r2, r1             ;r11 = 55555555
roli r12, r2, 3             ;r12 = 55555555
rori r13, r2, 3             ;r13 = 55555555
