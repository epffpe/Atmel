/******************************************************************************/
/* GLCD.h: Graphic LCD Definiciones y funciones prototipos                    */
/******************************************************************************/
/* AUTOR: Eugenio Peñate Fariñas                                              */
/*                                                                            */
/******************************************************************************/

#include<avr/io.h>


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
#define	BLACK	0x0000
#define	BLUE	0x001F
#define	RED 	0xF800
#define	GREEN 	0x07E0
#define CYAN	0x07FF
#define MAGENTA 0xF81F
#define YELLOW	0xFFE0
#define WHITE	0xFFFF

/* */

#define ID_AM         011


#define DATA_LCD_DDR  DDRC
#define DATA_LCD_PORT PORTC
#define DATA_LCD_PIN  PINC

#define DATA_INPUT()   DATA_LCD_DDR = 0x00;
#define DATA_OUPUT()   DATA_LCD_DDR = 0xFF;

#define LCD_CS_DDR  DDRA
#define LCD_CS_PORT PORTA
#define LCD_CS_PIN  PINA
#define LCD_CS_BIT  6

#define LCD_RS_DDR  DDRA
#define LCD_RS_PORT PORTA
#define LCD_RS_PIN  PINA
#define LCD_RS_BIT  7

#define LCD_RD_DDR  DDRB
#define LCD_RD_PORT PORTB
#define LCD_RD_PIN  PINB
#define LCD_RD_BIT  2

#define LCD_WR_DDR  DDRB
#define LCD_WR_PORT PORTB
#define LCD_WR_PIN  PINB
#define LCD_WR_BIT  3

#define LCD_RST_DDR  DDRB
#define LCD_RST_PORT PORTB
#define LCD_RST_PIN  PINB
#define LCD_RST_BIT  1


#define LCD_BL_DDR  DDRD
#define LCD_BL_PORT PORTD
#define LCD_BL_PIN  PIND
#define LCD_BL_BIT  6

#define LCD_CS_H() LCD_CS_PORT |= 1<<LCD_CS_BIT
#define LCD_CS_L() LCD_CS_PORT &= ~(1<<LCD_CS_BIT)

#define LCD_RS_H() LCD_RS_PORT |= 1<<LCD_RS_BIT
#define LCD_RS_L() LCD_RS_PORT &= ~(1<<LCD_RS_BIT)

#define LCD_WR_L() LCD_WR_PORT |= 1<<LCD_WR_BIT//
#define LCD_WR_H() LCD_WR_PORT &= ~(1<<LCD_WR_BIT)//

#define LCD_RD_H() LCD_RD_PORT |= 1<<LCD_RD_BIT
#define LCD_RD_L() LCD_RD_PORT &= ~(1<<LCD_RD_BIT)

#define LCD_RST_H() LCD_RST_PORT |= 1<<LCD_RST_BIT
#define LCD_RST_L() LCD_RST_PORT &= ~(1<<LCD_RST_BIT)

#define LCD_BL_H() LCD_BL_PORT |= 1<<LCD_BL_BIT
#define LCD_BL_L() LCD_BL_PORT &= ~(1<<LCD_BL_BIT)

#define LCD_PORT_INI(){ LCD_BL_DDR |= 1<<LCD_BL_BIT;\
						LCD_CS_DDR |= 1<<LCD_CS_BIT;\
						LCD_RS_DDR |= 1<<LCD_RS_BIT;\
						LCD_WR_DDR |= 1<<LCD_WR_BIT;\
						LCD_RD_DDR |= 1<<LCD_RD_BIT;\
						LCD_RST_DDR|= 1<<LCD_RST_BIT;\
					   }


void GUI_Point(unsigned int x, unsigned int y,unsigned int color) ;
void LCD_WR_REG(unsigned int index,unsigned int data);
void LCD_WR_REG16(unsigned int index);//Ð´»ý´æÆ÷ÃüÁî
void LCD_WR_DATA16(unsigned int data);//Î÷»ý´æÆ÷Êý¾Ý
void LCD_Init(void);
void LCD_Clear(unsigned int Color);
void LCD_write_english(unsigned char data,unsigned int color,unsigned int xcolor);//Ð´×Ö·û
void LCD_write_english_string(unsigned int x,unsigned int y,unsigned char *s,unsigned int color,unsigned int xcolor);//Ó¢ÎÄ×Ö·û´®ÏÔÊ¾
void LCD_SetCursor(unsigned int Xpos, unsigned int Ypos);
void Lcd_SetBox(unsigned int xStart,unsigned int yStart,unsigned int xLong,unsigned int yLong);
void Test(void);


/* Funciones para controlar el GLCD                                          */
extern void GLCD_Init           (void);
extern void GLCD_WindowMax      (void);
extern void GLCD_PutPixel       (unsigned int x, unsigned int y);
extern void GLCD_SetTextColor   (unsigned short color);
extern void GLCD_SetBackColor   (unsigned short color);
extern void GLCD_Clear          (unsigned short color);
extern void GLCD_DrawChar       (unsigned int x, unsigned int y, unsigned short *c);
extern void GLCD_DisplayChar    (unsigned int ln, unsigned int col, unsigned char  c);
extern void GLCD_DisplayString  (unsigned int ln, unsigned int col, unsigned char *s);
extern void GLCD_ClearLn        (unsigned int ln);
extern void GLCD_Bargraph       (unsigned int x, unsigned int y, unsigned int w, unsigned int h, unsigned int val);
extern void GLCD_Bitmap         (unsigned int x, unsigned int y, unsigned int w, unsigned int h, unsigned char *bitmap);
extern void GLCD_Bmp            (unsigned int x, unsigned int y, unsigned int w, unsigned int h, unsigned char *bmp);
