#include <avr/io.h>
#include <stdio.h>
//#include <math.h>
#include <avr/interrupt.h>

uint16_t multiplicaC(uint16_t a, uint16_t b);

uint16_t a=100;
uint16_t c;

ISR(TIMER0_OVF_vect){
	a=2;
	while(a) c=multiplicaC(a--, 1);
}

int main()
{

unsigned char ch[10]="hola";
unsigned char *ptr;

volatile uint16_t b=5;

ptr=ch;
*ptr='a';

TCCR0B=(1<<CS00);
TIMSK0=(1<<TOIE0);
sei();

a=atoi("15");
	while(1) {
		c=multiplicaC(a, b);
		a++;
		//printf("%s,%d",ch,c);
		
		
	}
}
