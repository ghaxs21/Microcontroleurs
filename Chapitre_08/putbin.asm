; file	putbin.asm   target ATmega128L-4MHz-STK300
; purpose library, binary ascii display

putbin:
; put binary value 
; in 	a0	(value to convert)
;	putc 	(address of a routine to "write" the character)

	mov	u,a0		; move value to temporary register u
	ldi	w,8			; load bit counter with 8
_putbin:
	lsl	u			; shift MSB bit into carry
	ldi	a0,'0'	
	brcc	PC+2	; test carry
	ldi	a0,'1'		; if C=0 then a0=‘0’ else a0=‘1’
	rcall	putc	; display the digit
	dec	w			; decrement the bit count
	brne	_putbin
	ret