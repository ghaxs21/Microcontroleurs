; file	tim0_ov.asm   target ATmega128L-4MHz-STK300
; purpose timer 0 overflow

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

.org	0
	jmp	reset
.org	OVF0addr				; timer overflow 0 interrupt vector
	INVP	PORTB,1				; invert the portD.1
	reti
reset: 
	LDSP	RAMEND				; load stack pointer (SP)
	OUTI	PORTB,0xff			; turn LEDs off
	OUTI	DDRB,0xff			; portB = output
		
	OUTI	TIMSK,(1<<TOIE0)	; timer0 overflow interrupt enable
	OUTI	ASSR, (1<<AS0)		; clock from TOSC1 (external)
	OUTI	TCCR0,1				; CS0=1 CK
	sei							; set global interrupt

main:
	WAIT_MS	100
	INVP	PORTB,7
	rjmp	main