; file	ctype.asm   target ATmega128L-4MHz-STK300
; purpose library, character set belonging check

; Routines for testing if characters belong
; to a certain type (numeric, upper, lower...).
; The result is returned within the carry:
; in range: carry=0; out of range: carry=1.

.macro	INRANGE		; x,low,high
	ldi	w,@1
	cp	@0,w		; x-low
	brcc	PC+2	
	ret
	ldi	w,@2		; x-high
	cp	w,@0		; high-x
	ret
	.endmacro
	
.macro	JNO			; jump if no (c=1)
	brcs	@0
	.endmacro
.macro	JYES		; jump if yes (c=0)
	brcc	@0
	.endmacro
.macro	CNO			; call if no (c=1)
	brcc	PC+2
	rcall	@0
	.endmacro
.macro	CYES		; call if yes (c=0)
	brcs	PC+2
	rcall	@0
	.endmacro
.macro	RNO			; return if no (c=1)
	brcc	PC+2
	ret
	.endmacro
.macro	RYES		; return if yes (c=0)
	brcs	PC+2
	ret
	.endmacro

isdigit: INRANGE a0,'0','9'		; decimal digits
islower: INRANGE a0,'a','z'		; lower-case letters
isupper: INRANGE a0,'A','Z'		; upper-case letters
isaf_lo: INRANGE a0,'a','f'		; lower-case hexadecimal a..f
isaf_up: INRANGE a0,'A','F'		; upper-case hexadecimal A..F
iscntrl: INRANGE a0,0,0x1f		; control characters
isprint: INRANGE a0,0x20,0x7e	; printable characters
isgraph: INRANGE a0,0x21,0x7e	; printable characters except space

isalnum:
	rcall	isdigit	; is char numeric?
	RYES			; return if yes
isalpha:
	rcall	islower	; is char lower-case?
	RYES			; return if yes
	rjmp	isupper	; is char upper-case?

isxdigit:
	rcall	isaf_lo	; is char in a..f?
	RYES			; return if yes
	rcall	isaf_up	; is char in A..F?
	RYES			; retun if yes
	rjmp	isdigit	; is char numeric?

ispunct:
	rcall	isgraph	; is it a graphic (printing) character
	RNO
	rcall	isalnum	; is it an alphanumeric character
	INVC			; invert the answer (C)
	ret
	
isspace:
	LDIZ	2*iss_tb
iss_comp:
	lpm
	cp	r0,a0
	breq	iss_found
	tst	r0
	breq	iss_notfound
	adiw	zl,1
	rjmp	iss_comp	
iss_found:
	clc
	ret
iss_notfound:	
	sec
	ret
iss_tb:.db	SPACE,FF,LF,CR,VT,HT,0
	
isascii:
	B2C	a0,7		; if ASCII then bit7=0
	ret

tolower:
	rcall	isupper	; is char upper-case?
	RNO				; return if no
	ldi	w,'a'-'A'
	add	a0,w		; change to lower-case
	ret
toupper:
	rcall	islower	; is char lower-case?
	RNO				; return if no
	ldi	w,'A'-'a'
	add	a0,w		; change to lower-case
	ret