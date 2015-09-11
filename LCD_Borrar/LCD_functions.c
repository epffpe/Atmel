//*****************************************************************************
//
//  File........: LCD_functions.c
//
//  Author(s)...: ATMEL Norway
//
//  Target(s)...: ATmega169
//
//  Compiler....: IAR EWAAVR 2.28a
//
//  Description.: Additional LCD functions, scrolling text and write data
//
//  Revisions...: 1.0
//
//*****************************************************************************

//  Include files
#include "iom169.h"
#include "Lcd_driver.h"
#include "Lcd_functions.h"

#define FALSE   0
#define TRUE    (!FALSE)



// Start-up delay before scrolling a string over the LCD. "LCD_driver.c"
extern char gLCD_Start_Scroll_Timer;


/****************************************************************************
*
*	Function name : LCD_puts
*
*	Returns :		None
*
*	Parameters :	pStr: Pointer to the string
*                   scrollmode: Not in use
*
*	Purpose :		Writes a string to the LCD
*
*****************************************************************************/
void LCD_puts(char *pStr, char scrollmode)
{
    char i;

    while (gLCD_Update_Required);      // Wait for access to buffer

    for (i = 0; pStr[i] && i < TEXTBUFFER_SIZE; i++)
    {
        gTextBuffer[i] = pStr[i];
    }

    gTextBuffer[i] = '\0';

    if (i > 6)
    {
        gScrollMode = 1;        // Scroll if text is longer than display size
        gScroll = 0;
        gLCD_Start_Scroll_Timer = 3;    //Start-up delay before scrolling the text
    }
    else
    {
        gScrollMode = 0;        
        gScroll = 0;
    }

    gLCD_Update_Required = 1;
}
