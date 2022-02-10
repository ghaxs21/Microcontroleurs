; file	sharp1.asm   target ATmega128L-4MHz-STK300
; purpose SHARP GP2D02 distance sensor interfacing
; misc   must uncomment/comment appropriate three lines in definitions.asm
;>related to GP2_CLK, GP2_DAT and GP2_AVAL assignments

.include "macros.asm"		; macro definitions
.include "definitions.asm"	; register/constant definitions

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	rcall	sharp_init		; initialize the SHARP distance sensor
	rcall	LCD_init		; initialize the LCD
	jmp	main				; jump ahead to the main program

.include "lcd.asm"			; include the LCD routines
.include "printf.asm"		; include formatted printing routines
.include "sharp.asm"		; include the SHARP GP2D02 distance sensor routines

main:
	rcall	sharp			; make the distance measurement

	PRINTF	LCD
.db	"a=",FDEC+FDIG3,a,CR,0
	rjmp	main			; jump back to main
