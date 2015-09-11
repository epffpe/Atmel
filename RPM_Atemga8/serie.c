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
#include "ConversorADC.h"
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

	//Se habilita el envio y recepcion y tamb interrupciones
	UCSRB = (1<<RXCIE)|(1<<RXEN)|(1<<TXEN);
	//Formato: 8dato, 2stop bit y paridad par
	UCSRC = (1<<UPM1)|(1<<URSEL)|(1<<USBS)|(3<<UCSZ0);

	//Estado 0
	staterx=0;
	

}
//*********************************************
//	Funcion que carga en *ptr el valor recibido
// y devuelve un 0 si no hay error y distinto de 
// de 0 si hay error
//*********************************************
char UART_recibe ( char *ptr) {
	*ptr=UDR;
	return (UCSRA & (1<<2));//UPE));
}

ISR(SIG_UART_RECV) {
char recibido;

	if(	UART_recibe(&recibido) ) {
		LCD_GotoXY(5, 1);
		LCD_DAT('*');
	}else {
		LCD_GotoXY(5, 1);
		LCD_DAT(' ');
	}	
		switch (staterx) {
			case 0:
				if (recibido=='e') {
					staterx +=1;
/*				}else {
					staterx=0;
*/				}
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
				RPM=pulsos2rpm(recibido);
				utoa(RPM, s, 10);
				//LCD_GotoXY(6, 1);
				LCD_enviar_msg(s);
   				LCD_enviar_msg(" rpm      ");
				//Activo transmision
				UCSRB |= (1<<UDRIE);
				staterx = 0;
				statetx = 0;
			default:
				staterx=0;
				break;
		}
	
}


ISR(SIG_UART_DATA) {

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
		case 3:				//Se envia el dato del ADC
			UDR= gases;	//Hay que corregir
			statetx =0;
			UCSRB &= ~(1<<UDRIE);  //Fin de la transmicion
			break;
		default:
			statetx= 0;
			UCSRB &= ~(1<<UDRIE);  //Fin de la transmicion
			break;
	}
	
}
