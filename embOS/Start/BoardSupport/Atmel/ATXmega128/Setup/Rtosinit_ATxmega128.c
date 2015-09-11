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
File    : RTOSInit_ATxmega128.c for Atmel ATXMega128 CPU and
          Olimex AVRPX128A1 eval board with IAR compiler
Purpose : Initializes and handles the hardware for embOS as far
          as required by the OS
          Feel free to modify this file acc. to your target system.
--------  END-OF-HEADER  ---------------------------------------------
*/

#include "RTOS.h"

/*********************************************************************
*
*       Configuration
*
**********************************************************************
*/

/*********************************************************************
*
*       Clock frequency settings
*/
#ifndef   OS_FSYS                   /* Main clock frequency         */
  #define OS_FSYS 32000000uL        /* Assume 32MHz                 */
#endif

#ifndef   OS_PCLK_TIMER             /* Peripheral clock for timer   */
  #define OS_PCLK_TIMER (OS_FSYS)
#endif

#ifndef   OS_INIT_PLL
  #define OS_INIT_PLL (1)
#endif

/*********************************************************************
*
*       Configuration of communication to OSView
*/
#ifndef   OS_VIEW_ENABLE            // Global enable of communication
  #define OS_VIEW_ENABLE    (1)     // Default: on
#endif

#ifndef   OS_VIEW_USE_UART          // If set, UART will be used
  #define OS_VIEW_USE_UART  (1)     // Default: 1 => Uart is used
#endif                              // if OS_VIEW_ENABLE is on

/*********************************************************************
*
*       UART settings for OSView
*       If you do not want (or can not due to hardware limitations)
*       to dedicate a UART to OSView, please define it to be -1
*       Currently UART1 is supported and the standard
*       setup enables UART1 per default
*/
#ifndef   OS_UART
  #define OS_UART (-1)
#endif

#ifndef   OS_BAUDRATE
  #define OS_BAUDRATE (38400)
#endif

#ifndef   OS_PCLK_UART
  #define OS_PCLK_UART  (OS_FSYS)
#endif

/****** End of configurable options *********************************/

#define OS_UART_USED  ((OS_VIEW_ENABLE && (OS_VIEW_USE_UART != 0)) && ((OS_UART == 1) || (OS_UART == 2)))

#if OS_UART_USED
  #define OS_COM_INIT() OS_COM_Init()
#else
  #define OS_COM_INIT()
#endif

/*********************************************************************
*
*       Check configuration
*
**********************************************************************
*/

#ifndef   DEBUG     /* Should normally be defined as project option */
  #define DEBUG  (0)
#endif

/*********************************************************************
*
*   Sfrs used in RTOSInit
*
**********************************************************************
*/
/* Clock control register */
#define CCP                    (*(volatile OS_U8*)  (0x34))

#define CLK_BASE_ADDR          (0x40)
#define CLK_CTRL               (*(volatile OS_U8*)  (CLK_BASE_ADDR + 0x00))
#define CLK_PSCTRL             (*(volatile OS_U8*)  (CLK_BASE_ADDR + 0x01))

#define OSC_BASE_ADDR          (0x50)
#define OSC_CTRL               (*(volatile OS_U8*)  (OSC_BASE_ADDR + 0x00))
#define OSC_STATUS             (*(volatile OS_U8*)  (OSC_BASE_ADDR + 0x01))
#define OSC_XOSCCTRL           (*(volatile OS_U8*)  (OSC_BASE_ADDR + 0x02))
#define OSC_XOSCFAIL           (*(volatile OS_U8*)  (OSC_BASE_ADDR + 0x03))
#define OSC_PLLCTRL            (*(volatile OS_U8*)  (OSC_BASE_ADDR + 0x05))

/* Timer register */
#define TCC0_BASE_ADDR         (0x800)
#define TCC0_CTRLA             (*(volatile OS_U8*)  (TCC0_BASE_ADDR + 0x00))
#define TCC0_CTRLB             (*(volatile OS_U8*)  (TCC0_BASE_ADDR + 0x01))
#define TCC0_CTRLD             (*(volatile OS_U8*)  (TCC0_BASE_ADDR + 0x03))
#define TCC0_INTCTRLA          (*(volatile OS_U8*)  (TCC0_BASE_ADDR + 0x06))
#define TCC0_INTCTRLB          (*(volatile OS_U8*)  (TCC0_BASE_ADDR + 0x07))
#define TCC0_INTFLAGS          (*(volatile OS_U8*)  (TCC0_BASE_ADDR + 0x0C))
#define TCC0_CNT               (*(volatile OS_U16*) (TCC0_BASE_ADDR + 0x20))
#define TCC0_CNTL              (*(volatile OS_U16*) (TCC0_BASE_ADDR + 0x20))
#define TCC0_CNTH              (*(volatile OS_U16*) (TCC0_BASE_ADDR + 0x21))
#define TCC0_PER               (*(volatile OS_U16*) (TCC0_BASE_ADDR + 0x26))
#define TCC0_CCA               (*(volatile OS_U16*) (TCC0_BASE_ADDR + 0x28))

#define PMIC_CTRL              (*(volatile OS_U8*)  (0xA2))
#define BIT0_LOLVLEN_MASK      (1 << 0)  // Low Level Interrupt Enable

#define TCC0_INT_BASE          (0x01C)
#define TCC0_CCA_VECT_OFFSET   (0x04)
#define TCC0_CCA_VECT          0x40 // Timer/Counter Compare Channel A Interrupt vector

/*********************************************************************
*
*       _ReadHWTimer()
*
*       This functions reads the
*/
static int _ReadHWTimer(void) {
  OS_U16 r = TCC0_CNTL;
  asm ("nop");
  return r | (TCC0_CNTH << 8);
}



/*********************************************************************
*
*       OS_ISR_Tick_Handler()
*       The OS system timer interrupt handler
*/
void OS_ISR_Tick_Handler(void);
void OS_ISR_Tick_Handler(void) {
  OS_TICK_Handle();
}

/*********************************************************************
*
*       OS_ISR_Tick()
*       The OS system timer interrupt
*/
#pragma vector = TCC0_CCA_VECT
__interrupt void OS_ISR_Tick (void);
#pragma vector = TCC0_CCA_VECT
__interrupt void OS_ISR_Tick (void)  {
  OS_CallISR(OS_ISR_Tick_Handler);
}

/*********************************************************************
*
*       OS_InitHW()
*
*       Initialize the hardware (timer) required for the OS to run.
*       May be modified, if an other timer should be used
*/
void OS_InitHW(void) {
  OS_IncDI();
  //
  // Initialize timer for embOS, assuming PLL is already initialized
  //
  TCC0_CNT       = 0x00;                   // Clear CNT - Counter Register
  TCC0_CTRLA     = 0x01;                   // No prescaler
  TCC0_CTRLB     = 0x10;                   // CCAEN - Compare or Capture Enable, FRQ
  TCC0_CTRLD     = 0x00;                   // Disable all
  TCC0_CCA       = (OS_PCLK_TIMER / 1000); // Set compare register
  TCC0_PER       = (OS_PCLK_TIMER / 1000); // Set period register
  TCC0_INTCTRLB  = 0x01;                   // Set CCA interrupt level 1
  PMIC_CTRL     |= BIT0_LOLVLEN_MASK       // Enable low level interrupts
  //
  // Initialize the optional UART for OS viewer
  //
  OS_COM_INIT();
  OS_DecRI();
}

/*********************************************************************
*
*       OS_Idle()
*
*       Please note:
*       This is basically the "core" of the idle loop.
*       This core loop can be changed, but:
*       The idle loop does not have a stack of its own, therefore no
*       functionality should be implemented that relies on the stack
*       to be preserved. However, a simple program loop can be programmed
*       (like toggeling an output or incrementing a counter)
*/
void OS_Idle(void) {    // Idle loop: No task is ready to exec
  for (;;) {            // Nothing to do ... wait for interrupt
    #if (DEBUG == 0)
                        // Switch CPU into sleep mode
    #endif
  }
}

/*********************************************************************
*
*       OS_GetTime_Cycles()
*
*       This routine is required for task-info via OSView or high
*       resolution time maesurement functions.
*       It returns the system time in timer clock cycles.
*/
OS_U32 OS_GetTime_Cycles(void) {
  OS_U32 Time;
  OS_U32 Cnt;

  Time = OS_GetTime32();
  Cnt  = _ReadHWTimer();
  //
  // Check if timer interrupt pending ...
  //
  if (TCC0_INTFLAGS & 0x10) {
    Cnt = _ReadHWTimer();  // Interrupt pending, re-read timer and adjust result
    Time++;
  }
  return ((OS_PCLK_TIMER/1000) * Time) + Cnt;
}

/*********************************************************************
*
*       OS_ConvertCycles2us()
*
*       Convert Cycles into micro seconds.
*
*       If your clock frequency is not a multiple of 1 MHz,
*       you may have to modify this routine in order to get proper
*       diagnostics.
*
*       This routine is required for profiling or high resolution time
*       measurement only. It does not affect operation of the OS.
*/
OS_U32 OS_ConvertCycles2us(OS_U32 Cycles) {
  return Cycles/(OS_PCLK_TIMER/1000000);
}

/*********************************************************************
*
*   Communication for embOSView
*
**********************************************************************
*/
#if OS_UART_USED

/*********************************************************************
*
*       OS_COM_Init()
*       Initialize UART 1
*/
void OS_COM_Init(void) {
}

/*********************************************************************
*
*       OS_COM_Send1()
*       Send one character via UART.
*       Never call this function from your application
*/
void OS_COM_Send1(OS_U8 c) {
}

/*********************************************************************
*
*       _OS_ISR_RxErr()
*       Interrupt handler for UART reception error
*/
static void _OS_ISR_RxErr (void) {
}

/*********************************************************************
*
*       _OS_ISR_Rx()
*       Interrupt handler for UART reception
*/
static void _OS_ISR_Rx (void) {
}

/*********************************************************************
*
*       _OS_ISR_Tx()
*       Interrupt handler for UART transmission
*/
static void _OS_ISR_Tx (void) {
}

#else  /* UART for communication not used, define dummy functions */

void OS_COM_Send1(OS_U8 c) {
  OS_USEPARA(c);           /* Avoid compiler warning */
  OS_COM_ClearTxActive();  /* Let the OS know that Tx is not busy */
}
#endif

/*********************************************************************
*
*       __low_level_init()
*
*       Initialize clock generation and pll
*
*       Has to be modified, if another CPU clock frequency should be
*       used. This function is called during startup and
*       has to return 1 to perform segment initialization.
*
*       Because variables are not initialized before __low_level_init() is called,
*       no access or call which relies on any variable can be used here.
*/
int __low_level_init(void);
int __low_level_init(void) {
#ifndef CSPY_SIM
  //
  // Initialize clocks, use internal 32 MHz ocsillator
  //
  OSC_CTRL |= 0x02;              // Enable 32 MHz oscillator
  while(!(OSC_STATUS & 0x02));   // Wait until it is stable
  CCP = 0xD8;                    // I/O Protection
  CLK_CTRL = 0x01;               // Set clock to 32 Mhz
#endif

  return 1;               // Always return 1 to enable segment initilization !
}

/****** End Of File *************************************************/
