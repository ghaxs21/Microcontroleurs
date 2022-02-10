; file	hw02-5.asm   target ATmega128L-4MHz-STK300
; purpose instructions and branching

.include	"definitions.asm"
.include	"macros.asm"

start:
	CLR4	r17,r18,r19,r20
	CLR4	r21,r22,r23,r24
	LDI4	r25,r26,r27,r28,2
	ldi	r20,-3
	ldi	r24,-3
	
loop:
	SEXT	r23,r24
	SWAP2	r17,r18,r19,r20
	SUB4	r17,r18,r19,r20,r21,r22,r23,r24
	;output
	subi	r28,0b1
	brne	loop
	nop