; file	wire1_temp2.asm   target ATmega128L-4MHz-STK300		
; purpose Dallas 1-wire(R) temperature sensor interfacing: temperature

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === initialization (reset) ===
reset:		
	LDSP	RAMEND				; load stack pointer (SP)
	rcall	wire1_init			; initialize 1-wire(R) interface
	rcall	lcd_init			; initialize LCD
	rjmp	main

.include "lcd.asm"				; include LCD driver routines
.include "printf.asm"			; include formatted printing routines
.include "wire1.asm"			; include Dallas 1-wire(R) routines

; === main program ===
main:
	rcall	wire1_reset			; send a reset pulse
	CA	wire1_write, skipROM	; skip ROM identification
	CA	wire1_write, convertT	; initiate temp conversion
	WAIT_MS	750					; wait 750 msec
	
	rcall	lcd_home			; place cursor to home position
	rcall	wire1_reset			; send a reset pulse
	CA	wire1_write, skipROM
	CA	wire1_write, readScratchpad	
	rcall	wire1_read			; read temperature LSB
	mov	c0,a0
	rcall	wire1_read			; read temperature MSB
	mov	a1,a0
	mov	a0,c0

	PRINTF	LCD
.db	"temp=",FFRAC2+FSIGN,a,4,$42,"C ",CR,0
	rjmp	main
