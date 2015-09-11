;/****************************************/
;/*  File Name: FuelGauge_Write_LCD.inc
;/***************************************/


#define	LCD_D4		PORTA, 0	; LCD data bits
#define	LCD_D5		PORTA, 1
#define	LCD_D6		PORTA, 2
#define	LCD_D7		PORTA, 3
;
#define	LCD_D4_DIR	TRISA, 0	; LCD data bits
#define	LCD_D5_DIR	TRISA, 1
#define	LCD_D6_DIR	TRISA, 2
#define	LCD_D7_DIR	TRISA, 3

; ---- new ----------
#define	LCD_E		PORTD, 2	; LCD E clock
#define	LCD_RW		PORTD, 1	; LCD read/write line
#define	LCD_RS		PORTD, 0	; LCD register select line


#define	LCD_INS		0	
#define	LCD_DATA	1
;

	extern	digitT1,digitT2,digitT3,digitT4,digitT5,digitT6,digitT7
	extern	digitT8,digitT9,digitT10,digitT11,digitT12,digitT13
; 	digitT1 --> Lsd, digitT13 --> MSD 
;   radix dec		; Very Important --> Specify default in Radix  

	global	Display_Results, Display_Results_Volts, Display_Results_Current
	global	Disp_FuelRemPerct, Disp_FuelRemmAH, Display_FuelUsed, Disp_StdUnderCharged
	global	Disp_ChargeCompleted, Disp_PressS1, Disp_DisconnectJP2, Disp_ConnectJP1, Disp_BatLowerThan0_75V
	global	Disp_PlseWaitAtL1, Disp_InitAtL2
	global	Disp_ConntBattery, Disp_AtTP9_PressS1
	global	LCDLine_1, LCDLine_2,d_write,i_write,LCDWrite,LCDBusy, LCDInit
 	global	temp_wr

	extern	bin_bcd, bin16_bcd 
	;Bin48_bcd_volts, Bin48_bcd_currents
	extern	ADC_Sign, Gain_Selected, LSD, FoundFistDigit

