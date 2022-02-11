; file	led.asm   target ATmega128L-4MHz-STK300
; purpose fast blinking LEDs

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:	OUTI	DDRB,0xff	; make portB output

main:	inc	a0			; 1 cycle
	out	PORTB,a0		; 1 cycle
	rjmp	main		; 2 cylces	total: 4 cylces