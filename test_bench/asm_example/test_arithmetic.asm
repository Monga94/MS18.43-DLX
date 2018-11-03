addi r1,r0,#2		r0	0
subi r2,r1,#1       r1	2
addi r3,r1,#-4      r2	-1
subi r4,r3,#-1      r3	-2
addui r5,r1,#4      r4	1
subui r6,r5,#3      r5	6
add r7,r1,r2        r6	-3
sub r8,r5,r6        r7	1
addu r9,r6,r1       r8	9
sge r10,r1,r2       r9	-1
sge r10,r2,r1       r10	1
sge r10,r1,r1       r11	65535
sle r10,r1,r2       r12	-65536
sle r10,r2,r1       r13	0
sle r10,r1,r1       r14	65535
sne r10,r1,r1       r15	0
sne r10,r1,r2       r16	0
seq r10,r1,r2       r17	0
seq r10,r1,r1       r18	0
sgt r10,r2,r1       r19	0
sgt r10,r1,r2       r20	0
slt r10,r2,r1       r21	-1
slt r10,r1,r2       r22	-32768
sgeu r10,r1,r3      r23	12
sgeu r10,r3,r1      r24	0
sgtu r10,r1,r3      r25	0
sgtu r10,r3,r1      r26	
sltu r10,r3,r1      r27	
sltu r10,r1,r3      r28	
sgei r10,r1,#4      r29	
sgei r10,r1,#1  	r30	
slei r10,r1,#0  	r31	
slei r10,r1,#2  
snei r10,r1,#1  
snei r10,r1,#2  
seqi r10,r1,#0  
seqi r10,r1,#2  
sgti r10,r1,#3  
sgti r10,r1,#1  
slti r10,r1,#1  
slti r10,r1,#3  
sgeui r10,r1,#4 
sgeui r10,r1,#1 
sgtui r10,r1,#3 
sgtui r10,r1,#1 
sltui r10,r1,#1 
sltui r10,r1,#3 
addui r11,r0,#65535
lhi r12,#65535
or r13,r11,r12
ori r14,r12,#65535
and r15,r14,r2
andi r16,r14,#1
sll r17,r16,r2
slli r18,r16,#1
srl r19,r16,r2
srli r20,r16,#1
sra r21,r12,r2
srai r22,r12,#1
mult r23,r1,r5
xor r24,r1,r1
xori r25,r1,#2