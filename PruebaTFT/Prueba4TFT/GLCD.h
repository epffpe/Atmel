/******************************************************************************/
/* GLCD.h: Graphic LCD Definiciones y funciones prototipos                    */
/******************************************************************************/
/* AUTOR: Eugenio Peñate Fariñas                                              */
/*                                                                            */
/******************************************************************************/

#include <avr/io.h>
/*------------------------------------------------------------------------------
  Codificacion de colores
  GLCD is coded:   15..11 red, 10..5 green, 4..0 blue  (unsigned short)  GLCD_R5, GLCD_G6, GLCD_B5   
  original coding: 17..12 red, 11..6 green, 5..0 blue                    ORG_R6,  ORG_G6,  ORG_B6

  ORG_R1..5 = GLCD_R0..4,  ORG_R0 = GLCD_R4
  ORG_G0..5 = GLCD_G0..5,
  ORG_B1..5 = GLCD_B0..4,  ORG_B0 = GLCD_B4
 *----------------------------------------------------------------------------*/
                            
/* GLCD RGB definicion de colores                                             */
#define Black           0x0000		/*   0,   0,   0 */
#define Navy            0x000F      /*   0,   0, 128 */
#define DarkGreen       0x03E0      /*   0, 128,   0 */
#define DarkCyan        0x03EF      /*   0, 128, 128 */
#define Maroon          0x7800      /* 128,   0,   0 */
#define Purple          0x780F      /* 128,   0, 128 */
#define Olive           0x7BE0      /* 128, 128,   0 */
#define LightGrey       0xC618      /* 192, 192, 192 */
#define DarkGrey        0x7BEF      /* 128, 128, 128 */
#define Blue            0x001F      /*   0,   0, 255 */
#define Green           0x07E0      /*   0, 255,   0 */
#define Cyan            0x07FF      /*   0, 255, 255 */
#define Red             0xF800      /* 255,   0,   0 */
#define Magenta         0xF81F      /* 255,   0, 255 */
#define Yellow          0xFFE0      /* 255, 255, 0   */
#define White           0xFFFF      /* 255, 255, 255 */


#define ID_AM         011


#define DATA_GLCD_DDR  DDRC
#define DATA_GLCD_PORT PORTC
#define DATA_GLCD_PIN  PINC

//#define GLCD_INPUT()	DATA_GLCD_DDR = 0x00;
//#define GLCD_OUPUT()	DATA_GLCD_DDR = 0xFF;

#define GLCD_CS_DDR  DDRA
#define GLCD_CS_PORT PORTA
#define GLCD_CS_PIN  PINA
#define GLCD_CS_BIT  6

#define GLCD_RS_DDR  DDRA
#define GLCD_RS_PORT PORTA
#define GLCD_RS_PIN  PINA
#define GLCD_RS_BIT  7

#define GLCD_RD_DDR  DDRB
#define GLCD_RD_PORT PORTB
#define GLCD_RD_PIN  PINB
#define GLCD_RD_BIT  2

#define GLCD_WR_DDR  DDRB
#define GLCD_WR_PORT PORTB
#define GLCD_WR_PIN  PINB
#define GLCD_WR_BIT  3

#define GLCD_RST_DDR  DDRB
#define GLCD_RST_PORT PORTB
#define GLCD_RST_PIN  PINB
#define GLCD_RST_BIT  1


#define GLCD_BL_DDR  DDRD
#define GLCD_BL_PORT PORTD
#define GLCD_BL_PIN  PIND
#define GLCD_BL_BIT  6

#define GLCD_CS_H() GLCD_CS_PORT |= 1<<GLCD_CS_BIT
#define GLCD_CS_L() GLCD_CS_PORT &= ~(1<<GLCD_CS_BIT)

#define GLCD_RS_H() GLCD_RS_PORT |= 1<<GLCD_RS_BIT
#define GLCD_RS_L() GLCD_RS_PORT &= ~(1<<GLCD_RS_BIT)

#define GLCD_WR_L() GLCD_WR_PORT |= 1<<GLCD_WR_BIT//
#define GLCD_WR_H() GLCD_WR_PORT &= ~(1<<GLCD_WR_BIT)//

#define GLCD_RD_H() GLCD_RD_PORT |= 1<<GLCD_RD_BIT
#define GLCD_RD_L() GLCD_RD_PORT &= ~(1<<GLCD_RD_BIT)

#define GLCD_RST_H() GLCD_RST_PORT |= 1<<GLCD_RST_BIT
#define GLCD_RST_L() GLCD_RST_PORT &= ~(1<<GLCD_RST_BIT)

#define GLCD_BL_H() GLCD_BL_PORT |= 1<<GLCD_BL_BIT
#define GLCD_BL_L() GLCD_BL_PORT &= ~(1<<GLCD_BL_BIT)

#define GLCD_PORT_INI(){ GLCD_BL_DDR |= 1<<GLCD_BL_BIT;\
						GLCD_CS_DDR |= 1<<GLCD_CS_BIT;\
						GLCD_RS_DDR |= 1<<GLCD_RS_BIT;\
						GLCD_WR_DDR |= 1<<GLCD_WR_BIT;\
						GLCD_RD_DDR |= 1<<GLCD_RD_BIT;\
						GLCD_RST_DDR|= 1<<GLCD_RST_BIT;\
					   }
					   
 //extern void GLCD_Init           (void);
 //extern void GLCD_WindowMax      (void);
 //extern void GLCD_PutPixel       (unsigned int x, unsigned int y);
 //extern void GLCD_SetTextColor   (unsigned short color);
 //extern void GLCD_SetBackColor   (unsigned short color);
 //extern void GLCD_Clear          (unsigned short color);
 //extern void GLCD_DrawChar       (unsigned int x, unsigned int y, unsigned short *c);
 //extern void GLCD_DisplayChar    (unsigned int ln, unsigned int col, unsigned char  c);
 //extern void GLCD_DisplayString  (unsigned int ln, unsigned int col, unsigned char *s);
 //extern void GLCD_ClearLn        (unsigned int ln);
 //extern void GLCD_Bargraph       (unsigned int x, unsigned int y, unsigned int w, unsigned int h, unsigned int val);
 //extern void GLCD_Bitmap         (unsigned int x, unsigned int y, unsigned int w, unsigned int h, unsigned char *bitmap);
 //extern void GLCD_Bmp            (unsigned int x, unsigned int y, unsigned int w, unsigned int h, unsigned char *bmp);
