; file	sharp.asm	   target ATmega128L-4MHz-STK300
; purpose library, SHARP GP2D02 distance sensor interfacing
	
.equ	gp2	= PORTD		; PORT of the distance sensor
						; DDR	= gp2-1
						; PIN	= gp2-2

; === simulating and open collector clock ===
.macro	CLK0
	sbi	gp2-1,GP2_CLK		; make CLK=output, pin=0, pull-down
	.endmacro
.macro	CLK1
	cbi	gp2-1,GP2_CLK		; make CKL=input, pin=hi-Z, floating
	.endmacro

sharp_init:
	cbi	gp2,GP2_CLK			; preset CLK with 0 (pull-down)
	ret	

; ===========================================
; out	a0	value corresponds to distance
; mod	a1

sharp:
	CLK0					; clk=0
	WAIT_MS	70				; wait 70ms
	ldi	a1,8				; load bit-counter
loop:
	CLK1					; clk=1
	WAIT_US	100				; wait 100us
	CLK0					; clk=0
	WAIT_US	100				; wait 100us
	P2C	gp2-2,GP2_DAT		; DAT to carry
	rol	a0					; rotate carry into LSB
	dec	a1					; decrement bit-counter
	brne	loop			; branch if not zero
	CLK1					; clk=1
	WAIT_MS	2				; wait 2ms
	ret