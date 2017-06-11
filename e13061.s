.text

.global main

main:
		sub	sp, sp, #4		
		str	lr, [sp, #0]

		ldr	r0, =formatkey 	@"Enter the key: "
		bl 	printf
		
		sub	sp, sp, #8
		
		@ scanning the first 64 bits in the key
		
		ldr	r0, =formats	
		mov	r1, sp	
		bl	scanf
		ldr	r4, [sp,#4]   		
		ldr	r5, [sp]		
		
		@ scanning the 2nd 64 bits in the key
		
		ldr	r0, =formats	
		mov	r1, sp	
		bl	scanf	
		ldr	r6, [sp,#4]
		ldr	r7, [sp]

		@ getting the plain text
		
		
		ldr	r0, =formatplain 	@"Enter the plain text: "
		bl 	printf
		
		@ scanning the first 64 bits in the plain text
		
		ldr	r0, =formats	
		mov	r1, sp	
		bl	scanf
		ldr	r8, [sp,#4]
		ldr	r9, [sp]
		
		@ scanning the 2nd 64 bits in the plain text
		
		ldr	r0, =formats	
		mov	r1, sp	
		bl	scanf
		ldr	r10, [sp,#4]
		ldr	r11, [sp]
	
		add sp,sp,#8
		
		@ printing the cipher text
		
		
		mov r0,r8   	@y
		mov r1,r9
		
		mov r2,r10		@x
		mov r3,r11
		
		
		@b -> r4,r5
		
		@a -> r6,r7
		
		
		@calling the encrypt function
		bl encrypt
		
		mov r6,r0  @y
		mov r7,r1
		
		mov r8,r2  @x
		mov r9,r3
		
		@ moving y
		mov r1,r6 
		mov r2,r7
	
		ldr	r0, =formatcipher1  @ Cipher text is : y
		bl printf
		
		@moving x
		mov r1,r8
		mov r2,r9

		ldr	r0, =formatcipher2  @ printing xx
		bl printf
		
		
	ldr	lr, [sp, #0]					 @ stack handling 
	add	sp, sp, #4
	mov	pc, lr	

roundRight:

	sub sp,sp,#24
	str lr,[sp,#0]
	str r4,[sp,#4]
	str r5,[sp,#8]
	str r6,[sp,#12]
	str r7,[sp,#16]
	str r8,[sp,#20]
		
	lsr r4, r0, r2		@ shifting right r0 from the value of r2 and put it into r4
	lsr r5, r1, r2		@ shifting right r1 from the value of r2 and put it into r5
	mov r8,#32
	sub r2,r8,r2		@ r2=32-r2
	lsl r6, r0, r2		@ shifting left r0 from the value (32-r2) and put it into r6
	lsl r7, r1, r2		@ shifting left r1 from the value (32-r2) and put it into r7
	
	@ getting or of r4 & r7
	orr r3,r4,r7
	
	@ getting or of r5 & r6
	orr r12,r5,r6
	
	ldr lr,[sp,#0]
	ldr r4,[sp,#4]
	ldr r5,[sp,#8]
	ldr r6,[sp,#12]
	ldr r7,[sp,#16]	
	ldr r8,[sp,#20]
	add sp,sp,#24
	
	mov pc ,lr	


roundLeft:
	sub sp,sp,#24
	str lr,[sp,#0]
	str r4,[sp,#4]
	str r5,[sp,#8]
	str r6,[sp,#12]
	str r7,[sp,#16]
	str r8,[sp,#20]
		
	lsl r4, r0, r2		@ shifting right r0 from the value of r2 and put it into r4
	lsl r5, r1, r2		@ shifting right r1 from the value of r2 and put it into r5
	mov r8,#32
	sub r2,r8,r2		@ r2=32-r2
	lsr r6, r0, r2		@ shifting left r0 from the value (32-r2) and put it into r6
	lsr r7, r1, r2		@ shifting left r1 from the value (32-r2) and put it into r7
	
	@ getting or of r4 & r7
	orr r3,r4,r7
	
	@ getting or of r5 & r6
	orr r12,r5,r6
	
	ldr lr,[sp,#0]
	ldr r4,[sp,#4]
	ldr r5,[sp,#8]
	ldr r6,[sp,#12]
	ldr r7,[sp,#16]	
	ldr r8,[sp,#20]
	add sp,sp,#24
	
	mov pc ,lr	
	
	
process:
	sub sp,sp, #12
	str lr,[sp,#0]
	str r2,[sp,#4]
	str r3,[sp,#8]
	
	
	mov r2,#8				@ roundRight(x, 8); r2=8
	bl roundRight
	@ outputs are in r3 and r12
	@ we should put that into x
	
	@ x= roundRight(x,8)    @ x-> r0,r1
	mov r0,r3  
	mov r1,r12
	
	@ x= x+y
	
	ldr r3,[sp,#8] 			@ laoding original r2, and r3 (y)
	ldr r2,[sp,#4]
	
	adds r1,r1,r3			@ x-> r0,r1
	adc r0,r0,r2			
	
	@ x= x XOR k			@ x-> r4,r5
	eor r4,r0,r4
	eor r5,r1,r5
	
	@ 	roundLeft(r0,r1,r2) -> roundLeft(y,3)		
	mov r0,r2
	mov r1,r3
	mov r2, #3
	bl roundLeft

	@ outputs are in r3 and r12  @ y-> r3,r12
	@ the result is y
	
	@ y = y XOR x		 @ y-> r2,r3
	eor r2,r3,r4
	eor r3,r12,r5

	mov r0,r4			 @ x-> r0,r1
	mov r1,r5

	ldr lr,[sp,#0]
	
	add sp,sp, #12
	mov pc ,lr
	
	
encrypt:
	
	@ x-> r0,r1  y-> r2,r3  a->r4,r5  b-> r6,r7
	
	
	sub sp,sp, #12
	str lr,[sp,#0]
	str r8,[sp,#4]
	str r9,[sp,#8]
	
	@ x-> r0,r1  y-> r2,r3  
	
	sub sp,sp,#8
	str r4,[sp,#0]     @ 'a' stored
	str r5,[sp,#4] 
	
	mov r4,r6  			 @ b-> r4,r5
	mov r5,r7			@ b-> r6,r7
	
	bl process
	
	ldr r4,[sp,#0] 		@ 'a' loaded
	ldr r5,[sp,#4] 		@ a->r4,r5
	add sp,sp,#8
	
	@  x-> r0,r1    @ y-> r2,r3
	
	
	mov r8,#0
	mov r9,#0     @ i=0
	
	
    L1 :
		cmp r9, #31 
		bge exit
		
		sub sp,sp,#16
		str r0,[sp,#0]
		str r1,[sp,#4]
		str r2,[sp,#8]
		str r3,[sp,#12]
		
		
		mov r0,r4			@ giving "a" as input parameter to process fun
		mov r1,r5
		
		mov r2,r6			@ giving "b" as input parameter to process fun
		mov r3,r7
		
		mov r4,r8			@ giving "i" as input parameter to process fun
		mov r5,r9
		
		bl process
		
		@ a-> r0,r1   @ b->  r2,r3
		
		mov r4,r0
		mov r5,r1
		
		mov r6,r2
		mov r7,r3
		
		@ a-> r4,r5   b-> r6,r7
		
		ldr r0,[sp,#0]
		ldr r1,[sp,#4]
		ldr r2,[sp,#8]
		ldr r3,[sp,#12]
		add sp, sp, # 16
		
		sub sp,sp,#8			@ 'a' stored
		str r4,[sp,#0] 
		str r5,[sp,#4] 
		
		mov r4,r6   @ b-> r4,r5
		mov r5,r7	@ b-> r6,r7
			
		bl process
		
		ldr r4,[sp,#0]  @ a-> r4,r5
		ldr r5,[sp,#4] 
		add sp,sp,#8
		
		@  x-> r0,r1    @ y-> r2,r3
		
		add r9,r9,#1
		b L1
		
	exit:
		ldr lr,[sp,#0]
		
		ldr r8,[sp,#4]
		ldr r9,[sp,#8]
		add sp, sp, #12
		mov pc,lr
	
		
		.data										@ data memory
formatkey : .asciz "Enter the key:\n"
formatplain: .asciz "Enter the plain text:\n"
formats: .asciz "%llx"
formatcipher1 : .asciz "Cipher text is:\n%08x%08x"
formatcipher2 : .asciz " %08x%08x\n"
formatt : .asciz "%08x%08x \n"



