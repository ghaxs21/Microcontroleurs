; file	animation0.asm   target ATmega128L-4MHz-STK300
; purpose custom character scrolling

.include "macros.asm"
.include "definitions.asm"

reset:
	LDSP	RAMEND
	rcall	LCD_init
	rjmp	main
.include "lcd.asm"

str0:
.db	0x03,0
arrow0:
.db	0b00000100,0b00001110,0b00011111,0b00000100,0b00000100,0b00000100,0b00000100,0b00000000

main:	
	ldi	r22,8
	
   prog0:
	rcall	LCD_drCGRAMupw		;load animation arrowhead upwards	
	ldi	r16,str0				;load text, including animated character
	ldi	zl, low(2*str0)			;load pointer to string
	ldi	zh,high(2*str0)
	rcall	LCD_putstring		;display string
 	WAIT_MS	400		
	dec	r22						;decrement offset
	_BRNE	prog0				;animated sequence steps not completed
	rjmp	main				;infinite loop

LCD_putstring:
; in	z 
	lpm							; load program memory into r0
	tst	r0						; test for end
	breq	done
	mov	a0,r0					; load argument
	rcall	LCD_putc
	adiw	zl,1
	rjmp	LCD_putstring
done:	ret	

LCD_drCGRAMupw: 
	lds	u, LCD_IR				;read IR to check busy flag  (bit7)
	JB1	u,7,LCD_drCGRAMupw		;Jump if Bit=1 (still busy)
	ldi	r16, 0b01011000			;2MSBs:write into CGRAM(instruction),
								;6LSBs:address in CGRAM and in charact.
	sts	LCD_IR, r16				;store w in IR
	ldi	zl,low(2*arrow0)+8
	ldi	zh,high(2*arrow0)
	mov	r23,zl			
	dec	r23
	mov	r24,r23			;store upper limit of character in memory
	ldi	r18,8			;load size of caracter in table arrow0
	sub	zl,r22			;subtract current value of moving offset

   loop01: 
  	lds	u, LCD_IR	
	JB1	u,7,loop01	 
	lpm					;load from z into r0
	mov	r16,r0
	adiw	zl,1
	mov	r23,r24			;garantee z remains in character memory
	sub	r23,zl			;zone, if not then restart at the begining
	brge	_reg		;of character definition
	subi	zl,8
	
  _reg:	sts	LCD_DR, r16		;load definition of one charecter line 
	dec	r18
	brne	loop01
	rcall	LCD_home		;leaving CGRAM
	ret