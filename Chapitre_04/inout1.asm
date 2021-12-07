; file	inout1.asm   target ATmega128L-4MHz-STK300
; purpose switch and LEDs read/write

reset:
	ldi	r16,0xff	; configure portB as output
	out	DDRB,r16
	ldi	r16,0x00	; configure portD as input
	out	DDRD,r16
loop:
	in	r16,PIND	; read input buttons
	out	PORTB,r16	; output result to LEDs
	rjmp	loop