; file	spi.asm   target ATmega128L-4MHz-STK300
; purpose generic SPI protocol

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	rcall	LCD_init		; initialize the LCD
	
	OUTI	DDRB,0x0f		; make SPI pins output
;	OUTI	SPCR,(1<<SPE)	; SPI Enable, as Slave		
	OUTI	SPCR,(1<<SPE)+(1<<MSTR); SPI Enable, as Master
	
	rjmp	main			; jump ahead to the main program
	
.include "lcd.asm"			; include the LCD routines
.include "printf.asm"		; include formatted printing

main:
	in	a0,PIND				; read switches into register a0
	com	a0					; invert to positive logic
	out	SPDR,a0				; load into SPI Data Register
	
	sbis	SPSR,SPIF		; skip if SPIF=1, (wait if SPIF=0)
	rjmp	PC-1			; loop back to previous instruction

	in	c0,SPDR				; load SPI Data Register to c0
	
	PRINTF	LCD
.db	"SPI out=",FHEX,a," in=",FHEX,c,CR,0
	
	WAIT_MS	100				; wait 100 msec
	rjmp	main
