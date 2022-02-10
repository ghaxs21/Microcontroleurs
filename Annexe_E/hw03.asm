; file	hw03.asm   target ATmega128L-4MHz-STK300
; purpose instructions and branching

.include "definitions.asm"
.include "macros.asm"

;===definitions===
.dseg
.org 0x100
varb1:	.byte	1					;room for variables
varw1:	.byte	2

.cseg
.equ	const16 = 0x0100
.equ	const8	= 0x60
table1: .dw	0xaf,0x9e
table2:	.dw	0x0001,0x0002,0x00a2


;===initial register setup===
	_LDI	r0,0x00
	_LDI	r1,0xe7
	clr	r2
	ldi	r16,0x00
	ldi	r17,0x00
	ldi	r18,0xa4
	ldi	r19,0xfe
	ldi	r20,0xff
	ldi	r21,0xab
	ldi	r22,0x40
	ldi	r23,0x04
	ldi	r24,0x02
	
	ldi	xl,0xff
	ldi	xh,0x10
	ldi	zl,0x00
	ldi	zh,0x00
	
	sts	varb1,r18
	sts	varw1,r18
	sts	varw1+1,r19
	clz

	nop
	
;===instructions to simulate=== 		 ; comment/uncomment to adapt to the subpart
;Section 1
	;mov	r19,r2
	;mov	_w,r24
	;mov	r1,zl
	;mov	r2,const8	;faulty
;Section 2
	;in	r5,PIND
	;sts	0x1070,r21
	;st	x, r18
	;ldi	r8,0xaa	;faulty
	;_LDI	r2,0xaa	
	;ldi	zl,0x01
	;ldi	r22,const8
	;lds	r22,const16
	;lds	r25,varw1+1
	;ld	r25,z
	;ld	r24,zl		;faulty
;Section 3	
	;lsr	r20
	;asr	r21
	;rol	r21
	;ser	r25
;Section 4
	;mul	r19,r24
	;add	r17,r20	
	;_ADDI	r2,0x22
;Section 5
	;or	r22,r23
	;ori	r22,0x04
	;eor	r21,r23
	;_EORI	r21,0xb4
	;ORB	r22,1,r23,2,r24,2
;Section 6
	;com	r21
	;neg	r21
	;INVB	r21,1
;Section 7
	;clr	r1
	;cpi	r21,0xaa
	;swap	r21
	;clv
;Section 8
	;subi	r16, (0b1<<0)
	;ldi		r16,(0b111>>2)
	;ldi		r16, (0b11<<9)
	;ldi		r16, (const8<<1)
	;ldi		r16, (const8>>1)
	
	
main: rjmp main