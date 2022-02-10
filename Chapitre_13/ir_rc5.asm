; file ir_rc5.asm   target ATmega128L-4MHz-STK300
; purpose IR sensor decoding RC5 format

.include "macros.asm"
.include "definitions.asm"

reset:
	LDSP		RAMEND 			; load stack pointer SP
	rcall		LCD_init		; initialize LCD
	rjmp		main			; jump to main

.include "lcd.asm"				; include the LCD routines
.include "printf.asm"			; include formatted printing routines

.equ		T1 = 1778			; bit period T1 = 1778 usec
main:	CLR2	b1,b0			; clear 2-byte register
	ldi			b2,14			; load bit-counter
	WP1			PINE,IR			; Wait if Pin=1 	
	WAIT_US		(T1/4)			; wait a quarter period
	
loop:	P2C		PINE,IR			; move Pin to Carry (P2C)
	ROL2		b1,b0			; roll carry into 2-byte reg
	WAIT_US		(T1-4)			; wait bit period (- compensation)	
	DJNZ		b2,loop			; Decrement and Jump if Not Zero
	
	com		b0					; complement b0
	rcall		LCD_home		; place cursor to begin of LCD
	PRINTF		LCD				; print formatted
.db	"cmd=",FHEX,b,0
	rjmp		main
