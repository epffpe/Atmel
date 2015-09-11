#include <avr/interrupt.h>
/*
#define FOSC 4000000
#define BAUD 9600
#define MYUBRR FOSC/16/BAUD-1
*/
unsigned char staterx;
unsigned char statetx;
void USART_Init(unsigned int ubrr);
char UART_recibe ( char *ptr);
