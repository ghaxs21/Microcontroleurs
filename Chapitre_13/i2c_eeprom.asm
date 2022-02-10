; file	i2c_eeprom.asm	   target ATmega128L-4MHz-STK300	
; purpose I2C interface to EEPROM M24C64

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

.equ	EEPROM	= 0b10100000	; device address
.equ	R	= 1					; read flag

reset:
	LDSP	RAMEND				; set up stack pointer (SP)
	OUTI	DDRB,0xff			; configure portB to output
	OUTI	PORTB,0xff			; turn off LEDs
	in	r16, SFIOR				; disable internal pull-up devices
	ori	r16, (1<<PUD)
	out	SFIOR, r16
	rcall	i2c_init			; initialize I2C	
	
	rjmp	main				; jump ahead to the main program
.include "i2cx.asm"				; I2C extended mode routines

; === main program ===	
main:	
	CA	i2c_start,EEPROM		; device address EEPROM
	CA	i2c_write,0x00			; address MSB
	CA	i2c_write,0x00			; address LSB
	CA	i2c_write,0xf5			; data byte1
	CA	i2c_write,0x33			; data byte2
	CA	i2c_write,0x0f			; data byte3	
	rcall	i2c_stop	
	WAIT_US	1000

loop:	
	WAIT_US	1000
			
	CA	i2c_start,EEPROM		; device address EEPROM
	CA	i2c_write,0x00			; address MSB
	CA	i2c_write,0x00			; address LSB
	CA	i2c_rep_start,EEPROM+R	; device address + read flag

	rcall	i2c_read			; read byte1
	rcall	i2c_ack

	rcall	i2c_read			; read byte2
	rcall	i2c_ack
	
	rcall	i2c_read			; read byte3
	rcall	i2c_no_ack			; no acknowledge to indicate end
	rcall	i2c_stop
	
	rjmp	loop
	