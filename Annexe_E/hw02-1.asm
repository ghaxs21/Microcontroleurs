; file	hw02-1.asm   target ATmega128L-4MHz-STK300
; purpose instructions and branching

.include	"macros.asm"

start:
	ldi	r16,0x01
Loop:
	mov	r17,r16
	add	r16,r17
	;output
	brne	loop
	nop		;suite du programme