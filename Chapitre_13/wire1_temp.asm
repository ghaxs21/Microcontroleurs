; file	wire1_temp.asm   target ATmega128L-4MHz-STK300
; purpose Dallas 1-wire(R) interfacing: circuit tag reading

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === initialization (reset) ===
reset:		
	LDSP	RAMEND			; load stack pointer (SP)
	rcall	wire1_init		; initialize 1-wire(R) interface
	rcall	lcd_init		; initialize LCD
	rjmp	main

.include "lcd.asm"			; include LCD driver routines
.include "printf.asm"		; include formatted printing routines
.include "wire1.asm"		; include Dallas 1-wire(R) routines

; === main program ===
main:
	rcall	wire1_reset		; send a reset pulse
	ldi	a1,8				; load byte counter
	CA	wire1_write, readROM	; ROM command
rom_read:
	rcall	wire1_read		; read one byte
	
	PRINTF	LCD
.db	FHEX,a,0				; display one byte on LCD

	DJNZ	a1,rom_read		; decrement and jump if not zero
	
	CA	lcd_pos, $40		; place cursor to begin of second line

	ldi	a1,8				; load byte counter
	CA	wire1_write, readScratchpad	
ram_read:
	rcall	wire1_read		; read one byte
	
	PRINTF	LCD
.db	FHEX,a,0				; display one byte on LCD

	DJNZ	a1,ram_read		; decrement and jump if not zero

	rjmp	PC				; infinite loop
