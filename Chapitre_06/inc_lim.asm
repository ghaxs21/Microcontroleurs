; file	inc_lim.asm   target ATmega128L-4MHz-STK300
; purpose limited loop incremnetation/decrementation

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:
	LDSP	RAMEND			; load stack pointer SP
	OUTI	DDRB,$ff		; make portB output
	
loop:	
	WAIT_MS	100				; wait 100 miliseconds
	JP0	PIND,0,button0		; Jump if Port=0
	JP0	PIND,1,button1		; Jump if Port=0
	rjmp	loop
	
button0:
	INC_LIM	a0,10			; increment and limit to 10
	inc		a0
	mov		w,a0
	com		w
	out		LED,w			; display result on LED
	rjmp	loop
	
button1:
	DEC_LIM	a0,3			; decrement and limit to 3
	dec		a0
	mov		w,a0			; invert the byte to output 
	com	w					; LED: 0=on, 1=off
	out		LED,w			; display result on LED
	rjmp	loop