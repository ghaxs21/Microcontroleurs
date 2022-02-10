; file	bootex01.asm   target ATmega128L-4MHz-STK300
; purpose  bootloader firmware upgrade (example)
; three pieces of codes that blink a different LED are placed into the 
;>SRAM; each is rewritten by the bootloader upon pressing a different
;>button
;>in a realistic case, the origin of the code should be external

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

.dseg
.org 0x0200
case0_code: .byte	 0xff
.org 0x0400
case1_code: .byte	 0xff
.org 0x0600
case2_code: .byte	 0xff

.cseg
; no interrupts in this code version
.org 0

reset:
	LDSP	RAMEND
	OUTI	DDRB, 0xFF		; portB = output	
	rcall	loadp

main:
	INVP	PORTB,0
	sbis	PIND,0
	rjmp	case0
	sbis	PIND,1
	rjmp	case1
	sbis	PIND,2
	rjmp	case2	
	WAIT_MS	200
	rjmp main

case0:
	;INVP	PORTB,0
	ldi		yl, low(case0_code)
	ldi		yh, high(case0_code)
	ldi		zl, low(0)
	ldi		zh, high(0)
	call	Write_page
	rjmp	reset
case1:
	;INVP	PORTB,1
	ldi		yl, low(case1_code)
	ldi		yh, high(case1_code)
	ldi		zl, low(0)
	ldi		zh, high(0)
	call	Write_page
	rjmp	reset	
case2:
	;INVP	PORTB,2
	ldi		yl, low(case2_code)
	ldi		yh, high(case2_code)
	ldi		zl, low(0)
	ldi		zh, high(0)
	call	Write_page
	rjmp	reset

; loading code from the Flash into the SRAM that emulates a (three) new
;>firmware block that can further be selected for writing intot the Flash
loadp:
	ldi		xl, low(case0_code)
	ldi		xh, high(case0_code)
	ldi		zl, low(2*case0_code_temp)
	ldi		zh, high(2*case0_code_temp)
	clr		r2
 loop01:
	lpm
	INC2	zh,zl
	st		x+, r0
	dec		r2
	brne	loop01

	ldi		xl, low(case1_code)
	ldi		xh, high(case1_code)
	ldi		zl, low(2*case1_code_temp)
	ldi		zh, high(2*case1_code_temp)
	clr		r2
 loop02:
	lpm
	INC2	zh,zl
	st		x+, r0
	dec		r2
	brne	loop02
	
	ldi		xl, low(case2_code)
	ldi		xh, high(case2_code)
	ldi		zl, low(2*case2_code_temp)
	ldi		zh, high(2*case2_code_temp)
	clr		r2
 loop03:
	lpm
	INC2	zh,zl
	st		x+, r0
	dec		r2
	brne	loop03

	ret

; Following is the new code that is written into the Flash upon
;>pressing PD0,PD1,PD2
;>the code actually consists of the initial code section of this program
;>enclosing a modification of the LED that blinks; only three codes are
;>different and appear on the first three lines; these codes are the
;>assembly of INVP	PORTB,0, INVP	PORTB,1 and INVP	PORTB,2  respectively
.org 0x200
case0_code_temp: .db 0x0f, 0xef, 0x0d, 0xbf, 0x00, 0xe1, 0x0e, 0xbf, \
0x0f, 0xef, 0x07, 0xbb, 0x34, 0xd0, 0xc0, 0x9b, \
0x02, 0xc0, 0xc0, 0x98, 0x01, 0xc0, 0xc0, 0x9a, \
0x80, 0x9b, 0x18, 0xc0, 0x81, 0x9b, 0x1d, 0xc0, \
0x82, 0x9b, 0x22, 0xc0, 0x08, 0xec, 0x30, 0x2e, \
0x01, 0xe0, 0x0f, 0x93, 0x3f, 0x92, 0x00, 0xe3, \
0x30, 0x2e, 0x06, 0xe0, 0x3a, 0x94, 0xf1, 0xf7, \
0x3a, 0x94, 0x0a, 0x95, 0xd9, 0xf7, 0x3f, 0x90, \
0x0f, 0x91, 0x3a, 0x94, 0x91, 0xf7, 0x0a, 0x95, \
0x81, 0xf7, 0xe1, 0xcf, 0xc0, 0xe0, 0xd2, 0xe0, \
0xe0, 0xe0, 0xf0, 0xe0, 0x0e, 0x94, 0x00, 0xfe, \
0xd3, 0xcf, 0xc0, 0xe0, 0xd4, 0xe0, 0xe0, 0xe0, \
0xf0, 0xe0, 0x0e, 0x94, 0x00, 0xfe, 0xcc, 0xcf, \
0xc0, 0xe0, 0xd6, 0xe0, 0xe0, 0xe0, 0xf0, 0xe0, \
0x0e, 0x94, 0x00, 0xfe, 0xc5, 0xcf, 0xa0, 0xe0, \
0xb2, 0xe0, 0xe0, 0xe0, 0xf4, 0xe0, 0x22, 0x24, \
0xc8, 0x95, 0x0f, 0xef, 0xe0, 0x1b, 0xf0, 0x0b, \
0x0d, 0x92, 0x2a, 0x94, 0xc9, 0xf7, 0xa0, 0xe0, \
0xb4, 0xe0, 0xe0, 0xe0, 0xf8, 0xe0, 0x22, 0x24, \
0xc8, 0x95, 0x0f, 0xef, 0xe0, 0x1b, 0xf0, 0x0b, \
0x0d, 0x92, 0x2a, 0x94, 0xc9, 0xf7, 0xa0, 0xe0, \
0xb6, 0xe0, 0xe0, 0xe0, 0xfc, 0xe0, 0x22, 0x24, \
0xc8, 0x95, 0x0f, 0xef, 0xe0, 0x1b, 0xf0, 0x0b, \
0x0d, 0x92, 0x2a, 0x94, 0xc9, 0xf7, 0x08, 0x95, \
0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, \
0xff, 0xff, 0xff, 0xff, 0xff

.org 0x400
case1_code_temp: .db 0x0f, 0xef, 0x0d, 0xbf, 0x00, 0xe1, 0x0e, 0xbf, \
0x0f, 0xef, 0x07, 0xbb, 0x34, 0xd0, 0xc1, 0x9b, \
0x02, 0xc0, 0xc1, 0x98, 0x01, 0xc0, 0xc1, 0x9a, \
0x80, 0x9b, 0x18, 0xc0, 0x81, 0x9b, 0x1d, 0xc0, \
0x82, 0x9b, 0x22, 0xc0, 0x08, 0xec, 0x30, 0x2e, \
0x01, 0xe0, 0x0f, 0x93, 0x3f, 0x92, 0x00, 0xe3, \
0x30, 0x2e, 0x06, 0xe0, 0x3a, 0x94, 0xf1, 0xf7, \
0x3a, 0x94, 0x0a, 0x95, 0xd9, 0xf7, 0x3f, 0x90, \
0x0f, 0x91, 0x3a, 0x94, 0x91, 0xf7, 0x0a, 0x95, \
0x81, 0xf7, 0xe1, 0xcf, 0xc0, 0xe0, 0xd2, 0xe0, \
0xe0, 0xe0, 0xf0, 0xe0, 0x0e, 0x94, 0x00, 0xfe, \
0xd3, 0xcf, 0xc0, 0xe0, 0xd4, 0xe0, 0xe0, 0xe0, \
0xf0, 0xe0, 0x0e, 0x94, 0x00, 0xfe, 0xcc, 0xcf, \
0xc0, 0xe0, 0xd6, 0xe0, 0xe0, 0xe0, 0xf0, 0xe0, \
0x0e, 0x94, 0x00, 0xfe, 0xc5, 0xcf, 0xa0, 0xe0, \
0xb2, 0xe0, 0xe0, 0xe0, 0xf4, 0xe0, 0x22, 0x24, \
0xc8, 0x95, 0x0f, 0xef, 0xe0, 0x1b, 0xf0, 0x0b, \
0x0d, 0x92, 0x2a, 0x94, 0xc9, 0xf7, 0xa0, 0xe0, \
0xb4, 0xe0, 0xe0, 0xe0, 0xf8, 0xe0, 0x22, 0x24, \
0xc8, 0x95, 0x0f, 0xef, 0xe0, 0x1b, 0xf0, 0x0b, \
0x0d, 0x92, 0x2a, 0x94, 0xc9, 0xf7, 0xa0, 0xe0, \
0xb6, 0xe0, 0xe0, 0xe0, 0xfc, 0xe0, 0x22, 0x24, \
0xc8, 0x95, 0x0f, 0xef, 0xe0, 0x1b, 0xf0, 0x0b, \
0x0d, 0x92, 0x2a, 0x94, 0xc9, 0xf7, 0x08, 0x95, \
0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, \
0xff, 0xff, 0xff, 0xff, 0xff

.org 0x600
case2_code_temp: .db 0x0f, 0xef, 0x0d, 0xbf, 0x00, 0xe1, 0x0e, 0xbf, \
0x0f, 0xef, 0x07, 0xbb, 0x34, 0xd0, 0xc2, 0x9b, \
0x02, 0xc0, 0xc2, 0x98, 0x01, 0xc0, 0xc2, 0x9a, \
0x80, 0x9b, 0x18, 0xc0, 0x81, 0x9b, 0x1d, 0xc0, \
0x82, 0x9b, 0x22, 0xc0, 0x08, 0xec, 0x30, 0x2e, \
0x01, 0xe0, 0x0f, 0x93, 0x3f, 0x92, 0x00, 0xe3, \
0x30, 0x2e, 0x06, 0xe0, 0x3a, 0x94, 0xf1, 0xf7, \
0x3a, 0x94, 0x0a, 0x95, 0xd9, 0xf7, 0x3f, 0x90, \
0x0f, 0x91, 0x3a, 0x94, 0x91, 0xf7, 0x0a, 0x95, \
0x81, 0xf7, 0xe1, 0xcf, 0xc0, 0xe0, 0xd2, 0xe0, \
0xe0, 0xe0, 0xf0, 0xe0, 0x0e, 0x94, 0x00, 0xfe, \
0xd3, 0xcf, 0xc0, 0xe0, 0xd4, 0xe0, 0xe0, 0xe0, \
0xf0, 0xe0, 0x0e, 0x94, 0x00, 0xfe, 0xcc, 0xcf, \
0xc0, 0xe0, 0xd6, 0xe0, 0xe0, 0xe0, 0xf0, 0xe0, \
0x0e, 0x94, 0x00, 0xfe, 0xc5, 0xcf, 0xa0, 0xe0, \
0xb2, 0xe0, 0xe0, 0xe0, 0xf4, 0xe0, 0x22, 0x24, \
0xc8, 0x95, 0x0f, 0xef, 0xe0, 0x1b, 0xf0, 0x0b, \
0x0d, 0x92, 0x2a, 0x94, 0xc9, 0xf7, 0xa0, 0xe0, \
0xb4, 0xe0, 0xe0, 0xe0, 0xf8, 0xe0, 0x22, 0x24, \
0xc8, 0x95, 0x0f, 0xef, 0xe0, 0x1b, 0xf0, 0x0b, \
0x0d, 0x92, 0x2a, 0x94, 0xc9, 0xf7, 0xa0, 0xe0, \
0xb6, 0xe0, 0xe0, 0xe0, 0xfc, 0xe0, 0x22, 0x24, \
0xc8, 0x95, 0x0f, 0xef, 0xe0, 0x1b, 0xf0, 0x0b, \
0x0d, 0x92, 0x2a, 0x94, 0xc9, 0xf7, 0x08, 0x95, \
0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, \
0xff, 0xff, 0xff, 0xff, 0xff


; Following code is based on ATmega128L doc2467
;>modified: declarations, incorrect pagesize offset in write
;>basic error handling
;
;-the routine writes one page of data from RAM to Flash
; the first data location in RAM is pointed to by the Y pointer
; the first data location in Flash is pointed to by the Z-pointer
;-error handling is not included
;-the routine must be placed inside the boot space
; (at least the Do_spm sub routine). Only code inside NRWW section can
; be read during self-programming (page erase and page write).
;-registers used: r0, r1, temp1 (r16), temp2 (r17), looplo (r24),
; loophi (r25), spmcsrval (r20)
; storing and restoring of registers is not included in the routine
; register usage can be optimized at the expense of code size
;-It is assumed that either the interrupt table is moved to the Boot
; loader section or that the interrupts are disabled.
.equ PAGESIZEB = PAGESIZE*2 ; PAGESIZEB is page size in BYTES, not words
.org SMALLBOOTSTART			; 0xfe00 from m128def.inc = 1fc00 (byte addressing)

.def looplo=r24
.def loophi=r25
.def temp1=r16
.def temp2=r17
.def spmcsrval=r20

  Write_page:
    ; page erase
	ldi spmcsrval, (1<<PGERS) | (1<<SPMEN)
	call Do_spm

    ; re-enable the RWW section
	ldi spmcsrval, (1<<RWWSRE) | (1<<SPMEN)
	call Do_spm

    ; transfer data from RAM to Flash page buffer
	ldi looplo, low(PAGESIZEB)	;init loop variable
	ldi loophi, high(PAGESIZEB)	;not required for PAGESIZEB<=256
  Wrloop:
	ld r0, Y+
	ld r1, Y+
	ldi spmcsrval, (1<<SPMEN)
	call Do_spm
	adiw ZH:ZL, 2
	sbiw loophi:looplo, 2		;use subi for PAGESIZEB<=256
	brne Wrloop

   ; execute page write
	subi zl, low(PAGESIZEB)		;restore pointer
	sbci zh, high(PAGESIZEB)
	sbiw loophi:looplo, 1		;use subi for PAGESIZEB<=256
	ldi spmcsrval, (1<<PGWRT) | (1<<SPMEN)
	call Do_spm

   ; re-enable the RWW section
	ldi spmcsrval, (1<<RWWSRE) | (1<<SPMEN)
	call Do_spm

 ; read back and check, optional
	ldi looplo, low(PAGESIZEB)	;init loop variable
	ldi loophi, high(PAGESIZEB)	;not required for PAGESIZEB<=256
	subi YL, low(PAGESIZEB)		;restore pointer
	sbci YH, high(PAGESIZEB) 
 Rdloop:
	lpm r0, Z+
	ld r1, Y+
	cpse r0, r1 
	jmp Error
	sbiw loophi:looplo, 1		;use subi for PAGESIZEB<=256 
	brne Rdloop 

	; return to RWW section
	; verify that RWW section is safe to read
 Return:
	lds temp1, SPMCSR
	sbrs temp1, RWWSB		; If RWWSB is set, the RWW section is not ready yet
	ret

	; re-enable the RWW section
	ldi spmcsrval, (1<<RWWSRE) | (1<<SPMEN)
	call Do_spm
	rjmp Return

 Do_spm:
	; check for previous SPM complete
 Wait_spm:
	lds temp1, SPMCSR
	sbrc temp1, SPMEN
	rjmp Wait_spm
	; input: spmcsrval determines SPM action
	; disable interrupts if enabled, store status
	in temp2, SREG
	cli
	; check that no EEPROM write access is present
 Wait_ee:
	sbic EECR, EEWE
	rjmp Wait_ee
	; SPM timed sequence
	sts SPMCSR, spmcsrval
	spm
	; restore SREG (to enable interrupts if originally enabled)
	out SREG, temp2
	ret

 Error:
	INVP	PORTB,7
	WAIT_MS	500
	rjmp Error