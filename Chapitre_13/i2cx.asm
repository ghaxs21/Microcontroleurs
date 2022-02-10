; file	i2cx.asm   target ATmega128L-4MHz-STK300
; purpose extended I2C (400 k bit/s), software emulation

; === definitions ===
.equ	SDA_port= PORTB
.equ	SDA_pin	= SDA
.equ	SCL_port= PORTB
.equ	SCL_pin	= SCL
/*.equ	SDA_port= PORTD
.equ	SDA_pin	= 1
.equ	SCL_port= PORTD
.equ	SCL_pin	= 0*/

; === macros ===
; these macros control DDRx to simulate an open collector
; with external pull-up resistors

.macro	SCL0
	sbi	SCL_port-1,SCL_pin 	; pull SCL low (output, port=0)
	.endmacro
.macro	SCL1
	cbi	SCL_port-1,SCL_pin 	; release SCL (input, hi Z)
	.endmacro
.macro	SDA0
	sbi	SDA_port-1,SDA_pin 	; pull SDA low (output, port=0)
	.endmacro
.macro	SDA1
	cbi	SDA_port-1,SDA_pin 	; release SDA (input, hi Z)
	.endmacro

.macro	I2C_BIT_OUT	;bit
	sbi	SCL_port-1,SCL_pin 	; pull SCL low (output, port=0)
	in	w,SDA_port-1		; sample the SDA line
	bst	a0,@0				; store a0(bit) to T
	bld	w,SDA_pin			; load w(SDA) with T
	out	SDA_port-1,w		; transfer bit_x to SDA
	cbi	SCL_port-1,SCL_pin 	; release SCL (input, hi Z)
	rjmp	PC+1			; wait 2 cyles
	.endmacro

.macro	I2C_BIT_IN	;bit
	sbi	SCL_port-1,SCL_pin 	; DDRx=output	SCL=0
	cbi	SDA_port-1,SDA_pin 	; release SDA (input, hi Z)	
	cbi	SCL_port-1,SCL_pin 	; DDRx=input	SCL=1
	nop						; wait 1 cycle
	in	w,SDA_port-2		; PINx=PORTx-2
	bst	w,SDA_pin			; store bit read in T
	bld	a0,@0				; load a0(bit) from T
	.endmacro

; === routines ===
i2c_init:
	cbi	SDA_port,  SDA_pin	; PORTx=0 (for pull-down)
	cbi	SCL_port,  SCL_pin	; PORTx=0 (for pull-down)
	SDA1					; release SDA
	SCL1					; release SCL
	ret

i2c_rep_start:
; in: 	a0 (byte to transmit)
	SCL0
	SDA1
	SCL1
i2c_start:
; in: 	a0 (byte to transmit)
	SDA0
i2c_write:
	com	a0					; invert a0
	I2C_BIT_OUT 7
	I2C_BIT_OUT 6
	I2C_BIT_OUT 5
	I2C_BIT_OUT 4
	I2C_BIT_OUT 3
	I2C_BIT_OUT 2
	I2C_BIT_OUT 1
	I2C_BIT_OUT 0
	com	a0					; restore a0
i2c_ack_in:
	SCL0
	SDA1					; release SDA
	SCL1
	in	w,SDA_port-2		; PINx=PORTx-2
	bst	w,SDA_pin			; store ACK into T
	ret

i2c_read:
; out: 	a0 (byte read)
	I2C_BIT_IN 7
	I2C_BIT_IN 6
	I2C_BIT_IN 5
	I2C_BIT_IN 4
	I2C_BIT_IN 3
	I2C_BIT_IN 2
	I2C_BIT_IN 1
	I2C_BIT_IN 0
	ret
	
i2c_ack:
	SCL0
	SDA0
	SCL1
	ret
	
i2c_no_ack:
	SCL0
	SDA1
	SCL1
	ret

i2c_stop:
	SCL0
	SDA0
	SCL1
	SDA1				; release again
	ret