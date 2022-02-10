; file	printf1.asm   target ATmega128L-4MHz-STK300
; purpose display formatted text and values using printf.asm, demo

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:	LDSP	RAMEND		; Load Stack Pointer (SP)
	rcall	UART0_init		; initialize UART
	jmp	main

.include "uart.asm"			; include UART routines
.include "sram.asm"
.include "printf.asm"		; include formatted printing routines

main:
	LDI4	a3,a2,a1,a0,$456789ab	; preload register a

	;PRINTF	UART0
	PRINTF SRAM
.db	FF,CR,"FHEX4,a       =",FHEX4,a
	PRINTF SRAM
.db	LF,CR,"FDEC,a        =",FDEC,a
.db	LF,CR,"FDEC2,a       =",FDEC2,a
.db	LF,CR,"FDEC3,a       =",FDEC3,a
.db	LF,CR,"FDEC4,a       =",FDEC4,a
.db	LF,CR,"FDEC+FSIGN,a   =",FDEC+FSIGN,a
.db	LF,CR,"FDEC2+FSIGN,a  =",FDEC2+FSIGN,a
.db	LF,CR,"FDEC3+FSIGN,a  =",FDEC3+FSIGN,a
.db	LF,CR,"FDEC+FDIG1,a   =",FDEC+FDIG1,a
.db	LF,CR,"FDEC+FDIG2,a   =",FDEC+FDIG2,a
.db	LF,CR,"FDEC+FDIG3,a   =",FDEC+FDIG3,a
.db	LF,CR,"FDEC+FDIG4,a   =",FDEC+FDIG4,a
.db	LF,CR,"FDEC+FDIG5,a   =",FDEC+FDIG5,a
.db	LF,CR,"FDEC+FDIG6,a   =",FDEC+FDIG6,a
.db	LF,CR,"FDEC+FDIG7,a   =",FDEC+FDIG7,a
.db	LF,CR,"FFRAC,a, 1,$33=",FFRAC,a,1,$33
.db	LF,CR,"FFRAC,a, 2,$33=",FFRAC,a,2,$33
.db	LF,CR,"FFRAC,a, 3,$33=",FFRAC,a,3,$33
.db	LF,CR,"FFRAC,a, 4,$33=",FFRAC,a,4,$33
.db	LF,CR,"FFRAC,a, 5,$33=",FFRAC,a,5,$33
.db	LF,CR,"FFRAC,a, 6,$33=",FFRAC,a,6,$33
.db	LF,CR,"FFRAC,a, 7,$33=",FFRAC,a,7,$33
.db	LF,CR,"FFRAC,a, 7,$36=",FFRAC,a,7,$36
.db	LF,CR,"FFRAC,a, 7,$39=",FFRAC,a,7,$39
.db	0
	rjmp	PC
