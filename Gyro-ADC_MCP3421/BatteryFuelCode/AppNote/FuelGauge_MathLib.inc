;/****************************************/
;/*  File Name: FuelGaugeD_MathLib.inc
;/***************************************/

	global	SubtractByteA, SubtractByteB
	global	Subtract_6Bytes_6Bytes 
	global	Multiply_24x24Bits_ADC, Multiply_3x3bytes
	global	Divide_6by_3Bytes
	global	Add_Two_6Bytes


;/**** The following variables are used in the "MULTIPLY_24x24Bits_ADC" 
;/***** and Multiply_3x3bytes ***************************************/
	extern	Multiplier1,Multiplier2,Multiplier3
	extern	Product1, Product2, Product3, Product4, Product5,Product6
	extern	Multipland1, Multipland2, Multipland3
	extern	IsitForU5_Volt, Gain_Selected

;/**** The following variables are used in the "Divide_6by_3Bytes" *********/

	extern	Dividend1, Dividend2, Dividend3,Dividend4,Dividend5,Dividend6
	extern	Divisor1, Divisor2, Divisor3

;/**** The following variables are used in the "Add_Two_6Bytes" *********/
	extern	Carry_fromAdd
	extern	AddByteA, AddByteB
