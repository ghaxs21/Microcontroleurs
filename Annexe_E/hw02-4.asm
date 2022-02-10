; file	hw02-4.asm   target ATmega128L-4MHz-STK300
; purpose instructions and branching

.include	"macros.asm"

start:
	
	LDI2	r16,r17,0xFFDA
	;output01
	ROL2	r16,r16
	;output02

loop:
	ROR2	r16,r17
	;output
	brmi	loop
	nop	