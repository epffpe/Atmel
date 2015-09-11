/*********************************************************************
*               SEGGER MICROCONTROLLER GmbH & Co KG                  *
*       Solutions for real time microcontroller applications         *
**********************************************************************
*                                                                    *
*       (c) 1995 - 2011  SEGGER Microcontroller GmbH & Co KG         *
*                                                                    *
*       www.segger.com     Support: support@segger.com               *
*                                                                    *
**********************************************************************
*                                                                    *
*       embOS * Real time operating system for microcontrollers      *
*                                                                    *
*                                                                    *
*       Please note:                                                 *
*                                                                    *
*       Knowledge of this file may under no circumstances            *
*       be used to write a similar product or a real-time            *
*       operating system for in-house use.                           *
*                                                                    *
*       Thank you for your fairness !                                *
*                                                                    *
**********************************************************************
*                                                                    *
*       OS version: 3.84                                             *
*                                                                    *
**********************************************************************

----------------------------------------------------------------------
File    : BSP.c
Purpose : BSP for Olimex AVRPX128A1 eval board
--------  END-OF-HEADER  ---------------------------------------------
*/

#include "BSP.h"

/*********************************************************************
*
*       Defines
*
**********************************************************************
*/
#define PORTB_BASE_ADDR   (0x620)
#define PORTB_DIRSET      (*(volatile unsigned char*)  (PORTB_BASE_ADDR + 0x01))
#define PORTB_OUTSET      (*(volatile unsigned char*)  (PORTB_BASE_ADDR + 0x05))
#define PORTB_OUTCLR      (*(volatile unsigned char*)  (PORTB_BASE_ADDR + 0x06))
#define PORTB_OUTTGL      (*(volatile unsigned char*)  (PORTB_BASE_ADDR + 0x07))

#define LED_BIT_MASK      (1uL << 3) // MAT Led on Olimex AVRPX128A1 eval board

/*********************************************************************
*
*       Global functions
*
**********************************************************************
*/

/*********************************************************************
*
*       BSP_Init()
*/
void BSP_Init(void) {
  PORTB_DIRSET = LED_BIT_MASK;  // Set led port pin to output
  PORTB_OUTSET = LED_BIT_MASK;  // Turn off led (low active)
}

/*********************************************************************
*
*       LED switching routines
*       LEDs are switched on with low level on port lines
*/
void BSP_SetLED(int Index) {
  if (Index == 0) {
    PORTB_OUTCLR = LED_BIT_MASK;
  }
}

void BSP_ClrLED(int Index) {
  if (Index == 0) {
    PORTB_OUTSET = LED_BIT_MASK;
  }
}

void BSP_ToggleLED(int Index) {
  if (Index == 0) {
    PORTB_OUTTGL = LED_BIT_MASK;
  }
}

/****** End Of File *************************************************/
