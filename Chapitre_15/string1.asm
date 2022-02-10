; file	string1.asm   target ATmega128L-4MHz-STK300
; purpose string manipulation, display through UART0

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === interrupt table ===
.org	0
	jmp	reset

.org	0x30
.include "string.asm"		; include string manipulation routines	
.include "uart.asm"			; include UART routines
.include "printf.asm"		; include formatted printing routines

reset:	
	LDSP	RAMEND			; Load Stack Pointer (SP)
	rcall	UART0_init
	rjmp	main

; === string constants in program memory ===	
cs1:	.db	"hello world.",0
cs2:	.db	"how are you today?0",0
cs3:	.db	0,0

; === string buffers in SRAM ===
.dseg
.org 0x200
sbf1:	.byte	32
sbf2:	.byte	32
sbf3:	.byte	32
.cseg

main:	
	CXZ	strstrldi,sbf1,2*cs1	; load buffers with string constants
	CXZ	strstrldi,sbf2,2*cs2
	CXZ	strstrldi,sbf3,2*cs3

	PRINTF	UART0				; print initial strings
.db	FF,CR,"sbf1= ",FSTR,sbf1
.db	LF,CR,"sbf2= ",FSTR,sbf2
.db	LF,CR,"sbf3= ",FSTR,sbf3,LF,0

	CXY	strstrcpy,sbf3,sbf2		; string copy
	
/*	PRINTF	UART0
.db	LF,CR,"strstrcpy sbf3,sbf2"
.db	LF,CR,"sbf1= ",FSTR,sbf1
.db	LF,CR,"sbf2= ",FSTR,sbf2
.db	LF,CR,"sbf3= ",FSTR,sbf3,LF,0

	ldi	a0,10
	CXY	strstrncpy,sbf3,sbf2	; string copy n characters	
	
	PRINTF	UART0
.db	LF,CR,"strstrncpy sbf3,sbf2,10"
.db	LF,CR,"sbf1= ",FSTR,sbf1
.db	LF,CR,"sbf2= ",FSTR,sbf2
.db	LF,CR,"sbf3= ",FSTR,sbf3,LF,0

	CXY	strstrcat,sbf3,sbf2		; string concatenate	
	
	PRINTF	UART0
.db	LF,CR,"strstrcat sbf3,sbf2"
.db	LF,CR,"sbf3= ",FSTR,sbf3,LF,0

	ldi	a0,10
	CXY	strstrncat,sbf3,sbf2	; string n concatenate	
	
	PRINTF	UART0
.db	LF,CR,"strstrncat sbf3,sbf2,10"
.db	LF,CR,"sbf3= ",FSTR,sbf3,LF,0

	CX	strstrlen,sbf1			; string length
	PRINTF	UART0
.db	LF,CR,"strstrlen sbf1  =",FDEC,a,"   sbf1=",FSTR,sbf1,0

	CX	strstrlen,sbf2
	PRINTF	UART0
.db	LF,CR,"strstrlen sbf2  =",FDEC,a,"   sbf2=",FSTR,sbf2,0

	CX	strstrlen,sbf3
	PRINTF	UART0
.db	LF,CR,"strstrlen sbf3  =",FDEC,a,"   sbf3=",FSTR,sbf3,LF,0

	CX	strstrinv,sbf1			; string inverse	
	
	PRINTF	UART0
.db	LF,CR,"strstrinv sbf1 "
.db	LF,CR,"sbf1= ",FSTR,sbf1,LF,0
*/
	rcall	UART0_getc
	rjmp	main
