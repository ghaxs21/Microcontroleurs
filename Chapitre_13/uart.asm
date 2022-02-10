; file	uart.asm  target ATmega128L-4MHz-STK300
; purpose setup to two UART units 0 and 1

;.equ	baud0	= 19200
.equ	baud0	= 9600
.equ	_UBRR0	= clock/(16*baud0)-1

UART0_init:	; 19200-8-N-1

	;ldi		r16, 12
	;out		UBRR0L,r16
	ldi		r16, 0x00
	sts		UBRR0H,r16
	ldi		r16,0b00000010
	out		DDRE,r16
	clr	r16
	ldi r16,(1<<TXEN0)|(1<<RXEN0)
	out	UCSR0B,r16
	clr r16
	ldi r16,(1<<UCSZ01)+(1<<UCSZ00)
	sts	UCSR0C, r16



	OUTI	UBRR0L, _UBRR0					; set Baud rate
	;OUTI	UBRR0H, 0x00
	;OUTI	DDRE,0b00000010					; make pin TX0 output
	;OUTI	UCSR0B,(1<<TXEN0)+(1<<RXEN0)	; Transmit/Receive Enable
	;OUTI	UCSR0C, (1<<UCSZ01)+(1<<UCSZ00)	; 8-bit, 1 stop bit, parity disabled
	ret

UART0:
UART0_putc:	
	sbis	UCSR0A,UDRE0					; wait for UART Data Register Empty
	rjmp	PC-1							; loop back if not empty
	out		UDR0,a0							; output character to UART Data Register
	ret
	
UART0_getc:
	sbis	UCSR0A,RXC0						; wait for UART Receive Complete
	rjmp	PC-1							; loop back if not complete
	in		a0,UDR0							; read character to UART Data Register
	ret