; file	cordic.asm   target ATmega128L-4MHz-STK300
; purpose library, Cordinate Rotation Digital Computer (CORDIC) algorithm

.def	dx0	= r4		; dx = x * 2^(-i)
.def	dx1	= r5
.def	dx2	= r6
.def	dx3	= r7
.def	dy0	= r8		; dy = y * 2^(-i)
.def	dy1	= r9
.def	dy2	= r10
.def	dy3	= r11
.def	dz0	= r12		; dz = arctan(2^(-i))
.def	dz1	= r13
.def	dz2	= r14
.def	dz3	= r15

.def	i	= r17
.def	x0	= r18		; x coordinate
.def	x1	= r19
.def	x2	= r20
.def	x3	= r21
.def	y0	= r22		; y coordinate
.def	y1	= r23
.def	y2	= r24
.def	y3	= r25
.def	z0	= r26		; z = angle phi
.def	z1	= r27
.def	z2	= r28
.def	z3	= r29

.equ	nbrdec	= 29			; number of iterations (i=1..29)
.equ	Kc	= $136e9db5			; 0.607252 (K constant for circular algorithm)
.equ	Kh	= $26a3d0e4			; 1.207497 (K constant for hyperbolic algorithm)
.equ	One	= $20000000			; 1.000000
.equ	Pi	= $6487ED51			; 3.141593

athtab:	.include "athtab.txt"	; include table with arctanh(2^(-i)), (i=1..29)
atgtab:	.include "atgtab.txt"	; include table with arctan(2^(-i)),  (i=1..29)

getxyz:	LPM4	dz3,dz2,dz1,dz0	; dz=arctan(-i)
getxyz2:MOV4	dx3,dx2,dx1,dx0,  x3,x2,x1,x0	; dx=x
	MOV4	dy3,dy2,dy1,dy0,  y3,y2,y1,y0		; dy=y
	tst	i
	breq	_getxyz
	mov	w,i		
_shftx:	ASR4	dx3,dx2,dx1,dx0			; dx=x/(2^i)
_shfty:	ASR4	dy3,dy2,dy1,dy0			; dy=y/(2^i)
	DJNZ	w,_shftx
_getxyz:ret

; === circular CORDIC (cc) ====
ccordic:LDIZ	2*atgtab						; point to arctan table
	clr	i
cc:	rcall	getxyz
	brts	cc_inv								; inverse if T=1 
cc_dir:	JB1	z3,7,cc_neg							; Jump if Bit=1
cc_pos:	SUB4	x3,x2,x1,x0,  dy3,dy2,dy1,dy0	; x=x-dy
	ADD4	y3,y2,y1,y0,  dx3,dx2,dx1,dx0		; y=y+dy
	SUB4	z3,z2,z1,z0,  dz3,dz2,dz1,dz0		; z=z-dz
	rjmp	cc_end
cc_inv:	JB1	y3,7,cc_pos							; Jump if Bit=0
cc_neg:	ADD4	x3,x2,x1,x0,  dy3,dy2,dy1,dy0	; x=x+dy
	SUB4	y3,y2,y1,y0,  dx3,dx2,dx1,dx0		; y=y-dx
	ADD4	z3,z2,z1,z0,  dz3,dz2,dz1,dz0		; z=z+dz
cc_end:	IJNK	i,nbrdec,cc						; Increment and Jump if Not K
	ret			
	
; === hyperbolic CORDIC (hc) ====
hcordic:LDIZ	2*athtab			; point to arctanh table
;	clr	i		
	ldi	i,1
hc:	rcall	getxyz
	rcall	hc_rot
	CK	i, 4,hc_rep					; Call if K (i= 4)
	CK	i,13,hc_rep					; Call if K (i=13)
	IJNK	i,nbrdec,hc				; Increment and Jump if Not K
	ret
	
hc_rep:	rcall	getxyz2	
hc_rot:	brts	hc_inv				; inverse if T=1
hc_dir:	JB1	z3,7,hc_neg				; Jump if Bit=1
hc_pos:	ADD4	x3,x2,x1,x0,  dy3,dy2,dy1,dy0	; z/y is positive
	ADD4	y3,y2,y1,y0,  dx3,dx2,dx1,dx0
	SUB4	z3,z2,z1,z0,  dz3,dz2,dz1,dz0
	rjmp	hc_end
hc_inv:	JB1	y3,7,hc_pos				; Jump if Bit=0
hc_neg:	SUB4	x3,x2,x1,x0,  dy3,dy2,dy1,dy0	; z/y is negative
	SUB4	y3,y2,y1,y0,  dx3,dx2,dx1,dx0
	ADD4	z3,z2,z1,z0,  dz3,dz2,dz1,dz0
hc_end:	ret

; =========================================
; func	cos
;
; in	a3..a0	angle -(pi/2)...+(pi/2)
; out	a3..a0	cos(a)
;	b3..a0	sin(a)
;
cos:	rcall	ldz_a
	rcall	ldx_Kc
	rcall	ldy_0
	clt			; T=0 (not inverse)
	rjmp	ccordic

; =========================================
; func	sin
;
; in	a3..a0	angle -(pi/2)...+(pi/2)
; out	a3..a0	sin(a)
;
sin:	rcall	cos
	rjmp	mov_ab

atn:	rcall	ldy_a
	rcall	ldx_1
atn2:	rcall	ldz_0
	set						; T=1 (inverse)
	rcall	ccordic			; circular cordic
	rjmp	mov_az

cosh:	rcall	ldz_a
	rcall	ldx_Kh
	rcall	ldy_0
	clt						; T=0 (not inverse)
	rjmp	hcordic

sinh:	rcall	cosh
	rjmp	mov_ab

exp:	rcall	ldz_a
	rcall	ldx_Kh
	rcall	ldy_Kh
	rjmp	hcordic

atnh:	rcall	ldy_a
	rcall	ldx_1
atnh2:	rcall	ldz_0
	set						; T=1 (inverse)
	rcall	hcordic			; circular cordic
	rjmp	mov_az

	
ln:	rcall	mov_ba
	addi	a3,0x20
	subi	b3,0x20
	set
	rcall	hcordic
	rcall	mov_az
	LSL4	a3,a2,a1,a0
	ret

; === input arguments ===
; in	a3..a0	x
;	b3..b0	y
; out	a3..a0	sqrt(x^2+y^2)/Kc
magn:	rcall	ldz_0
	set
	rjmp	ccordic

; === load & move ===
ldx_Kc:	LDI4	x3,x2,x1,x0, Kc
	ret
ldx_Kh:	LDI4	x3,x2,x1,x0, Kh
	ret
ldx_1:	LDI4	x3,x2,x1,x0, one
	ret
ldy_0:	LDI4	y3,y2,y1,y0, 0
	ret
ldy_Kh:	LDI4	y3,y2,y1,y0, Kh
	ret
ldy_a:	MOV4	b3,b2,b1,b0, a3,a2,a1,a0
	ret
ldz_0:	LDI4	z3,z2,z1,z0, 0
	ret
ldz_a:	MOV4	z3,z2,z1,z0, a3,a2,a1,a0
	ret
mov_ab:	MOV4	a3,a2,a1,a0, b3,b2,b1,b0
	ret
mov_ba:	MOV4	b3,b2,b1,b0, a3,a2,a1,a0
	ret
mov_az:	MOV4	a3,a2,a1,a0, z3,z2,z1,z0
	ret
