; file	ad.asm   target ATmega128L-4MHz-STK300
; purpose ADC demo without interrupts
; in pot on PORTF and Aref voltage on STK300, MCU pin 62

.include "macros.asm"			; include macro definitions
.include "definitions.asm"		; include register/constant definitions

reset:
	LDSP	RAMEND				; set up stack pointer (SP)
	OUTI	DDRB,0xff			; configure portB to output
	rcall	LCD_init			; initialize the LCD
	
	OUTI	ADCSR,(1<<ADEN)+6	; AD Enable, PS=CK/64	
	OUTI	ADMUX,POT			; select channel POT (potentiometer)	
	rjmp	main				; jump ahead to the main program
	
.include "lcd.asm"				; include the LCD routines
.include "printf.asm"			; include formatted printing routines

main:
	sbi	ADCSR,ADSC				; AD start conversion
	WP1	ADCSR,ADSC				; wait if ADIF=0
	in	a0,ADCL					; read low byte first
	in	a1,ADCH					; read high byte second
	PRINTF	LCD					; print formatted
.db	CR,CR,"ADC=",FHEX2,a,"=",FDEC2,a,"    ",0	
	WAIT_US	100000				; wait 100 msec
	rjmp	main				; jump back to main
