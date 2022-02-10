; file	encoder3.asm   target ATmega128L-4MHz-STK300
; purpose encoder operation, demo

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === definitions ===
.equ	SCROLL	= 0
.equ	EDIT	= 1

.equ	REC_LEN	= 16
.equ	REC_NBR	= 16

.dseg
record:	.byte	1				; current record 
pos:	.byte	1				; current position
abook:	.byte	REC_LEN * REC_NBR
.cseg

reset:
	LDSP	RAMEND				; set up stack pointer (SP)
	rcall	LCD_init			; initialize the LCD
	rcall	encoder_init		; initialize rotary encoder
	
	LDIZ	2*address_init
	LDIX	abook
	rcall	strstrldi			; string load into SRAM

	clr	w
	sts	record,w				; initialize record=0
	ldi	b0,SCROLL				; initialize to scroll mode
	jmp	main
	
.include "lcd.asm"				; include the LCD routines
.include "printf.asm"			; include formatted printing routines
.include "encoder.asm"			; include rotary encoder routines
.include "string.asm"			; include string routines
.include "menu.asm"				; include menu routines
	
address_init:
.db	"antoine         "
.db	"beatrice        "
.db	"christine       "
.db	"danielle        "
.db	"edouard         "
.db	"frederic        "
.db	"genevieve       "
.db	"hubert          "
.db	"isabelle        "
.db	"jacques         "
.db	"klaus           "
.db	"laurence        "
.db	"monique         "
.db	"natalie         "
.db	"otto            "
.db	"                ",0

main:

change_mode:					; changing modes
	CYCLIC	b0,0,EDIT			; make cyclic adjustments
	push	a0
	CA	lcd_pos,$40				; place cursor to line 2
	mov	a0,b0
	rcall	menui				; write menu item(b0) to line 2
.db	"SCROLL|EDIT  ",0
	pop	a0
	rcall	lcd_home			; place cursor back to line 1
	
	JK	b0,SCROLL,mode_scroll	; jump to scroll mode
	JK	b0,EDIT,  mode_edit		; jump to edit mode

mode_scroll:
	rcall	lcd_cursor_off		; no cursor in scroll mode
	lds	a0,record				; load the current record number
	rcall	encoder				; poll the encoder
	breq	change_mode			; if Z=1 then mode (b0) has changed
	CYCLIC	a0,0,(REC_NBR-1)	; make cyclic adjustment for record
	sts	record,a0				; store back to SRAM

	ldi	xl, low(abook)			; point x to base of buffer (abook)
	ldi	xh,high(abook)
	push	a0

	tst	a0						; if record=0 then x is already fine
	breq	PC+4
	adiw	xl,REC_LEN			; otherwise x = abook + rec*REC_LEN
	dec	a0
	brne	PC-2

	rcall	lcd_home			; place cursor to line 1
	ldi	b0,REC_LEN
	ld	a0,x+
	rcall	lcd_putc			; write all characters of record n
	dec	b0
	brne	PC-3	
	
	sbiw	xl,REC_LEN			; set pointer x back to begin
	pop	a0
	rjmp	mode_scroll	

mode_edit:
	rcall	lcd_cursor_on		; cursor on in edit mode
	ld	a0,x					; load current character from SRAM
	rcall	encoder
	_breq	change_mode
	CYCLIC	a0,'a','z'		
	push	a0

	rcall	lcd_putc			; write character back to LCD
	rcall	lcd_cursor_left		; reposition cursor to the left
	st	x,a0					; store character in SRAM
	
	brtc	PC+3				; if T=1 then cursor to the right
	rcall	lcd_cursor_right
	adiw	xl,1
		
	pop	a0
	rjmp	mode_edit
