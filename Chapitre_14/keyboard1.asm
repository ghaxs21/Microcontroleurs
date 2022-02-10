; file	keyboard1.asm   target ATmega128L-4MHz-STK300
; purpose interfacing PC AT keyboard

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRB,0xff		; LEDs output
	rcall	LCD_init		; initialize the LCD
	rjmp	main			; jump ahead to the main program
	
.include "lcd.asm"			; include the LCD routines
.include "printf.asm"		; include formatted printing routines
.include "keyboard.asm" 	; include keyboard routine

main:	
	rcall	kbd_getc

	PRINTF	LCD
.db	"code=",FHEX,a,CR,0		; print in HEX format r20
	rjmp	main			; jump back to main
