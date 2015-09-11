#include <avr/io.h>
#include <util/delay.h>
#include "lcd.h"

#define backcolor RED
int main(void) {
unsigned int fondo=0;
/***************************************************************************/
/*  Importante            */
/***************************************************************************/
	DDRD&=~(0x20);
	PORTD|=0xFF;
	DATA_OUPUT()
/***************************************************************************/
	LCD_Init();
	LCD_Clear(backcolor);
	LCD_write_english_string(20,50,"Hola irene",White,backcolor);
	LCD_write_english_string(20,150,"epf Supersonic",White,backcolor);
	while(1){

	}
}
