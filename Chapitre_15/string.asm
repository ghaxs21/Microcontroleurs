; file	string.asm   target ATmega128L-4MHz-STK300
; purpose library, strings manupulations

strstrcpy:				; (x) <- (y) string copy
	ld	w,y+
	st	x+,w
	tst	w
	brne	strstrcpy
	ret
	
strstrldi:				; (x) <- (z) string load immediate
	lpm
	adiw	zl,1		; increment z
	st	x+,r0
	tst	r0
	brne	strstrldi
	ret

strstrncpy:				; (x) <-  n(y) string copy n chars
	ld	w,y+
	st	x+,w
	dec	a0
	brne	strstrncpy
	st	x+,a0			; terminate with zero
	ret

strstrend:				; advance x to end of string
	ld	w,x+
	tst	w
	brne	strstrend
	sbiw	xl,1		; pointing to NUL
	ret
	
strstrcat:				; (x)+(y) string concatenate
	rcall	strstrend	; advance x to end(x)
	rjmp	strstrcpy	; copy (y) to end(x)

strstrncat:				; (x)+n(y) string concatenate n	
	rcall	strstrend	; advance x to end(x)
	rjmp	strstrncpy	; copy n(y) to end(x)
	
strstrcmp:				; (x) > (y) string compare
	ld	w,x+
	ld	u,y+
	cp	w,u
	breq	PC+2
	ret					; strings are not equal (w!=w1)
	tst	w				; w==w1
	brne	strstrcmp
	ret					; strings are equal
	
strstrncmp:				;  (x) > (y)n string compare n
	ld	w,x+
	ld	u,y+
	dec	a0
	brne	PC+2
	ret					; n characters compared
	cp	w,u
	breq	PC+2
	ret					; strings are not equal
	tst	w
	brne	strstrncmp
	ret					; strings are equal
	
strstrchr:
	ld	w,x+
	cp	w,a0
	brne	PC+3
	ld	w,-x			; decrement x to point to char
	ret					; found char in (x), Z=1
	tst	w
	brne	strstrchr
	clz					; clear Z flag (Z=0)
	ret			

strstrrchr:
	ld	w,x+
	cp	w,a0
	brne	strstrrchr_found
	tst	w
	brne	strstrrchr
	clz					; not found (Z=0)
	ret
strstrrchr_found:
	ld	w,x+			; find the end of string (x)
	tst	w
	brne	PC-2
	ld	w,-x			; find the position of (x)=char
	cp	w,a0
	brne	PC-2
	ret
	
strstrlen:				; returns the string length (x) in reg a
	ldi	a0,-1	
	ld	w,x+
	inc	a0
	tst	w
	brne	strstrlen+1
	ret

strstrinv:				; inverses string pointed by x
	PUSHY
	MOV2	yh,yl, xh,xl	; saveguard x in y
	clr	w
	ld	u,x+
	tst	u
	breq	_inv	
	push	u			; push the characters on the stack
	inc	w
	rjmp	PC-5	
_inv:	
	MOV2	xh,xl, yh,yl 	; point x to begin of string
	pop	u				; pop back the characters from the end
	st	x+,u
	dec	w
	brne	PC-3
	st	x+,w			; terminate with zero
	POPY
	ret
