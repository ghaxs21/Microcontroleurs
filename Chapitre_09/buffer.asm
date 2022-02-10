; file:	buffer.asm   target ATmega128L-4MHz-STK300
; purpose library, FIFO handling

; === FIFO (First In First Out) ===
; CB (circular buffer)

.equ	_in		= 0
.equ	_out	= 1
.equ	_nbr	= 2
.equ	_beg	= 3

.macro	CB_INIT ;buf
	clr	w
	sts	@0+_in ,w	; in-pointer	= 0
	sts	@0+_out,w	; out-pointer	= 0
	sts	@0+_nbr,w	; nbr of elems	= 0
	.endmacro

.macro	CB_PUSH ;buf,len,elem
; in:	a0	byte to push
; out:	T	1=buffer full

	lds	w, @0+_nbr		; load nbr
	cpi	w, @1			; compare with len
	set
	breq	_end		; if nbr=len then T=1 (buffer full)

	clt					; else T=0
	inc	w				; increment nbr
	sts	@0+_nbr,w		; store nbr

	push	xl			; push x on stack
	push	xh
	lds	w,@0+_in		; load in-pointer
	mov	xl,w
	subi	xl, low(-@0-_beg)
	sbci	xh,high(-@0-_beg) ; add in-pointer to buffer base
	st	x,@2			; store new element in circular buffer
	pop	xh				; pop x from stack
	pop	xl

	inc	w				; incremenent in-pointer
	cpi	w,@1			; if in=len then wrap around
	brne	PC+2
	clr	w
	sts	@0+_in,w		; store incremented in-pointer
_end:	
.endmacro

.macro	CB_POP ;buf,len,elem
; out:	a0	byte to pop
;	T	1=buffer empty

	lds	w,@0+_nbr		; load nbr
	tst	w
	set
	breq	_end		; if nbr=0 then T=1 (buffer empty)

	clt					; else T=0
	dec	w				; decrement nbr
	sts	@0+_nbr,w		; store nbr
	
	push	xl			; push x on stack
	push	xh
	lds	w,@0+_out		; load out-pointer
	mov	xl,w
	subi	xl, low(-@0-_beg)
	sbci	xh,high(-@0-_beg) ; add out-pointer to buffer base
	ld	@2,x			; take element from circular buffer
	pop	xh				; pop x from stack
	pop	xl			
	inc	w				; increment out-pointer
	cpi	w,@1			; if out=len then wrap around
	brne	PC+2
	clr	w
	sts	@0+_out,w		; store incremented out-pointer
_end:	
.endmacro
	
