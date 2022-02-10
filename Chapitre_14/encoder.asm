; file	encoder.asm   target ATmega128L-4MHz-STK300
; purpose library angular encoder operation

; === definitions ===
.equ	ENCOD	= PORTE

.dseg
enc_old:.byte	1
.cseg

; === routines ===

encoder_init:
	in	w,ENCOD-1		; make 3 lines input
	andi	w,0b10001111
	out	ENCOD-1,w
	in	w,ENCOD			; enable 3 internal pull-ups
	ori	w,0b01110000
	out	ENCOD,w
	ret

encoder:
; a0,b0	if button=up   then increment/decrement a0	 
; a0,b0	if button=down then incremnt/decrement b0 
; T 	T=1 button press (transition up-down)
; Z	Z=1 button down change

	clt						; preclear T
	in	_w,ENCOD-2			; read encoder port (_w=new)
	
	andi	_w,0b01110000	; mask encoder lines (A,B,I)
	lds	_u,enc_old			; load prevous value (_u=old)
	cp	_w,_u				; compare new<>old ?
	brne	PC+3
	clz
	ret						; if new=old then return (Z=0)
	sts	enc_old,_w			; store encoder value for next time

	eor	_u,_w				; exclusive or detects transitions
	clz						; clear Z flag
	sbrc	_u,ENCOD_I
	rjmp	encoder_button	; transition on I (button)
	sbrs	_u,ENCOD_A
	ret						; return (no transition on I or A)	

	sbrs	_w,ENCOD_I		; is the button up or down ?
	rjmp	i_down
i_up:	
	sbrc	_w,ENCOD_A
	rjmp	a_rise
a_fall:
	inc	a0					; if B=1 then increment
	sbrs	_w,ENCOD_B
	subi	a0,2			; if B=0 then decrement
	rjmp	i_up_done
a_rise:
	inc	a0					; if B=0 then increment
	sbrc	_w,ENCOD_B
	subi	a0,2			; if B=1 then decrement
i_up_done:
	clz						; clear Z
	ret

i_down:	
	sbrc	_w,ENCOD_A
	rjmp	a_rise2
a_fall2:
	inc	b0					; if B=1 then increment
	sbrs	_w,ENCOD_B
	subi	b0,2			; if B=0 then decrement
	rjmp	i_down_done
a_rise2:
	inc	b0					; if B=0 then increment
	sbrc	_w,ENCOD_B
	subi	b0,2			; if B=1 then decrement
i_down_done:
	sez						; set Z
	ret

encoder_button:
	sbrc	_w,ENCOD_I
	rjmp	i_rise
i_fall:
	set						; set T=1 to indicate button press
	ret
i_rise:
	ret

.macro	CYCLIC	;reg,lo,hi
	cpi	@0,@1-1
	brne	PC+2
	ldi	@0,@2
	cpi	@0,@2+1
	brne	PC+2
	ldi	@0,@1
.endmacro
	