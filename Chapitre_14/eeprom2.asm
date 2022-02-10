; file	eeprom2.asm   target ATmega128L-4MHz-STK300
; purpose internal EEPROM,

.include "macros.asm"		; macro definitions
.include "definitions.asm"	; register/constant definitions

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRB,0xff		; configure portB to output (LEDs)
	rjmp	main			; jump ahead to the main program

.include "eeprom.asm"		; eeprom access routines

main:	JP0	PIND,0,record

play:
	ldi	xl, low(0)			; load EEPROM address
	ldi	xh,high(0)
play_next:
	rcall	eeprom_load		; relaod a0 from EEPROM
	out	PORTB,a0			; output to LEDs
	adiw	xl,1			; increment EEPROM address
	WAIT_MS	200				; wait 200 msec
	rjmp	play_next
	
record:
	ldi	xl, low(0)			; load EEPROM address
	ldi	xh,high(0)
record_next:
	in	a0,PIND				; read buttons
	out	PORTB,a0			; display on LEDs
	rcall	eeprom_store	; store byte to EEPROM
	adiw	xl,1			; increment EEPROM address
	WAIT_MS	200				; wait 200 msec
	rjmp	record_next