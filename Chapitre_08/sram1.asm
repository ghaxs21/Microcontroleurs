; file	sram1.asm   target ATmega128L-4MHz-STK300
; purpose terminal simulation in SRAM

.include "macros.asm"			; include macro definitions
.include "definitions.asm"		; include register/constant definitions

reset:
	LDSP	RAMEND				; set up stack pointer (SP)
	rcall	SRAM_init			; initialize SRAM terminal
	rjmp	main

.include "sram.asm"		; include routines to simulate an SRAM terminal

main:
	CA	SRAM_putc,'a'			; write a
	CA	SRAM_putc,LF			; line feed
	CA	SRAM_putc,'b'			; write b
	CA	SRAM_putc,CR			; carriage return
	CA	SRAM_putc,'c'			; write c
	CA	SRAM_putc,FF			; write form feed
	CA	SRAM_putc,'x'			; write x
	rjmp	main