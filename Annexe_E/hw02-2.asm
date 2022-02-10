; file	hw02-2.asm   target ATmega128L-4MHz-STK300
; purposee instructions and branching

.include	"macros.asm"

start:
	ldi	r16,0b00000001
	ldi	r17,16
	
loop:
	lsl	r16
	;output
	subi	r17,1
	brne	loop
	nop		;suite du programm