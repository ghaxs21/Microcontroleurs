; file	menu.asm   target ATmega128L-4MHz-STK300
; purpose library, menu usage

menu:
; in	a0	menu item (0..n)
; 		z	pointer to menu string "item0|item1..item_n"

	push	a0				; safeguard a0
	tst	a0					; if a0=0 then print first item
	breq	menu_print		
menu_find:
	lpm
	mov	w,r0
	adiw	zl,1
	cpi	w,'|'
	brne	PC-4			; inner loop finds the '|'
	dec	a0		
	brne	PC-6			; outer loop counts down to zero

menu_print:
	lpm						; print the item	
	mov	a0,r0
	cpi	a0,'|'
	breq	menu_done		; if char='|' then end of item
	cpi	a0,0
	breq	menu_done		; if char=0 (NUL) then end of string
	adiw	zl,1
	rcall	lcd_putc		; put the character and continue
	rjmp	menu_print
menu_done:
	lpm
	adiw	zl,1
	tst	r0
	brne	menu_done		; advance pointer z beyond end of string
	pop	a0					; restore register a0
	ret

; === menu immediate ===
menui:
	POPZ					; the return address points to begin of string
	MUL2Z					; transform word->byte counter
	rcall	menu			; call the menu routine
	adiw	zl,1			; increment pointer once more
	DIV2Z					; transform byte->word counter
	ijmp					; indirect jump to address after string