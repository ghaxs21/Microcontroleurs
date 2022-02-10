; file	watchdog1.asm   target ATmega128L-4MHz-STK300
; purpose infinite loop, no watchdog timer

reset:
	ldi	r16,0xff		; make portB output
	out	DDRB,r16
main:	
	inc	r16				; inner loop 256x
	brne	main
	inc	r17				; outer loop 256x
	brne	main
	inc	r18
	out	PORTB,r18		; output to LED	
	sbic	PIND,0		; if button0 then jump to infinite
	rjmp	main
infinite:
	rjmp	infinite	; infinite loop	