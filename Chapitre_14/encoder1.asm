; file	encoder1.asm   target ATmega128L-4MHz-STK300
; purpose encoder operation, demo

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRB,0xff		; configure portB to output
	OUTI	PORTB,0xff		; turn off LEDs
	rcall	LCD_init		; initialize the LCD
	rcall	encoder_init
	rjmp	main			; jump ahead to the main program
	
.include "lcd.asm"			; include the LCD routines
.include "printf.asm"		; include formatted printing routines
.include "encoder.asm"		; include rotary encoder routines

main:	
	WAIT_MS	1				; wait 1 milisecond (debouncing)
	rcall	encoder			; poll encoder

	PRINTF	LCD
.db	"a=",FHEX,a,"  b=",FHEX,b,CR,0	
	rjmp	main
