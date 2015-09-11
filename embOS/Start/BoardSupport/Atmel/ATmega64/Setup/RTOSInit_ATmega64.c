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
File    : RTOSInit.c   (for ATmega64)
Purpose : Initializes and handles the hardware for embOS as far
          as required by embOS.
          Feel free to modify this file acc. to your
          target system.
--------  END-OF-HEADER  ---------------------------------------------
*/

#include "RTOS.h"

#if (((__TID__ >> 4) & 0x0F) == 1)
  #include "IO8535.H"
#elif (((__TID__ >> 4) & 0x0F) == 3)
  #include "IOM64.H"
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
  #define OS_FSYS 4000000L    // System frequency [Hz]
#endif

#ifndef   OS_UART
  #define OS_UART 0
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
  OS_U16 r = TCNT1L;
  asm ("nop");
  return r | (TCNT1H << 8);
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
  TCCR1A = (0<<6)       // 0: No output
          |(0<<4)       // 0: No output
          |(0<<0);      // No PWM
  TCCR1B = (1<<7)       // 0: Disable noise canceler
          |(0<<6)       // X: Capture edge
          |(1<<3)       // 1: Reset on compare match
          |(1<<0);      // 1: clock source CK/1
  OCR1A = (OS_FSYS/1000)-1;         // generate 1ms interrupts
  TIMSK |= (1<<4);      // Output CompareA Match Interrupt Enable
  OS_COM_Init();        // Initialize communication to embOS Viewer
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
  unsigned int t_cnt = _ReadHWTimer();
  OS_U32 time = OS_Time;
  if (TIFR & (1 << 4)) {  // Check if timer interrupt pending ...
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
*       OS_ISR_Tick()
*       The embOS timer tick interrupt Handler
*/
void OS_ISR_Tick_Handler(void);
void OS_ISR_Tick_Handler(void) {
  OS_TICK_Handle();
}

/*********************************************************************
*
*       OS_ISR_Tick()
*       The embOS timer tick interrupt Handler
*/
#pragma vector = TIMER1_COMPA_vect
__interrupt void OS_ISR_Tick (void);
#pragma vector = TIMER1_COMPA_vect
__interrupt void OS_ISR_Tick (void) {
  OS_CallISR(OS_ISR_Tick_Handler);
}

/*********************************************************************
*
*       Communication for embOSView (UART 0), optional
*
**********************************************************************
*/

#if (OS_UART == 0)

#define BAUDDIVIDE ((OS_FSYS+OS_BAUDRATE*8L)/(OS_BAUDRATE*16L)-1)

/*********************************************************************
*
*       OS_COM_Init()
*       Initialize UART for embOSView
*/
void OS_COM_Init(void) {
  UBRR0H = BAUDDIVIDE >> 8;
  UBRR0L = BAUDDIVIDE;
  UCSR0B =  (0<<0)   // X
        |(0<<1)      // X
        |(0<<2)      // CHR9: 9-bit Characters
        |(1<<3)      // TXEN: Transmitter Enable
        |(1<<4)      // RXEN: Receiver Enable
        |(0<<5)      // UDRIE: UART Data Register Empty Interrupt Enable
        |(0<<6)      // TXCIE Tx complete interrupt enable
        |(0<<7);     // RXCIE Rx complete interrupt enable
  UCSR0B =  (0<<0)   // X
        |(0<<1)      // X
        |(0<<2)      // CHR9: 9-bit Characters
        |(1<<3)      // TXEN: Transmitter Enable
        |(1<<4)      // RXEN: Receiver Enable
        |(1<<5)      // UDRIE: UART Data Register Empty Interrupt Enable
        |(0<<6)      // TXCIE Tx complete interrupt enable
        |(1<<7);     // RXCIE Rx complete interrupt enable
}

/*********************************************************************
*
*       OS_COM_Send1()
*       Never call this function directly from your application
*/
void OS_COM_Send1(unsigned char c) {
  UDR0    = c;
  UCSR0B |= (1 << 5);  // Generate interrupt on transmit buffer emtpy
}

/*********************************************************************
*
*       OS_ISR_rx_Handler()
*       embOS UART rx interrupt handler
*/
void OS_ISR_rx_Handler(void);
void OS_ISR_rx_Handler(void) {
  UCSR0B &=  ~(1 << 7);     // Avoid nesting itself !!!
  OS_OnRx(UDR0);
  OS_DI();                // Disable before allowing Rx interrupt
  UCSR0B |=  (1 << 7);
}

/*********************************************************************
*
*       OS_ISR_rx()
*       embOS UART rx interrupt handler
*/
#pragma vector = USART0_RXC_vect
__interrupt void OS_ISR_rx(void);
#pragma vector = USART0_RXC_vect
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
  UCSR0B &=  ~(1<<5);    // Do not generate any more interrupts
  if (OS_OnTx() == 0) {
    OS_DI();             // Disable before allowing Tx interrupt
    UCSR0B |=  (1<<5);   // Re-enable Tx interrupts
  }
}

/*********************************************************************
*
*       OS_ISR_tx()
*       embOS UART tx interrupt handler
*/
#pragma vector = USART0_UDRE_vect
__interrupt void OS_ISR_tx(void);
#pragma vector = USART0_UDRE_vect
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

/*****  End Of File  ************************************************/
