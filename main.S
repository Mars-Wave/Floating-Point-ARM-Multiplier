/*
 * main.S
 *
 *  Created on: 29/03/2020
 *      Author: Tomas Moro Lias
 */

.global start

.data
/*
Checked examples:

1)
	A = 1 10000011 00100000000000000000000
	B = 0 10000010 00110000000000000000000
	A*B=1 10000110 01010110000000000000000

2)
	C = 0 10000110 00001100001000000000000
	D = 1 10000000 00100000000000000000000
	C*D=1 10000111 00101101101001000000000

3)
	E = 1 10000010 11010000000000000000000
	F = 1 01111101 10000000000000000000000
	E*F=0 10000001 01011100000000000000000

*/
	.equ X,     0b11000001011010000000000000000000 //first operand
	.equ Y,     0b10111110110000000000000000000000 //second operand
	.equ mmask, 0b00000000011111111111111111111111 //mantissa mask
	.equ emask, 0b01111111100000000000000000000000 //exponent mask
	.equ smask, 0b10000000000000000000000000000000 //sign mask
	.equ normalizer, 0b000000000100000000000000000000000 //mask of 23th normalizer bit
	.equ ninebits, 0b11111111100000000000000000000000 //mask of 9 most significant bits
	.equ fourteenbits, 0b00000000000000000011111111111111 //mask of 14 least significant bits
	.equ specificbit,  0b00000000000000001000000000000000 //48th bit is important for if block
	.equ eightbits, 0b11111111000000000000000000000000 //mask of 8 most significant bits
	.equ fifteenbits, 0b00000000000000000111111111111111 //mask of 15 least significant bits
	.equ onetwoseven, 0b10000001 //-127 to subtract from exponent sum
	.equ exponentcleaner, 0b00000000000000000000000011111111 //cleaner for overflow in sum of exponents

.bss

	result: .space 4

.text

start:

	ldr r0, =X //first operand in r0
	ldr r1, =Y //second operand in r0
	ldr r2, =mmask
	and r3, r0, r2
	and r4, r1, r2 //mantissas in r3, r4
	ldr r2, =normalizer
	orr r3, r3, r2
	orr r4, r4, r2 //normalize mantissas
	umull r5, r6, r3, r4
	ldr r2, =specificbit
	and r10, r6, r2
	cmp r10, #0
	bgt do_15_8
	ldr r2, =ninebits  //take 9 most significant bits of umulled 1st reg
	and r5, r2, r5
	ldr r2, =fourteenbits //take 14 least significant bits of umulled 2nd reg
	and r6, r2, r6
	lsr r5, r5, #23 //put 9 bits on the right
	lsl r6, r6, #9 //put 14 bits on the left
	mov r9, #0 //did 14-9
	b assemble_mantissa
do_15_8:
	ldr r2, =eightbits  //take 8 most significant bits of umulled 1st reg
	and r5, r2, r5
	ldr r2, =fifteenbits //take 15 least significant bits of umulled 2nd reg
	and r6, r2, r6
	lsr r5, r5, #24 //put 8 bits on the right
	lsl r6, r6, #8 //put 15 bits on the left
	mov r9, #1 //did 15-8
assemble_mantissa:
	orr r6, r6, r5 //fully multiplied mantissa in r6
	ldr r2, =smask
	and r3, r0, r2
	and r4, r1, r2
	mov r5, #1  //sign in r5 "if" not_equal skips #0
	cmp r3, r4	//decide sign
	bne not_equal
	mov r5, #0	//sign in r5 accessed if signs they are equal
not_equal:
	lsl r5, #31 //shift to sign position
	ldr r2, =emask
	and r0, r2, r0
	and r1, r2, r1	//exponents in r0, r1
	lsr r0, r0, #23
	lsr r1, r1, #23 //shift right for sum
	add r0, r1, r0  //unbiased sum in r0
	ldr r2, =exponentcleaner
	and r0, r2, r0  //clean result
	ldr r2, =onetwoseven
	add r0, r0, r2 //unbiased sum -127
	ldr r2, =exponentcleaner
	and r0, r2, r0  //clean result again
	cmp r9,#1
	blo did_14_8
	add r0, r0, #1 //compensate for doing 15-8
did_14_8:
	lsl r0, #23 //shift to exponent position
	orr r10, r0, r5
	orr r10, r10, r6 //result is in r10 in this step
	ldr r0, =result
	str r10, [r0] //result stored in result space
	b end;

end: b end;
