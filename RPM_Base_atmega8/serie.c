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
	UBRRH = (unsigned char)(ubrr>>8);
	UBRRL = (unsigned char)ubrr;

	//Se habilita el envio y recepcion
	UCSRB = (1<<RXEN)|(1<<TXEN);
	//Formato: 8dato, 2stop bit paridad par
	UCSRC = (1<<URSEL)|(1<<UPM1)|(1<<USBS)|(3<<UCSZ0);

}

/*************************************************
//Transmitir un char en la USART
//Ejemplo:
//
//	USART_Transmit('a');
*/
void USART_Transmit(unsigned char data) {
	//Espera a que el buffer se vacie
	while( !(UCSRA &(1<<UDRE)) )
		;	
	//Coloca data en buffer, envia data
	UDR=data;

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
	while ( !(UCSRA & (1<<RXC)) )
		;
	//coge y devuelve el dato recibido del buffer
	return UDR;

}


/*************************************************
//Vaciar el buffer de entrada de la USART
//Ejemplo:
//
//	USART_Flush();
*/
void USART_Flush ( void ) {
unsigned char envase;
	while ( UCSRA & (1<<RXC) ) envase = UDR;

}

void UART_enviaCadena(char *msg) {
	while(*msg) USART_Transmit(*msg++);
}

char UART_recibe ( char *ptr) {
	*ptr=UDR;
	return (UCSRA & (1<<UPE));
}


ISR(USART_RXC_vect) {
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
				OCR2=recibido;
				T=(unsigned int)recibido * 100;
				T/=255;
				utoa(T, s, 10);
				//LCD_GotoXY(12, 0);
				LCD_enviar_msg(s);
				LCD_enviar_msg("%  ");

				UCSRB &= ~(1<<RXCIE);  //Fin recepcion
			
				staterx = 0;
				statetx = 0;
			default:
				staterx=0;
				break;
		}
	
}


ISR(USART_UDRE_vect) {

	switch (statetx) {
		case 0:				//Se envia e
			UDR='e';
			statetx +=1;
			break;
		case 1:				//Se envia p
			UDR='p';
			statetx +=1;
			break;
		case 2:				//Se envia f
			UDR='f';
			statetx +=1;
			break;
		case 3:				//Se envia el dato RPM
			UDR= pulsos;	//Hay que corregir
			statetx =0;
			UCSRB &= ~(1<<UDRIE);  //Fin de la transmision
			UCSRB |= (1<<RXCIE);   //habilita recepcion
			break;
		default:
			statetx= 0;
			UCSRB &= ~(1<<UDRIE);
			break;
	}
	
}
