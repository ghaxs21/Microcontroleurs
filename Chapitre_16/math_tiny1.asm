; file	math_tiny1.asmtarget ATmega128L-4MHz-STK300
; purpose advanced mathematical functions usage, display through UART0

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:	LDSP	RAMEND		; Load Stack Pointer (SP)
	rcall	UART0_init
	rjmp	main

.include "math_tiny.asm"	; include math routines
.include "uart.asm"			; include UART routines
.include "printf.asm"		; include formatted printing routines

main:
	LDI4	a3,a2,a1,a0,1234
	LDI4	b3,b2,b1,b0,5678

	PRINTF	UART0
.db	FF,CR,"        a=",FDEC4,a,"  b=",FDEC4,b,0

	rcall	addab
	PRINTF	UART0
.db	LF,CR,"addab   a=",FDEC4,a,"  b=",FDEC4,b,0

	rcall	movab
	PRINTF	UART0
.db	LF,CR,"movab   a=",FDEC4,a,"  b=",FDEC4,b,0

	rcall	inca
	PRINTF	UART0
.db	LF,CR,"inca    a=",FDEC4,a,"  b=",FDEC4,b,0

	rcall	mulab
	PRINTF	UART0
.db	LF,CR,"mulab   a=",FDEC4,a,"  b=",FDEC4,b,"  c=",FDEC4,c,0

	MOV4	a3,a2,a1,a0, c3,c2,c1,c0
	rcall	divab
	PRINTF	UART0
.db	LF,CR,"divab   a=",FDEC4,a,"  b=",FDEC4,b,"  c=",FDEC4,c,"  d=",FDEC4,d,00

	rcall	UART0_getc		; wait for a key stroke
	rjmp	main
