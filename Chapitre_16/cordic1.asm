; file	cordic1.asm   target ATmega128L-4MHz-STK300 
; purpose cordic algorithm testing using UART0

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:	LDSP	RAMEND		; Load Stack Pointer (SP)
	rcall	UART0_init
	rjmp	main

.include "cordic.asm"		; include CORDIC math routines
.include "uart.asm"			; include UART routines
.include "printf.asm"		; include formatted printing routines

main:
	LDI4	a3,a2,a1,a0, 0
	rcall	cos
	PRINTF	UART0
.db	FF,CR,"cos(0   )=",FFRAC4+FSIGN,a,29,$18, "  sin(0   )=",FFRAC4+FSIGN,b,29,$18,0 
	
	LDI4	a3,a2,a1,a0, pi/4
	rcall	cos
	PRINTF	UART0
.db	LF,CR,"cos(pi/4)=",FFRAC4+FSIGN,a,29,$18, "  sin(pi/4)=",FFRAC4+FSIGN,b,29,$18,0 

	LDI4	a3,a2,a1,a0, pi/3
	rcall	cos
	PRINTF	UART0
.db	LF,CR,"cos(pi/3)=",FFRAC4+FSIGN,a,29,$18, "  sin(pi/3)=",FFRAC4+FSIGN,b,29,$18,0 

	rcall	UART0_getc		; wait for a key stroke
	rjmp	main
