; file	math.asm   target ATmega128L-4MHz-STK300	
; purpose library, mathematical routines

; === unsigned multiplication (c=a*b) ===

mul11:	clr	c1					; clear upper half of result c
	mov	c0,b0					; place b in lower half of c
	lsr	c0						; shift LSB (of b) into carry
	ldi	w,8						; load bit counter
_m11:	brcc	PC+2			; skip addition if carry=0
	add	c1,a0					; add a to upper half of c
	ROR2	c1,c0				; shift-right c, LSB (of b) into carry
	DJNZ	w,_m11				; Decrement and Jump if bit-count Not Zero
	ret

mul21:	CLR2	c2,c1			; clear upper half of result c
	mov	c0,b0					; place b in lower half of c
	lsr	c0						; shift LSB (of b) into carry
	ldi	w,8						; load bit counter
_m21:	brcc	PC+3			; skip addition if carry=0
	ADD2	c2,c1, a1,a0		; add a to upper half of c
	ROR3	c2,c1,c0			; shift-right c, LSB (of b) into carry
	DJNZ	w,_m21				; Decrement and Jump if bit-count Not Zero
	ret

mul22:	CLR2	c3,c2			; clear upper half of result c
	MOV2	c1,c0, b1,b0		; place b in lower half of c
	LSR2	c1,c0				; shift LSB (of b) into carry
	ldi	w,16					; load bit counter
_m22:	brcc	PC+3			; skip addition if carry=0
	ADD2	c3,c2, a1,a0		; add a to upper half of c
	ROR4	c3,c2,c1,c0			; shift-right c, LSB (of b) into carry
	DJNZ	w,_m22				; Decrement and Jump if bit-count Not Zero
	ret

mul31:	CLR3	c3,c2,c1		; clear upper half of result c
	mov	c0,b0					; place b in lower half of c
	lsr	c0						; shift LSB (of b) into carry
	ldi	w,8						; load bit counter
_m31:	brcc	PC+4			; skip addition if carry=0
	ADD3	c3,c2,c1, a2,a1,a0	; add a to upper half of c
	ROR4	c3,c2,c1,c0			; shift-right c, LSB (of b) into carry
	DJNZ	w,_m31				; Decrement and Jump if bit-count Not Zero
	ret

mul32:	CLR3	d0,c3,c2		; clear upper half of result c
	MOV2	c1,c0, b1,b0		; place b in lower half of c
	LSR2	c1,c0				; shift LSB (of b) into carry
	ldi	w,16					; load bit counter
_m32:	brcc	PC+4			; skip addition if carry=0
	ADD3	d0,c3,c2, a2,a1,a0	; add a to upper half of c
	ROR5	d0,c3,c2,c1,c0		; shift-right c, LSB (of b) into carry
	DJNZ	w,_m32				; Decrement and Jump if bit-count Not Zero
	ret
	
mul33:	CLR3	d1,d0,c3		; clear upper half of result c
	MOV3	c2,c1,c0, b2,b1,b0	; place b in lower half of c
	LSR3	c2,c1,c0			; shift LSB (of b) into carry
	ldi	w,24					; load bit counter
_m33:	brcc	PC+4			; skip addition if carry=0
	ADD3	d1,d0,c3, a2,a1,a0	; add a to upper half of c
	ROR6	d1,d0,c3,c2,c1,c0	; shift-right c, LSB (of b) into carry
	DJNZ	w,_m33				; Decrement and Jump if bit-count Not Zero
	ret

mul41:	CLR4	d0,c3,c2,c1		; clear upper half of result c
	mov	c0,b0					; place b in lower half of c
	lsr	c0						; shift LSB (of b) into carry
	ldi	w,8						; load bit counter
_m41:	brcc	PC+5			; skip addition if carry=0
	ADD4	d0,c3,c2,c1, a3,a2,a1,a0; add a to upper half of c
	ROR5	d0,c3,c2,c1,c0		; shift-right c, LSB (of b) into carry
	DJNZ	w,_m41				; Decrement and Jump if bit-count Not Zero
	ret

mul42:	CLR4	d1,d0,c3,c2		; clear upper half of result c
	MOV2	c1,c0, b1,b0		; place b in lower half of c
	LSR2	c1,c0				; shift LSB (of b) into carry
	ldi	w,16					; load bit counter
_m42:	brcc	PC+5			; skip addition if carry=0
	ADD4	d1,d0,c3,c2, a3,a2,a1,a0; add a to upper half of c
	ROR6	d1,d0,c3,c2,c1,c0	; shift-right c, LSB (of b) into carry
	DJNZ	w,_m42				; Decrement and Jump if bit-count Not Zero
	ret

mul43:	CLR4	d2,d1,d0,c3		; clear upper half of result c
	MOV3	c2,c1,c0, b2,b1,b0	; place b in lower half of c
	LSR3	c2,c1,c0			; shift LSB (of b) into carry
	ldi	w,24					; load bit counter
_m43:	brcc	PC+5			; skip addition if carry=0
	ADD4	d2,d1,d0,c3, a3,a2,a1,a0; add a to upper half of c
	ROR7	d2,d1,d0,c3,c2,c1,c0	; shift-right c, LSB (of b) into carry
	DJNZ	w,_m43				; Decrement and Jump if bit-count Not Zero
	ret

mul44:	CLR4	d3,d2,d1,d0		; clear upper half of result c
	MOV4	c3,c2,c1,c0, b3,b2,b1,b0; place b in lower half of c
	LSR4	c3,c2,c1,c0			; shift LSB (of b) into carry
	ldi	w,32					; load bit counter
_m44:	brcc	PC+5			; skip addition if carry=0
	ADD4	d3,d2,d1,d0, a3,a2,a1,a0; add a to upper half of c
	ROR8	d3,d2,d1,d0,c3,c2,c1,c0	; shift-right c, LSB (of b) into carry
	DJNZ	w,_m44				; Decrement and Jump if bit-count Not Zero
	ret

; === signed multiplication ===		
mul11s: rcall	mul11
	sbrc	a0,7
	sub	c1,b0
	sbrc	b0,7
	sub	c1,a0
	ret

mul22s: rcall	mul22
	sbrs	a1,7
	rjmp	PC+3
	SUB2	c3,c2, b1,b0
	sbrs	b1,7
	rjmp	PC+3	
	SUB2	c3,c2, a1,a0
	ret

mul33s: rcall	mul33
	sbrs	a2,7
	rjmp	PC+4
	SUB3	d1,d0,c3, b2,b1,b0
	sbrs	b2,7
	rjmp	PC+4
	SUB3	d1,d0,c3, a2,a1,a0
	ret

mul44s: rcall	mul44
	sbrs	a3,7
	rjmp	PC+5
	SUB4	d3,d2,d1,d0, b3,b2,b1,b0
	sbrs	b3,7
	rjmp	PC+5
	SUB4	d3,d2,d1,d0, a3,a2,a1,a0
	ret

; === unsigned division c=a/b ===
div11:	mov	c0,a0				; c will contain the result
	clr	d0						; d will contain the remainder
	ldi	w,8						; load bit counter
_d11:	ROL2	d0,c0			; shift carry into result c
	sub	d0,b0					; subtract b from remainder
	brcc	PC+2	
	add	d0,b0					; restore if remainder became negative
	DJNZ	w,_d11				; Decrement and Jump if bit-count Not Zero
	rol	c0						; last shift (C into result c)
	com	c0						; complement result
	ret

div21:	MOV2	c1,c0, a1,a0	; c will contain the result
	clr	d0						; d will contain the remainder
	ldi	w,16					; load bit counter
_d21:	ROL3	d0,c1,c0		; shift carry into result c
	sub	d0,b0					; subtract b from remainder
	brcc	PC+2			
	add	d0,b0					; restore if remainder became negative
	DJNZ	w,_d21				; Decrement and Jump if bit-count Not Zero
	ROL2	c1,c0				; last shift (carry into result c)
	COM2	c1,c0				; complement result
	ret

div22:	MOV2	c1,c0, a1,a0	; c will contain the result
	CLR2	d1,d0				; d will contain the remainder
	ldi	w,16					; load bit counter
_d22:	ROL4	d1,d0,c1,c0		; shift carry into result c
	SUB2	d1,d0, b1,b0		; subtract b from remainder
	brcc	PC+3	
	ADD2	d1,d0, b1,b0		; restore if remainder became negative
	DJNZ	w,_d22				; Decrement and Jump if bit-count Not Zero
	ROL2	c1,c0				; last shift (carry into result c)
	COM2	c1,c0				; complement result
	ret

div31:	MOV3	c2,c1,c0, a2,a1,a0	; c will contain the result
	clr	d0						; d will contain the remainder
	ldi	w,24					; load bit counter
_d31:	ROL4	d0,c2,c1,c0		; shift carry into result c
	sub	d0, b0					; subtract b from remainder
	brcc	PC+2	
	add	d0, b0					; restore if remainder became negative
	DJNZ	w,_d31				; Decrement and Jump if bit-count Not Zero
	ROL3	c2,c1,c0			; last shift (carry into result c)
	COM3	c2,c1,c0			; complement result
	ret

div32:	MOV3	c2,c1,c0, a2,a1,a0	; c will contain the result
	CLR2	d1,d0				; d will contain the remainder
	ldi	w,24					; load bit counter
_d32:	ROL5	d1,d0,c2,c1,c0	; shift carry into result c
	SUB2	d1,d0, b1,b0		; subtract b from remainder
	brcc	PC+3	
	ADD2	d1,d0, b1,b0		; restore if remainder became negative
	DJNZ	w,_d32				; Decrement and Jump if bit-count Not Zero
	ROL3	c2,c1,c0			; last shift (carry into result c)
	COM3	c2,c1,c0			; complement result
	ret
	
div33:	MOV3	c2,c1,c0, a2,a1,a0	; c will contain the result
	CLR3	d2,d1,d0			; d will contain the remainder
	ldi	w,24					; load bit counter
_d33:	ROL6	d2,d1,d0,c2,c1,c0	; shift carry into result c
	SUB3	d2,d1,d0, b2,b1,b0	; subtract b from remainder
	brcc	PC+4	
	ADD3	d2,d1,d0, b2,b1,b0	; restore if remainder became negative
	DJNZ	w,_d33				; Decrement and Jump if bit-count Not Zero
	ROL3	c2,c1,c0			; last shift (carry into result c)
	COM3	c2,c1,c0			; complement result
	ret

div41:	MOV4	c3,c2,c1,c0, a3,a2,a1,a0; c will contain the result
	clr	d0						; d will contain the remainder
	ldi	w,32					; load bit counter
_d41:	ROL5	d0,c3,c2,c1,c0		; shift carry into result c
	sub	d0, b0					; subtract b from remainder
	brcc	PC+2		
	add	d0, b0					; restore if remainder became negative
	DJNZ	w,_d41				; Decrement and Jump if bit-count Not Zero
	ROL4	c3,c2,c1,c0			; last shift (carry into result c)
	COM4	c3,c2,c1,c0			; complement result
	ret

div42:	MOV4	c3,c2,c1,c0, a3,a2,a1,a0; c will contain the result
	CLR2	d1,d0				; d will contain the remainder
	ldi	w,32					; load bit counter
_d42:	ROL6	d1,d0,c3,c2,c1,c0	; shift carry into result c
	SUB2	d1,d0, b1,b0		; subtract b from remainder
	brcc	PC+3	
	ADD2	d1,d0, b1,b0		; restore if remainder became negative
	DJNZ	w,_d42				; Decrement and Jump if bit-count Not Zero
	ROL4	c3,c2,c1,c0			; last shift (carry into result c)
	COM4	c3,c2,c1,c0			; complement result
	ret

div43:	MOV4	c3,c2,c1,c0, a3,a2,a1,a0; c will contain the result
	CLR3	d2,d1,d0			; d will contain the remainder
	ldi	w,32					; load bit counter
_d43:	ROL7	d2,d1,d0,c3,c2,c1,c0	; shift carry into result c
	SUB3	d2,d1,d0, b2,b1,b0	; subtract b from remainder
	brcc	PC+4	
	ADD3	d2,d1,d0, b2,b1,b0	; restore if remainder became negative
	DJNZ	w,_d43				; Decrement and Jump if bit-count Not Zero
	ROL4	c3,c2,c1,c0			; last shift (carry into result c)
	COM4	c3,c2,c1,c0			; complement result
	ret

div44:	MOV4	c3,c2,c1,c0, a3,a2,a1,a0; c will contain the result
	CLR4	d3,d2,d1,d0			; d will contain the remainder
	ldi	w,32					; load bit counter
_d44:	ROL8	d3,d2,d1,d0,c3,c2,c1,c0	; shift carry into result c
	SUB4	d3,d2,d1,d0, b3,b2,b1,b0; subtract b from remainder
	brcc	PC+5	
	ADD4	d3,d2,d1,d0, b3,b2,b1,b0; restore if remainder became negative
	DJNZ	w,_d44				; Decrement and Jump if bit-count Not Zero
	ROL4	c3,c2,c1,c0			; last shift (carry into result c)
	COM4	c3,c2,c1,c0			; complement result
	ret

; === signed division ===
div33s:	push	u
	mov	u,a2
	eor	u,b2
	sbrs	a2,7
	rjmp	d33a
	NEG3	a2,a1,a0
d33a:	sbrs	b2,7
	rjmp	d33b
	NEG3	b2,b1,b0
d33b:	rcall	div33
	sbrs	u,7
	rjmp	d33c
	NEG3	c2,c1,c0
d33c:	pop	u
	ret