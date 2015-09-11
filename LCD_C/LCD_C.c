/***************************************
//***************************************
//	Autor: epf Supersonic
//	Descripcion: Programa para la asignatura
//			Interfaces Electroopticos 
//			para Comunicacion.
//		Con este programa se controla un motor DC
//		y se miden las revoluciones de las aspas 
//		a traves de un fotodetector.
//***************************************
*/
#include <avr/io.h>
#include <stdlib.h>
#include "LCD.h"
#include "serie.h"
#include "funciones.h"
#include <stdio.h>
//#define F_CPU 8000000UL
#include <util/delay.h>

#define FOSC 8000000
#define BAUD 9600
#define MYUBRR FOSC/16/BAUD-1


int main() {
unsigned char a='0';
//unsigned int i;
	SystemInit();
	
	//TIM16_WriteTCNT1( 0xF0F0);
	//i=TIM16_ReadTCNT1();
	//PORTB = 0x50;
	//PORTB &= ~(1<<PORTB1);
	//USART_Init(MYUBRR);
	//USART_Transmit('a');
	//a = USART_Receive();
	//USART_Transmit(a);

	while(1){
		//USART_Flush();
	}
	return(0);
}
