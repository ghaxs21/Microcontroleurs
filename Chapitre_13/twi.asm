; file	twi.asm   target ATmega128L-4MHz-STK300
; purpose internal two-wire interface (TWI, I2C), library

; === definitions ===
.equ	SLA_W = 0b10100000	; i2c slave adress, write mode
.equ	SLA_R = SLA_W + 1	; i2c slave adress, read mode

; === macros ===
; purpose: call subroutine with single register argument
; arg: subroutine, register; used: r18 (a0)
.macro CWA		
	mov		a0, @1
	call	@0
.endm

; purpose: call subroutine with single immediate argument
; arg: subroutine, immediate; used: r18 (a0)
.macro CWAI		
	ldi		a0, @1
	call	@0
.endm

; purpose: send complement to IO (LEDs)
; arg: port, register; used: void
.macro OUTCOM
	com		@1
	out		@0, @1
.endm 

; purpose: wait for ack signal
; arg: void; used: w
.macro TWI_ACKWAIT
	ack_wait:
	lds 		w, TWCR
	sbrs 		w, TWINT
	rjmp 		ack_wait
.endm

; === routines ===

; purpose: internal i2c twi, initialization
; arg: ; used: r16 (w)
twi_init:
	OUTEI  TWSR, 0x00
    OUTEI  TWBR, 0x0C
ret

; purpose: internal i2c twi, repeated start condition
; arg: r18 (a0); used: r16 (w)
twi_repstartc: 
	ldi 		w, (1<<TWINT) | (1<<TWSTA) | (1<<TWEN) | (0<<TWSTO)
	sts	 		TWCR, w
	TWI_ACKWAIT
	
	lds 		w, TWSR				; check operation completion status
	andi		w, 0xf8
	cpi 		w, I2CMT_REPSTART 		
	breq 		repstart_ret
	jmp			twi_errors
repstart_ret:
	ret

; purpose: internal i2c twi, master send data. ack
; arg: r18; used: r16 (w)
twi_dataWR_ack: 
	sts 		TWDR, a0			; a0: data	 
	OUTEI		TWCR, (1<<TWINT) | (1<<TWEN) | (0<<TWSTA) | (0<<TWSTO)
	TWI_ACKWAIT

	lds 		w, TWSR				
	andi		w, 0xf8
	cpi 		w, I2CMT_DATA_ACK
	breq		datawr_ret_ack
	;jmp		twi_errors		
datawr_ret_ack:
	ret

; purpose: internal i2c twi, master send data, no ack
; arg: r18; used: r16 (w)
twi_dataWR_noack: 
	sts 		TWDR, a0			; a0: data	 
	OUTEI		TWCR, (1<<TWINT) | (1<<TWEN) | (0<<TWSTA) | (0<<TWSTO)
	TWI_ACKWAIT

	lds 		w, TWSR				
	andi		w, 0xf8
	cpi 		w, I2CMT_DATA_NOACK
	breq		datawr_ret_noack
	;jmp			twi_errors		
datawr_ret_noack:
	ret

; purpose: internal i2c twi, master receive data, ack
; arg: r18; used: r16 (w)
twi_dataRD_ack: 	 
	OUTEI		TWCR, (1<<TWINT) | (1<<TWEN) | (0<<TWSTA) | (0<<TWSTO)| (1<<TWEA) 
	TWI_ACKWAIT

	lds 		w, TWSR				; check operation completion status
	andi		w, 0xf8
	cpi 		w, I2CMR_DATA_ACK
	breq		datard_ret_ack
	jmp			twi_errors
datard_ret_ack:
	lds 		a0, TWDR			; a0: data
	ret

; purpose: internal i2c twi, master receive data, noack
; arg: r18; used: r16 (w)
twi_dataRD_noack: 	 
	OUTEI		TWCR, (1<<TWINT) | (1<<TWEN) | (0<<TWSTA) | (0<<TWSTO)| (0<<TWEA) 
	TWI_ACKWAIT

	lds 		w, TWSR				; check operation completion status
	andi		w, 0xf8
	cpi 		w, I2CMR_DATA_NACK
	breq		datard_ret_noack
	jmp			twi_errors
datard_ret_noack:
	lds 		a0, TWDR			; a0: data
	ret

; purpose: internal i2c twi, generate i2c start condition
; arg: void; used: r16 (w)
twi_startc:
	ldi 		w, (1<<TWINT) | (1<<TWSTA) | (1<<TWEN) | (0<<TWSTO);
	sts	 		TWCR, w				; issue start condition
	TWI_ACKWAIT

	lds 		w, TWSR				; check operation completion status
	andi		w, 0xf8
	cpi 		w, I2CMT_START
	breq		start_ret
	jmp			twi_errors
start_ret:
	ret

; purpose: internal i2c twi, generate i2c stop condition
; arg: void; used: r16 (w)
twi_stopc:
	ldi 		w, (1<<TWINT) | (1<<TWSTO) | (1<<TWEN) | (0<<TWSTA)
	sts	 		TWCR, w
	
	ret

; purpose: internal i2c twi, generate i2c slave address in master write mode
; arg: r18 (a0) void; used: r16 (w)
twi_sla_address_mtwr:
	sts	 		TWDR, a0						; a0 address + RD/WRb
	OUTEI		TWCR, (1<<TWINT) | (1<<TWEN)	
	TWI_ACKWAIT

	lds 		w, TWSR
	andi		w, 0xf8
	cpi 		w, I2CMT_SLA_ACK
	breq		stop_ret_mtwr
	jmp			twi_errors
stop_ret_mtwr:
	ret

; purpose: internal i2c twi, generate i2c slave address in master read mode
; arg: r18 (a0) void; used: r16 (w)
twi_sla_address_mtrd:
	sts	 		TWDR, a0						; a0 address + RD/WRb
	OUTEI		TWCR, (1<<TWINT) | (1<<TWEN) 
	TWI_ACKWAIT

	lds 		w, TWSR
	andi		w, 0xf8
	cpi 		w, I2CMR_SLA_ACK
	breq		stop_ret_mtrd
	jmp			twi_errors
stop_ret_mtrd:
	ret
	
; purpose: internal i2c twi, handle error status transmission
; arg:  r16 (w); used: void
; any error is only handled by displaying the error code on the
; LCD and generating a stop condition. The error code is the
; status code, AVR specs pp. 214 and pp. 218 and can be interpreted
; from the tables
twi_errors:
	OUTCOM	PORTB, w		; status part of TWSR is w at this moment
	pop		w				; dump return address out of stack
	pop		w
	jmp		twi_end