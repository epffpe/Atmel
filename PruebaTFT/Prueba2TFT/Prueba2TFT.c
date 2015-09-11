#include <avr/io.h>
#include <util/delay.h>
#include "GLCD.h"
#include "lcd.h"

#define backcolor RED
int main(void) {
unsigned short fondo=0;
/***************************************************************************/
/*  Importante            */
/***************************************************************************/
	DDRD&=~(0x20);
	PORTD|=0xFF;
	DATA_OUPUT()
/***************************************************************************/
	//GLCD_Init();
	LCD_Init();
	LCD_Clear(backcolor);
	LCD_write_english_string(20,150,(unsigned char *)"epf Supersonic",WHITE,backcolor);
	//GLCD_DisplayString(2,2,(unsigned char *)"Hola mundo");

	while(1);
}
