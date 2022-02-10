; file wait.asm   target ATmega128L-4MHz-STK300
; purpose different methods for generating delays

.include "macros.asm"; include macro definitinos

reset:	LDSP	RAMEND

main:	
	nop					; takes  1 cycle (NO OPeration)
	nop					; takes  1 cycle (NO OPeration)
	rjmp	PC+1		; takes  2 cycles, but only one instruction
	rcall	wait7		; takes  7 cycles
	rcall	wait14		; takes 14 cycles
	rcall	wait28		; takes 28 cycles

	rcall	wait8		; takes  8 cycles
	rcall	wait16		; takes 16 cycles
	rcall	wait32		; takes 32 cycles
		
	rjmp	main

; === subroutines ===
; linear progression
wait28:	rcall	wait7		; falling through, returning at final ret	
wait21:	rcall	wait7		; falling through, returning at final ret
wait14:	rcall	wait7		; falling through, returning at final ret
wait7:	ret					; 4(rcall) + 3(ret) + = 7 cycles

; geometric progression
wait64:	rcall	wait32		; falling through, returning at final ret	
wait32:	rcall	wait16		; falling through, returning at final ret
wait16:	rcall	wait8		; falling through, returning at final ret
wait8:	nop
		ret					; 4(rcall) + 1(nop) + 3(ret) + = 8 cycles
