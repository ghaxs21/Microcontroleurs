; file	math1.asm   target ATmega128L-4MHz-STK300
; purpose advanced mathematical functions usage, display through UART0

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:	LDSP	RAMEND		; Load Stack Pointer (SP)
	rcall	UART0_init
	rjmp	main

.include "math.asm"			; include math routines
.include "uart.asm"			; include UART routines
.include "printf.asm"		; include formatted printing routines

main:
	LDI4	a3,a2,a1,a0,1234	; load register a
	LDI4	b3,b2,b1,b0,1234	; load register b
	
	rcall	mul44			; multiply 4x4 byte
	
	PRINTF	UART0
.db	LF,CR,FDEC4,a,"x ",FDEC4,b,"= ",FDEC4,c,0

	LDI4	a3,a2,a1,a0,1234567	; load register a
	
	rcall	div44			; divide 4x4 byte
	
	PRINTF	UART0
.db	LF,CR,FDEC4,a,"/ ",FDEC4,b,"= ",FDEC4,c,"  rem=",FDEC4,d,0	

	rcall	UART0_getc		; wait for a key stroke
	rjmp	main
