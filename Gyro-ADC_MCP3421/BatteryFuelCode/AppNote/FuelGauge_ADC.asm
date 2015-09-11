;/**************************************************************/
;/*  File Name: FuelGauge_ADC.asm
;/***************************************/
;/------ This routine performs the following tasks:
; (a) Writes configuration register of the MCP3421
; (b) Read the ADC results
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





	#include 	<p18f4550.inc>
	#include	FuelGauge_Project.inc
 	#include	FuelGaugeDemo_ADC.inc



ADC_VAR		UDATA
ACK_Flag	res 1
ReadyBitFlag	res 1
COUNT_Bits		res 1
COUNT_Byte		res 1
;SendACKret		res 1


	code

;/******************************************************************/
ADC_Write_Config
;------------------------------------------------------------------
; This routine writes the MCP3421 Configuration Register
; I2C Speed: 400 KHz
;------------------------------------------------------------------

;---- Write command Sequence: -------------------------------------
; start+1101(device code)+000(address bit:preprogrammed) +0(write) + Configuration (8 bits)
;------------------------------------------------------------------
	call	Start_bit_400KHz	
;-----------------------
Address_bits_400KHz_write

	call	Send_pulse_high_400KHz		; "1"
	call	Send_pulse_high_400KHz		; "1"
	call	Send_pulse_low_400KHz		; "0"
	call	Send_pulse_high_400KHz		; "1"
	call	Send_pulse_low_400KHz		; "0"
;	call	Send_pulse_low_400KHz		; "0"
;	call	Send_pulse_low_400KHz		; "0"

; for U5 --> Voltage

	banksel	IsitForU5_Volt
	btfss	IsitForU5_Volt,0			; U1 = current measurement, U5 = voltage measurement
	goto	ItsForU1_write				; for Current Measurement

	call	Send_pulse_high_400KHz		; U5 --> voltage
	call	Send_pulse_high_400KHz		; 
	goto	Write_bit
;-----------------------------------------------

ItsForU1_write
	call	Send_pulse_low_400KHz		; U1 --> current
	call	Send_pulse_low_400KHz		; 

Write_bit
	call	Send_pulse_low_400KHz		; writing "0"

;----- 9 th pulse -----
	call	LookingForACK_400KHz
;----------------------

; check ACK pulse flag
	banksel	ACK_Flag
	btfsc	ACK_Flag,0
	goto	ADC_Write_Config			; Repeat from start.  Not ACked yet!

;----- Send Configuration Bits -----------

	banksel	COUNT_Bits
	movlw	.8
	movwf	COUNT_Bits
Send_Config_400KHz
	banksel	Config_Data
	rlcf	Config_Data,1
	btfss	STATUS,C
	goto	Conf_400KHz_Low		
	call	Send_pulse_high_400KHz
	goto	JumpConf_400KHz
Conf_400KHz_Low
	call	Send_pulse_low_400KHz
JumpConf_400KHz
	decfsz	COUNT_Bits
	goto	Send_Config_400KHz
;---------------------------------------
;----- 9 th pulse -----
	call	LookingForACK_400KHz

; check ACK pulse flag
	banksel	ACK_Flag
	btfsc	ACK_Flag,0
	goto	ADC_Write_Config				; Repeat from start.  Not acknowlodged yet!
;----------------------
; Send Stop Pulse

	call	Send_StopBit_400KHz
	return

;/**************************************************************************/
ADC_Read_400KHz
; --------------------------------------------------------------------------
; This routine reads the ADC conversion results.
; I2C Speed: 400 kHz 
;
; Sequence: 
;	U5(Battery Volt): Start pulse +1101(device code)+000(address bit:preprogrammed) +1(read) + Configuration (8 bits)
;	U1(Current): Start pulse +1101(device code)+011(address bit:preprogrammed) +1(read) + Configuration (8 bits)
;---------------------------------------------------------------------------

	banksel ReadyBitFlag
	clrf	ReadyBitFlag

; turns-on sync pulse ---> only to trig better the SDA and SCL pules on scope
	bsf		Sync_LED11
	call	Start_bit_400KHz	

	bcf		Sync_LED11
;-----------------------
Address_bits_400KHz_read

	call	Send_pulse_high_400KHz		; "1"
	call	Send_pulse_high_400KHz		; "1"
	call	Send_pulse_low_400KHz		; "0"
	call	Send_pulse_high_400KHz		; "1"
	call	Send_pulse_low_400KHz		; "0"

; for U5 --> for Battery Voltage
	btfss	IsitForU5_Volt,0			; U1 = current measurement, U5 = voltage measurement
	goto	ItsForU1_read				; for current

	call	Send_pulse_high_400KHz		; U5 --> voltage  
	call	Send_pulse_high_400KHz		; 
	goto	Read_bit
;---------------------------------------------------------

ItsForU1_read
	call	Send_pulse_low_400KHz		; U1 --> current measurement
	call	Send_pulse_low_400KHz		; 

Read_bit
	call	Send_pulse_high_400KHz		; "1" --> Reading
;----- 9 th pulse -----

	call	LookingForACK_400KHz

; check ACK pulse flag
	btfsc	ACK_Flag,0
	goto	ADC_Read_400KHz				; Repeat from start. Not acknowlodged !
;----------------------

;------------------------------------------------------------
Read_ADC_3blocks

;-------- Instruction ---------------------------------------
; 	(a) MCU sends I2C clocks
;	(b) Keep the MCU' SDA line in trisate (default) as an input pin
;	(c) Give ACK pulse (bring SDA line low) after each byte
;	(d) Operate in 18 bit mode 
;------------------------------------------------------------

;-- Configure SDA_Pin as input
	banksel	PORTA	
	bcf		PORTA,5		; SDA
	bcf		LATA,5		; SDA

	bcf		PORTA,4		; SCL
	bcf		LATA,4		; SCL
	bcf		SCL_dir		; SCL pin --> output

	bsf		SDA_dir		; SDA pin --> input

	bcf		PORTA,5		; SDA
	bcf		LATA,5		; SDA
;-------------------------------------------------------------
; Initialize ADC_Value Array
	banksel	ADC_Value1
	CLRF	ADC_Value1
	CLRF	ADC_Value2
	CLRF	ADC_Value3
;	CLRF	ADC_Value4

;Reading_ADC Results
;Testing ready bit in Configuratin byte: continuous reading until it is "0"

	banksel	ADC_Value1
	lfsr	FSR0,ADC_Value1		; load FSR0 with ADC_Value1

;---------------------------------
	banksel	COUNT_Byte
	movlw	.3					; Read 3 bytes and another 1 byte after this for configuration byte
	movwf	COUNT_Byte

Read_OneByte_400KHz

	banksel COUNT_Bits
	movlw	.8					; read 8 bits not including ACK
	movwf	COUNT_Bits

Give_8Clocks_400KHz
	banksel	PORTA
	bcf		SCLK_I2C	
	nop
	nop
	nop	
	nop
	nop
	nop
	nop	
	nop

	bsf		SCLK_I2C		

;--- Data collection Begins ---- 

	bcf		STATUS,C
Test_3Bytes
	
Test_SDA_Pin
	btfss	SDA_I2C				; test SDA pin = RA4 pin
	goto	Shift_Bits
	bsf		STATUS,C		

Shift_Bits		
	rlcf	INDF0				;Shift digit 1 bit left
	bcf		STATUS,C

;---- Data collection end ----

	banksel	COUNT_Bits
	decfsz	COUNT_Bits
	goto	Give_8Clocks_400KHz
;--------------
	incf	POSTINC0,W
	bcf		STATUS,C		
;--------------

	nop
	bcf		SCLK_I2C		
	nop
	call	SendACK_400KHz

	banksel	COUNT_Byte
	decfsz	COUNT_Byte
	goto	Read_OneByte_400KHz
;	goto	Read_OneByte_400KHz


; now check ready bit
	
Read_ReadyBit_firstBit

	banksel	ReadyBitFlag

	banksel COUNT_Bits
	movlw	.1				; not including ACK
	movwf	COUNT_Bits

Give_8Clocks_Continue_1

;--------------------------------
	bcf		LATA,5
	bcf		PORTA,5		; SDA pin
	bsf		TRISA,5		; SDA --> input	
;-------------------------------

	bcf		SCLK_I2C		
	nop
	nop
	nop	
	nop
	nop
	nop	
	nop

	bsf		SCLK_I2C		

	btfss	PORTA,5				;Test if RDY_Bar is low on SDA pin = RA5 pin
	goto	ReadyBit_Done
	goto	KeepContinue
	
ReadyBit_Done
	banksel ReadyBitFlag
	bsf		ReadyBitFlag,0

KeepContinue
;-------------------------------------
	banksel COUNT_Bits
	movlw	.7					; 7 bits not including ACK
	movwf	COUNT_Bits

Give_8Clocks_Continue_2
	bcf		SCLK_I2C		
	nop
	nop
	nop
	nop	
	nop
	nop
	nop	
	nop

	bsf		SCLK_I2C		
	banksel	COUNT_Bits
	decfsz	COUNT_Bits
	goto	Give_8Clocks_Continue_2
	nop
	bcf		SCLK_I2C	
	nop

	goto	Final_OneByte	


	banksel	ReadyBitFlag
	btfss	ReadyBitFlag,0
	call	SendACK_400KHz


	banksel	ReadyBitFlag
	btfss	ReadyBitFlag,0
	goto	Read_ReadyBit_firstBit


; read one last byte after reading ready bit
;-------------------------------------------

Final_OneByte

	banksel COUNT_Bits
	movlw	.8						; 8 bits not including ACK
	movwf	COUNT_Bits

Give_Last8Clocks
	banksel	PORTA
	bcf		SCLK_I2C		
	nop
	nop
	nop	
	nop
	nop
	nop
	nop	
	nop

	bsf		SCLK_I2C		
;	nop
;	nop
;	nop
	banksel	COUNT_Bits
	decfsz	COUNT_Bits
	goto	Give_Last8Clocks
	nop
	bcf		SCLK_I2C		
	nop

	goto	Finish_Reading

; Done for the final one byte 

;-----------------------------------------------------

Finish_Reading
	call	Send_StopBit_400KHz

;----- testing Ready Bit------------------------------
	banksel	ReadyBitFlag
	btfss	ReadyBitFlag,0
	goto	ADC_Read_400KHz			; send a read command again
	return
	
;-----------------------------------------------------
LookingForACK_400KHz

	banksel	ACK_Flag
	clrf	ACK_Flag
; -- trisate the PORTA SDA pin input ---> Need to change to input for ACK response

	bcf		PORTA,5
	bcf		LATA,5
	bsf		SDA_dir			; SDA ---> Change to input

	bcf		SCLK_I2C		
	nop
	nop
	nop		; 1.5 us delay

	bsf		SCLK_I2C		
	nop
	nop
	nop		; 1.5 us delay

	btfsc	SDA_I2C
	bsf		ACK_Flag,0
	bcf		SCLK_I2C		
	
;---- Tristate MCU SDA pin to output after receiving ACK --------
	banksel	PORTA

	bcf		SDA_dir			; SDA ---> Change to Output
	bcf		SDA_I2C
	bcf		PORTA,5
	bcf		LATA,5
;---------------------------------------------------------------
	nop
	nop
	nop
	nop		; 2 us delay --> not necessary
	return


;/*************************************************************/

Start_bit_400KHz
;-- Configure I2C Pins as output
	
	bcf		SCL_dir		; SCL pin --> output
	bcf		SDA_dir		; SDA pin --> output

;----- Creating stop condition ---------------
	bsf		SCLK_I2C		
	nop
	nop
	bsf		SDA_I2C			;  creates stop condition first before tart condition
;							; depending on previous condition
;
;	nop
	call	delay_5us		 

;----- Creating start condtion --------------
	nop
	nop
	bsf		SCLK_I2C		
	nop
	nop
	call	delay_5us		
	nop
	nop

	bcf		SDA_I2C			;  creates stop condition first before tart condition
							; depending on previous condition
	nop
	nop
	nop
;-----------------------------------------
	nop
	nop
	nop
	nop

	nop
	nop
	nop
	bcf		SDA_I2C	; Start Pulse: SDA --> bring low from high during sclk is high
	nop
	nop
	nop
	nop
	nop
	nop
	bcf		SCLK_I2C		; sclk

	nop
	nop
	return


;/**********************************************************/
Send_StopBit_400KHz			; Stop bit: Bring SDA Pin to high from low when SCL is low
;-- Configure I2C Pins as output
	bcf		PORTA,5			; SDA
	bcf		LATA,5			; SDA
	bcf		SDA_dir			; SCL pin --> output

	bcf		SCLK_I2C
	bcf		SDA_I2C
;---------------------
	nop
	nop
	nop						; total 1.5 us
	bsf		SCLK_I2C		; bring up sclk hi
	nop
	nop
	bsf		SDA_I2C			; bring data line high
	nop
	nop
	nop
	nop
	nop						
; ---- tristate SDA pin to input again ---------
	bsf		SDA_dir
	bcf		SDA_I2C
	bcf		LATA,5
;-----------------------------------------------
	return


;/*******************************************************************/
Send_pulse_high_400KHz			; "1"

	bcf		SCL_dir
	bcf		SDA_dir
;------------------------

	bsf		SDA_I2C			; 1 st pulse --> bring data line high during sclk is low
	nop
	nop
	nop
	bsf		SCLK_I2C		; bring slck high
	nop						; 0.5 us
	nop						; 0.5 us  --> Total High time = 1.5 us.  
	bcf		SCLK_I2C		; bring down slck low
	return

Send_pulse_low_400KHz

;------------------------
	bcf		SCL_dir
	bcf		SDA_dir

;------------------------
	bcf		SDA_I2C			; 1 st pulse --> bring data line low during sclk is low
	nop
	nop
	nop
	bsf		SCLK_I2C		; bring slck high
	nop
	nop
	bcf		SCLK_I2C		; bring down slck low
	return


;/*******************************************************************/

SendACK_400KHz

; -- trisate SDA pin to output ---> to send ACK pulse 
	banksel	PORTA	
	bcf		PORTA,5		; SDA
	bcf		LATA,5		; SDA

	bcf		PORTA,4		; SCL
	bcf		LATA,4		; SCL

	bcf		SDA_dir		; SDA pin --> output
	bcf		SDA_I2C

	bcf		LATA,4		; SCL
	bcf		LATA,5		; SCL
;--------------------------------------------------------

	bcf		SCLK_I2C		; sclk
	nop
	bcf		SDA_I2C
	nop
	bsf		SCLK_I2C		; sclk
	nop
	nop
	nop
	bcf		SCLK_I2C		; sclk

;---- Release SDA pin to input after sending ACK ---------

	banksel	PORTA	
	bcf		PORTA,5		; SDA
	bcf		LATA,5		; SDA

	bsf		SDA_dir		; SDA pin --> input
	bsf		TRISA,5
	bcf		SDA_I2C
	bcf		PORTA,5		; sda
	bcf		LATA,5		; sda

;-----------------	
	nop
	nop
	nop
	nop
	nop
	nop

	return

;/******************************************************************/

Send_NotACK_400KHz

; -- trisate the PORTC SDA pin to output ----
	
	bcf		PORTA,5		; SDA
	bcf		LATA,5		; SDA

	bcf		PORTA,4		; SCL
	bcf		LATA,4		; SCL

	bcf		SDA_dir		; SDA pin --> output
	bcf		SDA_I2C

	bcf		LATA,4		; SCL
	bcf		LATA,5		; SCL
;------------------------------------------------

	bcf		SCLK_I2C		; sclk
	nop
	bcf		SDA_I2C
	nop
	bsf		SCLK_I2C		; sclk
	nop
	nop
	nop
	bsf		SDA_I2C
	nop
	nop
	nop
	bcf		SCLK_I2C		; sclk

;---Release SDA to input after sending ACK ------


	bcf		PORTA,5		; SDA
	bcf		LATA,5		; SDA

	bsf		SDA_dir		; SDA pin --> input

	bcf		SDA_I2C
	bcf		LATA,5		; scl
	bcf		PORTA,5		; scl
;------------------------------	
	nop
	nop
	nop
	nop
	nop
	nop

	return


;/*********************************************************/
;-------- Delay Loop for I2C ------------
; 8 MHz --> Tcy = 2MHz --> 0.5 us 
;----------------------------------------

delay_2_5us
	nop
	nop
	nop
	nop
	nop
	return

delay_5us
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	return

;/**********************************************************/


	end