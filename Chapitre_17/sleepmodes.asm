; file	sleepmodes.asm   target ATmega128L-4MHz-STK300
; purpose set MCU in every sleep mode and out through interrupt
;>by a timer or a PD0

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === interrupt table ===
.org	0
	jmp	reset
	
.org	INT0addr
	jmp	ext_int0
	
.org	INT1addr
	jmp	ext_int1
	
.org	INT2addr
	jmp	ext_int2
	
.org	INT3addr
	jmp	ext_int3
	
.org	OVF0addr		; timer0 blinks PB3 and interrupts (exits) 
	jmp	overflow0		;>idle and pwr-save modes


; === interrupt service routines ===	
.org	0x0064
reset:	
	LDSP	RAMEND				; Load Stack Pointer (SP)
	OUTI	DDRB, 0xFF			; portB = output
	OUTI	EIMSK,0b00001111	; enable INT0..INT3
	OUTI	TIMSK,(1<<TOIE0)	; timer 0 overflow interrupt enable
	OUTI	ASSR, (1<<AS0)		; clock from TOSC1 (external)
	OUTI	TCCR0,7				; CSxx=1024 CK 
	sei							; set global interrupt
	OUTI	MCUCR,(1<<SE)		; enable sleep mode
	
	rcall	LCD_init			; initialize LCD
	rcall	LCD_blink_on		; turn blinking on
	rjmp	main
	
ext_int0:						; wake-up interrupt
	ldi	r26,14
	rcall	message_p
	WAIT_MS	500
	clr	r26
	rcall	message_p	
	reti
	
ext_int1:						; idle mode interrupt
	ldi	r28,1					; set semaphore
	reti

ext_int2:						; power-down mode interrupt
	ldi	r28,2					; set semaphore
	reti	
	
ext_int3:						; power-save mode interrupt
	ldi	r28,4					; set semaphore	
	reti
	
overflow0:
	INVP	PORTB,3				; monitor timer 0 activity
	reti
	
	
; === main program ===
.include "printf.asm"
.include "lcd.asm"

main:	
	clr	r26
	rcall	message_p
	clr	r28

start:	
	INVP	PORTB,7				; monitor wake-up mode
	;WAIT_MS	200				; oscillo needed if line commented
	cpi	r28,1
	_BREQ	sleep_idle
	cpi	r28,2
	_BREQ	sleep_pwdn
	cpi	r28,4
	_BREQ	sleep_pwsv
	rjmp	start


;===============================================
; print message on the seconde line of LCD
; first line remains unmodified
; in: z
message_p:
	CA	lcd_pos,$40
	ldi	zl,  low(2*message_init)
	add	zl, r26
	ldi	zh, high(2*message_init)
	rcall	LCD_putstring
	rcall	LCD_home
	ret
	
;===============================================
; print message on LCD
; in: z
LCD_putstring:
	lpm				;load program memory into r0
	tst	r0			;test for end
	breq	done
	mov	a0,r0		;load argument
	rcall	LCD_putc
	adiw	zl,1
	rjmp	LCD_putstring
done:	ret
	
;===============================================
; list of messages to be printed on the LCD

message_init:
.db	"RUNNING MODE ",0
.db	"WAKING UP    ",0
.db	"IDLE MODE    ",0
.db	"PWR DWN MODE ",0
.db	"PWR SAVE MODE  ",0
;.db	"RUNNING MODE ",0,"WAKING UP    ",0,"IDLE MODE    ",0,"PWR DWN MODE ",0,"PWR SAVE MODE  ",0

;===============================================
; enter sleep mode: idle
sleep_idle:
	in	r27,MCUCR
	ori	r27,(0<<SM0)+(0<<SM1)
	out	MCUCR,r27 
	
	clr	r28				; reset semaphore
	
	ldi	r26,28			; select message
	rcall	message_p
	WAIT_MS	500
	
	in	r27,MCUCR
	ori	r27,(1<<SE)		; enable sleep mode
	out	MCUCR, r27
	OUTI	TCNT0,0
	
	sleep
	
	in	r27,MCUCR
	andi	r27,~(1<<SE); disable sleep mode
	out	MCUCR, r27
	
	clr	r26
	rcall	message_p
	ret
	
;===============================================
; enter sleep mode: power-down
sleep_pwdn:
	in	r27,MCUCR
	cbr	r27,(0<<SM0)
	sbr	r27,(1<<SM1)
	out	MCUCR,r27 
	
	clr	r28				; reset semaphore
	
	ldi	r26,42			; select message
	rcall	message_p
	WAIT_MS	500
	
	in	r27,MCUCR
	sbr	r27,(1<<SE)		; enable sleep mode
	out	MCUCR, r27
	OUTI	TCNT0,1
	
	sleep
	
	in	r27,MCUCR
	andi	r27,~(1<<SE); disable sleep mode
	out	MCUCR, r27
	
	clr	r26
	rcall	message_p	
	ret
	
;===============================================
; enter sleep mode: power-save
sleep_pwsv:
	in	r27,MCUCR
	sbr	r27,(1<<SM0)
	cbr	r27,(0<<SM1)
	out	MCUCR,r27 
	
	clr	r28				; reset semaphore
	
	ldi	r26,56
	rcall	message_p
	WAIT_MS	500
	
	in	r27,MCUCR
	sbr	r27,(1<<SE)		; enable sleep mode
	out	MCUCR, r27
	OUTI	TCNT0,1
	
	sleep
	
	in	r27,MCUCR
	andi	r27,~(1<<SE); disable sleep mode
	out	MCUCR, r27
	
	clr	r26
	rcall	message_p
	ret