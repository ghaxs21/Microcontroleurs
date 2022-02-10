; file	pulsout.asm   target ATmega128L-4MHz-STK300
; purpose rectangular signal generation based on timer2
; output PB7 (OC2)

.include "macros.asm"		; macro definitions
.include "definitions.asm"	; register/constant definitions

reset:	
	LDSP	RAMEND				; load the stack pointer
	OUTI	DDRB,0xff			; make portB all output
	OUTI	TCCR2,0b00011001	; CS2=001 (CK), COM=01 (toggle) CTC=1 (clear)
	rcall	LCD_init		
	rjmp	main

.include "lcd.asm"				; include the LCD routines
.include "printf.asm"			; include formatted printing routines

main:	out	OCR2,a0				; set output compare register
	in	w,TCCR2					; get TCCR2 register
	andi	w,0b11111000		; clear the 3 CS2 bits
	add	w,b0					; add b0
	out	TCCR2,w					; set new TCCR2
	PRINTF	LCD
.db	"CS2=",FHEX,b," OCR2=",FHEX,a,CR,0	
	WAIT_MS	100					; wait 100msec

loop:	JP0	PIND,0,increma		; jump if pin=0, check the buttons
	JP0	PIND,1,decrema
	JP0	PIND,2,incremb
	JP0	PIND,3,decremb
	rjmp	loop				; jump back to main
increma:
	inc	a0
	rjmp	main
decrema:
	dec	a0
	rjmp	main
incremb:
	INC_CYC	b0,1,5
	rjmp	main
decremb:
	DEC_CYC	b0,1,5
	rjmp	main
