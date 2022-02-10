; file	timer_oc1.asm   target ATmega128L-4MHz-STK300
; purpose timer output compare and toggle pin
; output: PB4, PB5, PB6 (OC) and PB0 (main)

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === interrupt vector table ===
.org	0
	rjmp	reset

; === initialisation (reset) ===
.set	timer0 = 100
.set	timer1 = 2000
.set	timer2 = 50
	
reset: 
	LDSP	RAMEND							; load stack pointer (SP)
	OUTI	PORTB,0xff						; turn LEDs off
	OUTI	DDRB,0xff						; portB = output
		
	OUTI	ASSR,  (1<<AS0)					; clock from TOSC1 (external)
	OUTI	TCCR0, (1<<WGM01)+(1<<COM00)+1	;  CS0=1 CK	(last expression: +1)
	OUTI	TCCR1B,(1<<WGM12)+2				;  CS1=1 CK/8	(last expression: +2)
	OUTI	TCCR2, (1<<WGM21)+(1<<COM20)+3	;  CS2=2 CK/64	(last expression: +3)
	OUTI	TCCR1A,(1<<COM1A0)
	
	OUTI	OCR0,timer0-1					; Output Compare register 0
	OUTI	OCR1AH,high(timer1)				; Output Compare register 1
	OUTI	OCR1AL, low(timer1)				; Output Compare register 1	
	OUTI	OCR2,timer2						; Output Compare register 2
	
; === main program ===
main:
	WAIT_MS	100
	INVP	PORTB,0
	rjmp	main