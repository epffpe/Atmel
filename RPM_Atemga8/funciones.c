#include "funciones.h"




/*
 *	
 */

void SistIni(void) {
	//Calibracion del oscilador RC
	OSCCAL=0x9D;
	//PuertoB como salida
	DDRB=0xff;
	//PuertoD como entrada y PULLUP
	//DDRD = 0x02;
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


