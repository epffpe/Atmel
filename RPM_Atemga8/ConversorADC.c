#include "ConversorADC.h"

void ADCinit( void ) {
	// Activo ADC, Autotrigrer, ADCinterrupcion y divisor por 128
	ADCSRA=(1<<ADEN)|(1<<ADFR)|(1<<ADIE)|(7<<ADPS0);
	// 
	//ADCSRB=(0<<ADTS0);
	// Entrada Temperatura,Referencia de voltage 1.1V
	ADMUX=(1<<REFS0)|(1<<ADLAR)|(0x0<<MUX0);		
}

char leer8ADC( void ) {
	return ADCH;
}

int leerADC ( void ) {
	char temp;
	temp = ADCL;
	return ((ADCH<<8)| temp);
}

ISR(SIG_ADC) {
	gases=leer8ADC();
	T=(int)gases;
	T*=100;
	T/=255;
	utoa(T, s, 10);
	LCD_GotoXY(12, 0);
	LCD_enviar_msg(s);
	LCD_enviar_msg("%  ");
}
