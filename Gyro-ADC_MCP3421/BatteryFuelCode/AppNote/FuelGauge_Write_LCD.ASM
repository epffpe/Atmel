;/**************************************************************/
;/*  File Name: FuelGauge_Write_LCD.asm
;/***************************************/
;      This routine contains various subroutines that are
;      needed to display stings and numbers in LCD for Fuel Gauge Demo Board
;
;       Ver 1.0
;       Date: 7-28-2007
;		AIPD
;		Microchip Technology Inc 
;/************************************************************/
;************************************************************************
;		LEGAL NOTICE
;
;  The information contained in this document is proprietary and 
;  confidential information of Microchip Technology Inc.  Therefore all 
;  parties are required to sign a non-disclosure agreement before  
;  receiving this document.
;
;  The information contained in this Application Note is for suggestion 
;  only.  It is your responsibility to ensure that your application meets 
;  with your specifications.  No representation or warranty is given and 
;  no liability is assumed by Microchip Technology Incorporated with 
;  respect to the accuracy or use of such information or infringement of 
;  patents or other intellectual property arising from such use or 
;  otherwise.
;
;		 Software License Agreement
;
; The software supplied herewith by Microchip Technology Incorporated 
; (the "Company") for its PICmicro® Microcontroller is intended and 
; supplied to you, the Company's customer, for use solely and 
; exclusively on Microchip PICmicro Microcontroller products. The 
; software is owned by the Company and/or its supplier, and is 
; protected under applicable copyright laws. All rights are reserved. 
;  Any use in violation of the foregoing restrictions may subject the 
; user to criminal sanctions under applicable laws, as well as to 
; civil liability for the breach of the terms and conditions of this 
; license.
;
; THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES, 
; WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED 
; TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
; PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT, 
; IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR 
; CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.


;************************************************************************



	list p=18f4550
#include 	<p18f4550.inc>
; #include	FuelGauge_LCDString.inc
#include	FuelGauge_Write_LCD.inc



LCD_Reg		UDATA
COUNTER		res	1
delay		res	1
temp_wr		res	1
temp_rd		res	1


;LCDString_VAR	UDATA
;digitT1		RES 1		;LSB
;digitT2		RES 1
;digitT3		RES 1
;digitT4		RES 1
;digitT5		RES 1
;digitT6		RES 1
;digitT7		RES 1
;digitT8		RES 1
;digitT9		RES 1
;digitT10	RES 1
;digitT11	RES 1
;digitT12	RES 1
;digitT13	RES 1		;MSB
;


LCD_CODE	code

;/* This routin is called from main routin (FuelGaugeDemo_Main.asm) 
;/*   This routin displays strings in LCD.
;*/


;------------------------------------------------------------------------------------------------------------	
Display_Results
Display_Results_Volts
;---------------------------------------
;		digitT1		; ones
;		digitT2		; tens
;		digitT3		; hundreds
;		digitT4		; thousands
;		digitT5		; Ten_Thousands
;		digitT6		; OneHundreds_Thousands
;		digitT7		; One_million
;		digitT8		; Ten_million
;		digitT9		; 
;		digitT10	; MSB for Gain = 1
;		digitT11	; ---> 
;		digitT12	; --->MSB for Gain = 8
;		digitT13	; --->0
;-----------------------------------------------------------------------------------------------------------
;
; digitT13-digitT12-digitT11-digitT10-digitT9-digitT8-digitT7-digitT6-digitT5-digitT4-digitT3-digitT2-digitT11
;  The Maximum value of MCP3421 is 4.096 V.

; 2^18 = 262,144 in decimal ==> 40000 hex --> 5 registers ===> display from digit5 to digit1

;---------------------------------------

;	banksel	VoltageOrCurrent
;	btfss	VoltageOrCurrent,0
;	bra		DisPlayCurrent

	call	LCDLine_1		;Display Battery Voltage in Line 1
	banksel	temp_wr 
	movlw	A'V'			
	movwf	temp_wr
	call	d_write

	banksel	temp_wr		
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr		
	movlw	A'='
	movwf	temp_wr
	call	d_write
	
	banksel	temp_wr
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	ADC_Sign
	btfss	ADC_Sign,0
	bra		Put_Negative_Sign
;	bra		Put_Positive_Sign
Put_Positive_Sign
	banksel	temp_wr
	movlw	A'+'			;send Positive Sign "+"
	movwf	temp_wr
	call	d_write
	goto	Start_DisPlay_Values

Put_Negative_Sign
	banksel	temp_wr
	movlw	A'-'			;send Positive Sign "-"
	movwf	temp_wr
	call	d_write
;	bra		Start_DisPlay_Values
	

Start_DisPlay_Values

	banksel	Gain_Selected
; testing
;	bra		DisVForGain4

	btfsc	Gain_Selected,0
	goto	DisVForGain2
	btfsc	Gain_Selected,1
	goto	DisVForGain4
	btfsc	Gain_Selected,2
	goto	DisVForGain8

DisVForGain1
 	banksel	digitT10
	movf	digitT10,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr
	movwf	temp_wr
	call	d_write

	banksel	temp_wr
	movlw	A'.'			;send decimal point "."
	movwf	temp_wr
	call	d_write

 	banksel	digitT9
	movf	digitT9,W			;below decimal point
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.#x

	banksel	temp_wr
	movwf	temp_wr
	call	d_write

	banksel	digitT8
	movf	digitT8,W			;Get hundreds
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr
	movwf	temp_wr
	call	d_write

	banksel	digitT7
	movf	digitT7,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr
	movwf	temp_wr
	call	d_write

	banksel	digitT6
	movf	digitT6,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr
	movwf	temp_wr
	call	d_write

	banksel	digitT5
	movf	digitT5,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr
	movwf	temp_wr
	call	d_write

	banksel	digitT4
	movf	digitT4,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr
	movwf	temp_wr
	call	d_write

	banksel	digitT3
	movf	digitT3,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr
	movwf	temp_wr
	call	d_write


	movlw	A' '			; spaces	
	banksel	temp_wr
	movwf	temp_wr
	call	d_write

	movlw	A'V'			;send "V" unit
	banksel	temp_wr
	movwf	temp_wr
	call	d_write


	return

DisVForGain2
	banksel	digitT11
	movf	digitT11,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'.'			;send decimal point "."
	movwf	temp_wr
	call	d_write


	banksel	digitT10
	movf	digitT10,W			;below decimal point
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.#x

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT9
	movf	digitT9,W			;below decimal point
	call	bin_bcd


	banksel	LSD
	movf	LSD,W			;send low digit   x.#x

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT8
	movf	digitT8,W			;Get hundreds
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT7
	movf	digitT7,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT6
	movf	digitT6,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT5
	movf	digitT5,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write


	banksel	digitT4
	movf	digitT4,W			;Get tens
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT3
	movf	digitT3,W			;Get tens
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write


	banksel	temp_wr 
	movlw	A'V'			;send "V" unit
	movwf	temp_wr
	call	d_write

	return


DisVForGain4

	banksel	temp_wr 
	movlw	A'.'			;send decimal point "."
	movwf	temp_wr
	call	d_write

	banksel	digitT11
	movf	digitT11,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT10
	movf	digitT10,W			;Get Above decimal point (>4)
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write


	banksel	digitT9
	movf	digitT9,W			;below decimal point
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.#x

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT8
	movf	digitT8,W			;Get hundreds
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT7
	movf	digitT7,W			;Get tens
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT6
	movf	digitT6,W			;Get tens
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT5
	movf	digitT5,W			;Get tens
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

;	banksel	digitT4
;	movf	digitT4,W			;Get tens
;	call	bin_bcd
;	movf	LSD,W			;send low digit   x.x#
;	movwf	temp_wr
;	call	d_write
;
;	banksel	digitT3
;	movf	digitT3,W			;Get tens
;	call	bin_bcd
;	movf	LSD,W			;send low digit   x.x#
;	movwf	temp_wr
;	call	d_write
;

	banksel	temp_wr 
	movlw	A' '			; spaces	
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'V'			;send "V" unit
	movwf	temp_wr
	call	d_write


;	movlw	A' '			; spaces	
;	movwf	temp_wr
;	call	d_write

	return





DisVForGain8

	banksel	temp_wr 
	movlw	A'.'			;send decimal point "."
	movwf	temp_wr
	call	d_write

	banksel	digitT12
	movf	digitT12,W			;Get Above decimal point (>4)
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write


	banksel	digitT11
	movf	digitT11,W			;Get Above decimal point (>4)
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT10
	movf	digitT10,W			;Get Above decimal point (>4)
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write


	banksel	digitT9
	movf	digitT9,W			;below decimal point
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.#x

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT8
	movf	digitT8,W			;Get hundreds
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT7
	movf	digitT7,W			;Get tens
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT6
	movf	digitT6,W			;Get tens
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

;	banksel	digitT5
;	movf	digitT5,W			;Get tens
;	call	bin_bcd
;	movf	LSD,W			;send low digit   x.x#
;	movwf	temp_wr
;	call	d_write
;
;
;	banksel	digitT4
;	movf	digitT4,W			;Get tens
;	call	bin_bcd
;	movf	LSD,W			;send low digit   x.x#
;	movwf	temp_wr
;	call	d_write
;
;	banksel	digitT3
;	movf	digitT3,W			;Get tens
;	call	bin_bcd
;	movf	LSD,W			;send low digit   x.x#
;	movwf	temp_wr
;	call	d_write

	banksel	temp_wr 
	movlw	A' '			; spaces	
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'V'			;send "V" unit
	movwf	temp_wr
	call	d_write

	return

;------------------------------------------------------------------------------------
Display_Results_Current
;---------------------------------------
;		digitT1		; ones
;		digitT2		; tens
;		digitT3		; hundreds
;		digitT4		; thousands
;		digitT5		; Ten_Thousands
;		digitT6		; OneHundreds_Thousands
;		digitT7		; One_million
;		digitT8		; Ten_million
;		digitT9		; 
;		digitT10	; MSB for Gain = 1
;		digitT11	; ---> 
;		digitT12	; --->MSB for Gain = 8
;		digitT13	; --->0
;-----------------------------------------------------------------------------------------------------------
;
; digitT13-digitT12-digitT11-digitT10-digitT9-digitT8-digitT7-digitT6-digitT5-digitT4-digitT3-digitT2-digitT1
;  The Maximum value of MCP3421 is 4.096 V.

; 2^18 = 262,144 in decimal ==> 40000 hex --> 5 registers ===> display from digit5 to digit1

;---------------------------------------

	call	LCDLine_2		;display A/D result on 2nd line
	movlw	A'I'			;send "RB0=Exit" to LCD

;Continue_disp
	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'='		
	movwf	temp_wr
	call	d_write
	
	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

;----------------------------------------------------------

	banksel ADC_Sign
	btfss	ADC_Sign,0
	bra		Put_Negative_Sign_I
;	bra		Put_Positive_Sign_I
Put_Positive_Sign_I
	banksel	temp_wr 
	movlw	A'+'			;send Positive Sign "+"
	movwf	temp_wr
	call	d_write
	goto	Start_DisPlay_I_Values

Put_Negative_Sign_I
	banksel	temp_wr 
	movlw	A'-'			;send Positive Sign "-"
	movwf	temp_wr
	call	d_write
	
Start_DisPlay_I_Values

;---------------------------------

	banksel	Gain_Selected

	btfsc	Gain_Selected,0
	bra		DisIForGain2
	btfsc	Gain_Selected,1
	bra		DisIForGain4
	btfsc	Gain_Selected,2
	bra		DisIForGain8
;---------------------------------

DisIForGain1
 	banksel	digitT7
	movf	digitT7,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'.'			;send decimal point "."
	movwf	temp_wr
	call	d_write

	banksel	digitT6
	movf	digitT6,W			;below decimal point
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.#x

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT5
	movf	digitT5,W			;Get hundreds
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT4
	movf	digitT4,W			;Get tens
	call	bin_bcd

	banksel LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT3
	movf	digitT3,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT2
	movf	digitT2,W			;Get tens
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write


	banksel	digitT1
	movf	digitT1,W			;Get tens
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write


;	movlw	A'u'			;send "uA" unit
;	movwf	temp_wr
;	call	d_write

	banksel	temp_wr 
	movlw	A'0'			;send "uA" unit
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A' '			;send "uA" unit
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'A'			;send "uA" unit
	movwf	temp_wr
	call	d_write

	return


DisIForGain2
	banksel	digitT11
	movf	digitT11,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'.'			;send decimal point "."
	movwf	temp_wr
	call	d_write

	banksel	digitT10
	movf	digitT10,W			;below decimal point
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.#x

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT9
	movf	digitT9,W			;below decimal point
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.#x

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	movf	digitT8,W			;Get hundreds
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT7
	movf	digitT7,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT6
	movf	digitT6,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT5
	movf	digitT5,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write


;	movf	digitT4,W			;Get tens
;	call	bin_bcd
;	movf	LSD,W			;send low digit   x.x#
;	movwf	temp_wr
;	call	d_write
;
;	movf	digitT3,W			;Get tens
;	call	bin_bcd
;	movf	LSD,W			;send low digit   x.x#
;	movwf	temp_wr
;	call	d_write



	banksel	temp_wr 
	movlw	A'('			;send "uA" unit
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'A'			;send "uA" unit
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A')'			;send "uA" unit
	movwf	temp_wr
	call	d_write

	return


DisIForGain4

	banksel	digitT12
	movf	digitT12,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write



	banksel	temp_wr 
	movlw	A'.'			;send decimal point "."
	movwf	temp_wr
	call	d_write

	banksel	digitT11
	movf	digitT11,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT10
	movf	digitT10,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write


	banksel	digitT9
	movf	digitT9,W			;below decimal point
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.#x

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT8
	movf	digitT8,W			;Get hundreds
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT7
	movf	digitT7,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT6
	movf	digitT6,W			;Get tens
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

;	movf	digitT5,W			;Get tens
;	call	bin_bcd
;	movf	LSD,W			;send low digit   x.x#
;	movwf	temp_wr
;	call	d_write
;
;
;	movf	digitT4,W			;Get tens
;	call	bin_bcd
;	movf	LSD,W			;send low digit   x.x#
;	movwf	temp_wr
;	call	d_write
;
;	movf	digitT3,W			;Get tens
;	call	bin_bcd
;	movf	LSD,W			;send low digit   x.x#
;	movwf	temp_wr
;	call	d_write


	banksel	temp_wr 
	movlw	A'('			;send "uA" unit
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'A'			;send "uA" unit
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A')'			;send "uA" unit
	movwf	temp_wr
	call	d_write
	return



DisIForGain8

	banksel	digitT13
	movf	digitT13,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'.'			;send decimal point "."
	movwf	temp_wr
	call	d_write

	banksel	digitT6
	movf	digitT6,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT5
	movf	digitT5,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write


	banksel	digitT4
	movf	digitT4,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT3
	movf	digitT3,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT2
	movf	digitT2,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT1
	movf	digitT1,W			;Get tens
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'0'			;send "uA" unit
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A' '			;send "uA" unit
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'A'			;send "uA" unit
	movwf	temp_wr
	call	d_write
	return




;--------------------------------------------------------------------------------------


Disp_FuelRemPerct
;/* Display Fuel Remain in Percentage */

;---------------------------------------
;		digitT1		; ones
;		digitT2		; tens
;		digitT3		; hundreds
;		digitT4		; thousands
;		digitT5		; Ten_Thousands
;		digitT6		; OneHundreds_Thousands
;		digitT7		; One_million
;		digitT8		; Ten_million
;		digitT9		; 
;		digitT10	; MSB for Gain = 1
;		digitT11	; ---> 
;		digitT12	; --->MSB for Gain = 8
;		digitT13	; --->0
;-----------------------------------------------------------------------------------------------------------
;
; digitT13-digitT12-digitT11-digitT10-digitT9-digitT8-digitT7-digitT6-digitT5-digitT4-digitT3-digitT2-digitT11
;  The Maximum value of MCP3421 is 4.096 V.

; 2^18 = 262,144 in decimal ==> 40000 hex --> 5 registers ===> display from digit5 to digit1

;---------------------------------------


;	banksel	Its_RemaFuel
;	btfss		Its_RemaFuel,0
;	goto		DispFuelUsed
;DispFuelRemaining

	call	LCDLine_1	

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write
	
	banksel	temp_wr 
	movlw	A'F'			
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'u'			
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'e'			
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'l'			
	movwf	temp_wr
	call	d_write

;	movlw	A'R'		
;	movwf	temp_wr
;	call	d_write
;	movlw	A'e'		
;	movwf	temp_wr
;	call	d_write
;	
;	movlw	A'm'			
;	movwf	temp_wr
;	call	d_write
;	movlw	A'a'		
;	movwf	temp_wr
;	call	d_write
;	movlw	A'i'		
;	movwf	temp_wr
;	call	d_write
;	movlw	A'n'		
;	movwf	temp_wr
;	call	d_write
;
	banksel	temp_wr 
	movlw	A'='		
	movwf	temp_wr
	call	d_write


;----------------------------------------------------------


;	banksel	digitT10
;	movf	digitT10,W			;Get Above decimal point (>4)
;	call	bin_bcd
;	movf	LSD,W			;send high digit from the LSD #.xx	
;	movwf	temp_wr
;	call	d_write
;
;	banksel	digitT9
;	movf	digitT8,W			;Get Above decimal point (>4)
;	call	bin_bcd
;	movf	LSD,W			;send high digit from the LSD #.xx	
;	movwf	temp_wr
;	call	d_write
;
;	banksel	digitT8
;	movf	digitT8,W			;Get Above decimal point (>4)
;	call	bin_bcd
;	movf	LSD,W			;send high digit from the LSD #.xx	
;	movwf	temp_wr
;	call	d_write
;
;	banksel	digitT7
;	movf	digitT7,W			;Get Above decimal point (>4)
;	call	bin_bcd
;	movf	LSD,W			;send high digit from the LSD #.xx	
;	movwf	temp_wr
;	call	d_write
;

;------------------------------------
	banksel	digitT6
	movlw	0xff
	andwf	digitT6,0
	btfsc	STATUS,Z	; Z -->1: Register is zero, Z -->0: Register is not zero
	goto	LessThan_99Pcnt	 
;------------------------------------

	banksel	digitT6
	movf	digitT6,W		; Checking 100% - 900*	
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

LessThan_99Pcnt
	banksel	digitT5
	movf	digitT5,W			
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT4
	movf	digitT4,W			
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'.'		
	movwf	temp_wr
	call	d_write


 	banksel	digitT3
	movf	digitT3,W			
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write
;----------------------------
	banksel	digitT2
	movf	digitT2,W			;below decimal point
	call	bin_bcd

	banksel	LSD
	movf	LSD,W				;send low digit   x.#x

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT1
	movf	digitT1,W			;Get hundreds
	call	bin_bcd
	banksel	LSD
	movf	LSD,W				;send low digit   x.x#

	banksel	temp_wr 
	movwf	temp_wr		
	call	d_write
;

	banksel	temp_wr 
	movlw	A'%'		
	movwf	temp_wr
	call	d_write


	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

;	movlw	A' '		
;	movwf	temp_wr
;	call	d_write
;	movlw	A' '		
;	movwf	temp_wr
;	call	d_write

	return

Disp_FuelRemmAH
;/* Display Fuel Remain in mAH */

;---------------------------------------
;		digitT1		; ones
;		digitT2		; tens
;		digitT3		; hundreds
;		digitT4		; thousands
;		digitT5		; Ten_Thousands
;		digitT6		; OneHundreds_Thousands
;		digitT7		; One_million
;		digitT8		; Ten_million
;		digitT9		; 
;		digitT10	; MSB for Gain = 1
;		digitT11	; ---> 
;		digitT12	; --->MSB for Gain = 8
;		digitT13	; --->0
;-----------------------------------------------------------------------------------------------------------
;
; digitT13-digitT12-digitT11-digitT10-digitT9-digitT8-digitT7-digitT6-digitT5-digitT4-digitT3-digitT2-digitT1
;  The Maximum value of MCP3421 is 4.096 V.
;---------------------------------------
	banksel	FoundFistDigit
	clrf	FoundFistDigit

	call	LCDLine_2		
	

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'('		
	movwf	temp_wr
	call	d_write




	banksel	digitT4

;   checking if the register is empty or not: digitT4 + digitT3 + digitT2 + digitT1
;------------------------------------

	movlw	b'11111111'
	andwf	digitT4,0
	btfsc	STATUS,Z	; Z -->1: Register is zero, Z -->0: Register is not zero
	goto	ChekDigitT3_RFuel		 
;------------------------------------
	banksel	digitT4
	movf	digitT4,W			;Register is not zero --> decimal point should be after digitT6!
	call	bin_bcd
	banksel	LSD
	movf	LSD,W				;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	FoundFistDigit
	bsf		FoundFistDigit,0

ChekDigitT3_RFuel
	banksel	FoundFistDigit
	btfsc	FoundFistDigit,0	
	goto	digitT3_RFuel

	banksel	digitT3
;   checking if the register is empty or not:
;------------------------------------
	movlw	b'11111111'
	andwf	digitT3,0
	btfsc	STATUS,Z	; Z -->1: Register is zero, Z -->0: Register is not zero
	goto	ChekDigitT2_RFuel	 
;------------------------------------
digitT3_RFuel
	banksel	digitT3
	movf	digitT3,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write
	banksel	FoundFistDigit
	bsf		FoundFistDigit,0


ChekDigitT2_RFuel
	banksel	FoundFistDigit
	btfsc	FoundFistDigit,0	
	goto	digitT2_RFuel
	banksel	digitT2
;   checking if the register is empty or not:
;------------------------------------

	movlw	b'11111111'
	andwf	digitT2,0
	btfsc	STATUS,Z	; Z -->1: Register is zero, Z -->0: Register is not zero
	goto	ChekDigitT1_RFuel	 
;------------------------------------
digitT2_RFuel
	banksel	digitT2
	movf	digitT2,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write
	banksel	FoundFistDigit
	bsf		FoundFistDigit,0

ChekDigitT1_RFuel
	banksel	digitT1
	movf	digitT1,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	FoundFistDigit
	bcf		FoundFistDigit,0

	

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'm'		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'A'		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'h'		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A')'		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write


	return






Display_FuelUsed

;/* Display Fuel Used */

;---------------------------------------------------	
; for 1000.xxxx mAh ----> (digitT9 + digitT8 + digitT7 + digitT6) . digitT5 + digitT4 +digitT3 + .. 
; Period --> after digitT6 !!
;---------------------------------------------------


	banksel	FoundFistDigit
	clrf	FoundFistDigit,0


;---------------------------------------
;		digitT1		; ones
;		digitT2		; tens
;		digitT3		; hundreds
;		digitT4		; thousands
;		digitT5		; Ten_Thousands
;		digitT6		; OneHundreds_Thousands
;		digitT7		; One_million
;		digitT8		; Ten_million
;		digitT9		; 
;		digitT10	; MSB for Gain = 1
;		digitT11	; ---> 
;		digitT12	; --->MSB for Gain = 8
;		digitT13	; --->0
;-----------------------------------------------------------------------------------------------------------
;
; digitT13-digitT12-digitT11-digitT10-digitT9-digitT8-digitT7-digitT6-digitT5-digitT4-digitT3-digitT2-digitT11
;  The Maximum value of MCP3421 is 4.096 V.

; 2^18 = 262,144 in decimal ==> 40000 hex --> 5 registers ===> display from digit5 to digit1

;---------------------------------------


	call	LCDLine_1	

	banksel	temp_wr 
	movlw	A' '			
	movwf	temp_wr
	call	d_write	
	
	banksel	temp_wr 
	movlw	A' '			
	movwf	temp_wr
	call	d_write	

	banksel	temp_wr 
	movlw	A' '			
	movwf	temp_wr
	call	d_write	

	banksel	temp_wr 
	movlw	A'F'			
	movwf	temp_wr
	call	d_write
	movlw	A'u'			
	movwf	temp_wr
	call	d_write
	movlw	A'e'			
	movwf	temp_wr
	call	d_write
	movlw	A'l'			
	movwf	temp_wr
	call	d_write

	movlw	A' '			
	movwf	temp_wr
	call	d_write

	movlw	A'U'			
	movwf	temp_wr
	call	d_write
	movlw	A's'		
	movwf	temp_wr
	call	d_write
	movlw	A'e'		
	movwf	temp_wr
	call	d_write
	movlw	A'd'		
	movwf	temp_wr
	call	d_write


	movlw	A':'		
	movwf	temp_wr
	call	d_write

	movlw	A' '			
	movwf	temp_wr
	call	d_write	
	
	movlw	A' '			
	movwf	temp_wr
	call	d_write	

	movlw	A' '			
	movwf	temp_wr
	call	d_write	

;	movlw	A' '			
;	movwf	temp_wr
;	call	d_write	

;	movlw	A' '			
;	movwf	temp_wr
;	call	d_write	
;	movlw	A' '			
;	movwf	temp_wr
;	call	d_write	
;	movlw	A' '			
;	movwf	temp_wr
;	call	d_write	

;---------------------------------------------------
	call	LCDLine_2	
;---------------------------------------------------	
; for 1000.xxxx mAh ----> (digitT9 + digitT8 + digitT7 + digitT6) . digitT5 + digitT4 +digitT3 + .. 
; Period --> after digitT6 !!
;---------------------------------------------------


	banksel	temp_wr


	movlw	A' '			
	movwf	temp_wr
	call	d_write	
	
	movlw	A' '			
	movwf	temp_wr
	call	d_write	

	movlw	A' '			
	movwf	temp_wr
	call	d_write	

;   checking if the register is empty or not:
;------------------------------------
	banksel	digitT10

	movlw	b'11111111'
	andwf	digitT10,0
	btfsc	STATUS,Z	; Z -->1: Register is zero, Z -->0: Register is not zero
	goto	ChekDigitT9_UsedF		 
;------------------------------------
	banksel	digitT10
	movf	digitT10,W			;Register is not zero --> decimal point should be after digitT6!
	call	bin_bcd
	banksel	LSD
	movf	LSD,W				;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	FoundFistDigit
	bsf		FoundFistDigit,0

;--------------------------------------------------------------
ChekDigitT9_UsedF
	banksel	FoundFistDigit
	btfsc	FoundFistDigit,0	
	goto	digitT9_used
	banksel	digitT9
;   checking if the register is empty or not:
;------------------------------------
	movlw	b'11111111'
	andwf	digitT9,0
	btfsc	STATUS,Z	; Z -->1: Register is zero, Z -->0: Register is not zero
	goto	ChekDigitT8_UsedF	 
;------------------------------------
digitT9_used
	banksel	digitT9
	movf	digitT9,W			;Get Above decimal point (>4)
	call	bin_bcd
	banksel	LSD
	movf	LSD,W				;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write
	banksel	FoundFistDigit
	bsf		FoundFistDigit,0


;--------------------------------------------------------------

ChekDigitT8_UsedF
	banksel	FoundFistDigit
	btfsc	FoundFistDigit,0	
	goto	digitT8_used
	banksel	digitT8
;   checking if the register is empty or not:
;------------------------------------
	movlw	b'11111111'
	andwf	digitT8,0
	btfsc	STATUS,Z	; Z -->1: Register is zero, Z -->0: Register is not zero
	goto	ChekDigitT7_UsedF	 
;------------------------------------
digitT8_used
	banksel	digitT8
	movf	digitT8,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	FoundFistDigit
	bsf		FoundFistDigit,0


ChekDigitT7_UsedF
	banksel	FoundFistDigit
	btfsc	FoundFistDigit,0	
	goto	digitT7_used
	banksel	digitT7
;   checking if the register is empty or not:
;------------------------------------

	movlw	b'11111111'
	andwf	digitT7,0
	btfsc	STATUS,Z	; Z -->1: Register is zero, Z -->0: Register is not zero
	goto	ChekDigitT6_UsedF	 
;------------------------------------
digitT7_used
	banksel	digitT7
	movf	digitT7,W			;Get Above decimal point (>4)
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

ChekDigitT6_UsedF
	banksel	digitT6
	movf	digitT6,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	FoundFistDigit
	bcf		FoundFistDigit,0


;-----------------------------
; decimal point in here for 1000 mAH 
	banksel	temp_wr 
	movlw	A'.'		
	movwf	temp_wr
	call	d_write
;-----------------------------

	banksel	digitT5
	movf	digitT5,W			;Get Above decimal point (>4)
	call	bin_bcd

	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT4
	movf	digitT4,W			;Get Above decimal point (>4)
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

 	banksel	digitT3
	movf	digitT3,W			;Get Above decimal point (>4)
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send high digit from the LSD #.xx	

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

	banksel	digitT2
	movf	digitT2,W			;below decimal point
	call	bin_bcd
	banksel	LSD
	movf	LSD,W			;send low digit   x.#x

	banksel	temp_wr 
	movwf	temp_wr
	call	d_write

;	movf	digitT1,W			;Get hundreds
;	call	bin_bcd
;	movf	LSD,W			;send low digit   x.x#
;	movwf	temp_wr
;	call	d_write

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'm'		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'A'		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A'h'		
	movwf	temp_wr
	call	d_write


	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	banksel	temp_wr 
	movlw	A' '		
	movwf	temp_wr
	call	d_write

	return


;/---------------------------------------------------------/
Disp_StdUnderCharged
;/* This routin displays " StartedUnderChgd" in Line 2  */

	call	LCDLine_2

	movlw	A'S'					; 1			
	movwf	temp_wr
	call	d_write	
	
	movlw	A't'					;2
	movwf	temp_wr
	call	d_write	

	movlw	A'a'					;3
	movwf	temp_wr
	call	d_write	

	movlw	A'r'					;4
	movwf	temp_wr
	call	d_write
	movlw	A't'					;5
	movwf	temp_wr
	call	d_write
	movlw	A'e'					;6
	movwf	temp_wr
	call	d_write
	movlw	A'd'					;7
	movwf	temp_wr
	call	d_write

	movlw	A'U'					;8
	movwf	temp_wr
	call	d_write

	movlw	A'n'					;9
	movwf	temp_wr
	call	d_write
	movlw	A'd'					;10
	movwf	temp_wr
	call	d_write
	movlw	A'e'					;11
	movwf	temp_wr
	call	d_write
	movlw	A'r'					;12
	movwf	temp_wr
	call	d_write


	movlw	A'C'					;13
	movwf	temp_wr
	call	d_write
	movlw	A'h'					;14
	movwf	temp_wr
	call	d_write
	movlw	A'g'					;15
	movwf	temp_wr
	call	d_write
	movlw	A'd'					;16
	movwf	temp_wr
	call	d_write

	return


;/*-----------------------------------------------------*/
Disp_ChargeCompleted
;/* This routin displays "Charging Done   " in Line 1 */

	call	LCDLine_1

	movlw	A'C'					; 1			
	movwf	temp_wr
	call	d_write	
	
	movlw	A'h'					;2
	movwf	temp_wr
	call	d_write	

	movlw	A'a'					;3
	movwf	temp_wr
	call	d_write	

	movlw	A'r'					;4
	movwf	temp_wr
	call	d_write
	movlw	A'g'					;5
	movwf	temp_wr
	call	d_write
	movlw	A'i'					;6
	movwf	temp_wr
	call	d_write
	movlw	A'n'					;7
	movwf	temp_wr
	call	d_write

	movlw	A'g'					;8
	movwf	temp_wr
	call	d_write

	movlw	A' '					;9
	movwf	temp_wr
	call	d_write
	movlw	A'D'					;10
	movwf	temp_wr
	call	d_write
	movlw	A'o'					;11
	movwf	temp_wr
	call	d_write
	movlw	A'n'					;12
	movwf	temp_wr
	call	d_write
	movlw	A'e'					;13
	movwf	temp_wr
	call	d_write
	
	movlw	A' '					;14
	movwf	temp_wr
	call	d_write
	movlw	A' '					;15
	movwf	temp_wr
	call	d_write
	movlw	A' '					;16
	movwf	temp_wr
	call	d_write

	return
;/*---------------------------------------------------*/
Disp_PressS1
;/* This routin displays "Push S1 for Next" in Line 2 */

	call	LCDLine_2

	movlw	A'P'					; 1			
	movwf	temp_wr
	call	d_write	
	
	movlw	A'u'					;2
	movwf	temp_wr
	call	d_write	

	movlw	A's'					;3
	movwf	temp_wr
	call	d_write	

	movlw	A'h'					;4
	movwf	temp_wr
	call	d_write
	movlw	A' '					;5
	movwf	temp_wr
	call	d_write
	movlw	A'S'					;6
	movwf	temp_wr
	call	d_write
	movlw	A'1'					;7
	movwf	temp_wr
	call	d_write

	movlw	A' '					;8
	movwf	temp_wr
	call	d_write

	movlw	A'f'					;9
	movwf	temp_wr
	call	d_write
	movlw	A'o'					;10
	movwf	temp_wr
	call	d_write
	movlw	A'r'					;11
	movwf	temp_wr
	call	d_write
	movlw	A' '					;12
	movwf	temp_wr
	call	d_write
	movlw	A'N'					;13
	movwf	temp_wr
	call	d_write
	
	movlw	A'e'					;14
	movwf	temp_wr
	call	d_write
	movlw	A'x'					;15
	movwf	temp_wr
	call	d_write
	movlw	A't'					;16
	movwf	temp_wr
	call	d_write

	return


;/*-------------------------------------------------*/
Disp_DisconnectJP2
;/* This routin display "Disconnect JP2  " in Line 1 */

	call	LCDLine_1

	movlw	A'D'					; 1			
	movwf	temp_wr
	call	d_write	
	
	movlw	A'i'					;2
	movwf	temp_wr
	call	d_write	

	movlw	A's'					;3
	movwf	temp_wr
	call	d_write	

	movlw	A'c'					;4
	movwf	temp_wr
	call	d_write
	movlw	A'o'					;5
	movwf	temp_wr
	call	d_write
	movlw	A'n'					;6
	movwf	temp_wr
	call	d_write
	movlw	A'n'					;7
	movwf	temp_wr
	call	d_write

	movlw	A'e'					;8
	movwf	temp_wr
	call	d_write

	movlw	A'c'					;9
	movwf	temp_wr
	call	d_write
	movlw	A't'					;10
	movwf	temp_wr
	call	d_write
	movlw	A' '					;11
	movwf	temp_wr
	call	d_write
	movlw	A'J'					;12
	movwf	temp_wr
	call	d_write
	movlw	A'P'					;13
	movwf	temp_wr
	call	d_write
	
	movlw	A'2'					;14
	movwf	temp_wr
	call	d_write
	movlw	A' '					;15
	movwf	temp_wr
	call	d_write
	movlw	A' '					;16
	movwf	temp_wr
	call	d_write

	return

;/*-------------------------------------------------*/
Disp_ConnectJP1
;/* This routin display "ConntJP1,Push S1" in Line 2 */

	call	LCDLine_2

	movlw	A'C'					; 1			
	movwf	temp_wr
	call	d_write	
	
	movlw	A'o'					;2
	movwf	temp_wr
	call	d_write	

	movlw	A'n'					;3
	movwf	temp_wr
	call	d_write	

	movlw	A'n'					;4
	movwf	temp_wr
	call	d_write
	movlw	A't'					;5
	movwf	temp_wr
	call	d_write
	movlw	A'J'					;6
	movwf	temp_wr
	call	d_write
	movlw	A'P'					;7
	movwf	temp_wr
	call	d_write

	movlw	A'1'					;8
	movwf	temp_wr
	call	d_write

	movlw	A','					;9
	movwf	temp_wr
	call	d_write
	movlw	A'P'					;10
	movwf	temp_wr
	call	d_write
	movlw	A'u'					;11
	movwf	temp_wr
	call	d_write
	movlw	A's'					;12
	movwf	temp_wr
	call	d_write
	movlw	A'h'					;13
	movwf	temp_wr
	call	d_write
	
	movlw	A' '					;14
	movwf	temp_wr
	call	d_write
	movlw	A'S'					;15
	movwf	temp_wr
	call	d_write
	movlw	A'1'					;16
	movwf	temp_wr
	call	d_write

	return
;/**********************************************************/





;/*-------------------------------------------------*/
Disp_BatLowerThan0_75V
;/* This routin display "ConntJP1,Push S1" in Line 2 */

	call	LCDLine_2

	movlw	A'B'					; 1			
	movwf	temp_wr
	call	d_write	
	
	movlw	A'a'					;2
	movwf	temp_wr
	call	d_write	

	movlw	A't'					;3
	movwf	temp_wr
	call	d_write	

	movlw	A't'					;4
	movwf	temp_wr
	call	d_write
	movlw	A'e'					;5
	movwf	temp_wr
	call	d_write
	movlw	A'r'					;6
	movwf	temp_wr
	call	d_write
	movlw	A'y'					;7
	movwf	temp_wr
	call	d_write

	movlw	A'V'					;8
	movwf	temp_wr
	call	d_write

	movlw	A' '					;9
	movwf	temp_wr
	call	d_write
	movlw	A'<'					;10
	movwf	temp_wr
	call	d_write
	movlw	A' '					;11
	movwf	temp_wr
	call	d_write
	movlw	A'0'					;12
	movwf	temp_wr
	call	d_write
	movlw	A'.'					;13
	movwf	temp_wr
	call	d_write
	
	movlw	A'7'					;14
	movwf	temp_wr
	call	d_write
	movlw	A'5'					;15
	movwf	temp_wr
	call	d_write
	movlw	A'V'					;16
	movwf	temp_wr
	call	d_write

	return
;/**********************************************************/


;/*-------------------------------------------------*/
Disp_PlseWaitAtL1
;/* This routin display "Please Wait ... */

	call	LCDLine_1

	movlw	A' '					; 1			
	movwf	temp_wr
	call	d_write	
	
	movlw	A'P'					;2
	movwf	temp_wr
	call	d_write	

	movlw	A'e'					;3
	movwf	temp_wr
	call	d_write	

	movlw	A'a'					;4
	movwf	temp_wr
	call	d_write
	movlw	A's'					;5
	movwf	temp_wr
	call	d_write
	movlw	A'e'					;6
	movwf	temp_wr
	call	d_write
	movlw	A' '					;7
	movwf	temp_wr
	call	d_write

	movlw	A'W'					;8
	movwf	temp_wr
	call	d_write

	movlw	A'a'					;9
	movwf	temp_wr
	call	d_write
	movlw	A'i'					;10
	movwf	temp_wr
	call	d_write
	movlw	A't'					;11
	movwf	temp_wr
	call	d_write
	movlw	A' '					;12
	movwf	temp_wr
	call	d_write
	movlw	A'.'					;13
	movwf	temp_wr
	call	d_write
	
	movlw	A'.'					;14
	movwf	temp_wr
	call	d_write
	movlw	A'.'					;15
	movwf	temp_wr
	call	d_write
	movlw	A'.'					;16
	movwf	temp_wr
	call	d_write

	return
;/**********************************************************/

;/*-------------------------------------------------*/
Disp_InitAtL2
;/* This routin display "Initialization ... */

	call	LCDLine_2

	movlw	A' '					; 1			
	movwf	temp_wr
	call	d_write	
	
	movlw	A'I'					;2
	movwf	temp_wr
	call	d_write	

	movlw	A'n'					;3
	movwf	temp_wr
	call	d_write	

	movlw	A'i'					;4
	movwf	temp_wr
	call	d_write
	movlw	A't'					;5
	movwf	temp_wr
	call	d_write
	movlw	A'i'					;6
	movwf	temp_wr
	call	d_write
	movlw	A'a'					;7
	movwf	temp_wr
	call	d_write

	movlw	A'l'					;8
	movwf	temp_wr
	call	d_write

	movlw	A'i'					;9
	movwf	temp_wr
	call	d_write
	movlw	A'z'					;10
	movwf	temp_wr
	call	d_write
	movlw	A'i'					;11
	movwf	temp_wr
	call	d_write
	movlw	A'n'					;12
	movwf	temp_wr
	call	d_write
	movlw	A'g'					;13
	movwf	temp_wr
	call	d_write
	
	movlw	A'.'					;14
	movwf	temp_wr
	call	d_write
	movlw	A'.'					;15
	movwf	temp_wr
	call	d_write
	movlw	A'.'					;16
	movwf	temp_wr
	call	d_write

	return
;/**********************************************************/


;/*-------------------------------------------------*/
Disp_ConntBattery
;/* This routin display "Initialization ... */

	call	LCDLine_1

	movlw	A'C'					; 1			
	movwf	temp_wr
	call	d_write	
	
	movlw	A'o'					;2
	movwf	temp_wr
	call	d_write	

	movlw	A'n'					;3
	movwf	temp_wr
	call	d_write	

	movlw	A'n'					;4
	movwf	temp_wr
	call	d_write
	movlw	A'e'					;5
	movwf	temp_wr
	call	d_write
	movlw	A'c'					;6
	movwf	temp_wr
	call	d_write
	movlw	A't'					;7
	movwf	temp_wr
	call	d_write

	movlw	A' '					;8
	movwf	temp_wr
	call	d_write

	movlw	A'B'					;9
	movwf	temp_wr
	call	d_write
	movlw	A'a'					;10
	movwf	temp_wr
	call	d_write
	movlw	A't'					;11
	movwf	temp_wr
	call	d_write
	movlw	A't'					;12
	movwf	temp_wr
	call	d_write
	movlw	A'e'					;13
	movwf	temp_wr
	call	d_write
	
	movlw	A'r'					;14
	movwf	temp_wr
	call	d_write
	movlw	A'y'					;15
	movwf	temp_wr
	call	d_write
	movlw	A':'					;16
	movwf	temp_wr
	call	d_write

	return
;/**********************************************************/


;/*-------------------------------------------------*/
Disp_AtTP9_PressS1
;/* This routin display "Initialization ... */

	call	LCDLine_2

	movlw	A'+'					; 1			
	movwf	temp_wr
	call	d_write	
	
	movlw	A'V'					;2
	movwf	temp_wr
	call	d_write	

	movlw	A' '					;3
	movwf	temp_wr
	call	d_write	

	movlw	A't'					;4
	movwf	temp_wr
	call	d_write
	movlw	A'o'					;5
	movwf	temp_wr
	call	d_write
	movlw	A'T'					;6
	movwf	temp_wr
	call	d_write
	movlw	A'P'					;7
	movwf	temp_wr
	call	d_write

	movlw	A'9'					;8
	movwf	temp_wr
	call	d_write

	movlw	A','					;9
	movwf	temp_wr
	call	d_write
	movlw	A'P'					;10
	movwf	temp_wr
	call	d_write
	movlw	A'u'					;11
	movwf	temp_wr
	call	d_write
	movlw	A's'					;12
	movwf	temp_wr
	call	d_write
	movlw	A'h'					;13
	movwf	temp_wr
	call	d_write
	
	movlw	A' '					;14
	movwf	temp_wr
	call	d_write
	movlw	A'S'					;15
	movwf	temp_wr
	call	d_write
	movlw	A'1'					;16
	movwf	temp_wr
	call	d_write

	return
;/**********************************************************/














;/*********************************************************/
	
LCDLine_1
	banksel temp_wr
	movlw	0x80
	movwf	temp_wr
	rcall	i_write
	return
;	GLOBAL	LCDLine_1

LCDLine_2
	movlw	0xC0
	movwf	temp_wr
	rcall	i_write
	return
;	GLOBAL	LCDLine_2

	;write data
d_write
;	movff	temp_wr,TXREG
;	btfss	TXSTA,TRMT
;	goto	$-2
	rcall	LCDBusy
	bsf		STATUS, C	
	rcall	LCDWrite
	return
;	GLOBAL	d_write

	;write instruction
i_write
	rcall	LCDBusy
	bcf		STATUS, C
	rcall	LCDWrite
	return
 ;	GLOBAL	i_write


rlcd	macro	MYREGISTER
 IF MYREGISTER == 1
	bsf	STATUS, C
	rcall	LCDRead
 ELSE
	bcf	STATUS, C
	rcall	LCDRead
 ENDIF
	endm
;****************************************************************************




; *******************************************************************
LCDInit

; no needed here ---
;	bsf		LATD,7
;	bcf		TRISD,7
;	bsf		LATD,7
;	call	Delay30ms
;	clrf	PORTA
;-----------------------------
	nop
	nop
	nop
	nop
	nop



; The following steps help discharging the LCD - Lee

	clrf	PORTD
	clrf	LATD
	call	Delay30ms	
	call	Delay30ms	

; turn off LED D11, D12, D13
	bsf	PORTD,3
	bsf	PORTD,6
	bsf	PORTD,7
;----------------------------
	
	bsf	PORTD,2
	bsf	PORTD,1
	bsf	PORTD,0
	call	Delay30ms	
	call	Delay30ms	

	bcf	PORTD,2
	bcf	PORTD,1
	bcf	PORTD,0
;--------------------------
;	bsf	LCD_RS			; LCD register select line
;	bcf	LCD_RS			; LCD register select line
;
;	bsf	LCD_RW			; LCD read/write line
;	bcf	LCD_RW			; LCD read/write line
;
;	bsf	LCD_E		
;	bcf	LCD_E		
;-------------------------
	call	Delay30ms	
	call	Delay30ms	

; test done for LCD pin discharging ....
;---------------------------------


	movlw	b'00001111'  ; all Digital I/O
	movwf	ADCON1	

	banksel	COUNTER
	movlw	0xff			; Wait ~15ms @ 20 MHz
	movwf	COUNTER
lil1
	movlw	0xFF
	movwf	delay
	rcall	DelayXCycles
	decfsz	COUNTER,F
	bra	lil1
	
;0x20
;	movlw	b'00110000'		;#1 Send control sequence 

	banksel	temp_wr

	movlw	b'00100000'		;#1 Send control sequence 
	movwf	temp_wr
	bcf		STATUS,C
	rcall	LCDWriteNibble

	banksel	COUNTER
	movlw	0xff			;Wait ~4ms @ 20 MHz
	movwf	COUNTER

lil2
	banksel	delay
	movlw	0xFF
	movwf	delay
	rcall	DelayXCycles
	banksel	COUNTER
	decfsz	COUNTER,F
	bra	lil2


	banksel	temp_wr
;;0x28--2
;	movlw	b'00110000'		;#2 Send control sequence
	movlw	b'00100000'		;#2 Send control sequence
	movwf	temp_wr
	bcf		STATUS,C
	rcall	LCDWriteNibble

	banksel	delay
	movlw	0xFF			;Wait ~100us @ 20 MHz
	movwf	delay
	rcall	DelayXCycles

	banksel	temp_wr	
;0x28-08					
;	movlw	b'0011000'		;#3 Send control sequence
	movlw	b'10000000'		;
	movwf	temp_wr
	bcf		STATUS,C
	rcall	LCDWriteNibble

		;test delay
	banksel	delay
	movlw	0xFF			;Wait ~100us @ 20 MHz
	movwf	delay
	rcall	DelayXCycles

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;0C--0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	banksel	temp_wr	
;	movlw	b'00100000'		;#4 set 4-bit
	movlw	b'00000000'		;#4 set 4-bit
	movwf	temp_wr
	bcf		STATUS,C
	rcall	LCDWriteNibble
;0x08--08
	movlw	b'11000000'		;#4 set 4-bit
	movwf	temp_wr
	bcf		STATUS,C
	rcall	LCDWriteNibble

	banksel	delay	
	movlw	0xFF			;Wait ~100us @ 20 MHz
	movwf	delay
	rcall	DelayXCycles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;0x01
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;0x01-0
	banksel	temp_wr	
	movlw	b'00000000'		;#4 set 4-bit
	movwf	temp_wr
	bcf		STATUS,C
	rcall	LCDWriteNibble
;0x01--01
	movlw	b'00010000'		;#4 set 4-bit
	movwf	temp_wr
	bcf		STATUS,C
	rcall	LCDWriteNibble

	banksel	delay	
	movlw	0xFF			;Wait ~100us @ 20 MHz
	movwf	delay
	rcall	DelayXCycles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	call	LongDelay ;2ms
	call	LongDelay ;2ms
	call	LongDelay ;2ms
	call	LongDelay ;2ms

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;0x02
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;0x0-0
	banksel	temp_wr	
	movlw	b'00000000'		;#4 set 4-bit
	movwf	temp_wr
	bcf		STATUS,C
	rcall	LCDWriteNibble
;0x02
	movlw	b'00100000'		;#4 set 4-bit
	movwf	temp_wr
	bcf		STATUS,C
	rcall	LCDWriteNibble

	banksel	delay	
	movlw	0xFF			;Wait ~100us @ 20 MHz
	movwf	delay
	rcall	DelayXCycles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;	rcall	LCDBusy			;Busy?
	call	LongDelay ;2ms
	call	LongDelay ;2ms
	call	LongDelay ;2ms
	call	LongDelay ;2ms
	call	LongDelay ;2ms
	call	LongDelay ;2ms
	call	LongDelay ;2ms

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;0x0C
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;0x0C-0
;	movlw	b'00000000'		;#4 set 4-bit
;	movwf	temp_wr
;	bcf	STATUS,C
;	rcall	LCDWriteNibble
;;0x01--0C
;	movlw	b'11000000'		;#4 set 4-bit
;	movwf	temp_wr
;	bcf	STATUS,C
;	rcall	LCDWriteNibble
;

	banksel	temp_wr	
	movlw	0x4E
	movwf	temp_wr
	rcall	LCDBusy
	bsf		STATUS, C	
	rcall	LCDWrite


	banksel	delay
	movlw	0xFF			;Wait ~100us @ 20 MHz
	movwf	delay
	rcall	DelayXCycles
	return
;	GLOBAL	LCDInit	
;/ ***************************************************************************/

;/****************************************************************************/
;     _    ______________________________
; RS  _>--<______________________________
;     _____
; RW       \_____________________________
;                  __________________
; E   ____________/                  \___
;     _____________                ______
; DB  _____________>--------------<______
;
LCDWriteNibble
	btfss	STATUS, C		; Set the register select
	bcf		LCD_RS
	btfsc	STATUS, C	
	bsf		LCD_RS

	bcf	LCD_RW			; Set write mode

	bcf	LCD_D4_DIR		; Set data bits to outputs
	bcf	LCD_D5_DIR
	bcf	LCD_D6_DIR
	bcf	LCD_D7_DIR

	NOP				; Small delay
	NOP

	bsf	LCD_E			; Setup to clock data
	
	btfss	temp_wr, 7			; Set high nibble
	bcf	LCD_D7	
	btfsc	temp_wr, 7
	bsf	LCD_D7
	btfss	temp_wr, 6
	bcf	LCD_D6	
	btfsc	temp_wr, 6
	bsf	LCD_D6
	btfss	temp_wr, 5
	bcf	LCD_D5	
	btfsc	temp_wr, 5
	bsf	LCD_D5
	btfss	temp_wr, 4
	bcf	LCD_D4
	btfsc	temp_wr, 4
	bsf	LCD_D4	

	NOP
	NOP

	bcf	LCD_E			; Send the data

	return
; *******************************************************************





; *******************************************************************
LCDWrite
;	rcall	LCDBusy
	rcall	LCDWriteNibble
	banksel	temp_wr
	swapf	temp_wr,F
	rcall	LCDWriteNibble
	swapf	temp_wr,F

	return

;	GLOBAL	LCDWrite
; *******************************************************************





; *******************************************************************
;     _____    _____________________________________________________
; RS  _____>--<_____________________________________________________
;               ____________________________________________________
; RW  _________/
;                  ____________________      ____________________
; E   ____________/                    \____/                    \__
;     _________________                __________                ___
; DB  _________________>--------------<__________>--------------<___
;
LCDRead
	bsf	LCD_D4_DIR		; Set data bits to inputs
	bsf	LCD_D5_DIR
	bsf	LCD_D6_DIR
	bsf	LCD_D7_DIR		

	btfss	STATUS, C		; Set the register select
	bcf	LCD_RS
	btfsc	STATUS, C	
	bsf	LCD_RS

	bsf	LCD_RW			;Read = 1

	NOP
	NOP			

	bsf	LCD_E			; Setup to clock data

	NOP
	NOP
	NOP
	NOP

	btfss	LCD_D7			; Get high nibble
	bcf	temp_rd, 7
	btfsc	LCD_D7
	bsf	temp_rd, 7
	btfss	LCD_D6			
	bcf	temp_rd, 6
	btfsc	LCD_D6
	bsf	temp_rd, 6
	btfss	LCD_D5			
	bcf	temp_rd, 5
	btfsc	LCD_D5
	bsf	temp_rd, 5
	btfss	LCD_D4			
	bcf	temp_rd, 4
	btfsc	LCD_D4
	bsf	temp_rd, 4

	bcf	LCD_E			; Finished reading the data

	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP

	bsf	LCD_E			; Setup to clock data

	NOP
	NOP

	btfss	LCD_D7			; Get low nibble
	bcf	temp_rd, 3
	btfsc	LCD_D7
	bsf	temp_rd, 3
	btfss	LCD_D6			
	bcf	temp_rd, 2
	btfsc	LCD_D6
	bsf	temp_rd, 2
	btfss	LCD_D5			
	bcf	temp_rd, 1
	btfsc	LCD_D5
	bsf	temp_rd, 1
	btfss	LCD_D4			
	bcf	temp_rd, 0
	btfsc	LCD_D4
	bsf	temp_rd, 0

	bcf	LCD_E			; Finished reading the data

FinRd
	return
; *******************************************************************






; *******************************************************************
LCDBusy
	call	LongDelayLast		
	call	LongDelayLast		; lee,added this line

;	call	Delay30ms			; lee added this line
;	call	LongDelayLast		; lee,added this line

	return
					; Check BF
	banksel	LCD_INS
	rlcd	LCD_INS
	btfsc	temp_rd, 7
	bra	LCDBusy
	return

;	GLOBAL	LCDBusy
; *******************************************************************

; *******************************************************************
DelayXCycles
	decfsz	delay,F
	bra	DelayXCycles

	return
; *******************************************************************
	
Delay1ms			;Approxiamtely at 4Mhz
	banksel	delay
	clrf	delay
Delay_1
	nop
	decfsz	delay
	goto	Delay_1
	return


Delay30ms	;more than 30 at 4 Mhz	
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms

	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms

	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	return

LongDelay:
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	return


LongDelayLast
	call	Delay1ms
	call	Delay1ms
	call	Delay1ms
	return



	end