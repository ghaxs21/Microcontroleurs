; file	uart_cb.asm			target ATmega128L-4MHz-STK300		
; purpose UART with circular buffer

.equ	baud	= 9600 ;19200
.equ	_UBRR	= clock/(16*baud)-1
.include "buffer.asm"		; include circular buffer routines

; === circular buffer memory definition ===
.dseg
.equ	tx_len	= 5			; buffer length
tx_buf:
	.byte	1				; buffer in-pointer
	.byte	1				; buffer out-pointer
	.byte	1				; number of elements in buffer
	.byte	tx_len			; buffer area

.equ	rx_len	= 8			; buffer length
rx_buf:
	.byte	1				; buffer in-pointer
	.byte	1				; buffer out-pointer
	.byte	1				; number of elements in buffer
	.byte	rx_len			; buffer area
.cseg


; === interrupt vector ===
.set	_cseg	= PC		; save current cseg address
.org	0x24
	rjmp	uart_rxc		; UART RX Complete handler
.org	0x26
	rjmp	uart_dre		; UDR Empty handler
.org	_cseg				; restore cseg address

; === interrupt routines ===
uart_rxc:
	in	_sreg,SREG			; save status register
	mov	_w,w				; save working register w
	in	_u,UDR				; read UDR register
	CB_PUSH rx_buf, rx_len, _u 		; push element into circular buf.
	
	brts	err_rxbuf_full
	mov	w,_w				; restore working register w
	out	SREG,_sreg			; restore status register	
	reti

err_rxbuf_full:
	P0	LED,0				; turn on LED 0
	mov	w,_w				; restore working register w
	out	SREG,_sreg			; restore status register	
	reti

uart_dre:
	in	_sreg,SREG			; save status register
	mov	_w,w				; save working register w
		
	CB_POP  tx_buf, tx_len, _u 		; pop element from circular buf.
	brts	buf_empty
	out	UDR,_u				; load UART Data Register
	mov	w,_w				; restore working register w
	out	SREG,_sreg			; restore status register	
	reti


buf_empty:
	cbi	UCR,UDRIE			; disable UDRE interrupt
	mov	w,_w				; restore working register w
	out	SREG,_sreg			; restore status register	
	reti

; === routines ===
UART_init:
	OUTI	UBRR, _UBRR		; set Baud rate
	sbi	UCR,TXEN			; Transmitter Enable
	sbi	UCR,RXEN			; UART Receive Enable
	sbi	UCR,RXCIE			; enable RXCIE interrupt
	CB_INIT tx_buf			; initialize circular buffer tx
	CB_INIT rx_buf 			; initialize circular buffer rx
	sei						; enable global interrupts
	ret

UART:		
UART_putc:
	JP0	USR,UDRE,_buf		; if UDR not empty, then buffer it
	out	UDR,a0				; place c into UDR and return
	ret
_buf:
	cli
	CB_PUSH tx_buf, tx_len, a0 		; push to circular buffer tx
	sei
	brts	err_txbuf_full	; error: tx buffer full
	sbi	UCR,UDRIE			; enable UDRIE interrupt
	ret
	
err_txbuf_full:
	P0	LED,1				; turn on LED 1
	ret

UART_getc:
	cli
	CB_POP  rx_buf,rx_len,a0 		; pop from circular buffer rx
	sei
	brts	UART_getc		; wait if rx buffer empty

	mov	w,a0
	com	w
	out	LED,w

	ret