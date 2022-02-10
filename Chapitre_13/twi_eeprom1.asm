; file	twi_eeprom1.asm   target ATmega128L-4MHz-STK300	
; purpose: internal i2c twi, 4 MHz, 100 kHz, without interrupts
; usage: twi on PD0: SCL, PD1: SDA

.include "definitions.asm"
.include "macros.asm"

; ----- IVT
.org 0x0000
	rjmp reset

; ----- configuration
.include "twi.asm"

; ----- startup configuration
reset:
	LDSP	RAMEND
	OUTI	DDRB, 0xff				; LEDs active and off
	OUTI	PORTB, 0xff
	OUTI	DDRD, 0xff				; PD0 output (SCL), PD1 input (SDA)
	OUTI	PORTD, 0xff

	OUTEI	TWBR, 2					; 4 MHz, 100 kHz -> 12
	OUTEI	TWSR, 0x00				; clear prescaler

	in	r16, SFIOR					; disable internal pull-up devices
	ori	r16, (1<<PUD)
	out	SFIOR, r16

	ldi		w, (1<<TWINT) | (1<<TWSTO) | (1<<TWEN)
	sts		TWCR,w					; stop condition

; ----- main program
main:			
	rcall	twi_startc
	CWAI	twi_sla_address_mtwr, SLA_W
	CWAI	twi_dataWR_ack, 0x00		; start EEPROM address
	CWAI	twi_dataWR_ack, 0x00
	CWAI	twi_dataWR_ack, 0xff		; stored data
	CWAI	twi_dataWR_ack, 0x00
	CWAI	twi_dataWR_ack, 0xaf
	rcall	twi_stopc

	WAIT_US	100
	
eeprom_read:
	rcall	twi_startc
	CWAI	twi_sla_address_mtwr, SLA_W
	CWAI	twi_dataWR_noack, 0x00		; start EEPROM address
	CWAI	twi_dataWR_noack, 0x02
	rcall	twi_repstartc
	CWAI	twi_sla_address_mtrd, SLA_R
	rcall	twi_dataRD_noack
	rcall	twi_stopc
	
twi_end:							; desination in case of error
	rcall	twi_stopc

	WAIT_US	200
	jmp		main