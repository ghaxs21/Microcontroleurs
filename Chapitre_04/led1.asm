; file	led1.asm   target ATmega128L-4MHz-STK300
; purpose slow blinking LEDs

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:	OUTI	DDRB,0xff	; make portB output

main:	inc	a1
	brne	main			; waiting 256*3 cycles = 768 cycles

	inc	a0					; 1 cycle
	out	PORTB,a0			; 1 cycle
	rjmp	main			; 2 cylces	total: 4 cylces