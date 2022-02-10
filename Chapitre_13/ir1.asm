; file	ir1.asm		target ATmega128L-4MHz-STK300
; purpose IR sensor detecting

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:
	LDSP	RAMEND			; load stack pointer SP
	OUTI	DDRB,$ff		; make portB output	
main:	
	WP0	PINE,IR				; Wait if Port=0 
	WP1	PINE,IR				; Wait if Port=1
	inc	r16					; increment the counter
	out	PORTB,r16			; display the counter on LEDs
	rjmp	main