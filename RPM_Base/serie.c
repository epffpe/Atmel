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
#include "funciones.h"
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
	//Formato: 8dato, 2stop bit paridad par
	UCSR0C = (1<<UPM01)|(1<<USBS0)|(3<<UCSZ00);

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

void UART_enviaCadena(char *msg) {
	while(*msg) USART_Transmit(*msg++);
}

char UART_recibe ( char *ptr) {
	*ptr=UDR0;
	return (UCSR0A & (1<<UPE0));
}


ISR(SIG_USART_RECV) {
char recibido;
unsigned int T;
	if ( UART_recibe (&recibido) ) {
		LCD_GotoXY(11, 0);
		LCD_DAT('*');

	}else {
		LCD_GotoXY(11, 0);
		LCD_DAT(' ');
	}
		switch (staterx) {
			case 0:
				if (recibido=='e') {
					staterx +=1;				
				}
				break;
			case 1:
				if (recibido=='p') {
					staterx +=1;
				}else {
					staterx=0;
				}
				break;
			case 2:
				if (recibido=='f') {
					staterx +=1;
				}else {
					staterx=0;
				}
				break;
			case 3:
				//Hay que terminar
				T=(unsigned int)recibido * 100;
				T/=255;
				utoa(T, s, 10);
				//LCD_GotoXY(12, 0);
				LCD_enviar_msg(s);
				LCD_enviar_msg("%  ");

				UCSR0B &= ~(1<<RXCIE0);  //Fin recepcion
			
				staterx = 0;
				statetx = 0;
			default:
				staterx=0;
				break;
		}
	
}


ISR(SIG_USART_DATA) {

	switch (statetx) {
		case 0:				//Se envia e
			UDR0='e';
			statetx +=1;
			break;
		case 1:				//Se envia p
			UDR0='p';
			statetx +=1;
			break;
		case 2:				//Se envia f
			UDR0='f';
			statetx +=1;
			break;
		case 3:				//Se envia el dato RPM
			UDR0= pulsos;	//Hay que corregir
			statetx =0;
			UCSR0B &= ~(1<<UDRIE0);  //Fin de la transmision
			UCSR0B |= (1<<RXCIE0);   //habilita recepcion
			break;
		default:
			statetx= 0;
			UCSR0B &= ~(1<<UDRIE0);
			break;
	}
	
}
