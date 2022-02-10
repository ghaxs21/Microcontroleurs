; file	ir2.asm   target ATmega128L-4MHz-STK300
; purpose IR sensor timing measurement

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:
	LDSP	RAMEND			; load stack pointer SP
	rcall	LCD_init		; initialize LCD
	rjmp	main			; jump to main
	
.include "lcd.asm"			; include LCD routines
.include "uart.asm"			; include UART routines
.include "printf.asm"		; include formatte print routines

main:	
	clr	r20					; clear counter low byte
	clr	r21					; clear counter high byte
	WP1	PINE,IR				; Wait if Port=0 
loop:
	subi	r20, low(-1)	; increment low byte
	sbci	r21,high(-1)	; increment high byte
	JP0	PINE,IR,loop		; loop back if pin=0
	
	PRINTF	LCD
.db	"t=",FDEC2,20,"usec  ",CR,0
	rjmp	main