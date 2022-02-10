; file	delay_ms.s   target ATmega128L-4MHz-STK300
; in: number of iteration, 16-bit data in R24 and R25
;     one iteration internal loop: 1us; ret: 1us; init: 0.5us
;     0xe6 = 998

#define _SFR_ASM_COMPAT 1   ; allows the use of port names and in and out instructions
#define __SFR_OFFSET 0

.global delay_ms
delay_ms: 
	ldi		r26, 0xe6
	ldi		r27, 0x03
loop01:
	subi	r26, 0x01   ; subtract 1
	sbci	r27, 0x00   ; subtract 0 with carry (word subtract operation)
	brne	loop01	
    subi    R24, 0x01   
    sbci    R25, 0x00   
    brne    delay_ms         
ret                     