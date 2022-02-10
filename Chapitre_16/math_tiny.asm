; file:	math_tiny.asm   target ATmega128L-4MHz-STK300	
; purpose library, mathematical routines, optimized for space saving

clra:	CLR4	a3,a2,a1,a0
	ret
clrb:	CLR4	b3,b2,b1,b0
	ret	
clrc:	CLR4	c3,c2,c1,c0
	ret
clrd:	CLR4	d3,d2,d1,d0	
	ret

addab:	ADD4	a3,a2,a1,a0, b3,b2,b1,b0
	ret
addda:	ADD4	d3,d2,d1,d0, a3,a2,a1,a0
	ret	
adddb:	ADD4	d3,d2,d1,d0, b3,b2,b1,b0
	ret
	
subab:	SUB4	a3,a2,a1,a0, b3,b2,b1,b0
	ret
subda:	SUB4	d3,d2,d1,d0, a3,a2,a1,a0
	ret
subdb:	SUB4	d3,d2,d1,d0, b3,b2,b1,b0
	ret	
	
coma:	COM4	a3,a2,a1,a0
	ret

nega:	rcall	coma
inca:	INC4	a3,a2,a1,a0
	ret
deca:	DEC4	a3,a2,a1,a0
	ret	

movab:	MOV4	a3,a2,a1,a0, b3,b2,b1,b0
	ret
movba:	MOV4	b3,b2,b1,b0, a3,a2,a1,a0
	ret
movcb:	MOV4	c3,c2,c1,c0, b3,b2,b1,b0
	ret
movca:	MOV4	c3,c2,c1,c0, a3,a2,a1,a0
	ret	

swapab:	SWAP4	b3,b2,b1,b0, a3,a2,a1,a0
	ret

mula8:	rcall	mula2
mula4:	rcall	mula2	
mula2:	LSL4	a3,a2,a1,a0
	ret	
mula10:	rcall	mula2
mula5:	rcall	movba			; store a in b
	rcall	mula4				; a=4*a
	rcall	addab				; add b  a=(4*a)+a
	ret

mulab:	rcall	clrd			; clear upper half of result c
	rcall	movcb				; place b in lower half of c
	LSR4	c3,c2,c1,c0			; shift LSB (of b) into carry
	ldi	w,32					; load bit counter
_m44:	brcc	PC+2			; skip addition if carry=0
	rcall	addda				; add a to upper half of c
	ROR8	d3,d2,d1,d0,c3,c2,c1,c0	; shift-right c, LSB (of b) into carry
	DJNZ	w,_m44				; Decrement and Jump if bit-count Not Zero
	ret

mulabs: rcall	mulab
	sbrc	a3,7
	rcall	subdb
	sbrc	b3,7
	rcall	subda
	ret

divab:	rcall	movca			; c will contain the result
	rcall	clrd				; d will contain the remainder
	ldi	w,32					; load bit counter
_d44:	ROL8	d3,d2,d1,d0,c3,c2,c1,c0	; shift carry into result c
	rcall	subdb				; subtract b from remainder
	brcc	PC+2	
	rcall	adddb				; restore if remainder became negative
	DJNZ	w,_d44				; Decrement and Jump if bit-count Not Zero
	ROL4	c3,c2,c1,c0			; last shift (carry into result c)
	COM4	c3,c2,c1,c0			; complement result
	ret