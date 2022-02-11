; file	inout2.asm   target ATmega128L-4MHz-STK300
; purpose switches and LEDs, rising edge triggered

reset:
	ldi	r16,0xFF	; configure portB as output
	out	DDRB,r16
	ldi	r16,0x00	; configure portD as input
	out	DDRD,r16
	clr	r16
loop:
	sbic	PIND,0	; wait if pin=1
	rjmp	PC-1
	sbis	PIND,0	; wait if pin=0
	rjmp	PC-1
	
	dec	r16			; decrement counter
	out	PORTB,r16	; output result to LEDs
	rjmp	loop