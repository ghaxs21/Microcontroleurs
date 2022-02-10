; file	ad-ssh.asm   target ATmega128L-4MHz-STK300
; purpose button triggered ADC with semaphore

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === interrupt table ===
.org	0
	jmp	reset
.org 	ADCCaddr
	jmp	ADCCaddr_sra
	
.org	0x30
	
; === interrupt service routines
ADCCaddr_sra:
	ldi	r23,0x01			; set the flag	
	reti					; ADIF cleared here
	
; === initialization (reset) ====
reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRB,0xff		; configure portB to output
	OUTI	DDRE,0xff
	sei
	rcall	LCD_init		; initialize the LCD
	
	OUTI	ADCSR,(1<<ADEN)+(1<<ADIE)+6 ; AD Enable, AD int. enable, PS=CK/64	
	OUTI	ADMUX,POT		; select channel POT (potentiometer)	
	rjmp	main			; jump ahead to the main program
	
	
.include "lcd.asm"			; include the LCD routines
.include "printf.asm"		; include formatted printing routines

; === main program ===
main:
	WAIT_MS	1000
	clr	r23					; reset r23 flag
	in	w, PIND				; AD conversion is subject to
	sbrc	w,0				;>pressing pd0
	jmp	PC-2	

	sbi	ADCSR,ADSC			; AD start conversion
	WB0	r23,0				; wait as long as flag reset
							;>flag set in the interrupt service routine
	
	in	a0,ADCL				; read low byte first
	in	a1,ADCH				; read high byte second

	PRINTF	LCD				; print formatted
.db	CR,CR,"ADC=",FHEX2,a,"=",FDEC2,a,"    ",0	

	rjmp	main			; jump back to main
