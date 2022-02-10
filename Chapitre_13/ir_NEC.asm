; file ir_NEC.asm   target ATmega128L-4MHz-STK300
; purpose IR sensor decoding NEC format

.include "macros.asm"
.include "definitions.asm"

reset:
	LDSP		RAMEND 			; load stack pointer SP
	rcall		LCD_init		; initialize LCD
	rjmp		main			; jump to main

.include "lcd.asm"				; include the LCD routines
.include "printf.asm"			; include formatted printing routines

.equ	T2 = 15532				; start timout, T2 = (14906 + (14906 * Terr2)) 
								;>with Terr2 = 4.2% observed with the oscilloscope
.equ	T1 = 1180				; bit period, T1 = (1125 + (1125 * Terr1)) with 
								;>Terr1 = 6.% observed with the oscilloscope

;.equ	T2 = 14906
;.equ	T1 = 1125

main:	CLR2	b1,b0			; clear 2-byte register
	CLR2		a1,a0
	ldi			b2,16			; load bit-counter
	WP1			PINE,IR			; Wait if Pin=1 
	WAIT_US		T2				; wait for timeout
	clc							; clearing carry
	
addr: P2C		PINE,IR			; move Pin to Carry (P2C, 4 cycles)
	ROL2		b1,b0			; roll carry into 2-byte reg (ROL2, 2 cycles)
	sbrc		b0,0			; (branch not taken, 1 cycle; taken 2 cycles)
	rjmp		rdz_a			; (rjmp, 2 cycles)
	WAIT_US		(T1 - 4.5)
	DJNZ		b2,addr			; Decrement and Jump if Not Zero (true, 2 cycles; false, 1 cycle)
	jmp			next_a			; (jmp, 3 cycles)
rdz_a:							; read a zero
	WAIT_US		(2*T1 - 5.5)
	DJNZ		b2,addr			; Decrement and Jump if Not Zero

next_a: MOV2	d1,d0, b1, b0	; store current address
	MOV2		a1,a0,b1,b0
	ldi			b2,16			; load bit-counter
	clc
	CLR2	b1,b0

data: P2C		PINE,IR			
	ROL2		b1,b0			
	sbrc		b0,0			
	rjmp		rdz_d			
	WAIT_US		(T1 - 4.5)
	DJNZ		b2,data			
	jmp			next_b			
rdz_d:							
	WAIT_US		(2*T1 - 5.5)
	DJNZ		b2,data				

next_b:
	MOV2		d3,d2,b1, b0	; store current command
 data_proc01:					; detect repeated code
	_CPI			d3, 0xff
	brne		data_proc02
	_CPI			d2, 0xff
	brne		data_proc02
	_CPI			d1, 0xff 
	brne		data_proc02
	_CPI			d0, 0xff
	brne		data_proc02 

display_repeat:
	rcall		LCD_clear
	rcall		LCD_home
	MOV4		a1,a0,b1,b0,c3,c2,c1,c0		; display the last correct code, i.e,
	PRINTF		LCD							;>not the repeated code which reads
.db	"A=",FHEX2,a," C=",FHEX2,b,0			;>address=data=0xff
	PRINTF		LCD		
.db	LF, "REPEAT",0
	rjmp		main 

data_proc02:								; detect transmission error
	com			d1
	cpse		d0, d1
	brne		display_error
	com			d3
	cpse		d2, d3
	brne		display_error

display_correct:	
	com			b0							; complement b0 (chip delivers the complement)
	com			b1
	com			a0
	com			a1
	rcall		LCD_clear
	rcall		LCD_home		
	PRINTF		LCD				
.db	"A=",FHEX2,a," C=",FHEX2,b,0
	MOV4		c3,c2,c1,c0,a1,a0,b1,b0		; storing correct code to display/use in 
	rjmp		main						;>case of repeated code condition

display_error:	
	com			b0					
	com			b1
	com			a0
	com			a1
	rcall		LCD_clear
	rcall		LCD_home		
	PRINTF		LCD				
.db	"EA=",FHEX2,a," EC=",FHEX2,b,0
	rjmp		main
