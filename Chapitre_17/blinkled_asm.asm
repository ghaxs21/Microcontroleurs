; file	blinkled.asm   target ATmega128L-4MHz-STK300		
; purpose oscillosope measurements on PB1

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:	OUTI	DDRB,0xff	; make portB output

main:	clr		r16			; 
loop01:	inc		r16
		brne	loop01		; waiting 256 increments of r16 
		INVP	PORTB,PB1
	
loop02:	inc		r16
		brne	loop02
		INVP	PORTB,PB1
		rjmp	loop01