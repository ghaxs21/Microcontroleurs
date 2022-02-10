; file	latency01.asm   target ATmega128L-4MHz-STK300
; purpose  create very long latency (MCU in idle mode)
	
.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === interrupt table ===
.org	0
	jmp	reset
	
.org	OC0addr		
	jmp	tim0_comp
	
.org	OC1Aaddr		
	jmp	tim1_compa
		
; === interrupt service routines ===
.org	0x0064
reset:	
	LDSP	RAMEND
	OUTI	DDRB, 0xFF						; portB = output
	OUTI	TIMSK,(1<<OCIE0)+(1<<OCIE1A)	; timer 0 and 1 output compare
											;>enable
	OUTI	TCCR0,(1<<COM00)+4				; Timer0 out: toggle PB4=OC0 pin
	OUTI	ASSR, (1<<AS0)					; Timer0 in:  clock from TOSC1 (external)
	OUTI	TCCR1A, (1<<COM1A0)				; Timer1 out: toggle OC1A on ovfl	
	OUTI	TCCR1B, 15						; Timer1 in:  clk = T1 rising
											;>clear on compare match
	OUTI	OCR1AH, 0						; load ocr register
	OUTI	OCR1AL, 7

	OUTI	MCUCR,(0<<SM0)+(0<<SM1)			; enable idle sleep mode

	sei
	rjmp	main
	
tim0_comp:							; OC0 interrupt handler
	INVP	PORTB,6
	reti	
	
tim1_compa:							; OC1 interrupt handler
	INVP	PORTB,3
	reti
		
; === main program ===
main:
	INVP	PORTB,7					; monitor wake-up mode
	WAIT_MS	200						; oscillo needed if line commented
	
	in	r27,MCUCR
	ori	r27,(1<<SE)					; enable sleep mode
	out	MCUCR, r27
	sleep
	in	r27,MCUCR
	andi	r27,~(1<<SE)			; disable sleep mode
	out	MCUCR, r27
	
	rjmp	main