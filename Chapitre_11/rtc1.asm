; file	rtc1.asm   target ATmega128L-4MHz-STK300
; purpose real-time clock

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === register definition ===
.def	second	= r18
.def	minute	= r19
.def	hour	= r20

; === interrupt table ===
.org	0
	rjmp	reset
.org	OVF0addr
	rjmp	tim0_ovf
.include "lcd.asm"
.include "printf.asm"	

; === interrupt service routine (ISR) ===	
tim0_ovf:
	in	_sreg,SREG	; save context
	inc	second
	cpi	second,60
	brne	done
	clr	second
	inc	minute
	cpi	minute,60
	brne	done
	clr	minute
	inc	hour
	cpi	hour,24
	brne	done
	clr	hour
done:
	out	SREG,_sreg	; restore context
	reti	

; === initialisation ===
reset:
	ldi	r16,low(RAMEND)
	out	SPL,r16
	ldi	r16,high(RAMEND)
	out	SPH,r16

	ldi	r16,(1<<AS0)
	out	ASSR,r16		; clock from TOSC1 (external)	
.set	CS0 	= 5		; clock select (prescaler)
.set	COM0	= 1		; toggle the OC pin
	ldi	r16,(COM0<<4)+CS0
	out	TCCR0,r16		; Timer/Counter0 Control Register	
	sei					; set global interrupt
	ldi	r16,(1<<TOIE0)	; enable timer0 interrupt
	out	TIMSK,r16
	OUTI	DDRB,0xff
	sei					; global interrupt enable
	
	rcall	LCD_init
	clr	hour
	clr	minute
	clr	second

; === main program ===		
main:
	INCDEC	PIND,0,1,second,0,59
	INCDEC	PIND,2,3,minute,0,59
	INCDEC	PIND,6,7,hour,  0,23
	
	PRINTF	LCD
.db	FDEC,20," :",FDEC,19," :",FDEC,18,"    ",CR,0

	WAIT_MS	100
	rjmp	main