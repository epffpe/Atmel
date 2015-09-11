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
	//OSCCAL=0x84;
//char T;
	SistIni();
	ADCinit();
	//ADCSRA |=(1<<ADSC);

	while(1){
		//ADCSRA |=(1<<ADSC);
		sleep_mode();
		//T=leer8ADC();
		//utoa(T, s, 10);
		//LCD_GotoXY(7, 0);
		//LCD_enviar_msg(s);
		//LCD_enviar_msg("     ");
	
	}
 return 0;
}
