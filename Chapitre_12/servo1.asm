; file	servo1.asm   target ATmega128L-4MHz-STK300
; purpose servo motor control from potentiometer
; module: M3, output port: PORTF
; module: M4, P7 servo Futaba S3003, output port: PORTB
.include "macros.asm"		; macro definitions
.include "definitions.asm"	; register/constant definitions

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRB,0xff		; configure portB to output
	rcall	LCD_init		; initialize the LCD
	
	OUTI	ADCSR,(1<<ADEN)+6; AD Enable, PS=CK/64	
	OUTI	ADMUX,POT		; select channel with potentiometer POT	
	rjmp	main			; jump ahead to the main program
	
.include "lcd.asm"			; include the LCD routines
.include "printf.asm"		; include formatted print routines

main:	P0	PORTB,SERVO1	; pin=4
	WAIT_US	20000
	sbi	ADCSR,ADSC			; AD start conversion
	WP1	ADCSR,ADSC			; wait if ADIF=0
	in	a0,ADCL				; read low byte first
	in	a1,ADCH				; read high byte second
	ADDI2	a1,a0,1000		; add an offset of 1000
	
	PRINTF	LCD				; print formatted
.db	"pulse=",FDEC2,a,"usec    ",CR,0
	
	P1	PORTB,SERVO1		; pin=4
loop:	DEC2	a1,a0
	brne	loop
	rjmp	main			
