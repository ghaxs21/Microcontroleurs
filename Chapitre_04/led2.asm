; file	led2.asm   target ATmega128L-4MHz-STK300
; purpose very slow blinking LEDs

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:	OUTI	DDRB,0xff	; make portB output

main:	inc	a2				; inner loop
	brne	main			; waiting 256*756 = 768 cycles

	inc	a1					; outer loop
	brne	main			; waiting 256*768 cycles = 196608 cycles

	inc	a0					; 1 cycle
	out	PORTB,a0			; 1 cycle
	rjmp	main			; 2 cylces	total: 4 cylces