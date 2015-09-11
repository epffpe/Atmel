;/****************************************/
;/*  File Name: FuelGaugeDemo_Main.inc
;/***************************************/

;/**** The folloing routines are used in "FuelGauge_Buzzer.asm" **************/	
	global	delay_100ms, delay_1s


;/**** The following variables are used in "FuelGauge_Write_LCD.asm" **************/	
	global	FoundFistDigit 
;/	global	ADC_Sign, Gain_Selected, FoundFistDigit

;/**** The following variables are used in "FuelGauge_ADC.asm" ********************/	
	global	Config_Data, ADC_Sign, Gain_Selected, ADC_Value1, ADC_Value2, ADC_Value3
	global	IsitForU5_Volt

;/**** The following variables are used in "Binary_To_BCDConversion.asm" **********/	
;/	global	countT1,countT2,countT3,countT4,countT5,countT6

;/**** The following variables are used in "FuelGauge_Write_LCD.asm" **********/	

	global	digitT1,digitT2,digitT3,digitT4,digitT5,digitT6,digitT7
	global	digitT8,digitT9,digitT10,digitT11,digitT12,digitT13

;/**** The folloing variables are used in the "FuelGauge_MathLib.asm" **************/	

	global	Multiplier1,Multiplier2,Multiplier3
	global	Product1, Product2, Product3, Product4, Product5,Product6
	global	Multipland1, Multipland2, Multipland3
;	global	IsitForU5_Volt, Gain_Selected

	global	Dividend1, Dividend2, Dividend3, Dividend4, Dividend5, Dividend6
	global	Divisor1, Divisor2, Divisor3

	global	Carry_fromAdd 
	global	AddByteA 
	global	AddByteB

; Function Lists:

;/**** The following routins are used in "FuelGauge_ADC.asm" ********************/	

	extern	ADC_Write_Config, ADC_Read_400KHz

;/**** The folloing routines are in the "FuelGauge_MathLib.asm" **************/	
	extern	SubtractByteA, SubtractByteB
	extern	Subtract_6Bytes_6Bytes 
	extern	Multiply_24x24Bits_ADC, Multiply_3x3bytes
	extern	Divide_6by_3Bytes
	extern	Add_Two_6Bytes


;/**** The folloing routines are in the "FuelGauge_Buzzer.asm" **************/	
	extern	Buzzer_ON, Buzzer_OFF, Buzzer1p2KHz_ON, Buzzer1p1KHz_ON
	extern	Buzzer1p1To1p5KHz_ON
	extern	BuzzerStartUp_ON


;/**** The folloing routines are in the "FuelGauge_Write_LCD.asm" **************/	
	extern	Display_Results, Display_Results_Volts, Display_Results_Current
	extern	Disp_FuelRemPerct, Disp_FuelRemmAH, Display_FuelUsed, Disp_StdUnderCharged
	extern	Disp_ChargeCompleted, Disp_PressS1, Disp_DisconnectJP2, Disp_ConnectJP1, Disp_BatLowerThan0_75V
	extern	Disp_PlseWaitAtL1, Disp_InitAtL2
	extern	Disp_AtTP9_PressS1, Disp_ConntBattery 
;	extern	Bin48_bcd_volts, Bin48_bcd_currents

	extern	LCDInit,temp_wr, d_write, i_write, LCDLine_1, LCDLine_2

