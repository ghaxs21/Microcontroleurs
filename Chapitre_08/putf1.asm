; file	putf1.asm   target ATmega128L-4MHz-STK300
; purpose display of formatted text and values, demo

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	rcall	SRAM_init		; initialize SRAM terminal
	jmp	main

.include "sram.asm"	; include routines to simulate an SRAM terminal

.equ	putc = SRAM_putc
.include "putstr.asm"		; include put string
.include "puthex.asm"		; include put hexadecimal
.include "putbin.asm"		; include put binary
.include "putdec.asm"		; include put decimal
.include "putf.asm"			; include put formatted strings

main:
	ldi	b0,123
	rcall	putf			; result: "b=123 =0x7b =0b01111011"
.db	"b=",FDEC,b," =0x",FHEX,b," =0b",FBIN,b,0

	rjmp	main