; file	puthex.asm   target ATmega128L-4MHz-STK300
; purpose library, hexadecimal ascii display

puthex:
; put hexadecimal value 
; in 	a0	(value to convert)
;	putc 	(address of a routine to "write" the character)

	push	a0			; push a0 to store it temporarly
	swap	a0			; swap high and low nibble
	andi	a0,0x0f		; mask half of byte
	rcall	puthex1		; display high nibble
	pop	a0				; restore a0
	andi	a0,0x0f		; mask half byte
	rcall	puthex1		; display low nibble
	ret

puthex1:
	cpi	a0,10			; test if a0 >= 10
	brsh	_af
	addi	a0,'0'		; add the ASCI code of ‘0’ as offset
	rcall	putc		; display the character
	ret
_af:	addi	a0,('a'-10)	; add the ASCI code of ‘a’ as offset
	rcall	putc		; display the character
	ret