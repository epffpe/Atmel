#include <avr/io.h>

volatile uint8_t pinbits; //define poer pins

extern void InitPort(void);//init port for output

extern void sendpinbits(void);//send to port

int main()

{

	pinbits=1;//set pin 1 as output

	InitPort();//call subroutine from assembler file

	while(1)//repeat for ever

	{

	pinbits=1;//Pin High

	sendpinbits();//call subroutine from assembler file

	pinbits=0;//Pin Low

	sendpinbits();//call subroutine from assembler file

	}

}
