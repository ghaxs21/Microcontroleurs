; file	putdec.asm   target ATmega128L-4MHz-STK300
; purpose library, decimal ascii display

putdec:
; put decimal value 
; in 	a0	(value to convert)
;	putc 	(address of a routine to "write" the character)

	mov	u,a0			; number to convert is kept in u

	ldi	a0,'0'-1		; preload a0 (digit)
	ldi	w,100			; load the "hundreds"
_putdec2:	
	inc	a0
	sub	u,w				; subtract 100
	brsh	_putdec2	; until the result is negative
	add	u,w				; undo the last substraction
	rcall	putc		; display the digit2

	ldi	a0,'0'-1		; preaload a0 (digit)
	ldi	w,10			; load the "tens"
_putdec1:	
	inc	a0
	sub	u,w				; subtract 10
	brsh	_putdec1	; until the result is negative
	add	u,w				; undo the last substraction
	rcall	putc		; display digit1
	ldi	a0,'0'	
	add	a0,u
	rcall	putc		; display digit0
	ret

putdecs:
; put signed decimal value
; in 	a0	(value to convert)
;	putc 	(address of a routine to "write" the character)

	tst	a0				; test a0
	brpl	putdec		; if positive got to putdec
	push	a0			; save a0 temporarily 
	ldi	a0,'-'
	rcall	putc		; display the negative sign
	pop	a0				; restore a0
	neg	a0				; negate a0
	rjmp	putdec