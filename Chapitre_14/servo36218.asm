; file	servo36218.asm   target ATmega128L-4MHz-STK300
; purpose 360-servo motor control as a classical 180-servo
; with increased angle capability
; module: M4, P7 servo Futaba S3003, output port: PORTB

.include "macros.asm"		; macro definitions
.include "definitions.asm"	; register/constant definitions

.equ	npt = 1566			; effective/observed neutral point of individual servo		

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRB,0xff		; configure portB to output
	rcall	LCD_init		; initialize the LCD	
	rjmp	main			; jump to the main program
	
.include "lcd.asm"			; include the LCD routines
.include "printf.asm"		; include formatted print routines

.macro CA3					;call a subroutine with three arguments in a1:a0 b0
	ldi	a0, low(@1)			;speed and rotation direction
	ldi a1, high(@1)		;speed and rotation direction
	ldi b0, @2				;angle
	rcall	@0
.endmacro

; main -----------------
main:	
init:							; initializations
	P0	PORTB,SERVO1			; pin=0
	LDI2	a1,a0,npt

	PRINTF	LCD					; print formatted
.db	"Set NP > PD0/PD1",LF,0
	PRINTF	LCD					; print formatted
.db "PD7 to set",LF,0

npset:							; neutral point setting
	in	r23,PIND
	cpi	r23, 0b11111110
	breq _cw
	cpi	r23, 0b11111101
	breq _ccw
	cpi	r23, 0b01111111
	breq _npmem
_exec:
	rcall	servoreg_pulse
	rjmp	npset
_cw:
	ADDI2	a1,a0,2			; increase pulse timing
	rjmp	_exec
_ccw:
	SUBI2	a1,a0,2			; decrease pulse timing
	rjmp	_exec
_npmem:
	LDI2	a1,a0,npt
	rcall	servoreg_pulse

	rcall LCD_home
	PRINTF	LCD					; print formatted
.db	"AR>PD7:PD0 R:PD4",LF,0
	WAIT_MS	50

ang_rot:						; fsm, utilization codes at locations t7:t0
	in		r23,PIND
t0:	cpi		r23,0b11111110
	brne	t1
	CA3	_s360, (npt+26), 0x36	; cw 90, low-speed
t1:	cpi		r23,0b11111101
	brne	t2
	CA3	_s360, (npt+316), 0x0e	; cw 180, high-speed
t2:	cpi		r23,0b11111011
	brne	t3
	CA3 _s360, (npt+310), 0x36	; cw 720, high-speed
t3:	cpi		r23,0b01111111
	brne	t4
	CA3 _s360, (npt-26), 0x36	; ccw 90, low-speed
t4:	cpi		r23,0b10111111
	brne	t5
	CA3 _s360, (npt-310), 0x0e	; ccw 180, high-speed
t5:	cpi		r23,0b11011111
	brne	t6
	CA3 _s360, (npt-316), 0x36	; ccw 720, high-speed
t6:	cpi		r23,0b11100111
	brne	t7
	rjmp	init			; recalibrate neutral point
t7:	rjmp ang_rot
	
; _s360, in a1:a0, a2 out void, mod a2,w
; purpose execute arbitrary rotation
_s360:	
ls3601:
	rcall	servoreg_pulse
	dec		b0
	brne	ls3601
	ret

; servoreg_pulse, in a1,a0, out servo port, mod a3,a2
; purpose generates pulse of length a1,a0
servoreg_pulse:
	PRINTF	LCD				; print formatted
.db	"pulse=",FDEC2,a,"usec    ",CR,0

	WAIT_US	20000
	MOV2	a3,a2, a1,a0
	P1	PORTB,SERVO1		; pin=1	
lpssp01:	DEC2	a3,a2
	brne	lpssp01
	P0	PORTB,SERVO1		; pin=0
	ret