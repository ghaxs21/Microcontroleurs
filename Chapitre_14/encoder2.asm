; file	encoder2.asm   target ATmega128L-4MHz-STK300
; purpose encoder operation, text editor

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRB,0xff		; configure portB to output
	OUTI	PORTB,0xff		; turn off LEDs
	rcall	LCD_init		; initialize the LCD
	rcall	encoder_init	; initialize rotary encoder
	ldi	a0,'a'				; initialize encoder value
	rjmp	main			; jump ahead to the main program
	
.include "lcd.asm"			; include the LCD routines
.include "printf.asm"		; include formatted printing routines
.include "encoder.asm"		; include rotary encoder routines

main:	
	WAIT_MS	1				; wait 1 msec (debouncing)
	rcall	encoder			; read encoder lines
	CYCLIC	a0,'a','z'		; cyclic limits
	
	brtc	PC+2			; if button press then cursor to right
	rcall	lcd_cursor_right

	rcall	lcd_putc		; write character to LCD
	rcall	lcd_cursor_left	; reposition cursor to previous character
	
	rjmp	main			; jump back to main