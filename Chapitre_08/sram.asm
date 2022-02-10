; file	sram.asm   target ATmega128L-4MHz-STK300
; purpose library, terminal simulation in SRAM
; >alignment to a base address with LSByte 0x00
; >is assumed

SRAM_init:
; initializes the SRAM buffer
.dseg
.org 0x100
buffer:		.byte	16*10	; create a buffer zone
.cseg	
	LDIX	buffer			; point x to begin of buffer 

	ldi	a0,'='				; write a line of equal signs (=)
	ldi	w,16	
	st	x+,a0
	dec	w
	brne	PC-2
	
	ldi	a0,' '				; write 8 lignes of spaces ( )
	ldi	w,16*8	
	st	x+,a0
	dec	w
	brne	PC-2
	
	ldi	a0,'='				; write a line of equal signs (=)
	ldi	w,16	
	st	x+,a0
	dec	w
	brne	PC-2
	
	ldi	w, low(buffer+16)	; store cursor default position
	sts	buffer,w
	ldi	w, high(buffer+16)
	sts buffer+1,w	
	ret	

SRAM:
SRAM_putc:
; a0	character to write to SRAM buffer
	lds	xh,buffer+1
	lds	xl,buffer
	cpi	a0,CR				; carriage return
	breq	_cr
	cpi	a0,LF				; line feed
	breq	_lf
	cpi	a0,FF				; form feed
	breq	SRAM_init
	st	x+,a0			; write character to buffer
	sts	buffer,xl			; store buffer pointer	
	ret
	
_cr:	andi	xl,0xf0		; reset pointer to begin of line
	sts	buffer,xl			; store buffer pointer	
	ret
_lf:	addi	xl,16		; advance pointer to next line
	sts	buffer,xl			; store buffer pointer	
	ret