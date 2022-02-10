; file	keyboard.asm   target ATmega128L-4MHz-STK300		
; prupose library, PC AT keyboard interface

.equ	KBD	= PIND

; === kbd_getc ==
; out:	a0

.macro	CLK10 			; timeout-addr	; wait for 1-0 transition on CLK	
	clr	w				; reset timout counter
p0:	dec	w				; decrement timeout counter
	breq	@0			; jump to timeout-addr if 0
	sbis	KBD,KB_CLK	; loop back if 0, skip if 1
	rjmp	p0

	clr	w				; reset timout counter
p1:	dec	w				; decrement timeout counter
	breq	@0			; jump to timeout-addr if 0
	sbic	KBD,KB_CLK	; loop back if 1, skip if 0
	rjmp	p1
	.endmacro

kbd_getc:	
	CLK10	kbd_getc	; detect start-bit
	ldi	a1,8

kbd_loop:	
	CLK10	kbd_getc	; detect data-bit
	P2C	PIND,KB_DAT		; pin to carry
	ror	a0				; roll carry to MSB
	DJNZ	a1,kbd_loop	; Decrement and Jump if Not Zero
	CLK10	kbd_getc	; detect parity-bit
	CLK10	kbd_getc	; detect stop-bit
	ret