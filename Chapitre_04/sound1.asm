; file	sound1.asm   target ATmega128L-4MHz-STK300
; purpose variable frequency and duration beep

.include "macros.asm"		; macro definitions
.include "definitions.asm"	; register/constant definitions

reset:
	LDSP	RAMEND			; load stack pointer SP
	OUTI	DDRB,$ff		; make LEDs output
	sbi	DDRE,SPEAKER		; make pin SPEAKER an output
	rjmp	main

.include "sound.asm"		; include sound routine

main:
	in	w,PIND				; read buttons
	out	PORTB,w				; write result to LEDs
	
	ldi	a0,-1				; preload a0 with -1
	clc						; carry=0
	lsr	w					; shift right, LSB-> carry
	inc	a0					; increment counter
	brcs	PC-2		

	clr	a1					; clear high byte
	ldi	zl, low(2*tbl)		; load table base into z
	ldi	zh,high(2*tbl)	
	add	zl,a0				; add offset to table base
	adc	zh,a1				; add high byte
	lpm						; load program memory, r0 <- (z)
	
	mov	a0,r0				; load oscillation period
	ldi	b0,20				; load duration (20*2.5ms = 50ms)
	rcall	sound
	rjmp	main

tbl:
.db	do,re,mi,fa,so,la,si,do2,0
