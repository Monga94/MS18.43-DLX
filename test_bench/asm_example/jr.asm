addi r1, r0, 0		;r1 index
addi r2, r0, 1      ;r2 value
nop                 ;
nop                 ;
nop                 ;
nop                 ;
sw 0(r1), r2        ;store in 0 <- 1
jal two             ;jump but execute both following instruction
addui r1, r1, 4     ;
addui r2, r2, 2     ;r2 = 3
j exit              ;
addui r2, r2, 3     ;r2 = 6
nop                 ;
nop                 ;
nop                 ;
two:                ;
nop                 ;
nop                 ;
nop                 ;
nop                 ;
sw 0(r1), r2        ;4 <- 3 - 12<-
jalr r31            ;jumps up to j exit
addui r1, r1, 4     ;
addui r2, r2, 4     ;r2 = 10
nop                 ;
exit:               ;
nop                 ;
nop                 ;
nop                 ;
sw 0(r1), r2        ;8 <- 6 - 12 <- 10
jalr r31            ;
addui r1, r1, 4	    ;
addui r2, r2, 5     ;r2 = 15
nop                 ;
nop                 ;
nop                 ;
nop                 ;
sw 0(r1), r2        ;16 <- 15
nop                 ;
nop                 ;
nop                 ;
nop                 ;