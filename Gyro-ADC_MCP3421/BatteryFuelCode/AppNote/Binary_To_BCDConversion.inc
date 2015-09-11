
;/****************************************/
;/*  File Name: Binary_To_BCDConversion.inc
;/***************************************/

	global	LSD, MsD, MSD
	global	bin_bcd, bin16_bcd
	;Bin48_bcd_volts, Bin48_bcd_currents ;---> These are in Main routine.
	
;	extern	digitT1,digitT2,digitT3,digitT4,digitT5,digitT6,digitT7
;	extern	digitT8,digitT9,digitT10,digitT11,digitT12,digitT13

;	extern	countT1,countT2,countT3,countT4,countT5,countT6

;/-----------------------------------------------------------/
;countT1		RES 1		;lsb
;countT2		RES 1	
;countT3		RES 1	
;countT4		RES 1	
;countT5		RES 1		;msb for gain=1
;countT6		RES 1		;msb for gain = 8,4,2
;/-----------------------------------------------------------/