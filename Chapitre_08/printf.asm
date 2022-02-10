; file	printf.asm   target ATmega128L-4MHz-STK300
; purpose library, formatted output generation
; v2019.02 20180821 supports SRAM input from 0x0260
;					through 0x02ff that should be reserved

; === description ===
; 
; The program "printf" interprets and prints formatted strings.
; The special formatting characters regognized are:
;
; FDEC	decimal number
; FHEX	hexadecimal number
; FBIN	binary number
; FFRAC	fixed fraction number
; FCHAR	single ASCII character
; FSTR	zero-terminated ASCII string
;	
; The special formatting characters are distinguished from normal 
; ASCII characters by having their bit7 set to 1.
;
; Signification of bit fields:
;
; b 	bytes		1..4 b bytes		2
; s 	sign		0(unsigned), 1(signed)	1
; i		integer digits	
; e 	base		2,,36			5
; dp 	dec. point	0..32			5
; $if	i=integer digits,  0=all digits,  1..15 digits 
;		f=fraction digits, 0=no fraction, 1..15 digits
;
; Formatting characters must be followed by an SRAM address (0..ff)
; that determines the origin of variables that must be printed (if any)
; FBIN,	sram
; FHEX,	sram
; FDEC,	sram
; FCHAR,sram
; FSTR,	sram
;
; The address 'sram' is a 1-byte constant. It addresses
; 	 0..1f	registers r0..r31, 
; 	20..3f	i/o ports, (need to be addressed with an offset of $20)
;	0x0260..0x02ff	SRAM
; Variables can be located into register and I/0s, and can also
; be stored into data SRAM at locations 0x0200 through 0x02ff. Any
; sram address higher than 0x0060 is assumed to be at (0x0260+address)
; from automatic address detection in _printf_formatted: and subsequent
; assignment to xh; xl keeps its value. Consequently, variables that are
; to be stored into SRAM and further printed by fprint must reside at
; 0x0200 up to 0x02ff, and must be addressed using a label. Usage: see
; file string1.asm, for example.

; The FFRAC formatting character must be followed by 
;	ONE sram address and 
;	TWO more formatting characters
; FFRAC,sram,dp,$if

; dp	decimal point position, 0=right, 32=left
; $if	format i.f, i=integer digits, f=fraction digits

; The special formatting characters use the following coding
;
; FDEC	11bb'iiis	i=0 all digits, i=1-7 digits
; FBIN	101i'iiis	i=0 8 digits,	i=1-7 digits
; FHEX	1001'iiis	i=0 8 digits,	i=1-7 digits
; FFRAC	1000'1bbs
; FCHAR	1000'0100
; FSTR	1000'0101
; FREP	1000'0110
; FFUNC	1000'0111
;	1000'0010
;	1000'0011
; FESC	1000'0000

; examples
; formatting string			printing
; "a=",FDEC,a,0				1-byte variable a, unsigned decimal
; "a=",FDEC2,a,0			2-byte variable a (a1,a0), unsigend
; "a=",FDEC|FSIGN,a,0		1-byte variable 1, signed decimal
; "n=",FBIN,PIND+$20,0		i/o port, binary, notice offset of $20
; "f=",FFRAC4|FSIGN,a,16,$88,0	4-byte signed fixed-point fraction
;				dec.point at 16, 8 int.digits, 8 frac.digits	
; "f=",FFRAC2,a,16,$18,0		2-byte unsigned fixed-point fraction
;				dec.point at 16, 1 int.digits, 8 frac.digits	
; "a=",FDEC|FDIG5|FSIGN,a,0	1-byte variable, 5-digit, decimal, signed
; "a=",FDEC|FDIG5,a,0		1-byte variable, 5-digit, decimal, unsigned

; === registers modified ===
; e0,e1	used to transmit address of putc routine
; zh,zl	used as pointer to prog-memory

; === constants ==============================================

.equ	FDEC	= 0b11000000	; 1-byte variable
.equ	FDEC2	= 0b11010000	; 2-byte variable
.equ	FDEC3	= 0b11100000	; 3-byte variable
.equ	FDEC4	= 0b11110000	; 4-byte variable

.equ	FBIN	= 0b10100000
.equ	FHEX	= 0b10010100	; 1-byte variable
.equ	FHEX2	= 0b10011000	; 2-byte variable
.equ	FHEX3	= 0b10011100	; 3-byte variable
.equ	FHEX4	= 0b10010000	; 4-byte variable

.equ	FFRAC	= 0b10001000	; 1-byte variable
.equ	FFRAC2	= 0b10001010	; 2-byte variable
.equ	FFRAC3	= 0b10001100	; 3-byte variable
.equ	FFRAC4	= 0b10001110	; 4-byte variable

.equ	FCHAR	= 0b10000100
.equ	FSTR	= 0b10000101

.equ	FSIGN	= 0b00000001

.equ	FDIG1	= 1<<1
.equ	FDIG2	= 2<<1
.equ	FDIG3	= 3<<1	
.equ	FDIG4	= 4<<1
.equ	FDIG5	= 5<<1
.equ	FDIG6	= 6<<1
.equ	FDIG7	= 7<<1

; ===macro ====================================================

.macro	PRINTF			; putc function (UART, LCD...)
	ldi	w, low(@0)		; address of "putc" in e1:d0
	mov	e0,w
	ldi	w,high(@0)
	mov	e1,w
	rcall	_printf
	.endmacro

; mod	y,z


; === routines ================================================

_printf:
	POPZ			; z points to begin of "string"
	MUL2Z			; multiply Z by two, (word ptr -> byte ptr)
	PUSHX
		
_printf_read:
	lpm				; places prog_mem(Z) into r0 (=c)
	adiw	zl,1	; increment pointer Z
	tst	r0			; test for ZERO (=end of string)
	breq	_printf_end	; char=0 indicates end of ascii string
	brmi	_printf_formatted ; bit7=1 indicates formatting character
	mov	w,r0
	rcall	_putw	; display the character
	rjmp	_printf_read	; read next character in the string
	
_printf_end:
	adiw	zl,1	; point to the next character
	DIV2Z			; divide by 2 (byte ptr -> word ptr)
	POPX
	ijmp			; return to instruction after "string"

_printf_formatted:

; FDEC	11bb'iiis
; FBIN	101i'iiis
; FHEX	1001'iiis
; FFRAC	1000'1bbs
; FCHAR	1000'0100
; FSTR	1000'0101

	bst	r0,0		; store sign in T
	mov	w,r0		; store formatting character in w
	lpm	
	mov	xl,r0		; load x-pointer with SRAM address
	cpi	xl,0x60
	brlo rio_space
dataram_space:		; variable originates from SRAM memory
	ldi	xh,0x02		;>addresses are limited to 0x0260 through 0x02ff
	rjmp space_detect_end	;>that enables automatic detection of the origin
rio_space:			; variable originates from reg or I/O space 
	clr	xh			; clear high-byte, addresses are 0x0000 through 0x003f (0x005f)
space_detect_end:
 	adiw	zl,1	; increment pointer Z

;	JB1	w,6,_putdec
;	JB1	w,5,_putbin
;	JB1	w,4,_puthex
;	JB1	w,3,_putfrac
	JK	w,FCHAR,_putchar
	JK	w,FSTR ,_putstr
	rjmp	_putnum
	
	rjmp	_printf_read	

; === putc (put character) ===============================
; in	w	character to put
;	e1,e0	address of output routine (UART, LCD putc)
_putw:
	PUSH3	a0,zh,zl
	MOV3	a0,zh,zl, w,e1,e0
	icall			; indirect call to "putc"
	POP3	a0,zh,zl
	ret

; === putchar (put character) ============================
; in	x	pointer to character to put
_putchar:
	ld	w,x
	rcall	_putw
	rjmp	_printf_read
	
; === putstr (put string) ================================
; in	x	pointer to ascii string
;	b3,b2	address of output routine (UART, LCD putc)
_putstr:
	ld	w,x+
	tst	w
	brne	PC+2
	rjmp	_printf_read
	rcall	_putw
	rjmp	_putstr

; === putnum (dec/bin/hex/frac) ===========================
; in	x	pointer to SRAM variable to print
; 	r0	formatting character
	
_putnum:
	PUSH4	a3,a2,a1,a0	; safeguard a
	PUSH4	b3,b2,b1,b0	; safeguard b	
	LDX4	a3,a2,a1,a0	; load operand to print into a

; FDEC	11bb'iiis
; FBIN	101i'iiis
; FHEX	1001'iiis
; FRACT	1000'1bbs

	JB1	w,6,_putdec
	JB1	w,5,_putbin
	JB1	w,4,_puthex
	JB1	w,3,_putfrac

; FDEC	11bb'iiis
_putdec:
	ldi	b0,10		; b0 = base (10)

	mov	b1,w
	lsr	b1
	andi	b1,0b111	
	swap	b1		; b1 = format 0iii'0000 (integer digits)
	ldi	b2,0		; b2 = dec. point position = 0 (right)
	
	mov	b3,w
	swap	b3
	andi	b3,0b11
	inc	b3			; b3 = number of bytes (1..4)
	rjmp	_getnum	; get number of digits (iii)

; FBIN	101i'iiis	addr
_putbin:	
	ldi	b0,2		; b0 = base (2)
	ldi	b3,4		; b3 = number of bytes (4)	
	rjmp	_getdig	; get number of digits (iii)

; FHEX	1001'iiis	addr
_puthex:	
	ldi	b0,16		; b0 = base (16)
	ldi	b3,4		; b3 = number of bytes (4)
	rjmp	_getdig

_getdig:
	mov	b1,w
	lsr	b1
	andi	b1,0b111
	brne	PC+2
	ldi	b1,8		; if b1=0 then 8-digits
	swap	b1		; b1 = format 0iii'0000 (integer digits)
	ldi	b2, 0		; b2 = dec. point position = 0 (right)
	rjmp	_getnum

; FFRAC	1000'1bbs	addr	 00dd'dddd, 	iiii'ffff
	
_putfrac:
	ldi	b0,10		; base=10	
	lpm
	mov	b2,r0		; load dec.point position
	adiw	zl,1	; increment char pointer
	lpm
	mov	b1,r0		; load ii.ff format
	adiw	zl,1	; increment char pointer
	
	mov	b3,w
	asr	b3
	andi	b3,0b11
	inc	b3			; b3 = number of bytes (1..4)

	rjmp	_getnum

_getnum:
; in 	a	4-byte variable
; 	b3	number of bytes (1..4)
;	T	sign, 0=unsigned, 1=signed

	JK	b3,4,_printf_4b
	JK	b3,3,_printf_3b
	JK	b3,2,_printf_2b	
	
_printf_1b:			; sign extension
	clr	a1
	brtc	PC+3	; T=1 sign extension
	sbrc	a0,7
	ldi	a1,0xff
_printf_2b:
	clr	a2
	brtc	PC+3	; T=1 sign extension	
	sbrc	a1,7
	ldi	a2,0xff
_printf_3b:	
	clr	a3
	brtc	PC+3	; T=1 sign extension
	sbrc	a2,7
	ldi	a3,0xff
_printf_4b:

	rcall	_ftoa		; float to ascii
	POP4	b3,b2,b1,b0	; restore b
	POP4	a3,a2,a1,a0	; restore a
	
	rjmp	_printf_read

; ===============================================
; func	ftoa
; converts a fixed-point fractional number to an ascii string
;
; in	a3-a0	variable to print
;	b0	base, 2 to 36, but usually decimal (10)
;	b1	number of digits to print ii.ff
; 	b2	position of the decimal point (0=right, 32=left)
;	T	sign (T=0 unsiged, T=1 signed)

_ftoa:
	push	d0
	PUSH4	c3,c2,c1,c0	; c = fraction part, a = integer part
	CLR4	c3,c2,c1,c0	; clear fraction part

	brtc	_ftoa_plus	; if T=0 then unsigned
	clt
	tst	a3				; if MSb(a)=1 then a=-a
	brpl	_ftoa_plus
	set					; T=1 (minus)
	tst	b1
	breq	PC+2		; if b1=0 the print ALL digits
	subi	b1,0x10		; decrease int digits
	NEG4	a3,a2,a1,a0	; negate a
_ftoa_plus:	
	tst	b2				; b0=0 (only integer part)
	breq	_ftoa_int	
_ftoa_shift:	
	ASR4	a3,a2,a1,a0	; a = integer part	
	ROR4	c3,c2,c1,c0	; c = fraction part
	DJNZ	b2,_ftoa_shift
_ftoa_int:
	push	b1			; ii.ff (ii=int digits)
	swap	b1
	andi	b1,0x0f
	
	ldi	w,'.'			; push decimal point
	push	w
_ftoa_int1:
	rcall	_div41		; int=int/10
	mov	w,d0			; d=reminder
	rcall	_hex2asc
	push	w			; push rem(int/10)
	TST4	a3,a2,a1,a0	; (int/10)=?
	breq	_ftoa_space	; (int/10)=0 then finished
	tst	b1
	breq	_ftoa_int1	; if b1=0 then print ALL int-digits
	DJNZ	b1,_ftoa_int1
	rjmp	_ftoa_sign
_ftoa_space:
	tst	b1				; if b1=0 then print ALL int-digits
	breq	_ftoa_sign
	dec	b1
	breq	_ftoa_sign
	ldi	w,' '			; write spaces
	rcall	_putw	
	rjmp	_ftoa_space
_ftoa_sign:
	brtc	PC+3		; if T=1 then write 'minus'
	ldi	w,'-'
	rcall	_putw
_ftoa_int3:
	pop	w
	cpi	w,'.'
	breq	PC+3
	rcall	_putw
	rjmp	_ftoa_int3

	pop	b1				; ii.ff (ff=frac digits)
	andi	b1,0x0f
	tst	b1
	breq	_ftoa_end
_ftoa_point:	
	rcall	_putw		; write decimal point
	MOV4	a3,a2,a1,a0, c3,c2,c1,c0		
_ftoa_frac:
	rcall	_mul41		; d.frac=10*frac
	mov	w,d0
	rcall	_hex2asc
	rcall	_putw
	DJNZ	b1,_ftoa_frac
_ftoa_end:
	POP4	c3,c2,c1,c0
	pop	d0
	ret

; === hexadecimal to ascii ===
; in	w
_hex2asc:
	cpi	w,10
	brsh	PC+3
	addi	w,'0'
	ret
	addi	w,('a'-10)
	ret

; === multiply 4byte*1byte ===
; funct mul41
; multiplies a3-a0 (4-byte) by b0 (1-byte)
; 
; in	a3..a0	multiplicand (argument to multiply)
;	b0	multiplier
; out	a3..a0	result
; 	d0	result MSB (byte 4)
;
_mul41:	clr	d0			; clear byte4 of result
	ldi	w,32			; load bit counter
__m41:	clc				; clear carry
	sbrc	a0,0		; skip addition if LSB=0
	add	d0,b0			; add b to MSB of a
	ROR5	d0,a3,a2,a1,a0	; shift-right c, LSB (of b) into carry
	DJNZ	w,__m41		; Decrement and Jump if bit-count Not Zero
	ret

; === divide 4byte/1byte ===
; func div41
; in	a0..a3 	divident (argument to divide)
;	b0 	divider
; out	a0..a3 	result 
;	d0	reminder
;
_div41:	clr	d0			; d will contain the remainder
	ldi	w,32			; load bit counter
__d41:	ROL5	d0,a3,a2,a1,a0	; shift carry into result c
	sub	d0, b0			; subtract b from remainder
	brcc	PC+2	
	add	d0, b0			; restore if remainder became negative
	DJNZ	w,__d41		; Decrement and Jump if bit-count Not Zero
	ROL4	a3,a2,a1,a0	; last shift (carry into result c)
	COM4	a3,a2,a1,a0	; complement result
	ret
