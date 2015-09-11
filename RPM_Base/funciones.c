#include "funciones.h"
#include "serie.h"



/*
 *	
 */

void SistIni(void) {
	//Calibracion del oscilador RC
	OSCCAL=0x84;
	//PuertoB como salida
	DDRB=0xff;
	//PuertoD como entrada y PULLUP
	PORTD=0xff;

	/*
	 * Inicializacion del LCD
	 */
	LCD_Init();
 	LCD_Display_conf();
	LCD_GotoXY(0, 0);
   	LCD_enviar_msg("Gases:");
   	LCD_GotoXY(0, 1);
   	LCD_enviar_msg("Rev:");
	/*
	 * Inicializacion del timer0, es el que cuenta los pulsos
	 * que provienen del sensor de RPM
	 */

	TCCR0B = (7<<CS00);

	/*
	 * Inicializacion del timer1 como generador de interrupcion cada
	 * 300ms
	 */
 	OCR1A=2273; 		//2343.75
	TIMSK1=(1<<OCIE1A);
	TCCR1B=(1<<WGM12)|5;
	//set_sleep_mode(SLEEP_MODE_IDLE);
	sei();
}



/*
 *	
 */

void inicia_cuenta(void) {
	TCNT0= 0;
}

/*
 *	Si cuenta 300ms, 1/0.3=3.33
 */
uint16_t pulsos2freq(uint8_t pulsos) {
	return (3 * (uint16_t)pulsos);
}


/*
 *	Si cuenta 300ms, 60/300m=200
 */
uint16_t pulsos2rpm(uint8_t pulsos) {
	return (200 * (uint16_t)pulsos);
}

/*
 *	
 */
ISR (TIMER1_COMPA_vect) {
	pulsos=TCNT0;
	inicia_cuenta();
	UCSR0B |= (1<<UDRIE0);		//Habilita la transmision serie

	RPM=pulsos2rpm(pulsos);
	utoa(RPM, s, 10);
	LCD_GotoXY(6, 1);
	LCD_enviar_msg(s);
   	LCD_enviar_msg(" rpm      ");

}
