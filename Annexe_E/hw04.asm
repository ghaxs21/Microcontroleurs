; file	hw04.asm   target ATmega128L-4MHz-STK300
; purpose complex addressing modes and branching

.include "definitions.asm"
.include "macros.asm"

.org 0	 
	jmp	reset

.org 0x0005
str:	
	.db	"hello", 0
	rjmp	part2

.org 0x000A
instr:	
	jmp	part3

.org 0x0010
reset:
	LDSP	RAMEND
main:
part1:
	ldi		zl, low(str)
	ldi		zh, high(str)
	ijmp
part2:
	ldi		zl, low(2*str)
	ldi		zh, high(2*str)
	ijmp
part3:
	rcall	readmem
	rjmp	PC

readmem:	;in: z, out: , mod: r0, zl
	lpm
	tst		r0
	breq	done
	adiw	zl, 1
	rjmp	readmem
done:
	ret