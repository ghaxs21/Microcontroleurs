; file	eeprom1.asm   target ATmega128L-4MHz-STK300
; purpose internal EEPROM, demo

.include "macros.asm"		; macro definitions
.include "definitions.asm"	; register/constant definitions

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRB,0xff		; configure portB to output
	rjmp	main			; jump ahead to the main program

.include "eeprom.asm"		; eeprom access routines

main:
	in	a0,PIND				; read buttons
	ldi	xl, low(123)		; load EEPROM address
	ldi	xh,high(123)
	rcall	eeprom_store	; store byte to EEPROM
	
	clr	a0					; clear a0
	rcall	eeprom_load		; relaod a0 from EEPROM
	out	PORTB,a0			; output to LEDs

	WAIT_MS	100				; wait 100 msec
	rjmp	main			; jump back to main