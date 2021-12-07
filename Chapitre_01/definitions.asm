; file:	definitions.asm   target ATmega128L-4MHz-STK300
; purpose library, definition of addresses and constants
; 20171114

; === definitions  ===
.nolist			; do not include in listing
.set	clock	= 4000000

.def	char	= r0	; character (ASCII)
.def	_sreg 	= r1	; saves the status during interrupts
.def	_u 	= r2	; saves working reg u during interrupt
.def	u	= r3	; scratch register (macros, routines)

.def	e0	= r4	; temporary reg for PRINTF 
.def	e1	= r5

.equ	c	= 8
.def	c0	= r8	; 8-byte register c
.def	c1	= r9
.def	c2	= r10
.def	c3	= r11

.equ	d	= 12	; 4-byte register d (overlapping with c)
.def	d0	= r12
.def	d1	= r13
.def	d2	= r14
.def	d3	= r15

.def	w	= r16	; working register for macros
.def	_w	= r17	; working register for interrupts

.equ	a	= 18
.def	a0	= r18	; 4-byte register a
.def	a1	= r19
.def	a2	= r20
.def	a3	= r21

.equ	b	= 22
.def	b0	= r22	; 4-byte register b
.def	b1	= r23
.def	b2	= r24
.def	b3	= r25

.equ	px	= 26	; pointer x
.equ	py	= 28	; pointer y
.equ	pz	= 30	; pointer z

; === ASCII codes
.equ	BEL	=0x07	; bell
.equ	HT	=0x09	; horizontal tab
.equ	TAB	=0x09	; tab
.equ	LF	=0x0a	; line feed
.equ	VT	=0x0b	; vertical tab
.equ	FF	=0x0c	; form feed
.equ	CR	=0x0d	; carriage return
.equ	SPACE	=0x20	; space code
.equ	DEL	=0x7f	; delete
.equ	BS	=0x08	; back space

; === STK-300 ===
.equ	LED	= PORTB	; LEDs on STK-300
.equ	BUTTON	= PIND	; buttons on the STK-300

; === module M2 (encoder/speaker/IR remote) ===
.equ	SPEAKER	= 2	; piezo speaker
.equ	ENCOD_A	= 4	; angular encoder A
.equ	ENCOD_B	= 5	; angular encoder B
.equ	ENCOD_I	= 6	; angular encoder button 
.equ	IR	= 7	; IR module for PCM remote control system

; === module M5 (I2C/1Wire) ===
.equ	SCL	= 0	; I2C serial clock
.equ	SDA	= 1	; I2C serial data
.equ	DQ	= 5	; Dallas 1Wire
				; master transmitter status codes, Table 88
.equ	I2CMT_START = 0x08      ; start
.equ	I2CMT_REPSTART = 0x10   ; repeated start
.equ	I2CMT_SLA_ACK= 0x18     ; slave ack
.equ	I2CMT_SLA_NOACK = 0x20  ; slave no ack
.equ	I2CMT_DATA_ACK = 0x28   ; data write, ack
.equ	I2CMT_DATA_NOACK = 0x30 ; data write, no ack
				; master receiver status codes, Table 89
.equ	I2CMR_SLA_ACK	= 0x40	; slave address ack
.equ	I2CMR_SLA_NACK	= 0x48	; slave address no ack
.equ	I2CMR_DATA_ACK = 0x50	; master data ack
.equ	I2CMR_DATA_NACK= 0x58	; master data no ack

; === module M4 (Keyboard/Sharp/Servo) ===
.equ	KB_CLK	= 0	; PC-AT keyboard clock line
.equ	KB_DAT	= 1	; PC-AT keyboard data line
.equ	GP2_CLK	= 2	; Sharp GP2D02 distance measuring sensor
.equ	GP2_DAT	= 3	; Sharp GP2D02 distance measuring sensor
.equ	GP2_AVAL = 3; Shart GP2Y0A21 distance measuring sensor
.equ	SERVO1	= 4	; Futaba position servo

; === module M3 (potentiometer/BNC) ===
.equ	POT	= 0	; potentiometer
.equ	BNC1	= 2	; BNC input
.equ	BNC2	= 4	; BNC input
.list
