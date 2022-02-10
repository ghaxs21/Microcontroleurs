// file main.c   target ATmega128L-4MHz-STK300
// purpose assembly call from c
// application oscillosope delay measurements on PB1

#include <avr/io.h>

void delay_ms(int);

int main(void)
{	
	DDRB = 0x02;

    while (1) 
    {
		delay_ms(100);
		PORTB ^= 0x02;
    }
}

