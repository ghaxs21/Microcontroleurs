; file	timer_ov.asm   target ATmega128L-4MHz-STK300
; purpose timers 0,1,2 overflows	

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === interrupt vector table ===
.org	0
	rjmp	reset
.org	OVF0addr		; timer overflow 0 interrupt vector
	rjmp	overflow0
.org	OVF1addr		; timer overflow 1 interrupt vector
	rjmp	overflow1
.org	OVF2addr		; timer overflow 2 interrupt vector
	rjmp	overflow2
.org	0x30

; === interrupt service routines ====
overflow0:
	INVP	PORTB,1		; invert PB1
	reti
overflow1:
	INVP	PORTB,3		; invert PB3
	reti
overflow2:
	INVP	PORTB,5		; invert PB5
	reti
	
; === initialisation (reset) ===	
reset: 
	LDSP	RAMEND		; load stack pointer (SP)
	OUTI	PORTB,0xff	; turn LEDs off
	OUTI	DDRB,0xff	; portB = output
		
	OUTI	ASSR, (1<<AS0)	; clock from TOSC1 (external)
	OUTI	TCCR0,1		; CS0=1 CK	
	OUTI	TCCR1B,2	; CS0=1 CK/8
	OUTI	TCCR2,3		; CS0=2 CK/64
	
	; timers 0,1,2 overflow interrupt enable
	OUTI	TIMSK,(1<<TOIE0)+(1<<TOIE1)+(1<<TOIE2)

	sei					; set global interrupt

; === main program ===
main:
	WAIT_MS	100
	INVP	PORTB,7		; invert PB7
	rjmp	main