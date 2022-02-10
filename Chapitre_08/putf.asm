; file	putf.asm   target ATmega128L-4MHz-STK300
; purpose library, display of formatted text and values

; === format identifiers ===
.equ	FHEX	= $80
.equ	FBIN	= $81
.equ	FDEC	= $82
.equ	FCHAR	= $83

putf:
; print formatted string
; in	.db "formatted string" which follows the function call

	POPZ				; pop the "return address" from stack
	MUL2Z				; multiply by 2 (word->byte pointer)
putf_next:	
	lpm					; load character into r0
	adiw	zl,1		; increment z pointer
	tst	r0				; test for end of string (NUL)
	breq	putf_done
	JB1	r0,7,putf_num	; if bit7=1 then print a numeric format
	mov	a0,r0
	rcall	putc		; display the character
	rjmp	putf_next

putf_num:
	mov	w,r0		; put the format (HEX,BIN,DEC) into w
	clr	xh			; clear pointer x high-byte
	lpm				; read the variable to display
	mov	xl,r0		; load pointer x low-byte
	adiw	zl,1	; increment pointer z
	ld	a0,x		; load register to display into a0
	
	cpi	w,FHEX		; print in hex format?
	brne	PC+3
	rcall	puthex
	rjmp	putf_next
	
	cpi	w,FBIN		; print in binary format?
	brne	PC+3
	rcall	putbin
	rjmp	putf_next
	
	cpi	w,FDEC		; print in decimail format?
	brne	PC+2
	rcall	putdec
	rjmp	putf_next

putf_done:
	DIV2Z			; divide by 2 (byte->word pointer)
	adiw	zl,1	; increment z pointer
	ijmp			; indirect jump to location after "string"