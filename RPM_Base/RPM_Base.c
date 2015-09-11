#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <stdint.h>
#include "LCDlib.h"
#include "serie.h"
#include "funciones.h"
#include "ConversorADC.h"

#define FOSC 8000000
#define BAUD 9600
#define MYUBRR FOSC/16/BAUD-1



int main() {

	SistIni();
	USART_Init(MYUBRR);

	while(1){

		sleep_mode();	
	}
 return 0;
} 
