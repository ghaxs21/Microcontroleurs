; file	uart2.asm   target ATmega128L-4MHz-STK300		
; purpose UART internal module, without interrupt
; module: FTDI cable, I/O port: UART

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:	
	LDSP	RAMEND		; Load Stack Pointer (SP)
	rcall	UART0_init	; initialize UART
	rjmp	main
	
.include "uart.asm"

; === main program ===
main:	rcall	UART0_getc	; read a character from the terminal
	rcall	UART0_putc	; write a character to the terminal
	rjmp	main
