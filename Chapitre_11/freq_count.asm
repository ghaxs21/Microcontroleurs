; file	freq_count.asm   target ATmega128L-4MHz-STK300
; purpose  frequency counter
; input PD6 (T1), e.g., BNC and AWG

.include "macros.asm"		; macro definitions
.include "definitions.asm"	; register/constant definitions

.equ	meas_ready = 0

; === interrupt vector table ===
.org	0
	rjmp	reset
.org	OVF0addr		; timer 0 overflow
	rjmp	overflow0
.org	OVF1addr		; timer 1 overflow
	rjmp	overflow1
.org	0x30			; after interrupt vector table

.include "lcd.asm"		; include the LCD routines
.include "printf.asm"	; include formatted printing routines

; === interrupt service routines ====
; timer0 overflow occurs every 1 second
overflow0:
	in	_sreg,SREG
	in	a0,TCNT1L		; transfer pulse count to a1:a0
	in	a1,TCNT1H
	clr	_w
	out	TCNT1H,_w		; reset count (a2 later)
	out	TCNT1L,_w
	FB1	b0,meas_ready	; set semaphore flag
	out	SREG,_sreg
	reti

overflow1:
; if the timer1 overflows we need to increment byte2 of the counter
	in	_sreg,SREG
	inc	a2				; increment byte a2
	out	SREG,_sreg
	reti
	
; === initialisation (reset) ===	
reset: 
	LDSP	RAMEND		; load stack pointer (SP)
	OUTI	PORTB,0xff	; turn LEDs off
	OUTI	DDRB,0xff	; portB = output
		
	OUTI	ASSR,  (1<<AS0)	; clock from TOSC1 (external)
	OUTI	TCCR0, 5	; CS0=5 CK/128 (1 second	
	OUTI	TCCR1B,7	; external pin T1 rising
	
	; timer 0,1 overflow interrupt enable
	OUTI	TIMSK,(1<<TOIE0)+(1<<TOIE1)
	sei					; set global interrupt
				
	rcall	LCD_init	; initialize LCD

; === main program ===
main:	
	WB0	b0,meas_ready	; wait if semaphore = 0		; 
	FB0	b0,meas_ready	; reset semaphore
	PRINTF	LCD
.db	"f=",FDEC3,a,"Hz  ",CR,0
	clr	a2				; clear byte 3
	rjmp	main
