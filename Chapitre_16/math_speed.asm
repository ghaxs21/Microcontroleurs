; file	math_speed.asm   target ATmega128L-4MHz-STK300	
; purpose library, mathematical routines, optimized for speed	

; === multiplication ===

.macro	M11
	sbrc	b0,@0
	add	c1,a0
	ror	c1
	ror	c0
.endmacro
mul11:	CLR2	c1,c0	; clears also the carry
	M11	0
	M11	1
	M11	2
	M11	3
	M11	4
	M11	5
	M11	6
	M11	7
	ret

.macro	M21
	sbrs	b0,@0
	rjmp	PC+3
	add	c1,a0
	adc	c2,a1
	ror	c2				; shift-in carry from MSB addition
	ror	c1
	ror	c0
.endmacro
mul21:	CLR3	c2,c1,c0
	M21	0
	M21	1
	M21	2
	M21	3
	M21	4
	M21	5
	M21	6
	M21	7
	ret
	
.macro	M22
	sbrs	b0,@0
	rjmp	PC+4
	add	c1,a0
	adc	c2,a1
	adc	c3,r0			; propagate the carry (r0=0)
	sbrs	b1,@0
	rjmp	PC+3
	add	c2,a0
	adc	c3,a1
	ror	c3				; shift-in carry from MSB addition
	ror	c2			
	ror	c1
	ror	c0
.endmacro
mul22:	CLR5	c3,c2,c1,c0,r0
	M22	0
	M22	1
	M22	2
	M22	3
	M22	4
	M22	5
	M22	6
	M22	7
	ret

.macro	M31
	sbrs	b0,@0
	rjmp	PC+4
	add	c1,a0
	adc	c2,a1
	adc	c3,a2
	ror	c3
	ror	c2
	ror	c1
	ror	c0
.endmacro
mul31:	CLR4	c3,c2,c1,c0
	M31	0
	M31	1
	M31	2
	M31	3
	M31	4
	M31	5
	M31	6
	M31	7
	ret	

.macro	M32
	sbrs	b0,@0
	rjmp	PC+5
	add	c1,a0
	adc	c2,a1
	adc	c3,a2
	adc	d0,r0
	sbrs	b1,@0
	rjmp	PC+4
	add	c2,a0
	adc	c3,a1
	adc	d0,a2
	ror	d0
	ror	c3
	ror	c2
	ror	c1
	ror	c0
.endmacro
mul32:	CLR6	d0,c3,c2,c1,c0,r0
	M32	0
	M32	1
	M32	2
	M32	3
	M32	4
	M32	5
	M32	6
	M32	7
	ret

.macro	M33
	sbrs	b0,@0
	rjmp	PC+5
	add	c1,a0
	adc	c2,a1
	adc	c3,a2
	adc	d0,r0
	adc	d1,r0
	sbrs	b1,@0
	rjmp	PC+4
	add	c2,a0
	adc	c3,a1
	adc	d0,a2
	adc	d1,r0
	sbrs	b2,@0
	rjmp	PC+4
	add	c3,a0
	adc	c0,a1
	adc	d1,a2
	ror	d1
	ror	d0
	ror	c3
	ror	c2
	ror	c1
	ror	c0
.endmacro
mul33:	CLR7	d1,d0,c3,c2,c1,c0,r0
	M33	0
	M33	1
	M33	2
	M33	3
	M33	4
	M33	5
	M33	6
	M33	7
	ret

.macro	M44
	sbrs	b0,@0
	rjmp	PC+8
	add	c1,a0
	adc	c2,a1
	adc	c3,a2
	adc	d0,a3
	adc	d1,r0
	adc	d2,r0
	adc	d3,r0
	
	sbrs	b1,@0
	rjmp	PC+7
	add	c2,a0
	adc	c3,a1
	adc	d0,a2
	adc	d1,a3
	adc	d2,r0
	adc	d3,r0	
	
	sbrs	b2,@0
	rjmp	PC+6
	add	c3,a0
	adc	d0,a1
	adc	d1,a2
	adc	d2,a3
	adc	d3,r0
	
	sbrs	b3,@0
	rjmp	PC+5
	add	d0,a0
	adc	d1,a1
	adc	d2,a2
	adc	d3,a3
	
	ror	d3
	ror	d2
	ror	d1
	ror	d0
	ror	c3
	ror	c2
	ror	c1
	ror	c0
.endmacro
mul44:	CLR9	d3,d2,d1,d0,c3,c2,c1,c0,r0	
	M44	0
	M44	1
	M44	2
	M44	3
	M44	4
	M44	5
	M44	6
	M44	7
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

; === division ===
.macro	D11
	rol	c0
	rol	d0
	sub	d0,b0			; subtract b from remainder a
	brcc	PC+2
	add	d0,b0			; restore if negative
.endmacro
div11:	mov	c0,a0		; load a into shift register
	sub	d0,d0			; clear c1 and carry=0
	D11		
	D11	
	D11
	D11	
	D11
	D11	
	D11
	D11
	rol	c0
	com	c0				; invert the bits
	ret

.macro	D22
	rol	c0
	rol	c1
	rol	d0
	rol	d1
	sub	d0,b0			; subtract b from a
	sbc	d1,b1
	brcc	PC+3
	add	d0,b0			; restore if negative
	adc	d1,b1
.endmacro
div22:	MOV2	c1,c0, a1,a0 ; load a into shift register
	CLR2	d1,d0
	D22
	D22
	D22
	D22
	D22
	D22
	D22
	D22
	D22
	D22
	D22
	D22
	D22
	D22
	D22
	D22
	ROL2	c1,c0			; last shift
	COM2	c1,c0			; invert the bits
	ret