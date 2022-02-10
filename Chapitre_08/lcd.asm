; file	lcd.asm   target ATmega128L-4MHz-STK300
; purpose  LCD HD44780U library
; ATmega 128 and Atmel Studio 7.0 compliant

; === definitions ===
.equ	LCD_IR	= 0x8000	; address LCD instruction reg
.equ	LCD_DR	= 0xc000	; address LCD data register

; === subroutines ===
LCD_wr_ir:
; in	w (byte to write to LCD IR)
	lds	u, LCD_IR		; read IR to check busy flag  (bit7)
	JB1	u,7,LCD_wr_ir	; Jump if Bit=1 (still busy)
	rcall	lcd_4us		; delay to increment DRAM addr counter
	sts	LCD_IR, w		; store w in IR
	ret
	
lcd_4us:
	rcall	lcd_2us		; recursive call		
lcd_2us:
	nop					; rcall(3) + nop(1) + ret(4) = 8 cycles (2us)
	ret

LCD:
LCD_putc:
	JK	a0,CR,LCD_cr	; Jump if a0=CR
	JK	a0,LF,LCD_lf	; Jump if a0=LF
LCD_wr_dr:
; in	a0 (byte to write to LCD DR)
	lds	w, LCD_IR		; read IR to check busy flag  (bit7)
	JB1	w,7,LCD_wr_dr	; Jump if Bit=1 (still busy)
	rcall	lcd_4us		; delay to increment DRAM addr counter
	sts	LCD_DR, a0		; store a0 in DR
	ret	
	
LCD_clear:		JW	LCD_wr_ir, 0b00000001		; clear display
LCD_home:		JW	LCD_wr_ir, 0b00000010		; return home
LCD_cursor_left:	JW	LCD_wr_ir, 0b00010000	; move cursor to left
LCD_cursor_right:	JW	LCD_wr_ir, 0b00010100	; move cursor to right
LCD_display_left:	JW	LCD_wr_ir, 0b00011000	; shifts display to left
LCD_display_right:	JW	LCD_wr_ir, 0b00011100	; shifts display to right
LCD_blink_on:		JW	LCD_wr_ir, 0b00001101	; Display=1,Cursor=0,Blink=1
LCD_blink_off:		JW	LCD_wr_ir, 0b00001100	; Display=1,Cursor=0,Blink=0
LCD_cursor_on:		JW	LCD_wr_ir, 0b00001110	; Display=1,Cursor=1,Blink=0
LCD_cursor_off:		JW	LCD_wr_ir, 0b00001100	; Display=1,Cursor=0,Blink=0
		
LCD_init:
	in	w,MCUCR					; enable access to ext. SRAM
	sbr	w,(1<<SRE)+(1<<SRW10)
	out	MCUCR,w
	CW	LCD_wr_ir, 0b00000001	; clear display
	CW	LCD_wr_ir, 0b00000110	; entry mode set (Inc=1, Shift=0)
	CW	LCD_wr_ir, 0b00001100	; Display=1,Cursor=0,Blink=0	
	CW	LCD_wr_ir, 0b00111000	; 8bits=1, 2lines=1, 5x8dots=0
	ret

LCD_pos:
; in	a0 = position (0x00..0x0f first line, 0x40..0x4f second line)
	mov	w,a0
	ori	w,0b10000000
	rjmp	LCD_wr_ir

LCD_cr:
; moving the cursor to the beginning of the line (carriage return)
	lds	w, LCD_IR			; read IR to check busy flag  (bit7)
	JB1	w,7,LCD_cr			; Jump if Bit=1 (still busy)
	andi	w,0b01000000	; keep bit6 (begin of line 1/2)
	ori	w,0b10000000		; write address command
	rcall	lcd_4us			; delay to increment DRAM addr counter
	sts	LCD_IR,w			; store in IR
	ret

LCD_lf:
; moving the cursor to the beginning of the line 2 (line feed)
	push	a0				; safeguard a0
	ldi	a0,$40				; load position $40 (begin of line 2)
	rcall	LCD_pos			; set cursor position
	pop	a0					; restore a0
	ret