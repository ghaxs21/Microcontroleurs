; file	hw01.asm   target ATmega128L-4MHz-STK300
; purpose conversion and flags

.include	"macros.asm"

; display the registers in the processor status window, right click to change
; format

/*
partE11a-b:		; comment/uncomment to adapt to the subpart
	ldi	r16, 11
	ldi r16, 0x11
	ldi	r16, 0b11

	ldi	r16, 0x96
	ldi r16, 96
	;ldi r16, 0b10100110110
	;ldi r16, 0x10101
	ldi	r16, 0
	ldi	r16, 0x9
	ldi	r16, 10
	ldi	r16, 0xff
	ldi	r16, 0x7f
	ldi	r16, 128
	ldi	r16, 0b11000000
*/

/*
partE12: 	; adapt to different entries and to partE13
	ldi	r16, 0b110101
	ldi	r17, 0b001100
	add	r16, r17
*/

partE14:	; comment/uncomment to adapt to the subpart
start:
	ldi	r16,0x8F
	ldi	r17,0x21
	Z2INVC
	nop
instr:
	;and	r16,r17
	;asr	r16
	;lsr	r16
	;ldi	r17,0b11111111
	;eor	r16,r17
	;sub	r16,r17
	;cpi	r16,0x90
	;ldi	r17,0x70
	;adc	r16,r17
	com	r16
	nop


