/****************************************
//***************************************
//	Autor: epf Supersonic
//	Descripcion: Funciones necesarias
//			para controlar el puerto 
//			Serie en modo asincrono
//***************************************
*/


#include <avr/io.h>
#include "serie.h"
/************************************************
//*
#define FOSC 4000000
#define BAUD 9600
#define MYUBRR FOSC/16/BAUD-1
//*
*/

/*************************************************
//Inicializacion de la USART
//Ejemplo:
//	USART_Init(MYUBRR);
*/
void USART_Init(unsigned int ubrr) {
	//Se fija el baudrate
	UBRR0H = (unsigned char)(ubrr>>8);
	UBRR0L = (unsigned char)ubrr;

	//Se habilita el envio y recepcion
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);
	//Formato: 8dato, 2stop bit
	UCSR0C = (1<<USBS0)|(2<<UCSZ00)|(1<<USBS0);

}

/*************************************************
//Transmitir un char en la USART
//Ejemplo:
//
//	USART_Transmit('a');
*/
void USART_Transmit(unsigned char data) {
	//Espera a que el buffer se vacie
	while( !(UCSR0A &(1<<UDRE0)) )
		;	
	//Coloca data en buffer, envia data
	UDR0=data;

}

/*************************************************
//Transmitir un char en la USART
//Ejemplo:
//
//	unsigned char a;
//	a = USART_Receive();
*/
unsigned char USART_Receive( void ) {
	//Espera a que se reciba un dato
	while ( !(UCSR0A & (1<<RXC0)) )
		;
	//coge y devuelve el dato recibido del buffer
	return UDR0;

}

/*************************************************
//Vaciar el buffer de entrada de la USART
//Ejemplo:
//
//	USART_Flush();
*/
void USART_Flush ( void ) {
unsigned char envase;
	while ( UCSR0A & (1<<RXC0) ) envase = UDR0;

}

void UART_enviaCadena(unsigned char *msg) {
	while(*msg) USART_Transmit(*msg++);
}
