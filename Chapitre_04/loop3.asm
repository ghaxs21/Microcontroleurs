; file	loop3.asm   target ATmega128L-4MHz-STK300
; purpose parametrized delay loop

.equ	clock	= 4000000	; clock speed 4MHz
.def	w	= r16			; r16 is used in macro

; --- macro definition ---
; wait k (k=3...768) cycles in increments of 3 cycles
.macro	SWAIT_C	; k
	ldi		w,low((@0)/3)
a:	dec		w
	brne	a	
.endmacro

.macro	SWAIT_US	; k
; wait a maximum of 768/clock(MHz) microseconds
	ldi		w,low((clock/1000*@0)/3000)
a:	dec		w
	brne	a
.endmacro

; --- main program ---
reset:
	ldi			r16,0xFF
	out			DDRB,r16	; portB = output
loop:
	SWAIT_US	150			; wait 150 us
	inc			r0
	out			PORTB,r0
	;SWAIT_C		100		; wait 100 cycles
	;inc			r0
	;out			PORTB,r0	
	rjmp		loop
