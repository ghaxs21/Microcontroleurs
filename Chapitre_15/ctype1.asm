; file	ctype1.asm   target ATmega128L-4MHz-STK300
; purpose testing the character type functions using UART0

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === interrupt table ===
.org	0
	jmp	reset

.org	0x30
.include "ctype.asm"	
.include "uart.asm"
.include "printf.asm"

.macro	ISTYPE	;funct		; print all characters of this type
	clr	a0					; set char=0
loop:	rcall	@0			; call the test function
	brcs	PC+2			; skip if c=1
	rcall	UART0_putc		; print the character (c=0)
	inc	a0					; increment char
	brne	loop			; branch if char <= 255
	.endmacro
	
reset:	
	LDSP	RAMEND			; Load Stack Pointer (SP)
	rcall	UART0_init
main:
	PRINTF	UART0
.db	FF,CR,"isdigit   ",0
	ISTYPE	isdigit			; print decimal digits 0..9
	
	PRINTF	UART0
.db	CR,LF,"islower   ",0
	ISTYPE	islower			; print lower-case letters a..z
	
	PRINTF	UART0
.db	CR,LF,"isupper   ",0
	ISTYPE	isupper			; print upper-case letters A..Z
	
	PRINTF	UART0
.db	CR,LF,"isaf_up   ",0
	ISTYPE	isaf_up			; print hex characters A..F
	
	PRINTF	UART0
.db	CR,LF,"isaf_lo   ",0
	ISTYPE	isaf_lo			; print hex characters a..f	
	
	PRINTF	UART0
.db	CR,LF,"isalnum   ",0
	ISTYPE	isalnum			; print alpha-numeric characters
	
	PRINTF	UART0
.db	CR,LF,"isalpha   ",0
	ISTYPE	isalpha			; print letters a..z and A..Z
	
	PRINTF	UART0
.db	CR,LF,"isxdigit  ",0
	ISTYPE	isxdigit		; print hexadecimal digits
	
	PRINTF	UART0
.db	CR,LF,"ispunct   ",0
	ISTYPE	ispunct			; print punctuation characters
	
	PRINTF	UART0
.db	CR,LF,"isprint   ",0
	ISTYPE	isprint			; print printable characters

	rjmp	PC				; infinite loop