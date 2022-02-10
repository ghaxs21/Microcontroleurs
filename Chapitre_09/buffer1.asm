; file	buffer1.asm   target ATmega128L-4MHz-STK300
; purpose FIFO usage, demo

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions
.include "buffer.asm"		; include macro definitions for buffers

.equ	len	= 8
.dseg
buf:
	.byte	1				; buffer in-pointer
	.byte	1				; buffer out-pointer
	.byte	1				; number of elements in buffer
	.byte	len				; buffer area
.cseg

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	rjmp	main			; jump ahead to the main program

; === subroutines ===

b_init:	CB_INIT	buf		
	ret
	
b_push:	CB_PUSH buf, len, a0
	ret
	
b_pop:	CB_POP  buf, len, a0
	ret

main:
	rcall	b_init

loop:
	CA	b_push,'h'			; push 5 elements
	CA	b_push,'e'
	CA	b_push,'l'
	CA	b_push,'l'
	CA	b_push,'o'
	rcall	b_pop			; pop 1 element
	rjmp	loop			; jump back to main