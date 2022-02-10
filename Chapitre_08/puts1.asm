; file	puts1.asm   target ATmega128L-4MHz-STK300
; purpose string display demo

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	rcall	SRAM_init		; initialize SRAM terminal
	rjmp	main

.include "sram.asm"			; include routines to simulate an SRAM terminal
.equ	putc = SRAM_putc	; define the putc routine to be used
.include "putstr.asm"		; include 

; === string constants in program memory ===
s1:	.db	"hello",CR,LF,0
s2:	.db	"Enter number",CR,LF,0
s3:	.db	"Exit",CR,LF,0
s4:	.db	"Error condition",CR,LF,0

main:
	LDIZ	2*s1			; multiply by 2 (word->byte address)
	rcall	puts
	LDIZ	2*s4			; multiply by 2 (word->byte address)
	rcall	puts

	rcall	putsi			; put string immediate
.db	"this is a string",CR,LF,0
	rcall	putsi			; put string immediate
.db	"in mid-text",CR,LF,0

	rjmp	main