/****************************************
//***************************************
//   Autor: epf Supersonic
//   Descripcion: Funciones necesarias
//         para manejar las pantalla 
//         LCD de texto
//***************************************
*/
/*
;**********************************************************
;   LCD
;   LCD to AVR Processor connections:
;   PB7 PB6 PB5 PB4 PB3 PB2
;   D7  D6  D5  D4  E   RS

.DEF   LCD_DAT    =R17
.DEF   LCD_CMD    =R18
.DEF   LCD_POS      =R19
.EQU   LCD_DB      =PORTB
.EQU   LCD_DDR      =DDRB
.EQU   LCD_RS      =PB2
.EQU   LCD_E      =PB3


#define LCD_DB PORTB
#define LCD_CB PORTB
#define LCD_DDR DDRB
#define LCD_RS PORTB2
#define LCD_E PORTB3
*/
#include <avr/interrupt.h>
#include "LCDlib.h"
//#include <avr/io.h>
//#define F_CPU 4000000UL  // 4 MHz
    //#define F_CPU 14.7456E6
//#include <util/delay.h>



void LCD_CMD(unsigned char LCD_cmd) {
#ifdef LCD_4bit
//LCD de cuatro bits
   unsigned char temp, sreg;
   sreg=SREG;
   cli();
   LCD_DB = LCD_cmd & 0xF0;
   //LCD_CB &= ~(1<<LCD_RS);
   LCD_CB |= (1<<LCD_E);
   _delay_us(0.25);
   LCD_CB &= ~(1<<LCD_E);
   _delay_us(1);

   temp = LCD_cmd;
   temp = (temp << 4);
   LCD_DB = temp & 0xF0; //(LCD_cmd << 4) & 0xF0;
   //LCD_CB &= ~(1<<LCD_RS);
   LCD_CB |= (1<<LCD_E);
   _delay_us(0.25);
   LCD_CB &= ~(1<<LCD_E);
   
   SREG=sreg;
   _delay_us(40);
   
#else
// LCD de ocho bits
#endif
}

void LCD_DAT(unsigned char LCD_dat) {
#ifdef LCD_4bit
//LCD de cuatro bits
   unsigned char temp, sreg;
   sreg=SREG;
   cli();

   LCD_DB = (LCD_dat & 0xF0) | (1<<LCD_RS);
   //LCD_CB |= (1<<LCD_RS);
   LCD_CB |= (1<<LCD_E);
   _delay_us(0.25);
   LCD_CB &= ~(1<<LCD_E);
   _delay_us(1);

   temp = LCD_dat;
   temp = (temp << 4);
   LCD_DB = (temp & 0xF0) | (1<<LCD_RS);
   //LCD_CB |= (1<<LCD_RS);
   LCD_CB |= (1<<LCD_E);
   _delay_us(0.25);
   LCD_CB &= ~(1<<LCD_E);
   
   SREG=sreg;
   _delay_us(40);
   
#else
// LCD de ocho bits
#endif
}

void LCD_Init( void ) {
   LCD_DB = 0;
#ifdef LCD_4bit
//LCD de cuatro bits
   _delay_ms(15);
   LCD_DB = 0x30 | (1<<LCD_E);
   _delay_us(0.25);
   LCD_DB = 0x30 & ~(1<<LCD_E);
   _delay_ms(4.1);
   LCD_DB = 0x30 | (1<<LCD_E);
   _delay_us(0.25);
   LCD_DB = 0x30 & ~(1<<LCD_E);
   _delay_us(100);
   LCD_DB = 0x30 | (1<<LCD_E);
   _delay_us(0.25);
   LCD_DB = 0x30 & ~(1<<LCD_E);
   _delay_us(40);
   LCD_DB = 0x20 | (1<<LCD_E);
   _delay_us(0.25);
   LCD_DB = 0x20 & ~(1<<LCD_E);
   _delay_us(40);
#else
// LCD de ocho bits
#endif
}

void LCD_Display_conf( void) {
   // Function set command 0x28
   LCD_CMD(0x28);
   // Entry Mode Set command, 0x06
   LCD_CMD(0x06);
   // Display On/Off command, 0x0C,
   LCD_CMD(0x0c);
   // Clear Display command, 0x01 y 1.64ms
   LCD_CMD(0x01);
   _delay_ms(1.64);
}

void LCD_enviar_msg(char *msg) {
   while(*msg) LCD_DAT(*msg++);
}

void LCD_GotoXY(uint8_t x, uint8_t y) {   //Mueve el cursor a la posicion X Y

   register uint8_t DDRAMAddr;
   // Mapea en la direccion real
   switch(y)
   {
   case 0: DDRAMAddr = LCD_LINE0_DDRAMADDR+x; break;
   case 1: DDRAMAddr = LCD_LINE1_DDRAMADDR+x; break;
   case 2: DDRAMAddr = LCD_LINE2_DDRAMADDR+x; break;
   case 3: DDRAMAddr = LCD_LINE3_DDRAMADDR+x; break;
   default: DDRAMAddr = LCD_LINE0_DDRAMADDR+x;
   }
   // Envia la direccion
   LCD_CMD(1<<LCD_DDRAM | DDRAMAddr);
   
}
