//*****************************************************************************
//
//  File........: LCD_driver.c
//
//  Author(s)...: ATMEL Norway
//
//  Target(s)...: ATmega169
//
//  Compiler....: IAR EWAAVR 2.28a
//
//  Description.: Functions used to control the AVR Butterfly LCD
//
//  Revisions...: 1.0
//
//*****************************************************************************


// Include files.
#include "iom169.h"
#include "LCD_driver.h"

#define FALSE   0
#define TRUE    (!FALSE)


// Used to indicate when the LCD interrupt handler should update the LCD
char gLCD_Update_Required = FALSE;

// LCD display buffer (for double buffering).
char LCD_Data[LCD_REGISTER_COUNT];

// Buffer that contains the text to be displayed
// Note: Bit 7 indicates that this character is flashing
char gTextBuffer[TEXTBUFFER_SIZE];

// Only six letters can be shown on the LCD.
// With the gScroll and gScrollMode variables,
// one can select which part of the buffer to show
signed char gScroll;
char gScrollMode;

////Start-up delay before scrolling a string over the LCD
char gLCD_Start_Scroll_Timer = 0;


// Look-up table used when converting ASCII to
// LCD display data (segment control)
__flash unsigned int LCD_character_table[] =
{
    0x0A51,     // '*' (?)
    0x2A80,     // '+'
    0x0000,     // ',' (Not defined)
    0x0A00,     // '-'
    0x0A51,     // '.' Degree sign
    0x0000,     // '/' (Not defined)
    0x5559,     // '0'
    0x0118,     // '1'
    0x1e11,     // '2
    0x1b11,     // '3
    0x0b50,     // '4
    0x1b41,     // '5
    0x1f41,     // '6
    0x0111,     // '7
    0x1f51,     // '8
    0x1b51,     // '9'
    0x0000,     // ':' (Not defined)
    0x0000,     // ';' (Not defined)
    0x0000,     // '<' (Not defined)
    0x0000,     // '=' (Not defined)
    0x0000,     // '>' (Not defined)
    0x0000,     // '?' (Not defined)
    0x0000,     // '@' (Not defined)
    0x0f51,     // 'A' (+ 'a')
    0x3991,     // 'B' (+ 'b')
    0x1441,     // 'C' (+ 'c')
    0x3191,     // 'D' (+ 'd')
    0x1e41,     // 'E' (+ 'e')
    0x0e41,     // 'F' (+ 'f')
    0x1d41,     // 'G' (+ 'g')
    0x0f50,     // 'H' (+ 'h')
    0x2080,     // 'I' (+ 'i')
    0x1510,     // 'J' (+ 'j')
    0x8648,     // 'K' (+ 'k')
    0x1440,     // 'L' (+ 'l')
    0x0578,     // 'M' (+ 'm')
    0x8570,     // 'N' (+ 'n')
    0x1551,     // 'O' (+ 'o')
    0x0e51,     // 'P' (+ 'p')
    0x9551,     // 'Q' (+ 'q')
    0x8e51,     // 'R' (+ 'r')
    0x9021,     // 'S' (+ 's')
    0x2081,     // 'T' (+ 't')
    0x1550,     // 'U' (+ 'u')
    0x4448,     // 'V' (+ 'v')
    0xc550,     // 'W' (+ 'w')
    0xc028,     // 'X' (+ 'x')
    0x2028,     // 'Y' (+ 'y')
    0x5009,     // 'Z' (+ 'z')
    0x0000,     // '[' (Not defined)
    0x0000,     // '\' (Not defined)
    0x0000,     // ']' (Not defined)
    0x0000,     // '^' (Not defined)
    0x0000      // '_'
};


/*****************************************************************************
*
*   Function name : LCD_Init
*
*   Returns :       None
*
*   Parameters :    None
*
*   Purpose :       Initialize LCD_displayData buffer.
*                   Set up the LCD (timing, contrast, etc.)
*
*****************************************************************************/
void LCD_Init (void)
{

    LCD_CONTRAST_LEVEL(LCD_INITIAL_CONTRAST);    //Set the LCD contrast level

    // Select asynchronous clock source, enable all COM pins and enable all
    // segment pins.
    LCDCRB = (3<<LCDMUX0) | (7<<LCDPM0);

    // Set LCD prescaler to give a framerate of 32,0 Hz
    LCDFRR = (2<<LCDPS0) | (0<<LCDCD0);    

    LCDCRA = (1<<LCDEN) | (1<<LCDAB);           // Enable LCD and set low power waveform

    //Enable LCD start of frame interrupt
    LCDCRA |= (1<<LCDIE);

    gLCD_Update_Required = FALSE;
}




/*****************************************************************************
*
*   Function name : LCD_WriteDigit(char c, char digit)
*
*   Returns :       None
*
*   Parameters :    Inputs
*                   c: The symbol to be displayed in a LCD digit
*                   digit: In which digit (0-5) the symbol should be displayed
*                   Note: Digit 0 is the first used digit on the LCD,
*                   i.e LCD digit 2
*
*   Purpose :       Stores LCD control data in the LCD_displayData buffer.
*                   (The LCD_displayData is latched in the LCD_SOF interrupt.)
*
*****************************************************************************/
void LCD_WriteDigit(char c, char digit)
{

    unsigned int seg = 0x0000;                  // Holds the segment pattern
    char mask, nibble;
    char *ptr;
    char i;


    if (digit > 5)                              // Skip if digit is illegal
        return;

    //Lookup character table for segmet data
    if ((c >= '*') && (c <= 'z'))
    {
        // c is a letter
        if (c >= 'a')                           // Convert to upper case
            c &= ~0x20;                         // if necessarry

        c -= '*';

        seg = LCD_character_table[c];
    }

    // Adjust mask according to LCD segment mapping
    if (digit & 0x01)
        mask = 0x0F;                // Digit 1, 3, 5
    else
        mask = 0xF0;                // Digit 0, 2, 4

    ptr = LCD_Data + (digit >> 1);  // digit = {0,0,1,1,2,2}

    for (i = 0; i < 4; i++)
    {
        nibble = seg & 0x000F;
        seg >>= 4;
        if (digit & 0x01)
            nibble <<= 4;
        *ptr = (*ptr & mask) | nibble;
        ptr += 5;
    }
}


/*****************************************************************************
*
*   LCD Interrupt Routine
*
*   Returns :       None
*
*   Parameters :    None
*
*   Purpose: Latch the LCD_displayData and Set LCD_status.updateComplete
*
*****************************************************************************/
#pragma vector = LCD_SOF_vect
__interrupt void LCD_SOF_interrupt(void)
{
    static char LCD_timer = LCD_TIMER_SEED;
    char c;
    char c_flash;
    char flash;

    char EOL;
    unsigned char i;


    LCD_timer--;                    // Decreased every LCD frame

    if (gScrollMode)
    {
        // If we are in scroll mode, and the timer has expired,
        // we will update the LCD
        if (LCD_timer == 0)
        {
            if (gLCD_Start_Scroll_Timer == 0)
            {
                gLCD_Update_Required = TRUE;
            }
            else
                gLCD_Start_Scroll_Timer--;
        }
    }
    else    
    {   // if not scrolling,
        // disble LCD start of frame interrupt
        gScroll = 0;
    }


    EOL = FALSE;
    if (gLCD_Update_Required == TRUE)
    {
        // Repeat for the six LCD characters
        for (i = 0; i < 6; i++)
        {
            if ((gScroll+i) >= 0 && (!EOL))
            {
                // We have some visible characters
                c = gTextBuffer[i + gScroll];
                c_flash = c & 0x80 ? 1 : 0;
                c = c & 0x7F;

                if (c == '\0')
                    EOL = i+1;      // End of character data
            }
            else
                c = ' ';

            // Check if this character is flashing

            if (c_flash && flash)
                LCD_WriteDigit(' ', i);
            else
                LCD_WriteDigit(c, i);
        }

        // Copy the segment buffer to the real segments
        for (i = 0; i < LCD_REGISTER_COUNT; i++)
            *(pLCDREG + i) = *(LCD_Data+i);


        // If the text scrolled off the display,
        // we have to start over again.
        if (EOL == 1)
            gScroll = -6;
        else
            gScroll++;

        // No need to update anymore
        gLCD_Update_Required = FALSE;
    }


    // LCD_timer is used when scrolling text
    if (LCD_timer == 0)
    {
/*        if ((gScroll <= 0) || EOL)
            LCD_timer = LCD_TIMER_SEED/2;
        else*/
            LCD_timer = LCD_TIMER_SEED;
    }
}
