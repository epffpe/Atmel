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
File    : RTOSInit_ATmega2561.c   (for ATmega256)
Purpose : Initializes and handles the hardware for embOS as far
          as required by embOS.
          Feel free to modify this file acc. to your
          target system.
--------  END-OF-HEADER  ---------------------------------------------
*/

#include "RTOS.h"

#if (((__TID__ >> 4) & 0x0F) == 5)
  #include <iom2561.h>
#else
  #error "This CPU version (selected by -v) is not supported !"
#endif

/*********************************************************************
*
*       Configuration
*
**********************************************************************

  Define clock frequency for CPU

  Select UART for embOSView, set baudrate,
  If you do not want (or can not due to hardware limitations) to dedicate
  a UART to embOSView, please define OS_UART to -1
*/

#ifndef   OS_FSYS
  #define OS_FSYS 8000000L    // System frequency [Hz]
#endif

#ifndef   OS_UART
  #define OS_UART 1
#endif
#ifndef   OS_BAUDRATE
  #define OS_BAUDRATE 19200L
#endif

/****** End of configuration settings *******************************/

/*********************************************************************
*
*       Local functions
*
**********************************************************************
*/
static int _ReadHWTimer(void) {
  OS_U16 r;

  r = TCNT3L;
  asm ("nop");
  return r | (TCNT3H << 8);
}

/*********************************************************************
*
*       Global functions
*
**********************************************************************
*/

/*********************************************************************
*
*       OS_InitHW()
*
*       Initialize the hardware (timer) required for embOS to run.
*       May be modified, if an other timer should be used
*/
void OS_InitHW(void) {
  TCCR3A_COM3A1 = 0;    // 0: No output
  TCCR3A_COM3A0 = 0;    // 0: No output
  TCCR3A_WGM31  = 0;    // 0: No PWM
  TCCR3A_WGM30  = 0;    // 0: No PWM

  TCCR3B_ICNC3 = 0;     // 0: Disable noise canceler
  TCCR3B_ICES3 = 0;     // 0: capturee edge
  TCCR3B_ICNC3 = 0;     // 0: Disable noise canceler
  TCCR3B_WGM32 = 1;     // 1: Reset on compare match
  TCCR3B_CS32  = 0;     // Clock-Source: 001 = CK/1 no prescaler
  TCCR3B_CS31  = 0;     // Clock-Source: 010 = CK/8
  TCCR3B_CS30  = 1;     // Clock-Source: 001 = CK/1

  OCR3A = (OS_FSYS/1000); // generate 1ms interrupts
  TIMSK3_OCIE3A = 1;      // Output CompareA Match Interrupt Enable
  OS_COM_Init();          // Initialize communication to embOSView
}

/*********************************************************************
*
*       Idle loop  (OS_Idle)
*
*       Please note:
*       This is basically the "core" of the idle loop.
*       This core loop can be changed, but:
*       The idle loop does not have a stack of its own, therefore no
*       functionality should be implemented that relies on the stack
*       to be preserved. However, a simple program loop can be programmed
*       (like toggeling an output or incrementing a counter)
*/
void OS_Idle(void) {  // Idle loop: No task is ready to exec
  for (;;);           // Nothing to do ... wait for an interrupt
}

/*********************************************************************
*
*       OS_GetTime_Cycles()
*
*       This routine is required for task-info via embOSView or high
*       resolution time maesurement functions.
*       It returns the system time in timer clock cycles.
*/
OS_U32 OS_GetTime_Cycles(void) {
  unsigned int t_cnt;
  OS_U32 time;

  t_cnt = _ReadHWTimer();
  time = OS_Time;
  if (TIFR3_OCF3A) {  // Check if timer interrupt pending ...
    t_cnt = _ReadHWTimer();
    time++;
  }
  return (OS_FSYS/1000)*time  + t_cnt;
}

/*********************************************************************
*
*       OS_ConvertCycles2us()
*
*       Convert Cycles into micro seconds.
*
*       If your clock frequency is not a multiple of 1 MHz,
*       you may have to modify this routine in order to get proper
*       diagonstics.
*
*       This routine is required for profiling or high resolution time
*       measurement only. It does not affect operation of the OS.
*/
OS_U32 OS_ConvertCycles2us(OS_U32 Cycles) {
  return Cycles/(OS_FSYS/1000000);
}

/*********************************************************************
*
*       OS_ISR_Tick_Handler()
*       The embOS timer tick interrupt Handler
*/
void OS_ISR_Tick_Handler(void);
void OS_ISR_Tick_Handler(void) {
  OS_TICK_Handle();
}

/*********************************************************************
*
*       OS_ISR_Tick()
*       The embOS timer tick interrupt routine
*/
#pragma vector = TIMER3_COMPA_vect
__interrupt void OS_ISR_Tick (void);
#pragma vector = TIMER3_COMPA_vect
__interrupt void OS_ISR_Tick (void) {
  OS_CallISR(OS_ISR_Tick_Handler);
}

/*********************************************************************
*
*       Communication for embOSView (UART 1), optional
*
**********************************************************************
*/

#if (OS_UART == 1)

#define BAUDDIVIDE ((OS_FSYS+OS_BAUDRATE*8L)/(OS_BAUDRATE*16L)-1)

/*********************************************************************
*
*       OS_COM_Init()
*       Initialize UART for embOSView
*/
void OS_COM_Init(void) {
  UBRR1H = BAUDDIVIDE >> 8;
  UBRR1L = BAUDDIVIDE;

  UCSR1B_TXB81   = 0; // X
  UCSR1B_RXB81   = 0; // X
  UCSR1B_UCSZ12  = 0; // CHR9: 9-bit Characters
  UCSR1B_TXEN1   = 1; // TXEN: Transmitter Enable
  UCSR1B_RXEN1   = 1; // RXEN: Receiver Enable
  UCSR1B_UDRIE1  = 0; // UDRIE: UART Data Register Empty Interrupt Enable
  UCSR1B_TXCIE1  = 0; // TXCIE Tx complete interrupt enable
  UCSR1B_RXCIE1  = 0; // RXCIE Rx complete interrupt enable

  UCSR1B_TXB81   = 0; // X
  UCSR1B_RXB81   = 0; // X
  UCSR1B_UCSZ12  = 0; // CHR9: 9-bit Characters
  UCSR1B_TXEN1   = 1; // TXEN: Transmitter Enable
  UCSR1B_RXEN1   = 1; // RXEN: Receiver Enable
  UCSR1B_UDRIE1  = 1; // UDRIE: UART Data Register Empty Interrupt Enable
  UCSR1B_TXCIE1  = 0; // TXCIE Tx complete interrupt enable
  UCSR1B_RXCIE1  = 1; // RXCIE Rx complete interrupt enable

}

/*********************************************************************
*
*       OS_COM_Send1()
*       Never call this function directly from your application
*/

void OS_COM_Send1(unsigned char c) {
  UDR1 =c;
  UCSR1B_UDRIE1  = 1; // Generate interrupt on transmit buffer emtpy
}

/*********************************************************************
*
*       OS_ISR_rx_Handler()
*       embOS UART rx interrupt handler
*/
void OS_ISR_rx_Handler(void);
void OS_ISR_rx_Handler(void) {
  UCSR1B_RXCIE1  = 0;     // Avoid nesting itself !!!
  OS_OnRx(UDR1);
  OS_DI();                // Disable before allowing Rx interrupt
  UCSR1B_RXCIE1  = 1;
}

/*********************************************************************
*
*       OS_ISR_rx()
*       embOS UART rx interrupt routine
*/
#pragma vector = USART1_RX_vect
__interrupt void OS_ISR_rx(void);
#pragma vector = USART1_RX_vect
__interrupt void OS_ISR_rx(void) {
  OS_CallISR(OS_ISR_rx_Handler);
}

/*********************************************************************
*
*       OS_ISR_tx_Handler()
*       embOS UART tx interrupt handler
*/
void OS_ISR_tx_Handler(void);
void OS_ISR_tx_Handler(void) {
  UCSR1B_UDRIE1  = 0;    // Do not generate any more interrupts
  if (OS_OnTx() == 0) {
    OS_DI();             // Disable before allowing Tx interrupt
    UCSR1B_UDRIE1  = 1;  // Re-enable Tx interrupts
  }
}

/*********************************************************************
*
*       OS_ISR_tx()
*       embOS UART tx interrupt routine
*/
#pragma vector = USART1_UDRE_vect
__interrupt void OS_ISR_tx(void);
#pragma vector = USART1_UDRE_vect
__interrupt void OS_ISR_tx(void) {
  OS_CallISR(OS_ISR_tx_Handler);
}

#else  /* No communication routines, just dummies  */
  void OS_COM_Init(void) {}
  void OS_COM_Send1(OS_U8 c) {
    OS_COM_ClearTxActive();    /* let OS know that transmitter is not busy */
    OS_USEPARA(c);             /* Avoid compiler warning */
  }
#endif /* defined (OS_UART) */


/****** End Of File *************************************************/


