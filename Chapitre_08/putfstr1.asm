; file	putfstr1.asm   target ATmega128L-4MHz-STK300
; purpose display of formatted values, demo

.include "macros.asm"			; include macro definitions
.include "definitions.asm"		; include register/constant definitions

reset:
	LDSP	RAMEND				; set up stack pointer (SP)
	rcall	SRAM_init			; initialize SRAM terminal
	rjmp	main

.include "sram.asm"		; include routines to simulate an SRAM terminal

.equ	putc = SRAM_putc
.include "putstr.asm"			; include put string
.include "puthex.asm"			; include put hexadecimal
.include "putbin.asm"			; include put binary
.include "putdec.asm"			; include put decimal

; === string constants in program memory ===
s1:	.db	"b=",0
s2:	.db	" =0x",0
s3:	.db	" =0b",0

main:
	ldi	a0,-123
	rcall	putdecs				; display in decimal format
	ldi	a0,-123
	rcall	putdec				; display in decimal format

	ldi	b0,123

	LDIZ	2*s1				; load pointer to string
	rcall	puts				; display string
	mov	a0,b0					; load register to display
	rcall	putdec				; display in decimal format
	
	LDIZ	2*s2				; load pointer to string
	rcall	puts				; display string
	mov	a0,b0					; load register to display
	rcall	puthex				; display in hexadecimal format

	LDIZ	2*s3				; load pointer to string
	rcall	puts				; display string
	mov	a0,b0					; load register to display
	rcall	putbin				; display in binary format
	
								; result "b=123 =0x7b =0b01111011"
	rjmp	main