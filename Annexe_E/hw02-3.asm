; file	hw02-3.asm   target ATmega128L-4MHz-STK300
; purpose instructions and branching

.include	"macros.asm"

start:
	ldi	r16,$3
	ldi	r17,252
	
loop:
	lsl	r16
	;output
	ADDI	r17,1
	brvc	loop
	nop	