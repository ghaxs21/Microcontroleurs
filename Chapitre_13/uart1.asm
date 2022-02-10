; file	uart1.asm   target ATmega128L-4MHz-STK300
; purpose RS232 UART emulation (internal UART modules not used)
; module: FTDI cable, I/O port: UART

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === definitions ===
;.equ	baud	= 19200		; Baud rate of UART
.equ	baud	= 9600
;.def	c 	= r20		; character

reset:	LDSP	RAMEND		; load stack pointer SP
	OUTI	DDRE,0b00000010	; make Tx (PE1) an output
	sbi	PORTE,PE1	; set Tx to high	
	ldi	r16,0xff ; debug
	out	DDRB,r16 ; debug
	rjmp	main

; === subroutines ===	
wait_bit:
	WAIT_C	(clock/baud)-18	; subtract overhead
	ret
wait_1bit5:
	WAIT_C	(3*clock/2/baud)-18
	ret
	
putc:	cbi	PORTE,PE1	; set start bit to 0
	rcall	wait_bit	; wait 1-bit period (start bit)
	sec			; set carry
loop:	ror	a0		; shift LSB into carry
 	C2P	PORTE,PE1	; carry to port
 	rcall	wait_bit	; wait 1-bit period (data bit)
	clc			; clear carry
	tst	a0		; test c for zero
	brne	loop		; loop back if not zero
	sbi	PORTE,PE1	; set stop bit to 1
	rcall	wait_bit	; wait 1-bit period (stop bit)
	ret	
	
getc:	WP1	PINE,PE0	; wait if pin Rx=1
	rcall	wait_1bit5	; wait 1.5-bit period (start bit)
	ldi	a0,0x80		; preload c
loop2:	P2C	PINE,PE0	; port to carry
	ror	a0		; shift carry into MSB
	rcall	wait_bit	; wait 1-bit period (data bit)
	brcc	loop2		; loop back if carry=0
	ret

; === main program ===
main:	rcall	getc		; get a character from the terminal
	rcall	putc		; put a character back to the terminal 
	INVP	PORTB,1 ; debug
	rjmp	main
