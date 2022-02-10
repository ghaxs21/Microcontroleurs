; file	sound2.asm   target ATmega128L-4MHz-STK300
; purpose record from button and play recorded music
; 
; at start: PD0=record, PD7=play
; at recording: use buttons, PD7=stop recording 

.include "macros.asm"				; macro definitions
.include "definitions.asm"			; register/constant definitions

reset:
	LDSP	RAMEND					; load stack pointer SP
	OUTI	DDRB,$ff				; make LEDs output
	sbi	DDRE,SPEAKER				; make pin SPEAKER an output
	rjmp	main

.include "sound.asm"				; include sound routine

.dseg
buffer:	.byte	1000				; recording buffer 
.cseg

main:	OUTI	LED,0b01111110		; LED0 and LED7 on
	JP0	PIND,0,record				; if button0 then record 	
	JP0	PIND,7,play					; if button7 then play
	rjmp	main

play:	ldi	xl, low(buffer)			; set pointer x to begin of buffer
	ldi	xh,high(buffer)
play_next:
	ld	a0,x+						; load a0 from buffer and autoincrement x
	out	LED,a0						; output a0 to LEDs
	tst	a0							; test for end of sequence NUL (0)
	breq	main
	rcall	decode_button			; decode the button
	rcall	lookup_period			; lookup up the oscillation frequency
	ldi	b0,20						; sound duration 20 * 2.5ms = 50ms
	rcall	sound					; play the sound
	rjmp	play_next

record:	ldi	xl, low(buffer)			; set pointer x to begin of buffer
	ldi	xh,high(buffer)
record_next:		
	JP0	PIND,7,record_stop			; if button7 then stop recording
	in	a0,PIND						; read buttons
	out	PORTB,a0					; write result to LEDs
	st	x+,a0						; record in buffer, autoincrement x
	rcall	decode_button			; decode button
	rcall	lookup_period			; lookup the oscillation frequency
	ldi	b0,20						; sound duration 20 * 2.5ms = 50ms
	rcall	sound					; play the sound
	rjmp	record_next
record_stop:
	clr	a0		 
	st	x+,a0						; add 0 (NUL) to indicate end of sequence
	rjmp	main

decode_button:
; in	a0 	the button state ($ff=no button, $00=all buttons)
; out	a0	number of right-most button pressed (0..7), 8=none
	mov	w,a0
	ldi	a0,-1			; preload a0 with -1
	clc					; carry=0 (to indicate end)
	lsr	w				; shift right, LSB-> carry
	inc	a0				; increment counter
	brcs	PC-2		; loop back
	ret	

lookup_period:
; in	a0	button pressed (0..7)
; out	a0	corresponding oscillation period (do..do2)
	clr	a1				; clear high byte
	ldi	zl, low(2*tbl)	; load table base into z
	ldi	zh,high(2*tbl)	
	add	zl,a0			; add offset to table base
	adc	zh,a1			; add high byte
	lpm					; load program memory, r0 <- (z)
	mov	a0,r0			; load oscillation period into a0
	ret
tbl:
.db	do,re,mi,fa,so,la,si,do2,0