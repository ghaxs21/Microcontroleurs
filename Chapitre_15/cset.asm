; file	cset.asm   target ATmega128L-4MHz-STK300
; purpose library, character set operations

csEmpty:
; in	x (ptr on charset)	
	ldi	w,16			; a character set has 16 bytes (128 bits)
	clr	r0
	st	x+,r0			; store 0 to each byte
	dec	w
	brne	PC-2
	sbiw	xl,16		; restore x to initial value
	ret

csCopy:
; in	x (ptr on source)
; out	y (ptr on destination)
	ldi	w,16			; a character set has 16 bytes
	ld	r0,x+			; copy a byte from x to y
	st	y+,r0
	dec	w
	brne	PC-3
	sbiw	xl,16		; restore x to initial value
	sbiw	yl,16		; restore y to initial value	
	ret
	
csUnion:
; in	x,y (ptr on charset)
; out	z (ptr on charset), z = (x u y)
	ldi	w,16			; a character set has 16 bytes
	ld	r0,x+			; load both bytes in registers
	ld	r1,y+
	or	r0,r1			; set union corresponds to logical or
	st	z+,r0
	dec	w
	brne	PC-5
	sbiw	xl,16		; restore x to initial value
	sbiw	yl,16		; restore y to initial value
	sbiw	zl,16		; restore z to initial value	
	ret

csIntersect:
; in	x,y (ptr on charset)
; out	z (ptr on charset), z = (x n y)
	ldi	w,16			; a character set has 16 bytes
	ld	r0,x+			; load both bytes in registers
	ld	r1,y+
	and	r0,r1			; set intersection corresponds to logical and
	st	z+,r0
	dec	w
	brne	PC-5
	sbiw	xl,16		; restore x to initial value
	sbiw	yl,16		; restore y to initial value
	sbiw	zl,16		; restore z to initial value		
	ret

csDifference:
; in	x,y (ptr on charset)
; out	z (ptr on charset), z = (x - y)
	ldi	w,16			; a character set has 16 bytes
	ld	r0,x+			; load both bytes in registers
	ld	r1,y+
	com	r1		
	and	r0,r1			; difference = (X) AND (NOT Y)
	st	z+,r0
	dec	w
	brne	PC-6
	sbiw	xl,16		; restore x to initial value
	sbiw	yl,16		; restore y to initial value
	sbiw	zl,16		; restore z to initial value		
	ret

csComplement:
; in	x (ptr on charset)
; out	y (ptr on charset)	
	ldi	w,16			; a character set has 16 bytes
	ld	r0,x+			; read a byte from the char set
	com	r0				; complement the byte
	st	y+,r0			; store the byte back to the char set
	dec	w
	brne	PC-4
	sbiw	xl,16		; restore x to initial value
	sbiw	yl,16		; restore y to initial value
	ret

csIsMember:
; in	x (ptr on charset), a0 (char to test)
	PUSH3	a0,xl,xh
	mov	w,a0		
	DIV8	w			; divide by 8 to get byte address
	ADDX	w			; add the displacement to x
	SETBIT	a0			; set bit corresponding to (b2..b0)
	ld	w,x
	and	w,a0			; member (Z=0), not member (Z=1)
	Z2C					; transfer Z to C
	POP3	a0,xl,xh
	ret

csIsEmpty:
; in	x (ptr on charset)
	PUSHX	
	ldi	w,16			; a character set has 16 bytes (128 bits)
	ld	r0,x+	
	tst	r0
	brne	PC+3		; Z=0 not empty
	dec	w
	brne	PC-4		; if finishing the loop (Z=1)
	Z2INVC				; transfer Zero to inverse Carry
	POPX				; restore x to initial value
	ret

csIsEqual:
; in	x,y (ptr on charset)
	PUSH4	xl,xh,yl,yh	
	ldi	w,16			; a character set has 16 bytes (128 bits)
	ld	r0,x+
	ld	r1,y+
	cp	r0,r1
	brne	PC+3		; Z=0 not empty
	dec	w
	brne	PC-5		; if finishing the loop (Z=1)
	Z2INVC				; transfer Zero to inverse Carry
	POP4	xl,xh,yl,yh	; restore x to initial value
	ret

csAddChar:
; in	x (ptr on charset), a0 (char to add)
	PUSH3	a0,xl,xh
	mov	w,a0		
	DIV8	w			; divide by 8 to get byte address
	ADDX	w			; add the displacement to x
	SETBIT	a0			; set bit corresponding to (b2..b0)
	ld	w,x
	or	w,a0			; set the bit to 1
	st	x,w
	POP3	a0,xl,xh
	ret

csRmvChar:
; in	x (ptr on charset), a0 (char to remove)
	PUSH3	a0,xl,xh
	mov	w,a0
	DIV8	w			; divide by 8 to get byte address
	ADDX	w			; add the displacement to x
	SETBIT	a0			; set bit corresponding to (b2..b0)
	com	a0				; invert the bitmask
	ld	w,x
	and	w,a0			; set the bit to 0
	st	x,w
	POP3	a0,xl,xh
	ret

csAddStr:
; in	x (ptr on charset), y (ptr on string to add)
	PUSH3	a0,yl,yh
	ld	a0,y+			; load a character from string
	tst	a0				; if char=0 it's the end of the string
	breq	PC+3
	rcall	csAddChar	; add the character to the set
	rjmp	PC-4
	POP3	a0,yl,yh
	ret
	
csRmvStr:
; in	x (ptr on charset), y (ptr on string to add)
	PUSH3	a0,yl,yh
	ld	a0,y+			; load a character from string
	tst	a0				; if char=0 it's the end of the string
	breq	PC+3
	rcall	csRmvChar	; remove the character from the set
	rjmp	PC-4
	POP3	a0,yl,yh
	ret

csAddRange:
; in	x (ptr on charset), a0,b0 (char range a0..b0 to add)
	PUSH2	xl,xh
	mov	r0,a0			; r0 is char pointer
	_andi	r0,0b11111000	; point to byte boundary
	mov	w,a0
	DIV8	w			; divide by 8 to get byte address
	ADDX	w			; add the displacement to x
csAR1:
	ldi	w,8				; now we reuse w as loop counter
csAR2:
	cp	r0,a0			; r0-a0		C=0 for r0>=a0
	brcs	PC+2		; if C=1 then second test not necessary
	cp	b0,r0			; b0-r0		C=0 for r0<=b0
	INVC				; invert the carry
	ror	r1				; shift carry into byte
	inc	r0				; point to next character			
	dec	w
	brne	csAR2
	ld	w,x				; now we reuse w as temporary reg
	or	w,r1
	st	x+,w
	cp	r0,b0			; are above the second range limit?
	brlo	csAR1
	POP2	xl,xh
	ret

csRmvRange:
; in	x (ptr on charset), a0,b0 (char range a0..b0 to add)
	PUSH2	xl,xh
	mov	r0,a0			; r0 is char pointer
	_andi	r0,0b11111000	; point to byte boundary
	mov	w,a0
	DIV8	w			; divide by 8 to get byte address
	ADDX	w			; add the displacement to x
csRR1:
	ldi	w,8				; now we reuse w as loop counter
csRR2:
	cp	r0,a0			; r0-a0		C=0 for r0>=a0
	brcs	PC+2		; if C=1 then second test not necessary
	cp	b0,r0			; b0-r0		C=0 for r0<=b0
	ror	r1				; shift carry into byte
	inc	r0				; point to next character			
	dec	w
	brne	csRR2
	ld	w,x				; now we reuse w as temporary reg
	and	w,r1		
	st	x+,w
	cp	r0,b0			; are above the second range limit?
	brlo	csRR1
	POP2	xl,xh
	ret