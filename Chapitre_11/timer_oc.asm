; file	timer_oc.asm		target ATmega128L-4MHz-STK300
; purpose timer 0,1,2 output compare

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === interrupt vector table ===
.org	0
	rjmp	reset
.org	OC0addr					; timer 0 output compare match
	rjmp	output_compare0
.org	OC1Aaddr				; timer 1 output compare match
	rjmp	output_compare1
.org	OC2addr					; timer 2 output compare match
	rjmp	output_compare2
.org	0x30

; === interrupt service routines ====
.set	timer0 = 100
.set	timer1 = 2000
.set	timer2 = 50

output_compare0:
	INVP	PORTB,1				; invert PB1
	reti
output_compare1:
	INVP	PORTB,3				; invert PB3
	reti
output_compare2:
	INVP	PORTB,5				; invert PB5
	reti
	
; === initialisation (reset) ===	
reset: 
	LDSP	RAMEND				; load stack pointer (SP)
	OUTI	PORTB,0xff			; turn LEDs off
	OUTI	DDRB,0xff			; portB = output
		
	OUTI	ASSR,  (1<<AS0)		; clock from TOSC1 (external)
	OUTI	TCCR0, (1<<CTC0)+1	;  CS0=1 CK	
	OUTI	TCCR1B,(1<<CTC10)+2	;  CS1=1 CK/8
	OUTI	TCCR2, (1<<CTC2)+3	;  CS2=2 CK/64
	
	OUTI	OCR0,timer0-1		; Output Compare reg 0
	OUTI	OCR1AH,high(timer1) ; Output Compare reg 1
	OUTI	OCR1AL, low(timer1) ; Output Compare reg 1	
	OUTI	OCR2,timer2			; Output Compare reg 2
	
	; timer 0,1,2 overflow interrupt enable
	OUTI	TIMSK,(1<<OCIE0)+(1<<OCIE1A)+(1<<OCIE2)
	sei							; set global interrupt

; === main program ===
main:
	WAIT_MS	100
	INVP	PORTB,7
	rjmp	main