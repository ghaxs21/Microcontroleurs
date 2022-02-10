; file	timer_pwm.asm   target ATmega128L-4MHz-STK300			
; purpose timer 0, 1, 2, PWM generation
; output: PB4, PB5, PB6, PB7 (OC) and PB0 (main)

.include "macros.asm"			; include macro definitions
.include "definitions.asm"		; include register/constant definitions

; === interrupt vector table ===
.org	0
	rjmp	reset

; === initialisation (reset) ===
.set	pwm_0 = 100
.set	pwm_1a = 300
.set	pwm_1b = 550
.set	pwm_2 = 50
	
reset: 
	LDSP	RAMEND										; load stack pointer (SP)
	OUTI	PORTB,0xff									; turn LEDs off
	OUTI	DDRB,0xff									; portB = output
		
	OUTI	TCCR0, (1<<PWM0)+(0b10<<COM00)+1 			; CS0=1 CK	
	OUTI	TCCR1B, 2									; CS1=1 CK/8
	OUTI	TCCR2, (1<<PWM2)+(0b10<<COM20)+3			; CS2=2 CK/64
	OUTI	TCCR1A,(0b10<<COM1A0)+(0b10<<COM1B0)+11		; 10-bit PWM
	
	OUTI	OCR0,pwm_0									; Output Compare reg 0
	OUTI	OCR1AH,high(pwm_1a) 						; Output Compare reg 1a
	OUTI	OCR1AL, low(pwm_1a)
	OUTI	OCR1BH,high(pwm_1b) 						; Output Compare reg 1b
	OUTI	OCR1BL, low(pwm_1b)	
	OUTI	OCR2,pwm_2									; Output Compare reg 2
	
; === main program ===
main:
	WAIT_MS	100
	INVP	PORTB,0
	rjmp	main