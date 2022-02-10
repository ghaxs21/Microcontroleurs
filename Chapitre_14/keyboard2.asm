; file	keyboard2.asm   target ATmega128L-4MHz-STK300	
; purpose interfacing the PC AT keyboard, ASCII LUT decoding

.include "macros.asm"
.include "definitions.asm"

reset:
	LDSP	RAMEND		; set up stack pointer (SP)
	rcall	LCD_init	; initialize the LCD
	rjmp	main		; jump ahead to the main program

.include "lcd.asm"		; include the LCD routines
.include "printf.asm"	; include formatted printing routines

.macro	DETECT_10		; port,pin,timeout-addr	; Wait for 1-0 transition	
	clr	r16				; reset timout counter
p0:	dec	r16				; decrement timeout counter
	breq	@2			; jump to timeout-addr if 0
	sbis	@0,@1		; loop back if 0, skip if 1
	rjmp	p0

	clr	r16				; reset timout counter
p1:	dec	r16				; decrement timeout counter
	breq	@2			; jump to timeout-addr if 0
	sbic	@0,@1		; loop back if 1, skip if 0
	rjmp	p1
	.endmacro

decode:					; decode code, result in r21
	LOOKUP	r21,r20,unshifted
	ret

unshifted:
	;0123456789abcdef
.db	"              ¦ "	;0
.db	"     q1   zsaw2 "	;1
.db	" cxde43   vftr5 "	;2
.db	" nbhgy6  ,mju78 "	;3
.db	" ,kio09  .-l p+ "	;4
.db	"     \     ¨'   "	;5
.db	" <       1 47   "	;6
.db	"0,2568   +3-*9  "	;7
shifted:
	;0123456789abcdef
.db	"              § "	;0
.db	"     Q!   ZSAW  "	;1
.db	" CXDE #   VFTR% "	;2
.db	" NBHGY&  LMJU/( "	;3
.db	"  KIO=)  :_L P? "	;4
.db	"     `     ^ *  "	;5
.db	" >       1 47   "	;6
.db	"0,2568   +3-*9  "	;7
	;0123456789abcdef

main:	
	DETECT_10 PIND,KB_CLK,main		; detect start-bit
	ldi	r17,8
loop:	DETECT_10 PIND,KB_CLK,main	; detect data-bit
	P2C	PIND,KB_DAT		; pin to carry
	ror	r20				; roll carry to MSB
	dec	r17
	brne	loop	
	DETECT_10 PIND,KB_CLK,main		; detect parity-bit
	DETECT_10 PIND,KB_CLK,main		; detect stop-bit

	clr	r22				; null terminator for string
	rcall	decode
	rcall	LCD_home
	PRINTF	LCD			; print formatted
.db	"code=",FHEX,20," =",FSTR,21,0
	rjmp	main		; jump back to main
