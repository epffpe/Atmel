//***************************************************************************
//
//  File........: main.c
//
//  Author(s)...: ATMEL Norway
//
//  Target(s)...: ATmega169
//
//  Compiler....: IAR EWAAVR 2.28a
//
//  Description.: AvrStudio4 LCD demo main module
//
//  Revisions...: 1.0
//
//***************************************************************************

#include <inavr.h>

#include "iom169.h"
#include "LCD_functions.h"
#include "LCD_driver.h"


/*****************************************************************************
*
*   Function name : main
*
*   Returns :       None
*
*   Parameters :    None
*
*   Purpose :       Contains the main loop of the program
*
*****************************************************************************/
__C_task void main(void)
{    
    
    LCD_Init();                 // initialize the LCD
    
    __enable_interrupt();       // enable global interrupt

    LCD_puts("LCD plugin demo",1);   // text to be displayed in the LCD

    while(1);                   // endless loop, waiting for LCD interrupts
}
