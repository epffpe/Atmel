#include <avr/io.h>
#include <util/delay.h>
#include "LCDlib.h"
#define FOSC 8000000

int main(){
	OSCCAL=0x84;
	//PuertoB como salida
	DDRB=0xff;
	//PuertoD como entrada y PULLUP
	LCD_Init();
	LCD_Display_conf();
	LCD_GotoXY(0,0);
	LCD_enviar_msg("Prueba de texto en movimiento");
	LCD_GotoXY(0,1);
	//LCD_enviar_msg("jaja, Pringaooo!!!");
	_delay_ms(300);
	LCD_CMD(0x08);
	_delay_ms(500);
	LCD_CMD(0b00001100);
	_delay_ms(500);
	while(1){
		for (int i=0;i<16;i++) {
			LCD_CMD(0x18);
			_delay_ms(250);
		}
	
/*
		for (int i=0;i<16;i++) {
			LCD_CMD(0x1C);
			_delay_ms(300);
		}
*/	}
return 0;
}
