; file	menu1.asm   target ATmega128L-4MHz-STK300
; purpose usage of menu, demo

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	rcall	LCD_init		; initialize the LCD
	rcall	encoder_init	; initialize rotary encoder
	ldi	a0,0				; initialize day (Mon)
	ldi	b0,0				; initialize month (Jan)
	jmp	main
	
.include "lcd.asm"			; include the LCD routines
.include "printf.asm"		; include formatted printing routines
.include "encoder.asm"		; include rotary encoder routines
.include "menu.asm"			; include menu routines

main:
	rcall	encoder			; poll encoder
	CYCLIC	a0,0,6			; make cyclic adjustments
	CYCLIC	b0,0,11			; make cyclic adjustments

	PRINTF	LCD
.db	CR,CR,FHEX,a,"=>",0		; print a (day)
	
	rcall	menui
.db	"Mon|Tue|Wed|Thu|Fri|Sat|Sun",0

	PRINTF	LCD
.db	"  ",FHEX,b,"=>",0		; print b (month)

	push	a0
	mov	a0,b0
	rcall	menui
.db	"Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec",0
	pop	a0

	WAIT_MS	1
	rjmp	main
