#include "funciones.h"
#include "serie.h"



/*
 *	
 */

void SistIni(void) {
	//Calibracion del oscilador RC
	// OSCCAL=0xA8; // para la placa 1
	// OSCCAL=0xA6; //Para la placa secundaria
	OSCCAL=0xA6;
	//PuertoB como salida
	DDRB=0xff;
	//PuertoD como entrada y PULLUP
	PORTD=0xff;

	//PuertoC, Motor conectado en PC1
	DDRC= (1<<PORTC1);

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

	TCCR0 = (7<<CS00);

	/*
	 * Inicializacion del timer1 como generador de interrupcion cada
	 * 300ms
	 */
 	OCR1A=2273; 		//2343.75
	TIMSK|=(1<<OCIE1A);
	TCCR1B=(1<<WGM12)|5;
	/*
	 * Inicializacion del timer2 para generar la señal PWM
	 * que controla el motor
	 */
	TCCR2= (0<<WGM20)|(7<<CS20);
	TIMSK|=(1<<OCIE2)|(1<<TOIE2);
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
 *  Si la helice es de 5 aspas entonces 200/5=40
 */
uint16_t pulsos2rpm(uint8_t pulsos) {
	//return (200 * (uint16_t)pulsos);
	return (200/5 * (uint16_t)pulsos);
}

/*
 *	
 */
ISR (TIMER1_COMPA_vect) {
	pulsos=TCNT0;
	inicia_cuenta();
	UCSRB |= (1<<UDRIE);		//Habilita la transmision serie

	RPM=pulsos2rpm(pulsos);
	utoa(RPM, s, 10);
	LCD_GotoXY(6, 1);
	LCD_enviar_msg(s);
   	LCD_enviar_msg(" rpm      ");

}

/*
 *	
 */
ISR (TIMER2_COMP_vect)
{
	PORTC &= ~(1<<PORTC1);	
}

/*
 *	
 */
ISR (TIMER2_OVF_vect)
{
	PORTC |=(1<<PORTC1);
}
