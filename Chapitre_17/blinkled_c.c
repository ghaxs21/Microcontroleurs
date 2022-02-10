// file	blinkled_c.c   target ATmega128L-4MHz-STK300
// purpose oscilloscope measurements on PB1

#include <inttypes.h>
#include <avr/io.h>

volatile uint8_t i;
//volatile uint16_t i;

int main (void)
{

    DDRB = _BV(PB1); // set line output mode
	
	int	b;

	while (1) 
	{
		for (b=0;b<255;b++)
		{}
       PORTB = ~_BV(PB1); // set output to gnd, LED ON  
       for (i=0;i<255;i++)
	      {}
       PORTB = _BV(PB1);  // set output to vdd, LED OFF
       for (i=0;i<255;i++)
	      {}
	};
	
    return (0);
}