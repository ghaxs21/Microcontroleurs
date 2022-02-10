; file	freq_count2.asm   target ATmega128L-4MHz-STK300
; purpose time period measurement
; input PD6 (T1), e.g., BNC and AWG

.include "macros.asm"		; macro definitions
.include "definitions.asm"	; register/constant definitions

; === interrupt vector table ===
.org	0
	rjmp	reset
.org	ICP1addr
	rjmp	input_capt1	; input capture interrupt

.org	0x30			; end of interrupt vector table

.include "lcd.asm"		; include the LCD routines
.include "printf.asm"	; include formatted printing routines

input_capt1:
	in	_sreg,SREG
	in	c0,ICR1L		; new value into c (old value in d)
	in	c1,ICR1H
	mov	a0,c0
	mov	a1,c1
	sub	a0,d0			; period(a) = new(c)-old(d)
	sbc	a1,d1
	mov	d0,c0			; old(d) = new(c)
	mov	d1,c1	
	out	SREG,_sreg
	reti
	
; === initialisation (reset) ===	
reset: 
	LDSP	RAMEND		; load stack pointer (SP)
	OUTI	PORTB,0xff	; turn LEDs off
	OUTI	DDRB,0xff	; portB = output
		
	OUTI	TCCR1B,1	; clock select CK/1
	; timer1 input capture interrupt enable
	OUTI	TIMSK,(1<<TICIE1)
	sei					; set global interrupt
	
	rcall	LCD_init	; initialize LCD

; === main program ===
main:	
	cli
	PRINTF	LCD
.db	"t=",FFRAC2,a,2,$62,"us",CR,0
	sei
	WAIT_MS	200
	rjmp	main
