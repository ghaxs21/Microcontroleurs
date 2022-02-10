; file	cset1.asm   target ATmega128L-4MHz-STK300
; purpose character set manipulations using UART0

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

.dseg
s1:	.byte	16				; define space in SRAM
s2:	.byte	16				; a character set is 128 bits
s3:	.byte	16
s4:	.byte	16
str1:	.byte	64			; buffer space for strings
str2:	.byte	64

.cseg
reset:	LDSP	RAMEND		; Load Stack Pointer (SP)
	rcall	UART0_init
	rjmp	main

.include "cset.asm"			; include character set routines
.include "string.asm"		; include string manipulation routines
.include "uart.asm"			; include UART routines
.include "printf.asm"		; include formatted printing routines

; === constant strings in program memory ===
cs1:	.db	"The ATmega103 is a low-power CMOS 8-bit microcontroller",0
cs2:	.db	"The device uses nonvolatile memory technology",0

main:	CXZ	strstrldi,str1,2*cs1	; string load from Flash to SRAM
	CXZ	strstrldi,str2,2*cs2		; prog mem address must be multiplied by 2

	CX	csEmpty,s1			; start with an empty set
	CAB	csAddRange,'0','9'	; add the range 0..9 (digits)
	CA	csAddChar,'A'		; add thd character A
	CA	csRmvChar,'7'		; remove the character 7
	
	CX	csEmpty,s2			; start with an empty set
	CXY	csAddStr,s2,str1	; add string 1
	
	CX	csEmpty,s3			; start with an empty set
	CXY	csAddStr,s3,str2	; add string 2
		
	PRINTF	UART0
.db	FF,CR,"cs1 =",FSTR,str1
.db	LF,CR,"cs2 =",FSTR,str2
.db	LF,LF,CR,CR,"s1 =",0
	CX	print_cset,s1

	PRINTF	UART0
.db	LF,CR,"s2 =",0
	CX	print_cset,s2
	
	PRINTF	UART0
.db	LF,CR,"s3 =",0
	CX	print_cset,s3
	
	CXYZ	csUnion,s2,s3,s4
	PRINTF	UART0
.db	LF,LF,CR,CR,"union(s2,s3)     =",0
	CX	print_cset,s4

	CXYZ	csIntersect,s2,s3,s4
	PRINTF	UART0
.db	LF,CR,"intersect(s2,s3) =",0
	CX	print_cset,s4

	CXYZ	csDifference,s2,s3,s4
	PRINTF	UART0
.db	LF,CR,"difference(s2,s3)=",0
	CX	print_cset,s4

	CXY	csCopy,s2,s4
	CX	csComplement,s4
	CAB	csRmvRange,0,31		; remove non-printable chars
	PRINTF	UART0
.db	LF,CR,"complement(s2)   =",0
	CX	print_cset,s4
	
	rjmp	PC				; infinite loop

print_cset:
; in	x (ptr to charset)
	ldi	a0,0
pcset1:	rcall	csIsMember	s; C=0 (yes)
	brcs	PC+2
	rcall	UART0_putc
pcset2:	IJNK	a0,127,pcset1
	ret
