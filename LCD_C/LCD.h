//Descomentar si se usa un LCD con interfaz de 4bits
//******************************************
#define LCD_4bit
//***********************************************
#include <avr/io.h>
#include <util/delay.h>


#define LCD_DB PORTB
#define LCD_CB PORTB
#define LCD_DDR DDRB
#define LCD_RS PORTB2
#define LCD_E PORTB3


// Mapeo de la posicion del cursor DDRAM
#define LCD_DDRAM 				7
#define LCD_LINE0_DDRAMADDR      0x00
#define LCD_LINE1_DDRAMADDR      0x40
#define LCD_LINE2_DDRAMADDR      0x14
#define LCD_LINE3_DDRAMADDR      0x54

// barra progresiva
#define PROGRESSPIXELS_PER_CHAR   6


void LCD_CMD(unsigned char LCD_cmd);
void LCD_DAT(unsigned char LCD_dat);
void LCD_Init( void );
void LCD_Display_conf( void);
void LCD_enviar_msg(unsigned char *msg);
void LCD_GotoXY(uint8_t x, uint8_t y);
