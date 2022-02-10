; file	music.asm   target ATmega128L-4MHz-STK300
; purpose play music from LUT

.include "macros.asm"		; macro definitions
.include "definitions.asm"	; register/constant definitions

reset:
	LDSP	RAMEND		; load stack pointer SP
	sbi	DDRE,SPEAKER	; make pin SPEAKER an output
	rjmp	main

.include "sound.asm"		; include sound routine
	
; === music score ===
elise:	
.db	mi3,rem3
.db	mi3,rem3,mi3,si2,re3,do3, 	la2,mi,la,do2,mi2,la2
.db	si2,mi,som,mi2,som2,si2,	do3,mi,la,mi2,mi3,rem3
.db	mi3,rem3,mi3,si2,re3,do3,  	la2,mi,la,do2,mi2,la2		
.db	si2,mi,som,re2,do3,si2,		la2,mi,la,si2,do3,re3

.db	mi3,so,do2,so2,fa3,mi3,		re3,so,si,fa2,mi3,re3
.db	do3,mi,la,mi2,re3,do3,		si2,mi,mi2,mi2,mi3,mi2
.db	mi3,mi2,mi3,rem3,mi3,rem3,	mi3,rem3,mi3,rem3,mi3,rem3
.db	mi3,rem3,mi3,si2,re3,do3,	la2,mi,la,do2,mi2,la2
.db	si2,mi,som,mi2,som2,si,		do3,mi,la,mi2,mi3,rem3
.db	mi3,rem3,mi3,si2,re3,do3,	la2,mi,la,do2,mi2,la2
.db	si2,mi,som,re2,do3,si2,		la2,mi,la,si2,do3,re3
.db	0 ; odd number of byte -> assembler will do padding !

main:	ldi	zl, low(2*elise)	; pointer z to begin of musical score
	ldi	zh,high(2*elise)
play:	lpm						; load note to play
	adiw	zl,1				; increment pointer z 
	tst	r0						; test end of file (NUL)
	breq	end
	mov	a0,r0					; move note to a0
	ldi	b0,100					; load play duration (50*2.5ms = 125ms)
	rcall	sound				; play the sound
	rjmp	play

end:	rjmp	end