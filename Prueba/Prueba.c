#include <avr/io.h>
#define F_CPU 8000000UL
#define BAUD 38400
#include <util/setbaud.h>
#include <stdio.h>

static int uart_putchar(char c, FILE *stream);
static FILE mystdout = FDEV_SETUP_STREAM(uart_putchar, NULL,
							_FDEV_SETUP_WRITE);
static int uart_putchar(char c, FILE *stream)
	{
	if (c == '\n')
		uart_putchar('\r', stream);
	loop_until_bit_is_set(UCSR0A, UDRE0);
	UDR0 = c;
	return 0;
	}

static void uart_9600(void)
{
	#define BAUD 9600
	#include <util/setbaud.h>
	UBRR0H = UBRRH_VALUE;
	UBRR0L = UBRRL_VALUE;
	#if USE_2X
		UCSR0A |= (1 << U2X0);
	#else
		UCSR0A &= ~(1 << U2X0);
	#endif
}
int main(void)
{
	//init_uart();
	uart_9600();
	stdout = &mystdout;
	printf("Hello, world!\n");
	return 0;
}




/*
#include <util/delay.h> /*
#define F_CPU 8000000UL

void retardoms(uint16_t millis) {

	while (millis) {
		_delay_ms(1);
		millis--;
	}
}

int main()
{

	DDRD |=1 << PD1;
	while (1) {
		PORTD &= ~(1 << PD1); //led off
		//retardoms(10);
		_delay_ms(1);
		PORTD |= (1 << PD1);
//		retardoms(15);
	}
return 0;
}

*/
