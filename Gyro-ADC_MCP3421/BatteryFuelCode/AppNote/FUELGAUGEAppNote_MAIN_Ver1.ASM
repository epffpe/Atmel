;/**************************************************************/
;/*  File Name: FuelGaugeAppNote_Main.asm
;*		Dependent rutines:
;*			FuelGauge_ADC.asm
;*			FuelGauge_Buzzer.asm
;*			FuelGauge_Write_LCD.asm
;*			FuelGauge_Math.asm
;*			Binary_To_BCDConversion.asm
;*      
;*		Clock = 8 MHz, Internal Clock
;--------------------------------------------------------------
;     This is the main routin for the MCP3421 Fuel Gauge Demo Board.
;	  This firmware is modified from the "FuelGageDemo_Main_Ver1.asm" for recharging battery. 
;	  This firmware is for demonstration and example only. 
 
; 	  This routine performs the following tasks:
; 	  	(1) Get Battery Voltage using U5
; 	  	(2) Get Voltage drop on the current sensor using U1
; 			ADC Device Address:
;				 U5 = A3 --> Get voltage
;				 U1 = A0 --> Get Current
;			Note: 	MCP3421 Config sets:  18 bits.
;					ADC results  = ADC_Res1 + ADC_Res2 + ADC_Res3 
;					Multiply the ADC value with d'15625'  ---> h'3D09' ---> 1 LSB = 15.625 uV
;											---> Multilier1(00) + Multilier2(0x3D) +Multilier3(0x09) 
;      				Results are in 6 resisters  ---> Product1 + Product2 + Product3 + Product4 + Product5 + Product6
;
;		(3) Calculate Discharging Current using the voltage and resistor value
;		(4) Converts 48 binary to BCD
;		(5) Display the Battery Voltage and Current on LCD
;		(6) Calculate Fuel used
;		(7) Beeps if the battery voltage is less than 0.75V (when it uses 1.5V AAA battery)
;
;	This firmware enabled the Rechargeable Function in the MCP3421 battery fuel gauging demo board. 
;	Note: 
;		Any customer who need this rechargeable feature can contact Microchip Technology Inc for further information.
;		Battery is explosive and can cause fire or injury or accidents if inproperly handled.
;		This firmware uses the battery P/N: PL05052025, 170 mV Polymer Li-Ion Rechargeable battery. 
;		This firmware does not guarantee any other rechargeable batteries.
;		The users can modify this firmware for their purposes with their own risks and responsibilities.  

;		The users need to handle the battery carefully. Do not short or overcharge the battery.  
;		The users are responsible for any accidents that are occured by using the demo kit and this firmware.    
;		When the battery recharge function is enabled, this routine addes the folloing tasks:
;		(8) Calculate Fuel Remain
;		(9) Display the Fuel Used and Fuel Remain
;		(10)Recharge the Battery
;		(11)Stop the Recharge at Battery Volts = 4.0V when it uses the following battery type:
;					Battery Manufacturer: www.batteryspace.com (Powerizer)
;					Battery Type: 3.7V, 170 mAH, Polymer Li-Ion Cell
;					P/N: PL052025					 
;-------------------------------------------------------------------------
;       Ver 1.0
;       Date: 12-19-2007
;		AIPD
;		Microchip Technology Inc 
;
;------------------------------------------------------------------------
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

	list 		p=18f4550
	#include 	<p18f4550.inc>
	#include	FuelGauge_Project.inc
	#include	FuelGaugeAppNote_Main.inc

	ERRORLEVEL 0,-301,-302,-305  	; Messages, Warnings and Errors Printed
                        			; Ignore [301] => Processor Mismatch. 
                       				; Ignore [302] => Register in operand not in bank 0. 

; See more details in <p18f4550.inc>:\Microchip\MPASM Suite\ P18F4550.INC 
	CONFIG	FOSC = INTOSC_HS     ;Internal oscillator, HS for USB 
   	CONFIG	FCMEN = OFF
	CONFIG	IESO = OFF
	CONFIG	PWRT = OFF            
	CONFIG	BOR  = ON				;Brown-out Reset disabled in hardware and software
	CONFIG	BORV  = 2				;Brown-out Voltage bits
	CONFIG	WDT = OFF 
	CONFIG	MCLRE = ON  
	CONFIG	PBADEN = OFF 
	CONFIG	LVP = OFF  
    CONFIG	XINST = OFF				;Instruction set extension and Indexed Addressing mode disabled (Legacy mode)


	
variables	UDATA

bitcnt		RES 1
digcnt		RES 1

countT1		RES 1					;lsb
countT2		RES 1	
countT3		RES 1	
countT4		RES 1	
countT5		RES 1					;msb for gain=1
countT6		RES 1					;msb for gain = 8,4,2

;/* The following parameters are defined in subroutine */

digitT1		RES 1					;lsd
digitT2		RES 1
digitT3		RES 1
digitT4		RES 1
digitT5		RES 1
digitT6		RES 1
digitT7		RES 1
digitT8		RES 1
digitT9		RES 1
digitT10	RES 1
digitT11	RES 1
digitT12	RES 1
digitT13	RES 1					;msd

radix dec		; Very Important --> Specify default in Radix  


FoundFistDigit res 1

;variables	UDATA
ptr_pos		RES 1
ptr_count	RES 1
temp_1		RES 1
temp_2		RES 1
temp_3		RES 1

          
; Varuables for multiplication:

Product1	res 1
Product2	res 1
Product3	res 1
Product4	res 1
Product5	res 1
Product6	res 1
Multipland1	res	1
Multipland2	res	1
Multipland3	res	1
Multiplier1	res	3
Multiplier2	res	3
Multiplier3	res	3
;BitCount	res 1
;--------------------------

ADC_Value1	res 1
ADC_Value2	res 1
ADC_Value3	res 1
;ADC_Value4	res 1

ADC_Value1_temp	res 1
ADC_Value2_temp	res 1
ADC_Value3_temp	res 1


Config_Data	res 1
IsitForU5_Volt res 1

ADC_Sign	res 1
Gain_Selected	res 1
;-------------------------
Dividend1	res 1
Dividend2	res 1
Dividend3	res 1
Dividend4	res 1
Dividend5	res 1
Dividend6	res 1

Divisor1	res 1
Divisor2	res 1
Divisor3	res 1

Carry_AddTotal res 1
Voltage_Dispayed res 1

FSR0_TEMP	res 1	
PCLATH_TEMP res 1
STATUS_TEMP res 1
W_TEMP		res 1
BSR_Temp	res 1

Timer0_Interrupt res 1

;Variables for Addition
AddByteA		res 6
AddByteB		res 6
Carry_fromAdd 	res 1
Current_Used	res 6
;---------------------

I_remain_uAS	res 6
I_remain_mAH1	res 1
I_remain_mAH2	res 1
I_remain_mAH3	res 1
I_remain_mAH4	res 1
I_remain_mAH5	res 1
I_remain_mAH6	res 1

I_Init1_mAH		res 1
I_Init2_mAH		res 1
I_Init3_mAH		res 1
I_Init4_mAH		res 1
I_Init5_mAH		res 1
I_Init6_mAH		res 1

I_Init_uAS		res 6

Disp_FuelUsed	res 1
Disp_RemainFuel	res 1

RB0Int_Found	res 1	
SelBettryType res 1
Delay_Returned	res 1
OUTER		res 1	
INNER		res 1

;Users_Battery	res 1
PORTBInt_Found	res 1
ChargingBat		res 1
FirstPowered	res 1
LessThan1or2V	res 1
LowerThan0_75V	res 1
HigherThan4V	res 1
NotChargedBat 	res 1
;---------------------


;---------------------
RESET_VEC	code 0x0000
RESET_VECTOR
	goto	Start				

HIGH_INT_VEC	code 0x0008		
	goto	ISR				

LOW_INT_VEC		code 0x0018

	goto	ISR


REST	code
	

;------------------------------------------------------------------------------+
;                                                                              |
;    ISR()                                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    The interrupt service routine generates the needed events.                |
;    It also handles standard interrupts, like delay routines or timers.       |
;    It should be as short as possible, to provide best reaction times.        |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
ISR	
	banksel	W_TEMP
	movwf   W_TEMP	         				;Save off current W register contents
	movff	STATUS,STATUS_TEMP
	movff	BSR, BSR_Temp
							 
	movff	PCLATH,PCLATH_TEMP				;Save PCLATH
	movff	FSR0,FSR0_TEMP					;Save FSR


CheckTIMER0_Int

	btfss	INTCON,TMR0IF					; Check if Timer1 Interrupt  Flag Set
	bra		CheckRBO_Int					; ... No, then end search
	btfss	INTCON,TMR0IE					; Check if Timer1 Interrupt Enabled
	bra		CheckRBO_Int

	banksel	Timer0_Interrupt		
	incf	Timer0_Interrupt,1

	bcf		INTCON,TMR0IF
	bra		Endisr

;--------------------------

CheckRBO_Int
	BTFSS	INTCON, INT0IF					;INT0 FLAG
	GOTO	CheckINT1_Int					;Check Int1(PortB1) Interrupt  	
	bcf		INTCON, INT0IF					; INT0 FLAG
	BTFSS	INTCON, INT0IE					; PortB RBO INTERRUPT ENABLE BIT
	GOTO	CheckINT1_Int					;Check Int1(PortB1) Interrupt
;	GOTO	RB0_Interrupt	

RB0_Interrupt
;--------
	btfsc	PORTB,0	
	goto	End_RB0_Interrupt				;No, its not a true SW event
;--------
	call	Debounce_RB0
	sublw	.1			  					;Is Switch Closed?	
	btfss	STATUS,Z					
	goto	End_RB0_Interrupt  				;No
	banksel	RB0Int_Found
	incf	RB0Int_Found,1					;YES, interrupt occured
	bcf		PORTD,3							;TURN ON LED13 

Wait_RBOSW_done
	banksel	PORTB
	btfss	PORTB,0				
	GOTO	Wait_RBOSW_done	
	bsf		PORTD,3							;TURN OFF LED13

End_RB0_Interrupt 
	BCF		INTCON, INT0IF		
	GOTO	Endisr

;--------------------------

CheckINT1_Int
	BTFSS	INTCON3, INT1IF					; INT1 FLAG, RB1 pin
	GOTO	CheckINT2_Int					;Check Int2(PortB2) Interrupt  	

	BTFSS	INTCON3, INT1IE					; PortB RB1 INTERRUPT ENABLE BIT
	GOTO	CheckINT2_Int					;Check Int1(PortB1) Interrupt
RB1_Interrupt
;--------
	btfsc	PORTB,1	
	goto	End_RB1_Interrupt				; No, its not a true SW event
;--------

	call	Debounce_RB1
	sublw	.1			  					;Is Switch Closed?	
	btfss	STATUS,Z					
	goto	End_RB1_Interrupt  				;No
	banksel	PORTBInt_Found
	bsf		PORTBInt_Found,1				; YES, RB1 interrupt occured

	
Wait_RB1SW_done
	bcf		PORTD,3							; TURN ON LED13
	banksel	PORTB
	btfss	PORTB,1			
	GOTO	Wait_RB1SW_done	

End_RB1_Interrupt 
	bsf		PORTD,3							; TURN OFF LED13 
;	bcf		PORTD,3							; TURN ON LED13 
	banksel	INTCON3
	BCF		INTCON3, INT1IF
	BCF		INTCON3, INT2IF
	GOTO	Endisr
;-----------------------------

CheckINT2_Int
	banksel	INTCON3
	BTFSS	INTCON3, INT2IF					; INT2 FLAG, RB2 pin
	GOTO	CheckRB4567_Int					;(RB4, RB5, RB6, RB7) Interrupt  	
	BTFSS	INTCON3, INT2IE					; PortB RB1 INTERRUPT ENABLE BIT
	GOTO	CheckRB4567_Int					;(RB4, RB5, RB6, RB7) Interrupt  	
RB2_Interrupt
;--------
	btfsc	PORTB,2	
	goto	End_RB2_Interrupt				;No, its not a true SW event
;--------

	bcf		PORTD,3							;TURN ON LED13 

	call	Debounce_RB2
	sublw	.1			  					;Is Switch Closed?	
	btfss	STATUS,Z					
	goto	End_RB2_Interrupt  				;No
	banksel	PORTBInt_Found
	bsf		PORTBInt_Found,2				; YES, RB2 interrupt occured
	bcf		PORTD,3							; TURN ON LED13 

Wait_RB2SW_done
	banksel	PORTB
	btfss	PORTB,2			

	GOTO	Wait_RB2SW_done	
	bcf		PORTD,3							; TURN OFF LED13

End_RB2_Interrupt 
	banksel	INTCON3
	BCF		INTCON3, INT1IF
	BCF		INTCON3, INT2IF
	GOTO	Endisr
;-----------------------------

CheckRB4567_Int							;(RB4, RB5, RB6, RB7) Interrupt
	BTFSS	INTCON, RBIF				; Int flag for RB4,5,6,7
	GOTO	Endisr		  	
	BTFSS	INTCON, RBIE				; PortB RB4,5,6,7 INTERRUPT ENABLE BIT
	GOTO	Endisr		  	
CheckRB4567_6_Interrupt
;--------
	btfsc	PORTB,6	
	goto	End_RB6_Interrupt			; No, its not a true SW event
;--------
	call	Debounce_RB6
	sublw	.1			  				;Is Switch Closed?	
	btfss	STATUS,Z					
	goto	CheckRB4567_7_Interrupt  	;No
	banksel	PORTBInt_Found
	bsf		PORTBInt_Found,6			; YES, RB6 interrupt occured
	bcf		PORTD,3						; TURN ON LED13 


Wait_till_RB6SW_done
	banksel	PORTB
	btfss	PORTB,6						; sw1 = RB6
	GOTO	Wait_till_RB6SW_done	
	bsf		PORTD,3						; TURN OFF LED13

End_RB6_Interrupt 
	BCF		INTCON, RBIF
	GOTO	Endisr
;-------------------------------
CheckRB4567_7_Interrupt

;--------
	btfsc	PORTB,7	
	goto	End_RB7_Interrupt			; No, its not a true SW event
;--------

	call	Debounce_RB7
	sublw	.1			  				;Is Switch Closed?	
	btfss	STATUS,Z					
	goto	CheckRB4567_4_Interrupt  	;No
	banksel	PORTBInt_Found
	bsf		PORTBInt_Found,7			; YES, RB7 interrupt occured
	bcf		PORTD,3						; TURN ON LED13 

Wait_till_RB7SW_done
	banksel	PORTB
	btfss	PORTB,7						; Probably not connected
	GOTO	Wait_till_RB7SW_done	
	bsf		PORTD,3						; TURN OFF LED13

End_RB7_Interrupt 
	BCF		INTCON, RBIF
	GOTO	Endisr
;------------------------------
CheckRB4567_4_Interrupt
;--------
	btfsc	PORTB,4	
	goto	End_RB4_Interrupt			; No, its not a true SW event
;--------

	call	Debounce_RB4
	sublw	.1			  				;Is Switch Closed?	
	btfss	STATUS,Z					
	goto	CheckRB4567_5_Interrupt 	;No
	banksel	PORTBInt_Found
	bsf		PORTBInt_Found,4			; YES, RB4 interrupt occured
	bcf		PORTD,3						; TURN ON LED13 

Wait_till_RB4SW_done
	banksel	PORTB
	btfss	PORTB,4			
	GOTO	Wait_till_RB4SW_done	
	bsf		PORTD,3						; TURN OFF LED13

End_RB4_Interrupt 
	BCF		INTCON, RBIF
	GOTO	Endisr
;-----------------------------
CheckRB4567_5_Interrupt
;--------
	btfsc	PORTB,5	
	goto	End_RB5_Interrupt			; No, its not a true SW event
;--------

	call	Debounce_RB5
	sublw	.1			  				;Is Switch Closed?	
	btfss	STATUS,Z					
	goto	End_RB5_Interrupt  			;No
	banksel	PORTBInt_Found
	bsf		PORTBInt_Found,5			; YES, RB4 interrupt occured
	bcf		PORTD,3						; TURN ON LED13 

Wait_till_RB5SW_done
	banksel	PORTB
	btfss	PORTB,5			
	GOTO	Wait_till_RB5SW_done	
	bsf		PORTD,3						; TURN OFF LED13

End_RB5_Interrupt 
	BCF		INTCON, RBIF
	GOTO	Endisr
;-------------------------------
		
Endisr	

	movff	BSR_Temp, BSR
	movwf   W_TEMP	         			;Save off current W register contents
	movff	STATUS_TEMP,STATUS			;Restore STATUS

	movff	FSR0_TEMP,FSR0				;Restore FSR
	RETFIE	0x01					
;------------------------------------------------------------------------------


PROG_main 	CODE

stan_table				;table for standard code
;-----------------------------------------
	data	"   Microchip    "      ;0
	data	"Fuel Gauge Demo "      ;16

	data	" Battery In-Use "		;32
	data	" 170 mAH, 3.7V  "		;48

	data	"BatteryVolt.<50%"		;64 
	data	"S1: for Charging"		;80 

	data	" Under Charging "		;96 
	data	"S1: StopCharging"		;112

; For Demo Unit
	data	"Disconnect JP2 &"		;128	---> For Demo Unit with Non-Rechargeable battery
	data	"ConntJP1,Push S1"		;144
;---------------------------------------

; Training and App Note version with rechargeable Battery
	data	"Disconnect JP1 &"		;160	---> For rechargeable battery
	data	"ConntJP2,Push S1"		;176
;---------------------------------------
;	data	" Please Wait ..."		;160	---> Changed to call routin	
;	data	" Initializing .."		;176	---> Changed to call routin	
;---------------------------------------
; Demo Unit
;	data	"Connect 1.5V Bat"		;192	  ---> 1.5V, 1500 mAH
;	data	"at TP9. Press S1"		;208
;---------------------------------------
; for Training Unit and App Note Algorithm:	
	data	"S2:1.5V  Battery"		;192	  ---> 1.5V, 1500 mAH
	data	"S3:LiPoly,170mAH"		;208
;---------------------------------------
 
	data	"AAA,1.5V,1500mAH"		;224
	data	"FuelRemanUnknown"		;240			; 240 is the last words  


;------------------------------------------
	nop
	nop



Start	
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
	nop
	nop
	nop
	nop
	nop
	nop
	nop


	call	FuelGaugeInit
	call	BuzzerStartUp_ON
	call	delay_100ms
	call	delay_100ms



	call 	LCDInit

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
	nop
	nop
	nop
	nop

; This program is using only non-rechargeable battery 
	banksel	SelBettryType	
	clrf	SelBettryType			; 0: AAA BAttery, 1: Rechargeable Battery: Li_polymer, 170 mAH, 4.2V
;-----------------------------------------------------------


; ----Enables Interrupts: TMR0, PortB ----------------------

	clrf	RCON			; disabled interrupt priority
	movlw	b'00010111'		; IPEN = RCON<7> --> Interrupt priority
	movwf	RCON

	movlw	b'00000101'		; All PortB Pull-up Disabled, (RB0, RB1, RB2) --> Interrupt-on-rising edge		
	movwf	INTCON2			; TMR0--> High Priority, PortB --> High Priority

	movlw	b'11111000'		; (RB1, RB2) --> High Priority, Interrupt enabled. 		
	movwf	INTCON3			; 

	movlw	b'11111000'		; Enable TMR0 and PORTB Interrupt (RB0, RB1, RB2, RB4, RB5, RB6, RB7)
	movwf	INTCON			; To Enable Timer0 Interrupt

	banksel	PORTBInt_Found
	clrf	PORTBInt_Found

;---------- Display Greetings ------------------

	nop	
	banksel ptr_pos
	movlw	.0				;send "Microchip" to LCD
	movwf	ptr_pos
	call	stan_char_1


	banksel ptr_pos
	movlw	.16				;send "Fuel Gauge Demo" to LCD
	movwf	ptr_pos
	call	stan_char_2

	call	Buzzer_OFF	

;-------------------------------------------
	call	delay_1s
	call	delay_1s
	call	delay_1s

	banksel	RB0Int_Found
	clrf	RB0Int_Found
;	goto	SelectBatteryType	
;;	call	Wait_SW3Interrupt



; To rearrange the Jumper SW:
	banksel ptr_pos
	movlw	.128				;"DisConnect JP2"		;128
	movwf	ptr_pos
	call	stan_char_1


	banksel ptr_pos
	movlw	.144				;;"Connect JP1: S1 "		;144
	movwf	ptr_pos
	call	stan_char_2

	call	delay_1s			;delay for display
	call	delay_1s			;delay for display

	banksel	PORTBInt_Found
	clrf	PORTBInt_Found


S1forReadyToStart					; Checking SW1 (RB6)
	banksel	PORTBInt_Found
	btfss	PORTBInt_Found,6		; SW1 (RB6)				
	bra		S1forReadyToStart

	banksel	PORTBInt_Found
	clrf	RB0Int_Found
	clrf	PORTBInt_Found


;--------------------------------------
	call	Disp_ConntBattery			; ---> Connect Battery:	--> 16 Characters
	call	Disp_AtTP9_PressS1			; ---> +V toTP9,Push S1	--> 16 Characters
;--------------------------------------

	banksel	PORTBInt_Found
	clrf	PORTBInt_Found

S1forBatteryConnect					; Checking SW1 (RB6)
	banksel	PORTBInt_Found
	btfss	PORTBInt_Found,6		; SW1 (RB6)				
	bra		S1forBatteryConnect

	banksel	PORTBInt_Found
	clrf	PORTBInt_Found




;------------------------------------------------
; The commands select Rechargeable or Non-Rechargeable Battery
;------------------------------------------------
SelectBatteryType

;-----------------------------
	banksel ptr_pos				; Is it AAA Battery ?
	movlw	.192				;"SW3: AAA Battery"		;192 ---> 1.5V, 1500 mAH
	movwf	ptr_pos
	call	stan_char_1

	banksel ptr_pos				; Is it rechargeable 42V Battery ?
	movlw	.208				; "SW2: 170mAH,4.2V"	;208 
	movwf	ptr_pos
	call	stan_char_2
;-----------------------------


	banksel	PORTBInt_Found
	clrf	PORTBInt_Found


	banksel	RB0Int_Found
	clrf	RB0Int_Found



CheckRB0orRB1						; RB0 ---> SW3 ---> Recharegable: 
									; Display (V,I,RemainFuel, Used Fuel), 
									; and Charging battery if less than 50% and Beeps for charging.   
									;  RB1 ---> SW2 ----> AAA Battery --> Display (V,I, and Used Fuel).  
	banksel	RB0Int_Found
	movlw	b'11111111'
	andwf	RB0Int_Found
	btfsc	STATUS,Z				; Z -->1: Register is zero, Z -->0: Register is not zero	
	goto	CheckifSW2Selected		

	banksel	SelBettryType
	bsf		SelBettryType,0			; 1: Rechargeable Battery: Li_polymer, 170 mAH, 4.2V
									; 0: AAA BAttery
	goto	Bat_LiPoly170mAH

	banksel	RB0Int_Found
	clrf	RB0Int_Found

CheckifSW2Selected					; Checking SW2 (RB1)
	banksel	PORTBInt_Found
	btfss	PORTBInt_Found,1		; Z -->1: Register is zero, Z -->0: Register is not zero	
	goto	CheckRB0orRB1

	banksel	SelBettryType	
	clrf	SelBettryType			; 1: Rechargeable Battery: Li_polymer, 170 mAH, 4.2V
									; 0: AAA BAttery
	banksel	RB0Int_Found
	clrf	RB0Int_Found

	goto	Bat_AAA1_5V
;------ Above are for Training unit: Select Rechargeable or Non-Rechargeable Battery --------------






Bat_AAA1_5V
;------"Display Battery Type: for non-Rechargeable Battery" -------
	nop	
	banksel ptr_pos
	movlw	.32				;" Battery In-Use "		;32
	movwf	ptr_pos
	call	stan_char_1
	nop
	nop

	banksel ptr_pos
	movlw	.224				;	data	"AAA,1.5V,1500mAH"		;224
	movwf	ptr_pos
	call	stan_char_2

;---------------------
	call	delay_1s
	call	delay_1s
	call	delay_1s

	goto	Prepare_ToBegin	
;	goto	Check_SW3Int
	
Bat_LiPoly170mAH
Battery_Inused			; Display battery: P/N: PL-02550 = 127 mAH, 3.7V in load, 4.2 V with no load 	
;--------"Display Battery Type: for Rechargeable Battery" -------
	nop	
	banksel ptr_pos
	movlw	.32				;" Battery In-Use "		;32
	movwf	ptr_pos
	call	stan_char_1
	nop
	nop

	banksel ptr_pos
	movlw	.48				;" 170 mAH, 3.7V  "		;48
	movwf	ptr_pos
	call	stan_char_2

;---------------------
	call	delay_1s
	call	delay_1s
	call	delay_1s
;---------------------
	banksel	RB0Int_Found
	clrf	RB0Int_Found
	goto	Prepare_ToBegin	

;------ "Greeting until MCU prepare data to display" --------
Prepare_ToBegin
;---------------------------
;	nop	
;	banksel ptr_pos
;	movlw	.160				;"Please Wait ...."		;160
;	movwf	ptr_pos
;	call	stan_char_1
;
;	banksel ptr_pos
;	movlw	.176				;" Initialization "		;176
;	movwf	ptr_pos
;	call	stan_char_2
;---------------------------

	call	Disp_PlseWaitAtL1
	call	Disp_InitAtL2



	
	goto	Start_VoltMeasurement	

;-----------------------------------------------------------




BatterySelted_170mAh
;-----------------------------------------------------------

;  I_Init_mAH ---> 3 bytes
;  example: 1000 mAH = 3E8 mAH in hex 
;		     170mAH = AA hex mAH	
;			  10 mAH = 0A hex mAH  --> tested
;			 100 mAH = 64 hex mAH
;----------------------------------------
; for 170mAH Battery: 170mAH = AA hex mAH	

	banksel	I_Init1_mAH
	movlw	0xAA		; 170 mAH 
	movwf	I_Init1_mAH		; LSB
	movlw	0x00
	movwf	I_Init2_mAH
	movlw	0x00
	movwf	I_Init3_mAH		; MSB

; Store initial currents in 6 bytes
; Unit = mAseconds
; example: I_init_mAH = 1000 mAH = 1000mA x60x60 =  3600000mA in dec =  36EE80 hex in mA
;		            170mAH = 170 x 60x60 = 612000mA in dec = 956A0 hex in mA	
;

; Initial Value of T_CurrentRemain = I_Init/10 = 
; test with 2* Current_Used =2*( 1365322 uAs) = 29AA94 hex

; Now let start with Battery in uAseconds with:
;	 10 mAH = 10000*3600 uASec = 3600000 dec = 2255100 hex
; 	 1000 mAH = 1000*1000*3600 uASeconds =  D693A400 in hex 
;	 170mAH = 170*1000*3600 = 612000000 uAs in dec = 247A6100 hex in uAs

; for 170 mAH battery 
;	banksel	I_remain_uAS
;	movlw	0x00
;	movwf	I_remain_uAS		; LSB
;	movlw	0x61
;	movwf	I_remain_uAS+1
;	movlw	0x7A
;	movwf	I_remain_uAS+2
;	movlw	0x24
;	movwf	I_remain_uAS+3
;	movlw	0x00
;	movwf	I_remain_uAS+4
;	movlw	0x00
;	movwf	I_remain_uAS+5		; MSB
;----------------------------------------------------------------
; In uAS unit
	banksel	I_Init_uAS
	movlw	0x00
	movwf	I_Init_uAS			; LSB
	movlw	0x61
	movwf	I_Init_uAS+1
	movlw	0x7A
	movwf	I_Init_uAS+2
	movlw	0x24
	movwf	I_Init_uAS+3
	movlw	0x00
	movwf	I_Init_uAS+4
	movlw	0x00
	movwf	I_Init_uAS+5		; MSB
;---------------------------------------------------------------

;----------- To Display User Slected Battery Type --------------
;	banksel	countT6
;	clrf	countT6	
;	clrf	countT6				; MSB for gain =2,4,8
;	clrf	countT5				; MSB for gain =1
;	clrf	countT4
;
;	banksel	I_Init3_mAH
;	movff	I_Init3_mAH,countT3	 	
;	movff	I_Init2_mAH,countT2
;	movff	I_Init1_mAH,countT1	; LSB
;
;	call 	Bin48_bcd_volts
;	call	Disp_BatteryType_170mAH
	goto	Start_VoltMeasurement		
;--------------------------------------------------------------

BatterySelted_1000mAh
;--------------------------------------------------------------

;  I_Init_mAH ---> 3 bytes
;  example: 1000 mAH = 3E8 mAH in hex 
;		     170mAH = AA hex mAH	
;			  10 mAH = 0A hex mAH  --> tested
;			 100 mAH = 64 hex mAH
;----------------------------------------
; for 1000mAH Battery
; 1000mAH = 3E8 mAH in hex

	banksel	I_Init1_mAH
	movlw	0xE8		; 1000 mAH 
	movwf	I_Init1_mAH		; LSB
	movlw	0x03
	movwf	I_Init2_mAH
	movlw	0x00
	movwf	I_Init3_mAH		; MSB

; Store initial currents in 6 bytes
; Unit = mAseconds
; example: I_init_mAH = 1000 mAH = 1000mA x60x60 =  3600000mA in dec =  36EE80 hex in mA
;		            170mAH = 170 x 60x60 = 612000mA in dec = 956A0 hex in mA	
;

; Initial Value of T_CurrentRemain = I_Init_mAH/10 = 
; test with 2* Current_Used =2*( 1365322 uAs) = 29AA94 hex

; Now let start with Battery in uAseconds with:
;	 10 mAH = 10000*3600 uASec = 3600000 dec = 2255100 hex
; 	 1000 mAH = 1000*1000*3600 uASeconds =  D693A400 in hex 
;	 170mAH = 170*1000*3600 = 612000000 uAs in dec = 247A6100 hex in uAs

; for 170 mAH battery 
;	banksel	I_remain_uAS
;	movlw	0x00
;	movwf	I_remain_uAS		; LSB
;	movlw	0x61
;	movwf	I_remain_uAS+1
;	movlw	0x7A
;	movwf	I_remain_uAS+2
;	movlw	0x24
;	movwf	I_remain_uAS+3
;	movlw	0x00
;	movwf	I_remain_uAS+4
;	movlw	0x00
;	movwf	I_remain_uAS+5		; MSB
;
;--- for 1000 mA battery in uAs -------------
	banksel	I_Init_uAS
	movlw	0x00
	movwf	I_Init_uAS		; LSB
	movlw	0xA4
	movwf	I_Init_uAS+1
	movlw	0x93
	movwf	I_Init_uAS+2
	movlw	0xD6
	movwf	I_Init_uAS+3
	movlw	0x00
	movwf	I_Init_uAS+4
	movlw	0x00
	movwf	I_Init_uAS+5		; MSB

	goto	Start_VoltMeasurement		


;--------------------------------------------------------------
	banksel	PORTC
	bsf		TRISC,6			; tristate the PROG pin to input (high impedance) during charging 
							; ---> Important to keep the PROG pin in high impedance
							; during charing mode. If it is low, it draws a lot of current and the STAUS pin will show
							; unpredictable value !
;---------------------------------------------------------------


Start_VoltMeasurement

	bsf		PORTD,3					; TURN OFF LED13 
	banksel	RB0Int_Found
	clrf	RB0Int_Found	


test_buzzer1
	call	Buzzer_OFF


	nop
	nop

	banksel	Timer0_Interrupt
	clrf	Timer0_Interrupt

	banksel Disp_FuelUsed
	clrf	Disp_FuelUsed
	clrf	Disp_RemainFuel

	banksel	RB0Int_Found
	clrf	RB0Int_Found	

	banksel	FirstPowered
	clrf	FirstPowered
;----------------------------------------------------
Volts_Measurement
; Measure Volts and Display the Results
;-----------------------------------

;Write configuration register
	banksel	Config_Data
;	movlw	b'10011100'		; Continuous mode, 18 bit mode, gain = 1
;	movlw	b'10001100'		; change later to 18 bit, one-shot, gain=1
;	movlw	b'10001111'		; change later to 18 bit, one-shot, gain=8
;	movlw	b'10011100'		; Continuous mode, 18 bit mode, gain = 1
	movlw	b'10001100'		; change later to 18 bit, one-shot, gain=1
	movwf	Config_Data		; put this code before calling ADC_Write_Config

; ---- Gain Select -------------------------
	clrf	Gain_Selected
;	bsf		Gain_Selected,0			; Gain=2
;	bsf		Gain_Selected,1			; Gain=4
;	bsf		Gain_Selected,2			; Gain=8
;------------------------------------------


	banksel	Gain_Selected
	btfsc	Gain_Selected,0
	bra		Set_Gain_2
	btfsc	Gain_Selected,1
	bra		Set_Gain_4
	btfsc	Gain_Selected,2
	bra		Set_Gain_8

Set_Gain_1	
	banksel	Config_Data	
	bcf	Config_Data,0
	bcf	Config_Data,1
	bra	Now_WriteConf

Set_Gain_2	
	banksel	Config_Data	
	bsf	Config_Data,0
	bcf	Config_Data,1
	bra	Now_WriteConf
Set_Gain_4	
	banksel	Config_Data	
	bcf	Config_Data,0
	bsf	Config_Data,1
	bra	Now_WriteConf
Set_Gain_8
	banksel	Config_Data	
	bsf	Config_Data,0
	bsf	Config_Data,1
	bra	Now_WriteConf


Now_WriteConf
; turn on sync pulse
	bsf		Sync_LED11
	banksel	IsitForU5_Volt
	bsf		IsitForU5_Volt,0		; 1: for battery voltage, 0: for current measurement
	call	ADC_Write_Config		; put in initialization loop
	bcf		Sync_LED11


Reading_ADC_Value
	call	ADC_Read_400KHz				; U5: for voltage
	bcf		Sync_LED11
;	ADC Values ---> ADC_Value1 (MSB) + ADC_Value2 + ADC_Value3 (LSB)  

	banksel ADC_Value1
	movff	ADC_Value1,	ADC_Value1_temp		; copy these values to use in "Chk_BatIfLowerthan1V" and "Chk_BatIfLowerthan2V"
	movff	ADC_Value2,	ADC_Value2_temp
	movff	ADC_Value3,	ADC_Value3_temp
	
	call	Convert_ADCvalues
	call	Display_Voltage

	call	Current_Measurement
	call	Display_Current

	call	delay_1s
	call	delay_1s


; Check Battery Type Here:

	banksel	SelBettryType
	btfss	SelBettryType,0			; 1: Rechargeable Battery: Li_polymer, 170 mAH, 4.2V
									; 0: AAA BAttery
	bra		DoforAAABattery	
	bra		DoforLiPolymer

DoforAAABattery
;/*********************************************************************/
;/** (1) Display only: (V, I, Fuel Used)
;/** (2) Check if Battery Voltage < 0.75V (or 50%) 
;/** (3) Make Buzz on if the Battery Volt < 50%
;/** (4) Repeats (1) - (3)
;/********************************************************************/
	banksel	LowerThan0_75V
	clrf	LowerThan0_75V

	call	Chk_BatIfLowerthan0_75V	

	banksel	LowerThan0_75V
	btfss	LowerThan0_75V, 0		; 	LowerThan0_75V(1) --> Battery volt less than 0.75V, 	
									;   LowerThan0_75V(0) --> Battery volt higher than 0.75V, 
	goto	Continue_NormalMeas
;	call	Disp_BatLessThan2V

	call	Disp_BatLowerThan0_75V

;----------	
	call	Buzzer1p1To1p5KHz_ON
	call	Buzzer_OFF
;---------
	goto	Continue_NormalMeas	

DoforLiPolymer

;------------------------------------------------------------
; This routine is for 170 mAh, 3.7V, Rechargeable Battery 
;------------------------------------------------------------
;------- Check if it is  in charging mode  -----------------
	banksel	ChargingBat
	btfsc	ChargingBat,0
	goto	ItsUnderChaging
	goto	NotInChargingMode

ItsUnderChaging
	call	ChargingBattery				; Its in charging mode

	goto	Volts_Measurement


NotInChargingMode
; Check if battery is less than 2V before continue measurement

	banksel	FirstPowered
	btfss	FirstPowered,0
	goto	ChkIfChargedBat
;	bra		CheckIfNotConnected
	goto	CheckIfLessThan2V

ChkIfChargedBat
	banksel	FirstPowered
	bsf		FirstPowered,0		; come here only once after reset 

	call	IsBatHigherThan4V	

	banksel	HigherThan4V
	btfsc	HigherThan4V,0			;1: higher than 4V, 0: less than 4V
	goto	ItsFullyChargedBat
; Not fully charged battery
	banksel	NotChargedBat
	bsf		NotChargedBat, 0		; 0--> not fully charged battery
	banksel	HigherThan4V
	clrf	HigherThan4V	

	goto	CheckIfLessThan2V		

ItsFullyChargedBat
	banksel	NotChargedBat
	clrf	NotChargedBat

	banksel	HigherThan4V
	clrf	HigherThan4V	

	
;------------------------------------------------------
CheckIfLessThan2V
;-----------------------------
; Check Battery Volts and do the following actions:
; (a) Go to normal measurement if greater than 2V
; (b) Choice if User want to recharge ---> not selected --> go to normal measuremnt, if selected ---> do the charging
;----------------------------- 
	banksel	LessThan1or2V
	clrf	LessThan1or2V

	call	Chk_BatIfLowerthan2V	

	banksel	LessThan1or2V
	btfss	LessThan1or2V, 1		; 	LessThan1or2V(0) --> Battery volt less than 1V, 	
									;   LessThan1or2V(1) --> Battery volt less than 2V, 
	goto	Continue_NormalMeas

	call	Disp_BatLessThan2V
	call	ChekIfWantRecharge

	sublw	.1			  			;Want to recharge battery ?	
	btfss	STATUS,Z					
	goto	Continue_NormalMeas  	;No, Don't want to recharge battery ...
	call	RechargeBattery			;Yes, Want to recharge
	goto	Continue_NormalMeas
		
;------------------------------------------------------

skip_simulation_U5		; Voltage
Continue_NormalMeas
;	goto	Comput_BatteryFuel


;---- Battey Fuel Computation ----------
Comput_BatteryFuel
;----- Now multiply the measured current with time ----
; Algorithm:
; Actual Current coming out from the battery = (Current Measured in uA)* (Time_Interval_in second) between current and previous measuements
; Time_Inerval in second is recorded using Timer0 interrupt for every second based on 8 MHz internal oscillator  
; The Time_Interval is recorded in "Timer0_Interrupt". 


CurrentMult_Timer0Int				; Current draw = Measured current * No. of Timer0 Interrupt

; Preparing to calculate the current draws during the last time interval (No. of Timer0 Interrupt)
	banksel	Dividend1			; ---> Current in uA
	movff	Dividend1,AddByteA	; LSB 
	movff	Dividend2,AddByteA+1
	movff	Dividend3,AddByteA+2
	movff	Dividend4,AddByteA+3
	movff	Dividend5,AddByteA+4 	; MSB for gain =1
	movff	Dividend6,AddByteA+5	; MSB for gain =2,4,8

	banksel	Dividend1			; ---> Current in uA
	movff	Dividend1,AddByteB	; LSB 
	movff	Dividend2,AddByteB+1
	movff	Dividend3,AddByteB+2
	movff	Dividend4,AddByteB+3
	movff	Dividend5,AddByteB+4 	; MSB for gain =1
	movff	Dividend6,AddByteB+5	; MSB for gain =2,4,8
	
;--- wait for Timer0 interrupt at least for once --------
Wait_ForTMR0Int
	movlw	0xff		
	banksel	Timer0_Interrupt
	andwf	Timer0_Interrupt		; make it sure the Timer0_Interrupt is not zero
	btfsc	STATUS,Z				; Z -->1: Register is zero, Z -->0: Register is not zero
	goto	Wait_ForTMR0Int

	banksel	Carry_AddTotal
	clrf	Carry_AddTotal


Add_IforNtimes
; current just measured * No of seconds (using Timer0 interval: Interrupt occurs every second):
; Add the measured current to AddByteB N-1 times, N = Number of timer0 interrupt. 
; Timer0 Interrupt event --> every 1 second.  

	banksel	Timer0_Interrupt
	decfsz	Timer0_Interrupt,1
;	decfsnz	Timer0_Interrupt,1		; ---> causes a compiler error
	goto	Keep_AddsCurrents
	goto	Done_CurrentXInt


Keep_AddsCurrents
	banksel	Dividend1			; ---> Current just measured in uA
	movff	Dividend1,AddByteA	; LSB 
	movff	Dividend2,AddByteA+1
	movff	Dividend3,AddByteA+2
	movff	Dividend4,AddByteA+3
	movff	Dividend5,AddByteA+4 	; MSB for gain =1
	movff	Dividend6,AddByteA+5	; MSB for gain =2,4,8


; AddBytesB = AddByteA (Dividend) + AddByteB (Dividend) ---> AddByteA (Dividend)*No.of Timer0 Interrupt

	call	Add_Two_6Bytes		; When current is discharged

;----------------
; 	Add_Two_6Bytes -->  AddBytesA + AddBytesB =Carry_fromAdd + AddBytesB
; Add results = Carry_fromAdd + AddByteB_6 + AddByteB_5 + AddByteB_4 +AddByteB_3 +AddByteB_2 +AddByteB_1
;----------------
	
	goto	Add_IforNtimes	

;-----------------------------------------------------------------------

Done_CurrentXInt

Current_NoTimerInt

; calculate total current used ---> Current_Used = Current_Used + current measured now (AddByteB)
	
	banksel	ADC_Sign
;	bsf		ADC_Sign,0 ; for now until testing done

	btfss	ADC_Sign,0
	goto	Add_toTotalCurrentRemain		; Current is charged into the battery	
	bra		Add_toTotalCurrentUsed			; Current is coming out from the battey --> consumed


Add_toTotalCurrentUsed

;------------------------------------------------------------------------
;Calculate Current_Used = Current_Used (AddByteA) + Current measured * N of timer0 interrupt (AddByteB)
;------------------------------------------------------------------------

; AddByteB Array has currents added for the last interval events

; current_used array has the sum of all current used 
; rearrange array	
	banksel	Current_Used			; Current_used = Total current used
	movff	Current_Used,AddByteA	; LSB
	movff	Current_Used+1,AddByteA+1	
	movff	Current_Used+2,AddByteA+2	
	movff	Current_Used+3,AddByteA+3	
	movff	Current_Used+4,AddByteA+4	
	movff	Current_Used+5,AddByteA+5


	call	Add_Two_6Bytes		; When current is discharged

;----------------
; 	Add_Two_6Bytes -->  AddBytesA + AddBytesB =Carry_fromAdd + AddBytesB
; Add results = Carry_fromAdd + AddByteB_6 + AddByteB_5 + AddByteB_4 + AddByteB_3 + AddByteB_2 + AddByteB_1
;----------------

; rearrange array ---> Added the result (AddByteB) to the Current_Used
	banksel	AddByteB
	movff	AddByteB, Current_Used	; LSB
	movff	AddByteB+1, Current_Used+1	
	movff	AddByteB+2, Current_Used+2	
	movff	AddByteB+3, Current_Used+3	
	movff	AddByteB+4, Current_Used+4	
	movff	AddByteB+5, Current_Used+5 ; MSB

;	goto	Calc_RemainCurrent			; it has total current used in 6 bytes
										; now calculate remaining currents
	goto	Display_TotalUsedFuel
;-------------------------------------------------------------------------------
; when battery is charged !
Add_toTotalCurrentRemain
	goto	Ok_ToAddCurrent

;--------- The following routine is disabled -----------------------------------
Check_IfOverCharging
; Note: Before keep add, it is important to find out if the battery is over charging. 
;       The following routine test if the I_Init_uAS > 170 mA. 
 
;--------------------------------------------------------------
;       SubtractByteA+5 (MSB)  ....... SubtractByteA (LSB)
;     - SubtractByteB+5 (MSB) ......... SubtractByteB (LSB)
;    =  SubtractByteA+5 (MSB)  ....... SubtractByteA (LSB)
;-------------------------------------------------------------- 

	banksel	AddByteB	; AddbyteB has a measured current during the current looping 
	movff	AddByteB, SubtractByteB	; LSB
	movff	AddByteB+1, SubtractByteB+1
	movff	AddByteB+2, SubtractByteB+1
	movff	AddByteB+3, SubtractByteB+1
	movff	AddByteB+4, SubtractByteB+1
	movff	AddByteB+5, SubtractByteB+5 ; MSB


; 170 mAH in uAS unit
	banksel	SubtractByteA
	movlw	0x00
	movwf	SubtractByteA		; LSB
	movlw	0x61
	movwf	SubtractByteA+1
	movlw	0x7A
	movwf	SubtractByteA+2
	movlw	0x24
	movwf	SubtractByteA+3
	movlw	0x00
	movwf	SubtractByteA+4
	movlw	0x00
	movwf	SubtractByteA+5		; MSB

	call	Subtract_6Bytes_6Bytes   

;--------------------------------------------------------------
;       SubtractByteA+5 (MSB)  ....... SubtractByteA (LSB)
;     - Current_Used+5 (MSB) ......... Current_Used (LSB)
;    =  SubtractByteA+5 (MSB)  ....... SubtractByteA (LSB)
;
;	Note:  	Carry  = 0: Success --> A > B or A == B
;  			Carry  = 1: Fail --->  A < or  B
;-------------------------------------------------------------- 



; need to check the following return:
	btfsc	STATUS,C				; C:0 ---> successful
	goto	FullyCharged			; Unsuccessful: SubtractByteA < SubtractByteB ---> 170 mA <  FuelCharged
	goto	Ok_ToAddCurrent 		; Successful_sub:  SubtractByteA > SubtractByteB ---> 170 mA > FuelCharging

FullyCharged						; This routine will be improved later. For now, it just do not add to the initial current anymore. 
;	goto	Calc_RemainCurrent
	goto	Display_TotalUsedFuel	
;--------- The following routine is disabled -------------------


Ok_ToAddCurrent

;-----------------------------------------
; Add remaining Current -->  I_Remain_uAS =  I_Remain_uAS + Measured Current (AddBytesB)              
;-----------------------------------------
; rearrange array	
	banksel	I_Init_uAS			; Current_remains
	movff	I_Init_uAS, AddByteA	; LSB
	movff	I_Init_uAS+1, AddByteA+1	
	movff	I_Init_uAS+2, AddByteA+2	
	movff	I_Init_uAS+3, AddByteA+3	
	movff	I_Init_uAS+4, AddByteA+4	
	movff	I_Init_uAS+5, AddByteA+5
	
	call	Add_Two_6Bytes		; When current is charged into battery ---> add to the register for remaining current

; rearrange array ---> current remaining ---> used different arrays in a case not to mass up due to errors !
	banksel	AddByteB
	movff	AddByteB, I_Init_uAS	; LSB
	movff	AddByteB+1, I_Init_uAS+1	
	movff	AddByteB+2, I_Init_uAS+2	
	movff	AddByteB+3, I_Init_uAS+3	
	movff	AddByteB+4, I_Init_uAS+4	
	movff	AddByteB+5, I_Init_uAS+5 ; MSB
;----------------------------------------------------------------


;---------------- Displaying Fuel Used --------------------------

Display_TotalUsedFuel

;---------------------------------------------------------------
; (b) Fuel_used in mAH = Current_Used/(1000*3600),  mAH
;---------------------------------------------------------------
; Algorithm:
; When it converting a small number of used fule in uAS to mAH,
; the fixed point division (1000*3600) loses remainders after decimal point (gives no remainder in some cases). 
; This gives a zero value below (3600)*(1000) uAs. 
; So, instead of dividing the "Current_Used" by (3600)*(1000),
; it divides by "Current_Used" by only (36).
; The 10^5 factor will be taken care of at the LCD display.
; For example:
;  "Current_Used" = 1000.01085mAH = 3600039062uAs
; "Current_Used" --> 3600039062uAs/36 = 100001085.1 -->5F5E53D --> 100001085 (dec)
; In LCD display --> 1000.01085 mAH by shifting a decimal point 5 points to the right. 
;----------------------------------------------------------------- 

; now, let it converts the uA in Current_Used to mAH ---> divide by 36 (dec) = 24 (hex),  (deficit --> 10^5)
	banksel	Divisor1
	movlw	0x24
	movwf	Divisor1		; LSB
	movlw	0x00
	movwf	Divisor2		; 
	movlw	0x00
	movwf	Divisor3		; MSB
;----------------------------------------
	banksel	Current_Used
	movff	Current_Used, Product6	; LSB
	movff	Current_Used+1, Product5
	movff	Current_Used+2, Product4
	movff	Current_Used+3, Product3
	movff	Current_Used+4, Product2
	movff	Current_Used+5, Product1 ; MSB

;----------------------------------------
	call	Divide_6by_3Bytes		; Current_Used(6 bytes) div. (1000*3600 --> 3 byes) = current in mAH
						
; return  = Dividend6(MSB) + Dividend5 + ---- Dividend1 (LSB)
;         = Current_Used in mAH
;-----------------------------------------

	banksel	countT1
	clrf	countT1
	clrf	countT2
	clrf	countT3
	clrf	countT4
	clrf	countT5
	clrf	countT6
;---------------------------------

	banksel	Dividend1
	movff	Dividend6,countT6	; MSB for gain =2,4,8
	movff	Dividend5,countT5	; MSB for gain =1
	movff	Dividend4,countT4
	movff	Dividend3,countT3
	movff	Dividend2,countT2
	movff	Dividend1,countT1	; LSB

	call 	Bin48_bcd_volts
Display_UsedFuel		; in mAH

	call	Display_FuelUsed

	call	delay_1s
	call	delay_1s

;-------------------------------
	banksel	SelBettryType
	btfss	SelBettryType,0			; 1: Rechargeable Battery: Li_polymer, 170 mAH, 4.2V
									; 0: AAA BAttery
	goto	Volts_Measurement
	bra		Calc_RemainFuels
;------------------------------
Calc_RemainFuels

; Check if the battery is started with fully charged battery or not

	banksel	NotChargedBat
	btfss	NotChargedBat,0		; 0---> fully charged, 1---> not fully charged battery
	goto	DoCalRemainFuels
;	bra		SkipCalRemainFuels
	
SkipCalRemainFuels

;-----------------------------
	banksel ptr_pos
	movlw	.240				;"FuelRemanUnknown"		;240 
	movwf	ptr_pos
	call	stan_char_1

	call	Disp_StdUnderCharged

;	banksel ptr_pos
;	movlw	.256				;"StartedUnderChgd"		;256
;	movwf	ptr_pos
;	call	stan_char_2
;-----------------------------


	call	delay_1s
	call	delay_1s		;delay for display

	nop
	nop

	goto	Volts_Measurement


DoCalRemainFuels

;-----------------------------------------
; calculate remaining battery fuel:
; I_remaining = T_IStored Current - I_Used
;------------------------------------

	banksel	I_Init_uAS
	movff	I_Init_uAS, SubtractByteA	; LSB
	movff	I_Init_uAS+1, SubtractByteA+1
	movff	I_Init_uAS+2, SubtractByteA+2
	movff	I_Init_uAS+3, SubtractByteA+3
	movff	I_Init_uAS+4, SubtractByteA+4
	movff	I_Init_uAS+5, SubtractByteA+5 ; MSB


	banksel	Current_Used
	movff	Current_Used, SubtractByteB	; LSB
	movff	Current_Used+1, SubtractByteB+1
	movff	Current_Used+2, SubtractByteB+2
	movff	Current_Used+3, SubtractByteB+3
	movff	Current_Used+4, SubtractByteB+4
	movff	Current_Used+5, SubtractByteB+5 ; MSB


; --- Algorithm for Calculating Remaining Currents ------------
; (a) Remaining Currents = Initial Currents - Currents Used
; 
; (b) Initial_Currents_uAs ----> SubtractByteA 
; (c) Current_Used(==Total Used Current in uAs) --->  SubtractByteB
; (d) Calculation: 
;         SubtractByteA = SubtractByteA - Current_Used
;         Remaining Currents <---- SubtractByteA
;--------------------------------------------------------------

;--------------------------------------------------------------
;       SubtractByteA+5 (MSB)  ....... SubtractByteA (LSB)
;     - Current_Used+5 (MSB) ......... Current_Used (LSB)
;    =  SubtractByteA+5 (MSB)  ....... SubtractByteA (LSB)
;-------------------------------------------------------------- 

	call	Subtract_6Bytes_6Bytes   
; need to check the following return:
	btfsc	STATUS,C	
	goto	FullyDischarged			; SubtractByteA < SubtractByteB ---> 170 mA < FuelUsed
	goto	Successful_sub			; SubtractByteA > SubtractByteB ---> 170 mA > FuelUsed

FullyDischarged						; SubtractByteA < SubtractByteB ---> 170 mA < FuelUsed
									; Battery is completely discharged ! ---> Just shows the previous remaining fuel calculation
										; ---> Most likely around 0 mAH
	goto	Convert_uATomAH



Successful_sub
;---------------------------------
; SubtractByteA+5   --> MSB
; SubtractByteA   --> LSB
;---------------------------------
;confirming --- OK
;Now, Update the Remaining Current(Fuel) Arrays 

	banksel	SubtractByteA
	movff	SubtractByteA,I_remain_uAS	; LSB
	movff	SubtractByteA+1,I_remain_uAS+1
	movff	SubtractByteA+2,I_remain_uAS+2
	movff	SubtractByteA+3,I_remain_uAS+3
	movff	SubtractByteA+4,I_remain_uAS+4
	movff	SubtractByteA+5,I_remain_uAS+5		; MSB
;----------------------------------

; Calculate % of remaining battery capacity
; Algorithm ---> (T_CurrentRemain/I_Init) x 100% ---> 100% can be treated in display routine
;  T_CurrentRemain ---> 6 bytes
;  I_Init ---> 3 bytes
;  Rearrange Divisor(I_Init)
;  example: 1000 mAH = 1000mA x60x60 =  3600000mA in dec =  36EE80 hex in mA
;		   170mAH = 170 x 60x60 = 612000mA in dec = 956A0 hex in mA	

;----------------------------------------

Convert_uATomAH

; now let it converts the uA in T_CurrentRemain to mAH ---> divide by (1000*3600) --> 36EE80
	banksel	Divisor1
	movlw	0x80
	movwf	Divisor1		; LSB
	movlw	0xEE
	movwf	Divisor2		; 
	movlw	0x36
	movwf	Divisor3		; MSB
;----------------------------------------
	movff	I_remain_uAS, Product6		; LSB
	movff	I_remain_uAS+1, Product5	
	movff	I_remain_uAS+2, Product4	
	movff	I_remain_uAS+3, Product3	
	movff	I_remain_uAS+4, Product2
	movff	I_remain_uAS+5, Product1		; MSB

;----------------------------------------
	call	Divide_6by_3Bytes		; T_CurrentRemain(6 bytes) div. (1000*3600 --> 3 byes) = current in mAH
								    ; This result will be divided again using I_Init for % of fuel. 
	; return  = Dividend6(MSB) + Dividend5 + ---- Dividend1 (LSB)
;-----------------------------------------

	banksel	Dividend1
	movff	Dividend1,I_remain_mAH1	; LSB
	movff	Dividend2,I_remain_mAH2	
	movff	Dividend3,I_remain_mAH3
	movff	Dividend4,I_remain_mAH4
	movff	Dividend5,I_remain_mAH5
	movff	Dividend6,I_remain_mAH6	; MSB

;-------------------------------------------------

; (a) Fuel_Remaining in mAH = (I_Remain_mAH * 100,000 %)/I_Init_mAH
;      Note: The reasons using 100,000% is not to lose number after decimal when the numurate is divided.
;			 The extra 1000 will be taken care of at the LCD display. 
; (b) Fuel_used in mAH = Current_Used/(1000*3600),  mAH
;--------------------------------------------------

;(a) Fuel_Remaining in mAH = (I_Remain_mAH * 100,000 %)/I_Init_mAH

; Multiply 100,000% to the  I_remain_mAH ---> It could be better to multiply before converting to mAH 
;							--> revisit later !


; 3 bytes should be enough for mAH unit
; example: 1000 mAH ---> 3E8 (mAH) in hex

	banksel	I_remain_mAH1
	movff	I_remain_mAH1, Multipland3	; LSB
	movff	I_remain_mAH2, Multipland2	; 
	movff	I_remain_mAH3, Multipland1	; MSB

; 100000% --> 186A0 hex
	banksel	Multiplier1			
	MOVLW   0x01			; MSB
	MOVWF   Multiplier1
	MOVLW   0x86
	MOVWF   Multiplier2
	MOVLW   0xA0
	MOVWF   Multiplier3		; LSB

	call	Multiply_3x3bytes		
; Return is: Product1 (MSB) + Product2 + Product3 + Product4 + Product5 + Product6 (LSB)
;----------------------------------------

	banksel	I_Init1_mAH
	movff	I_Init1_mAH, Divisor1		; LSB
	movff	I_Init2_mAH, Divisor2		
	movff	I_Init3_mAH, Divisor3		; MSB

;----------------------------------------
	call	Divide_6by_3Bytes			; The return result is the remaining fuel in %

; Division ---> (Product1 + Product2 + ..Product6)/(Divisor3+Divisor2+Divisor1) 
; Return --> Dividend6+Dividend5+...Dividend1
;------------------------------------------
   

; Now display the remaining fuel data in ratio
; Remember that the display will take care of x1000 factor
	banksel	countT1
	clrf	countT1
	clrf	countT2
	clrf	countT3
	clrf	countT4
	clrf	countT5
	clrf	countT6
;---------------------------------

	banksel	Dividend1
	movff	Dividend6,countT6	; MSB for gain =2,4,8
	movff	Dividend5,countT5	; MSB for gain =1
	movff	Dividend4,countT4
	movff	Dividend3,countT3
	movff	Dividend2,countT2
	movff	Dividend1,countT1	; LSB

	call 	Bin48_bcd_volts

;-----------------------------------------
; Display the remaining fuel in percentage on Line 1:
	call	Disp_FuelRemPerct	
;-----------------------------------------

; Display remaining fuel in mAh on Line 2
	banksel	countT1
	clrf	countT1
	clrf	countT2
	clrf	countT3
	clrf	countT4
	clrf	countT5
	clrf	countT6
;---------------------------------
	banksel	I_remain_mAH1
	movff	I_remain_mAH1, countT1	; LSB
	movff	I_remain_mAH2, countT2	; 
	movff	I_remain_mAH3, countT3	; MSB

	call 	Bin48_bcd_volts

;----------------------------------------
; Display remaining fuel in mAh on Line 2:
	call	Disp_FuelRemmAH	
;----------------------------------------
	call	delay_1s
	call	delay_1s		;delay for display

	nop
	nop

Skip_DispFuelUsed
	goto	Volts_Measurement
;----------------------------------------------------------------------	
;----Standard code, Place characters on line-1-------------------------
stan_char_1
	call	LCDLine_1		;mvoe cursor to line 1 

	banksel	ptr_count
	movlw	.16			;1-full line of LCD
	movwf	ptr_count


	movlw	UPPER stan_table
	movwf	TBLPTRU
	movlw	HIGH stan_table
	movwf	TBLPTRH
	movlw	LOW stan_table
	movwf	TBLPTRL

	banksel	ptr_pos
	movf	ptr_pos,W
	addwf	TBLPTRL,F
	clrf	WREG
	addwfc	TBLPTRH,F
	addwfc	TBLPTRU,F

stan_next_char_1
	tblrd	*+
	movff	TABLAT,temp_wr			
	call	d_write			;send character to LCD

	decfsz	ptr_count,F		;move pointer to next char
	bra		stan_next_char_1

;	movlw	"\n"			;move data into TXREG
;	movwf	TXREG			;next line
;	btfss	TXSTA,TRMT		;wait for data TX
;	goto	$-2
;	movlw	"\r"			;move data into TXREG
;	movwf	TXREG			;carriage return
;	btfss	TXSTA,TRMT		;wait for data TX
;	goto	$-2

	return

;----Standard code, Place characters on line-2--------------------------
stan_char_2	
	call	LCDLine_2		;move cursor to line 2 
	movlw	.16			;1-full line of LCD
	movwf	ptr_count
	movlw	UPPER stan_table
	movwf	TBLPTRU
	movlw	HIGH stan_table
	movwf	TBLPTRH
	movlw	LOW stan_table
	movwf	TBLPTRL
	movf	ptr_pos,W
	addwf	TBLPTRL,F
	clrf	WREG
	addwfc	TBLPTRH,F
	addwfc	TBLPTRU,F

stan_next_char_2
	tblrd	*+
	movff	TABLAT,temp_wr
	call	d_write			;send character to LCD

	decfsz	ptr_count,F		;move pointer to next char
	bra	stan_next_char_2

; these are for RS232 ---> Nor used here
;	movlw	"\n"			;move data into TXREG
;	movwf	TXREG			;next line
;	btfss	TXSTA,TRMT		;wait for data TX
;	goto	$-2
;	movlw	"\r"			;move data into TXREG
;	movwf	TXREG			;carriage return
;	btfss	TXSTA,TRMT		;wait for data TX
;	goto	$-2

	return
;----------------------------------------------------------------------



;----------- 100ms Delay for 8 MHz clock, Tcy = 0.5 us ----------------
delay_100ms				; 100 ms ---> 100000 us ---> 200000 Tcy
	banksel	temp_1
	movlw	0xFF
	movwf	temp_1
	movlw	0xFF
	movwf	temp_2

d100l1					; This gives approximately: 255*3*255 + 255*3 + 255*4 = 196860 Tcy =  98.43 ms
	decfsz	temp_1,F
	bra	d100l1
	decfsz	temp_2,F
	bra	d100l1
	return

;----------- 1s Delay for 8 MHz clock -----------------------------------
delay_1s					; 1 s ---> 1000000 us ---> 2000000 Tcy
	banksel	temp_1
	movlw	0xFF
	movwf	temp_1
	movwf	temp_2
	movlw	0x0A
	movwf	temp_3
d1l1					   ; This gives approximately: 255*3*255*10 + 255*3 + 255*4 + 10*5 = 1952585 Tcy =  976 ms
	decfsz	temp_1,F
	bra	d1l1
	decfsz	temp_2,F
	bra	d1l1
	decfsz	temp_3,F
	bra	d1l1
	return	



Wait_SW1Interrupt
	; Stay here until SW1 has an interrupt event ...
Delay_SW1Interrupt
	bcf		PORTD,3					; TURN ON LED13 
	banksel	PORTBInt_Found
	btfss	PORTBInt_Found,6		; sw1			
	bra		Delay_SW1Interrupt
	clrf	PORTBInt_Found
	return


Wait_SW3Interrupt
	; Stay here until SW3 (RB0) has an interrupt event ...

	banksel	RB0Int_Found
	clrf	RB0Int_Found	
Delay_SW3Interrupt
	bcf		PORTD,3					; TURN ON LED13 
	movlw	b'11111111'
	andwf	RB0Int_Found
	btfsc	STATUS,Z				; Z -->1: Register is zero, Z -->0: Register is not zero	
	bra	Delay_SW3Interrupt	
	banksel	RB0Int_Found
	clrf	RB0Int_Found	
	return
	




;*** Two's complement the 24-bit number in A24_B *************
;*************************************************************
TwosComp24

	banksel	ADC_Value1
	comf	ADC_Value1,f		; This is the one's complement...
	comf	ADC_Value2,f
	comf	ADC_Value3,f
	incfsz	ADC_Value3,f		; Now add one to get the two's...
	goto	TC24_Exit
	incfsz	ADC_Value2,f
	goto	TC24_Exit
	incfsz	ADC_Value1,f

TC24_Exit
	return





;****************************************************************************
;DEBOUNCE() - Pushbutton Debouncing Routine
;			- Returns 1 If Switch Is Closed
;           - Returns 0 If Switch Is Open
;****************************************************************************
Debounce_RB0
;	global	Debounce
	banksel	DELAYTIME
	movlw	DELAYTIME	  	; Delay
	call	Delay
	btfsc	PORTB,0 	; Is The RB0 PIN 0 (Switch2) ZERO?
	goto	Open			
Closed
	retlw	1	  				
Open	
	retlw	0

Debounce_RB1
;	global	Debounce
	banksel	DELAYTIME
	movlw	DELAYTIME	  	; Delay
	call	Delay
	banksel	PORTB
	btfsc	PORTB,1 	; Is The RB1  ZERO?
	goto	Open			
Closed_RB1
	retlw	1	  				
Open_RB1	
	retlw	0

Debounce_RB2
;	global	Debounce
	banksel	DELAYTIME
	movlw	DELAYTIME	  	; Delay
	call	Delay

	banksel	PORTB
	btfsc	PORTB,2 	; Is The RB2  ZERO?
	goto	Open			
Closed_RB2
	retlw	1	  				
Open_RB2	
	retlw	0



Debounce_RB4
;	global	Debounce
	banksel	DELAYTIME
	movlw	DELAYTIME	  	; Delay
	call	Delay

	banksel	PORTB
	btfsc	PORTB,4 	; Is The RB4 ZERO?
	goto	Open			
Closed_RB4
	retlw	1	  				
Open_RB4	
	retlw	0
	

Debounce_RB5
;	global	Debounce
	banksel	DELAYTIME
	movlw	DELAYTIME	  	; Delay
	call	Delay

	banksel	PORTB
	btfsc	PORTB,5 	; Is The RB5 ZERO?
	goto	Open			
Closed_RB5
	retlw	1	  				
Open_RB5	
	retlw	0


Debounce_RB6
;	global	Debounce
	banksel	DELAYTIME
	movlw	DELAYTIME	  	; Delay
	call	Delay

	banksel	PORTB
	btfsc	PORTB,6 	; Is The RB6 ZERO?
	goto	Open			
Closed_RB6
	retlw	1	  				
Open_RB6	
	retlw	0

Debounce_RB7
;	global	Debounce
	banksel	DELAYTIME
	movlw	DELAYTIME	  	; Delay
	call	Delay

	banksel	PORTB
	btfsc	PORTB,7 	; Is The RB7 ZERO?
	goto	Open			
Closed_RB7
	retlw	1	  				
Open_RB7	
	retlw	0

	
;****************************************************************************
;Delay(W) - DelayTime = [ (1)+(2)+(2)+(W*768-W)+(W*3-1)+(2) ]*(OSC/4)cycles
;           (This includes the call & The movlw)
;         - Max Time When W=0xFF, [ 196356 Cycles * (OSC/4) ] ---> 98.1 ms
;         - Must Declare INNER & OUTER AS GPR'S
;****************************************************************************
Delay
	banksel	Delay_Returned
	clrf	Delay_Returned
	MOVLW	DELAYTIME		; ADDED
	movwf	OUTER
	clrf	INNER
D1	decfsz	INNER,f
	goto	D1
D2	decfsz	OUTER,f
	goto	D1

	bsf		Delay_Returned,0
	return

;------------------------------------------------------------------
Convert_ADCvalues

;-------Converting Acquired ADC Values to Real numbers ------------------
;skip_simulation_U5		; Voltage
;Continue_NormalMeas

;---Rearrange the collected ADC data ------------------
	banksel	Multipland1
	CLRF	Multipland1
	CLRF	Multipland2
	CLRF	Multipland3
;----------------------------	

	banksel	ADC_Sign
	clrf	ADC_Sign

	banksel	ADC_Value1
	btfsc	ADC_Value1,1
	bra		Its_NegativeSignA
Its_PositiveSignA
	banksel ADC_Sign
	bsf		ADC_Sign,0			; Vin+ --> positive ---> current is moving out from the battery
	goto	Test_Bit16A
Its_NegativeSignA
	bcf		ADC_Sign,0			; This is the case when current is chaged into battery
								; This need to take care of I_TStored Current

	call	TwosComp24	; for negative numbers

Test_Bit16A
	banksel	ADC_Value1
	btfsc	ADC_Value1,0
	bsf		Multipland1,0			; MSB = 1 ---> 2^16


;	movff	ADC_Value1,Multipland1	; bit 0 (=B16) was taken care of already
	movff	ADC_Value2,Multipland2
	movff	ADC_Value3,Multipland3
;------------------------------------------------------------------	

	banksel	IsitForU5_Volt
	bsf		IsitForU5_Volt,0		; for battery voltage
	
	call	Multiply_24x24Bits_ADC	; Raw ADC value (3 bytes) * LSB (3 byes)
									; LSB = 15.625 uV
									; Actual multiplication  = Raw ADC values (3 bytes) * 15.625/Gain settings = true input values

; Input to the "MULTIPLY_24x24Bits_ADC" is:
; 									Multipland1 (MSB) +  Multipland2 + Multipland3 (LSB) 			
;									These values are multiplied by 15.625. The 15.625 is stored in the "MULTIPLY_24x24Bits_ADC". 
;	
; Results: 
;			Product1 (MSB) + Product2 + Product3 + Product4 + Product5 + Product6 (LSB)  
;			for 18 bit MCP3421, Product1 and Product2 registers have all 0's.
; 			So, it needds to take care of Product3 - 4 - 5 - 6 only. 
;--------------------------------------------------------------------

	RETURN	



;----------- To display Battery Volts --------------------------------
Display_Voltage
	banksel	Product1
	movff	Product1,countT6	; MSB for gain =2,4,8
	movff	Product2,countT5	; LSB for gain =1
	movff	Product3,countT4
	movff	Product4,countT3
	movff	Product5,countT2
	movff	Product6,countT1	; LSB


	call 	Bin48_bcd_volts
	call	Display_Results_Volts
	return
;--------------------------------------------------------------------


Current_Measurement
; 1. Get a voltage on the current sensor using U5
; 2. Divide the voltage by Resistor Value of the current sensor
;---------------------------------------------------------------------

;Write configuration register
	banksel	Config_Data
;	movlw	b'10011100'		; Continuous mode, 18 bit mode, gain = 1
;	movlw	b'10001100'		; change later to 18 bit, one-shot, gain=1
	movlw	b'10001111'		; change later to 18 bit, one-shot, gain=8

	movwf	Config_Data		; put this code before calling ADC_Write_Config

;---- Gain Select ---------------------------
	banksel	Gain_Selected
	CLRF	Gain_Selected
	bsf		Gain_Selected,2			; Gain=8
;------------------------------------------


	btfsc	Gain_Selected,0
	goto	Set_Gain_2_U1
	btfsc	Gain_Selected,1
	goto	Set_Gain_4_U1
	btfsc	Gain_Selected,2
	goto	Set_Gain_8_U1

Set_Gain_1_U1	
	banksel	Config_Data	
	bcf		Config_Data,0
	bcf		Config_Data,1
	goto	Now_WriteConf_U1

Set_Gain_2_U1	
	banksel	Config_Data	
	bsf		Config_Data,0
	bcf		Config_Data,1
	goto	Now_WriteConf_U1
Set_Gain_4_U1	
	banksel	Config_Data	
	bcf		Config_Data,0
	bsf		Config_Data,1
	goto	Now_WriteConf_U1
Set_Gain_8_U1
	banksel	Config_Data	
	bsf		Config_Data,0
	bsf		Config_Data,1
	goto	Now_WriteConf_U1


Now_WriteConf_U1

; turn on sync pulse
;	bsf		PORTC,7	; old
	bsf		Sync_LED11

	banksel	IsitForU5_Volt
	bcf		IsitForU5_Volt,0		; for U1, current
	call	ADC_Write_Config	; put in initialization loop

	bcf		Sync_LED11



Reading_ADC_U1

	call	ADC_Read_400KHz
	bcf		Sync_LED11

;--- testing : Simulation with knwon ADC values -------------------

	bra		skip_simulation_U1
Simulation_U1	; for current

;	bra		For_0587mV	

For_2_408v
	banksel ADC_Value1
	movlw	0x01
	movwf	ADC_Value1
	movlw	0xFF
	movwf	ADC_Value2
	movlw	0xFF
	movwf	ADC_Value3

	goto	skip_simulation_U1	
;----------------------

For_0587mV				; this gives 0.587 mV --> [()*8]*15.625uV = 0.587mV --> [()x8] = 37.568 --> [()x8 ] = 37.568*8 = 300.544 --> 12C'hex
						; (2) Now see what is the code after multiplication (multiply_24x24)
	banksel ADC_Value1
	movlw	0x00
	movwf	ADC_Value1
	movlw	0x01
	movwf	ADC_Value2
	movlw	0x2C
	movwf	ADC_Value3
;----------------------

skip_simulation_U1	
;--- Rearrange the collected ADC data --------------
	banksel	Multipland1
	CLRF	Multipland1
	CLRF	Multipland2
	CLRF	Multipland3

;---------------------------------------------------	

	banksel	ADC_Sign
	clrf	ADC_Sign

	banksel	ADC_Value1				; U1 ---> sensing at current sensor
	btfsc	ADC_Value1,1
	bra		Its_Negative_Sign_U1
Its_Positive_Sign_U1
	bsf		ADC_Sign,0			; Vin+ --> positive ---> current is moving out from the battery
	goto	Test_Bit16_U1
Its_Negative_Sign_U1
	bcf		ADC_Sign,0			; This is the case when current is charged into battery
								; This need to take care of I_TStored Current

	call	TwosComp24	; for negative numbers

Test_Bit16_U1
	banksel	ADC_Value1
	btfsc	ADC_Value1,0
	bsf		Multipland1,0			; MSB = 1 ---> 2^16

;	movff	ADC_Value1,Multipland1	; bit 0 (=B16) is taken care of already
	movff	ADC_Value2,Multipland2
	movff	ADC_Value3,Multipland3

;------------------------------------

	banksel	IsitForU5_Volt
	bcf		IsitForU5_Volt,0		; for U1, current measurement

	call	Multiply_24x24Bits_ADC	; Raw ADC value (3 bytes) * LSB (3 byes)
									; LSB = 15.625 uV
									; Actual multiplication  = Raw ADC values (3 bytes) * 15.625/Gain settings = true input values


	banksel	Product1
	movff	Product1,countT6	; MSB for gain =2,4,8
	movff	Product2,countT5	; LSB for gain =1
	movff	Product3,countT4
	movff	Product4,countT3
	movff	Product5,countT2
	movff	Product6,countT1	; LSB

;------- Note ---------------------------------------------------
; The voltage measured here with gain of 8 has 10^-12 unit
;----------------------------------------------------------------

;	call 	Bin48_bcd_volts
;	banksel	VoltageOrCurrent
;	bcf		VoltageOrCurrent,0		; this is current
;	call	Display_Results_Current

; test
;	btfsc	Gain_Selected,0
;	banksel	VoltageOrCurrent
;	bcf		VoltageOrCurrent,0		; this is current
;	clrf	Gain_Selected
;	call	Display_Results_Current

;------------------------------------------------------
; test results
; The voltage measured on the current sensor = 0.00005664 V. 
; I = 3.944V/1K = 3.944 mA
; R_sensor = 0.00005664/3.944mA = 0.0144 ohms. 
;------------------------------------------------------

	
Currents_byUsingU1
; Algorithm: It needs to multilply (1/resistor) to get current 	
; Voltage ---> 6 bytes.
; Current ----> 2 bytes
; Results ----> 8 bytes

;------------------testing Divide routine -------------

testing_Divider_U1 ;	---> tested successful

; Dividend6: MSB --> returned values
; Dividend1: LSB
; Divisor3	; MSB	---> Divisor (Resistor Values)
; Divisor1	; LSB
; Product6 ; MSB
; Product1 ; LSB

;	banksel	Divisor1
;	movlw	b'00000100'
;	movwf	Divisor1				; LSB
;	movlw	b'00010010'
;	movwf	Divisor2
;	movlw	b'00010001'
;	movwf	Divisor3				; MSB
;
;	banksel	Product1
;	movlw	b'00010001'
;	movwf	Product1			; LSB
;	movlw	b'11111111'
;	movwf	Product2
;	movlw	b'11111111'
;	movwf	Product3
;	movlw	b'11111111'
;	movwf	Product4	
;	movlw	b'11111111'
;	movwf	Product5
;	movlw	b'11111111'
;	movwf	Product6			; MSB
;---------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------

; Calculate current = V/R = Dividend
; enter resistor value here
; 0.4 ohms ---> b'0000-0100' and x10
;----------------------------------------
	banksel	Divisor3
	movlw	b'00000000'
	movwf	Divisor3		; MSB
	movlw	b'00000000'
	movwf	Divisor2
	movlw	b'00000100'		; 0.4 ohms x 10
	movlw	b'00010110'		; 2.2 ohms x 10
	movlw	b'00001111'		; 1.5 ohms x 10
	movlw	b'00001010'		; 1 ohm x 10

	movwf	Divisor1		; LSB
;----------------------------------------

; 1.5 ohms --> 1500 ohms (multiplied x1000) for unit = uA
;1500 dec ===> 5DC in hex
;	banksel	Divisor3
;	movlw	0x00
;	movwf	Divisor3		; MSB
;	movlw	0x05
;	movwf	Divisor2
;	movlw	0xDC			; 1500 ohms ---> multiplied 1000 times. It use 0.015 ohms but actual resistor value becomes much higher (1.5 ohms) due to solder resistor
;	movwf	Divisor1		; LSB

;------- new: For Proto Typed Units ----------
; 0.015 ohms --> 15000 ohms (multiplied x1000000) for unit = uA
;15000 dec ===> 3A98 in hex
	banksel	Divisor3
	movlw	0x00
	movwf	Divisor3		; MSB
	movlw	0x3A
	movwf	Divisor2
	movlw	0x98			; 15000 ohms ---> multiplied 1000000 times. 
	movwf	Divisor1		; LSB


;------- Final_1: For 1st Production Units ----------
; The contact resistance is much less than protyped units

; 0.01 ohms --> 10000 ohms (multiplied x1000000) for unit = uA
;10000 dec ===> 2710 in hex
	banksel	Divisor3
	movlw	0x00
	movwf	Divisor3		; MSB
	movlw	0x27
	movwf	Divisor2
	movlw	0x10			; 10000 ohms (actual value = 0.01 ohm) ---> multiplied 1000000 times. 
	movwf	Divisor1		; LSB


;------- Final_2: For 2nd Production Units ----------
; The contact resistance is much less than protyped units
; The first production unit give about 18 - 20 mA. 
; Expected about 15 mA. So, let me use 0.013 ohms :

; 0.0135 ohms --> 13500 ohms (multiplied x1000000) for unit = uA
;13500 dec ===> 32C8 in hex
	banksel	Divisor3
	movlw	0x00
	movwf	Divisor3		; MSB
	movlw	0x34
	movwf	Divisor2
	movlw	0xBC			; 13500 ohms ---> multiplied 1000000 times. 
	movwf	Divisor1		; LSB




;--------------------------------------------------------------------------------------------------------------
; Division Results:
; Suppose it got V = 60 uV with Gain = x8 ---> Actual V = 60 uV/8 = 7.5 uV --> 7 hex (lose 0.5)
; 1. Unit after Multiplication: 
;    ( ) x (1953125)x 10^-6 ---> (15.625/8 = 1.953125uV --> 1953125 x 10^-6 x 10^-6)
;    Here it was multiplied 1953125, and there is 10^-12 deficit in the register value
;    then, it is divided by R (15000). Actual R value = 0.015 ohms. This means it has 10^-6 deficit.
;    Now the resulting value is in uA. 
;    I = () * 10^-12/(15000 * 10^-6) = () x 10^6 = () uA
; 2. Maximum Values:
; Suppose the ADC value is 2^18 =262144
; Multiplication results =  262144 * 1953125 (Gain = 8) = 512000000000 (dec) = 77-35-94-00-00 (hex) = 5 bytes
; 
; 3. Example:
; (a) if Vr = 2.047V at current sensor
; (a1)   2^17*15.625/8 (Vr = 0.256V) = 256000 x 10^6 uAs (Deficit -->10^-12)   
; (a2) (   )/15000 = 17066536(dec) = 1046A28(hex)
;  So, the worst case (Vr = 2.048V, I = 136.5A), the current output has 5 bytes
; (b) In typical cases (high side), Vr = 1.5 mV for I = 100 mA:
; (b1) Vr=0.0015V = 1500 x 10^6 uAs (Deficit = 10^12)
; (b2) (  )/15000 = 100000 (dec) = 1-86-A0 (hex) --> 3 bytes for 100 mA load. 
;--------------------------------------------------------------------------------------------------------------
; Unit of current becomes uAs
;-------------------------------------------------
	call	Divide_6by_3Bytes		; Voltage(6 bytes) div. R (3 byes) = Current


;-------------------------------------------------
; 
;  Divide_6by_3Bytes ---> 	Input: 	Product1 (MSB) + Product2 + Product3 + Product4 + Product5 + Product6(LSB) 
;									and Divisor3 (MSB) + Divisor2 + Divisor1 (LSB)
;					  		Output: 	

;								Dividend6	; MSB for gain =2,4,8
;								Dividend5	; MSB for gain =1
;								Dividend4
;								Dividend3
;								Dividend2
;								Dividend1	; LSB
;--------------------------------------------------

	return


Display_Current
;-----------------------------------------------
;	Display current in LCD Line 2
;-----------------------------------------------

;Enter here to display currents in LCD Line 2

	banksel	countT1
	clrf	countT1
	clrf	countT2
	clrf	countT3
	clrf	countT4
	clrf	countT5
	clrf	countT6

; ----- Note ---------------------------------

; The unit of resulting Current is uAs
;---------------------------------------------


; Arrange Current Array for LCD display

	banksel	Dividend1
	movff	Dividend6,countT6	; MSB for gain =2,4,8
	movff	Dividend5,countT5	; MSB for gain =1
	movff	Dividend4,countT4
	movff	Dividend3,countT3
	movff	Dividend2,countT2
	movff	Dividend1,countT1	; LSB

;	goto	Display_Results
;	call 	Bin48_bcd_volts
	call	Bin48_bcd_currents
	call	Display_Results_Current
; Unit of current = uAs

;--------------------------------------------
;	banksel	Voltage_Dispayed
;	bcf		Voltage_Dispayed,0	

	return
;-------------------------------------------------------------------------------------

Chk_BatIfLowerthan2V	
;--------------------------------------------------------------------------------------
; This routine does the followig tasks:
; 1. When first powered, it check if Batry is not connected or not ( Battery Volt < 1V)
; 2. After first powerd, it check if the battery down less than 2V (50% of 4V). 
; 3. It gives choice to recharge
;--------------------------------------------------------------------------------------

;----------- testing : Simulation with knwon ADC values -------------------------------

;	bra		skip_simulation_U5	; Voltage
;Simulation
; for 2.048V
;	banksel ADC_Value1
;	movlw	0x01				; MSB
;	movwf	ADC_Value1
;	movlw	0xFF
;	movwf	ADC_Value2
;	movlw	0xFF
;	movwf	ADC_Value3			; LSB


; for 1.024 V
;	banksel ADC_Value1
;	movlw	0x00
;	movwf	ADC_Value1
;	movlw	0xFF				; MSB
;	movwf	ADC_Value2
;	movlw	0xFF				; LSB
;	movwf	ADC_Value3

;	test done

;----- Check if it needs battery charging ----------------
;	banksel	ChargingBat
;	btfsc	ChargingBat,0
;	goto	ChargingBattery


;---------------- Battey Voltage below 50%? --------------
; for 1.024 V = 00FFFF(hex) --> 00FFFF (hex)x 15.625 (dec)uV = 1.024V  --> 
; Actually this equivalents to (1.024)x 2 = 2.048 V because it uses a voltage divider (50%) 
; and therefoer multiplying  by two for the input source.
; Now the following routin checks if the measured voltage is less than 2.048V (below 50% of original voltage) or not.
; The action is as follows:
; (1) Measured Votage > 2.028V  ---> 	Keep doing the normal job as usual
; (2) Measured Voltage < or = 2.048V ---> Give a message for charging while doing the normal job
;     (a) If charging is selected, then it charge by bring done the RC6 pin (PROG pin for U3).
;	      During the charging it shows the votlage, current and remaining fules, etc.
;	  (b) If charging is not selected ---> Keep doing the normal job while still showing the 
;		  Selection choice. 
;---------------------------------------------------------------------------		 

; Measured ADC Value

;	banksel	ADC_Value1
;	btfsc	ADC_Value1,1			; 1 --> negative number, 0 --> positive number
;	goto	CheckIfLessThan1V		; Its negative or close to negative: 
									; (a) Battery is not attaced or (b) battery is fully discharged. 
									; Consider for charging action
; Working fine: Verified ------------------------------------------------------

	banksel	ADC_Value1
	clrf	 SubtractByteA	; LSB
	clrf	 SubtractByteA+1
	clrf	 SubtractByteA+2

	movff	ADC_Value3_temp, SubtractByteA+3
	movff	ADC_Value2_temp, SubtractByteA+4	
	movff	ADC_Value1_temp, SubtractByteA+5 ; MSB

;----------- Reference Number for Comparison --------------
; 50% of 2.048 = 1.024 = (00FFFF, hex) --> actual battery voltage = 2.048 because of voltage divider
; ---> Put this one from MSB, and put "0s" towards LSB.
	
	banksel	SubtractByteB
	movlw	0x00
	movwf	SubtractByteB				; LSB	
	movwf	SubtractByteB+1
	movwf	SubtractByteB+2
	movlw	0xFF
	movwf	SubtractByteB+3	
	movwf	SubtractByteB+4				
	movlw	0x00
	movwf	SubtractByteB+5				; MSB

;--------------------------------------------------------------
;       SubtractByteA+5 (MSB)  ....... SubtractByteA (LSB)
;     - Current_Used+5 (MSB) ......... Current_Used (LSB)
;    =  SubtractByteA+5 (MSB)  ....... SubtractByteA (LSB)
;
;	Note:  	Carry  = 0: Success --> A > B or A == B
;  			Carry  = 1: Fail --->  A <  B
;-------------------------------------------------------------- 
	call	Subtract_6Bytes_6Bytes   

	banksel	SubtractByteA
	clrf	SubtractByteA	; LSB
	clrf	SubtractByteA+1
	clrf	SubtractByteA+2
	clrf	SubtractByteA+3
	clrf	SubtractByteA+4
	clrf	SubtractByteA+5 ; MSB

; Need to check the following return:
	btfss	STATUS,C
	bra		CheckedHigherThan2V		; sucessful --> Battery volts > 2V
;	bra		CheckedLessThan2V		; Unsuccessful --> Battery Volt < 2V

CheckedLessThan2V

	banksel LessThan1or2V
	bsf		LessThan1or2V, 1		; 	LessThan1or2V(0) --> Battery volt less than 1V, 	
									;   LessThan1or2V(1) --> Battery volt less than 2V, 
	bra		CheckDonefor2V
CheckedHigherThan2V
	clrf	LessThan1or2V			; Battery value is still good -> >50%
CheckDonefor2V
	return



Chk_BatIfLowerthan0_75V	
;--------------------------------------------------------------------------------------
; This routine does the followig tasks:
; 1. If the battery voltage (1.5V AAA Battery) is less than 0.75V (50%)
; 2. Or if Battery is not connected at input pin
; 3. It turns on Buzzer and Display Message on LCD
;--------------------------------------------------------------------------------------

;----------- 2.1 V Reference value at U6 --------------
; 4.2 V Bvat is equivalent to 2.1V at U5 input due to the voltage divider. 
; Hex Value of  2.1V --->  (ADC Value) * 15.625 uV = 2.1V --> ADC Value 
;				= 134400 (dec)--->20D00 (hex)
;			---> (000000020D00, hex) --> put into 6 registers. 
;
; Since 4.2V is the max charging value, this demo use 4.0 V as a full charging condition. 
;
; 4.0V Battery is equivalent to 2.0V at U5 input due to the voltage divider. 
; Hex Value of  2.0V --->  (ADC Value) * 15.625 uV = 2.0V --> ADC Value 
;				= 128000 (dec)--->1F400 (hex)
;			---> (00000001F400, hex) --> put into 6 registers.
; Hex value of 2.1V  --->  (ADC Value) * 15.625 uV = 2.1V --> ADC Value 
;				= 134400 (dec)--->20D00 (hex)
;			---> (000000020D00, hex) --> put into 6 registers. 
;-------------------------------------------------------

;	ADC Values ---> ADC_Value1 (MSB) + ADC_Value2 + ADC_Value3 (LSB)  


;-------------------------------------------------------------------------------------
	banksel	ADC_Value1
	clrf	 SubtractByteA	; LSB
	clrf	 SubtractByteA+1
	clrf	 SubtractByteA+2

	movff	ADC_Value3_temp, SubtractByteA+3
	movff	ADC_Value2_temp, SubtractByteA+4	
	movff	ADC_Value1_temp, SubtractByteA+5 ; MSB

;----------- Examples ---------------------------
; 50% of 2.048 = 1.024 = (00FFFF00, hex) --> actual battery voltage = 2.048 because of voltage divider

; Hex Value of  2.0V --->  (ADC Value) * 15.625 uV = 2.0V --> ADC Value 
;				= 128000 (dec)--->1F400 (hex)---> (01F400, hex) --> put this value into 6 registers, MSB first. 
;-------------> "01-F4-00-00-00-00"
	
; Hex value of 2.1V  --->  (ADC Value) * 15.625 uV = 2.1V --> ADC Value 
;				= 134400 (dec)--->20D00 (hex)---> (020D00, hex) --> put into 6 registers, MSB first
;------------> "02-0D-00-00-00-00"            


; Hex Value of  0.375V --->  (ADC Value) * 15.625 uV = 0.375V --> ADC Value 
;				= 24000 (dec)--->5DC0 (hex)---> (005DC0, hex) --> put this value into 6 registers, MSB first. 
;-------------> "00-5D-C0-00-00-00"

	banksel	SubtractByteB
	movlw	0x00
	movwf	SubtractByteB				; LSB	
	movwf	SubtractByteB+1
	movwf	SubtractByteB+2
	
	movlw	0xC0
	movwf	SubtractByteB+3	

	movlw	0x5D
	movwf	SubtractByteB+4				
	movlw	0x00
	movwf	SubtractByteB+5				; MSB
;--------------------------------------------------------------

	call	Subtract_6Bytes_6Bytes   
;--------------------------------------------------------------
;       SubtractByteA+5 (MSB)  ....... SubtractByteA (LSB)
;     - Current_Used+5 (MSB) ......... Current_Used (LSB)
;    =  SubtractByteA+5 (MSB)  ....... SubtractByteA (LSB)
;
;	Note:  	Carry  = 0: Success --> A > B or A == B
;  			Carry  = 1: Fail --->  A < or  B
;-------------------------------------------------------------- 
	banksel SubtractByteA
	clrf	SubtractByteA	; LSB
	clrf	SubtractByteA+1
	clrf	SubtractByteA+2
	clrf	SubtractByteA+3
	clrf	SubtractByteA+4
	clrf	SubtractByteA+5 ; MSB

; Need to check the following return:
	btfss	STATUS,C
	bra		ItsHigherThan075V			; Sucessful --> Battery volts > 0.75 (actually 0.375V in ADC input)
;	bra		Its_LessThan075V			; Unsuccessful --> Battery Volt < 0.75 V (actually 0.375V in ADC input)
Its_LessThan075V
	banksel	LowerThan0_75V
	bsf		LowerThan0_75V,0			; 1: lower than 0.75V, 0: higher than 0.75V

	return 	
ItsHigherThan075V
	banksel	LowerThan0_75V
	clrf	LowerThan0_75V				; 1: lower than 0.75V, 0: higher than 0.75V
	return	




;-----------------------------------------------------------------
Disp_BatLessThan2V
; Indicates the Battery Volt is Below 2V and get User's Input

	banksel	PORTBInt_Found
	bcf		PORTBInt_Found,6			; SW1
	
	banksel ptr_pos
	movlw	.64				;"BatteryVolt.<50%"		;64
	movwf	ptr_pos
	call	stan_char_1
;	call	delay_1s		;delay for display
;	call	delay_1s		;delay for display


	banksel ptr_pos
	movlw	.80				;"SW1:for Charging"		;80
	movwf	ptr_pos
	call	stan_char_2
	return

Disp_BatLessThan1V

; Indicates the Battery Volt is Below 1V or no connected and get User's Input

	banksel	PORTBInt_Found
	bcf		PORTBInt_Found,6			; SW1
	banksel ptr_pos
	movlw	.224				;"BatteryVolt < 1V"	;224 
	movwf	ptr_pos
	call	stan_char_1
;	call	delay_1s		;delay for display
;	call	delay_1s		;delay for display
	banksel ptr_pos
	movlw	.80				;"SW1:for Charging"		;80
	movwf	ptr_pos
	call	stan_char_2
	return


ChekIfWantRecharge

;	bcf		PORTBInt_Found,6			; SW1
;----------	
	call	Buzzer1p1KHz_ON
	call	delay_100ms			;delay for display
;	call	delay_1s			;delay for display
	call	Buzzer_OFF
;---------

	call	delay_1s			;delay for displaying mesage
	call	delay_1s			;delay for displaying mesage


	banksel	temp_1
	movlw	.256
	movwf	temp_1
Chk_sw1forCharge
;	call	delay_1s			;delay for display
;	call	delay_1s			;delay for display

	banksel	temp_1
	decfsz	temp_1,1
	bra		sw1forCharge
;	goto	Continue_NormalMeas		; time expired --> go to normal measurement mode
NotWantToCharge	
	retlw	0
	
sw1forCharge
	banksel	PORTBInt_Found
	btfss	PORTBInt_Found,6		; sw1			
	goto	Chk_sw1forCharge
WantToCharge	
	retlw	1



RechargeBattery
;-------------------------------------------------------------------------------
; This routin charing battery
;-------------------------------------------------------------------------------
Start_Charging
;	banksel	PORTC
;	bcf		PORTC, 6		; Make U3 Charger output Available ---> Apply logic low at PROG pin of U3

	banksel	ChargingBat
	clrf	ChargingBat	
	bsf		ChargingBat,0


	banksel	PORTC
	bsf		TRISC,6			; tristate the PROG pin to input (high impedance) during charging 
							; ---> Important to keep the PROG pin in high imped
							; during charing mode. If it is low, it draws a lot of current and the STAUS pin has
							; unpredictable value !
	

; Training and App Note version with rechargeable Battery
;	data	"Disconnect JP1 &"		;160	---> For rechargeable battery
;	data	"ConntJP2,Push S1"		;176
;---------------------------------------


	banksel ptr_pos
	movlw	.160				;	"Disconnect JP1 &"	;160	---> For rechargeable battery
	movwf	ptr_pos
	call	stan_char_1


	banksel ptr_pos
	movlw	.176				;"ConntJP2,Push S1"		;176
	movwf	ptr_pos
	call	stan_char_2

	call	delay_1s			;delay for display
	call	delay_1s			;delay for display

;--------------------------------------------------------
	banksel	PORTBInt_Found
	clrf	PORTBInt_Found


S1forReadyToCharge					; Checking SW1 (RB6)
	banksel	PORTBInt_Found
	btfss	PORTBInt_Found,6		; SW1 (RB6)				
	bra		S1forReadyToCharge

	banksel	PORTBInt_Found
	clrf	PORTBInt_Found

;--------------------------------------------------------
ChargingBattery
	call	Buzzer_OFF

	banksel	PORTBInt_Found
	bcf		PORTBInt_Found,6	; SW1

	
Still_Charging	
	banksel ptr_pos
	movlw	.96					;" Under Charging "		;96 
	movwf	ptr_pos
	call	stan_char_1
;	call	delay_1s			;delay for display
;	call	delay_1s			;delay for display


	banksel ptr_pos
	movlw	.112				;"SW1:StopCharging"		;112
	movwf	ptr_pos
	call	stan_char_2
	call	delay_1s			;delay for display
	call	delay_1s			;delay for display


;-------Disabled Checking PortB,3 ----------------------	
;	banksel	PORTB
;	btfsc	PORTB, 3		; Testing STATUS pin: 
							; high: Charge completed (4.2V), low: Still Charging (less than 4.2V)
							; Note that the MCP73831 start charging at below 4.05V and stop charging (Status Bit = high) at 4.2V
;	goto	Charge_Done		;Yes, Its charged enough

;	bra		CheckIfHigerThan4V
;-------------------------------------------------------

CheckIfHigerThan4V			; Status bit = high, but it is not very accurate enough in the board,
							; so here it checks battery volt also.
							; If Vbat > 4.2V ----> Charge completed. 
							; If Vbat < 4.2V ----> stay in charging loop
	
;-----------------------------
; Check Battery Volts and do the following actions:
; (a) Go to normal measurement if greater than 2V
; (b) Choice if User want to recharge ---> not selected --> go to normal measuremnt, if selected ---> do the charging
;----------------------------- 
	call	IsBatHigherThan4V	

	banksel	HigherThan4V
	btfss	HigherThan4V,0			;1: higher than 4V, 0: less than 4V
	goto	Cont_ToChargeLoop  		;No, Its less than 4.0V
	goto	Charge_Done				;Yes, Its higher than 4.0V

;------------------------------------------------------

Cont_ToChargeLoop

	banksel temp_1
	movlw	.256			;time delay for display
	movwf	temp_1

Chk_forSWChargeStop
;	call	delay_1s			

	banksel	temp_1
	decfsz	temp_1,1		;time delay for display
	bra		SwforChargeStop
	goto	ContinueToLoop

SwforChargeStop
	banksel	PORTBInt_Found
	btfss	PORTBInt_Found,6		; sw1			
	goto	Chk_forSWChargeStop
	goto	Stop_Charging


Charge_Done
	banksel	ChargingBat
	bcf		ChargingBat,0

	banksel	NotChargedBat
	clrf	NotChargedBat		; Battery is fully charged.

;----------------------------------
	banksel	PORTC
	bcf		TRISC,6				; make output
	bsf		PORTC,6				; Give "High" to  U3 PROG pin ----> This will stop the Charger output	

	call	Init_FuelValues 	; Initialize fuel parameters

;----------------------------------

	call	Buzzer1p1To1p5KHz_ON

	banksel	PORTBInt_Found		; sw1			
	clrf	PORTBInt_Found,6		
		
	call 	Disp_ChargeCompleted		; in Line 1	
	call 	Disp_PressS1				; in Line 2	
	call 	Wait_SW1Interrupt

	call	Buzzer_OFF

	call 	Disp_DisconnectJP2			; in Line 1
	call 	Disp_ConnectJP1			; in Line 2
	call 	Wait_SW1Interrupt

	goto 	Stop_Charging



Stop_Charging

;---------------------------
	banksel	PORTC
	bcf		TRISC,6		; make output		
	bsf		PORTC, 6	; Give "High" to  U3 PROG pin ----> This will stop the Charger output	
;---------------------------
	banksel	ChargingBat
	clrf	ChargingBat

	banksel	PORTBInt_Found
	bcf		PORTBInt_Found,6

	call	Buzzer1p1To1p5KHz_ON
	call	Buzzer_OFF

	
ContinueToLoop

	RETURN





IsBatHigherThan4V
; Check if Battery Volts higher than 4.2V. 
; This routine is called from "RechargeBattery" routine. 
; This routine is used to verify that the charging battery volts is no greater than 4.2V for safety. 

;----------- 2.1 V Reference value at U6 --------------
; 4.2 V Bvat is equivalent to 2.1V at U5 input due to the voltage divider. 
; Hex Value of  2.1V --->  (ADC Value) * 15.625 uV = 2.1V --> ADC Value 
;				= 134400 (dec)--->20D00 (hex)
;			---> (000000020D00, hex) --> put into 6 registers. 
;
; Since 4.2V is the max charging value, this demo use 4.0 V as a full charging condition. 
;
; 4.0V Battery is equivalent to 2.0V at U5 input due to the voltage divider. 
; Hex Value of  2.0V --->  (ADC Value) * 15.625 uV = 2.0V --> ADC Value 
;				= 128000 (dec)--->1F400 (hex)
;			---> (00000001F400, hex) --> put into 6 registers.
; Hex value of 2.1V  --->  (ADC Value) * 15.625 uV = 2.1V --> ADC Value 
;				= 134400 (dec)--->20D00 (hex)
;			---> (000000020D00, hex) --> put into 6 registers. 
;-------------------------------------------------------

;	ADC Values ---> ADC_Value1 (MSB) + ADC_Value2 + ADC_Value3 (LSB)  


;-------------------------------------------------------------------------------
	banksel	ADC_Value1
	clrf	 SubtractByteA	; LSB
	clrf	 SubtractByteA+1
	clrf	 SubtractByteA+2

	movff	ADC_Value3_temp, SubtractByteA+3
	movff	ADC_Value2_temp, SubtractByteA+4	
	movff	ADC_Value1_temp, SubtractByteA+5 ; MSB

;----------- Reference Number for Comparison --------------
; 50% of 2.048 = 1.024 = (00FFFF00, hex) --> actual battery voltage = 2.048 because of voltage divider

; Hex Value of  2.0V --->  (ADC Value) * 15.625 uV = 2.0V --> ADC Value 
;				= 128000 (dec)--->1F400 (hex)---> (01F400, hex) --> put this value into 6 registers, MSB first. 
;-------------> "01-F4-00-00-00-00"
	
; Hex value of 2.1V  --->  (ADC Value) * 15.625 uV = 2.1V --> ADC Value 
;				= 134400 (dec)--->20D00 (hex)---> (020D00, hex) --> put into 6 registers, MSB first
;------------> "02-0D-00-00-00-00"            


	banksel	SubtractByteB
	movlw	0x00
	movwf	SubtractByteB				; LSB	
	movwf	SubtractByteB+1
	movwf	SubtractByteB+2
	movwf	SubtractByteB+3	

	movlw	0xF4
	movwf	SubtractByteB+4				
	movlw	0x01
	movwf	SubtractByteB+5				; MSB
;-------------------------------------------------------------

	call	Subtract_6Bytes_6Bytes   
;--------------------------------------------------------------
;       SubtractByteA+5 (MSB)  ....... SubtractByteA (LSB)
;     - Current_Used+5 (MSB) ......... Current_Used (LSB)
;    =  SubtractByteA+5 (MSB)  ....... SubtractByteA (LSB)
;
;	Note:  	Carry  = 0: Success --> A > B or A == B
;  			Carry  = 1: Fail --->  A < or  B
;-------------------------------------------------------------- 
	banksel SubtractByteA
	clrf	SubtractByteA	; LSB
	clrf	SubtractByteA+1
	clrf	SubtractByteA+2
	clrf	SubtractByteA+3
	clrf	SubtractByteA+4
	clrf	SubtractByteA+5 ; MSB

; Need to check the following return:
	btfss	STATUS,C
	bra		ItsHigherThan4V			; Sucessful --> Battery volts > 4.2 (actually 2.1V in ADC input)
;	bra		Its_LessThan4V			; Unsuccessful --> Battery Volt < 4.2 V (actually 2.1V in ADC input)
Its_LessThan4V
	banksel	HigherThan4V
	clrf	HigherThan4V		; 	1: higher than 4V, 0: less than 4V
	return 	
ItsHigherThan4V
	banksel	HigherThan4V
	bsf		HigherThan4V,0			; 	1: higher than 4V, 0: less than 4V
	return	





;--------------------------------------------------------------
;
; FUNCTION     : INITIALIZE ()	      			
;
; DESCRIPTION  : INITIALIZE ALL REGISTERS
;
;--------------------------------------------------------------
FuelGaugeInit
; Initializing Port A:

	banksel	TRISA
	clrf	Timer0_Interrupt

	banksel	TRISA
	clrf	PORTA
	clrf	LATA
	
	movlw	b'00000000'		; for the time being. RA5--> SDA, RA4 --> SCL 
							; RA3-RA0 --> LCD data line
	movwf	TRISA
	movlw	b'11001110'
	movwf	PORTA

; Initializing Port B:
	banksel	TRISB
	clrf	PORTB
	clrf	LATB
;	movlw	b'11110111'			
	movlw	b'11111111'		; RB2 - RB0: Sw inputs, use RB3 for battery charger status indicator 		
	movwf	TRISB
;	bcf		PORTB,3

	clrf	PORTB
	clrf	LATB
	
;	bsf		PORTB,1
	
; Initializing Port C:
	banksel	TRISC
	clrf	PORTC
	clrf	LATC

;	movlw	b'10010001'		;RC0, RC1 --> Unused:

	movlw	b'11010001'		;RC0, RC1 --> Unused:
							;RC2 ---> PWM output
							;RC3 --->Unused
							;RC4, RC5 ---> USB
							;RC6 --> Output for U3 pin 5: Charger Prog pin.
							; During charge --> Should be kept in high impedance mode
							; ----> It may need high impedance when it first powered up.
							; To stop charging ---> Apply logic high --> exit charging loop
							; This is done by tristate this pin to output and apply "high"						
							;RC7 ---> unused
							
	movwf	TRISC
	clrf	PORTC
;-------- for battery Charger ------------------------------------
	bcf		TRISC,6			; tristate to output
	bsf		PORTC, 6		; No Charging output
;-----------------------------------------------------------------

; Initializing Port D:
	banksel	TRISD
	clrf	PORTD
	clrf	LATD
;	movlw	b'11111111'		; old -->RD pins are all grounded 		
	movlw	b'00000000'		; RD4: PWM Output
	movwf	TRISD


	clrf	PORTD
	clrf	LATD

	movlw	b'11111111'		
	movwf	PORTD


; Initializing Port E:
	banksel	TRISE
	clrf	PORTE
	clrf	LATE
	
	movlw	b'11111111'		; RD pins are all grounded 		
	movwf	TRISE
	CLRF    STATUS          ; Do initialization
	CLRF    INTCON
	CLRF    INTCON2
	CLRF    INTCON3
	CLRF    PIR1
	CLRF    PIR2
	CLRF    PIE1            ; Disable all peripheral interrupts
	Clrf	PIE2
	CLRF	RCON
	CLRF	IPR1
	CLRF	IPR2

	movlw	b'00000111'		; All ADC pins (RA, RB, RE,) are digital I/O
	banksel	CMCON
	movwf	CMCON			; all comparators off
;--------------------------------------------------	
	banksel	INTCON
	clrf	INTCON		
;-------- Set MCU I/O to digital I/O --------------
							; PIC18F4550 has RA,RB,RC,RD,RE Ports.
							; RA,RB,RE port have analog I/O
	movlw	b'00001111'		; All ADC pins (RA, RB, RE,) are digital I/O
	banksel	ADCON1
	movwf	ADCON1		
		
;	movlw	b'00000000'		
	clrf	INTCON2
;--------------------------------------------------	
; -- USB --> Disabled

; Oscillator set-up:
	banksel	OSCCON
	movlw	b'11111111'			; 8 MHz internal osc
	movwf	OSCCON
;---------------------------------------------------
	movlw	0x05			;postscale 1:1, prescaler 4, Timer2 ON
	movwf	T2CON
		
	bsf		TRISB,0			;make switch RA4 an Input
	bsf		TRISB,1			;make switch RB0 an Input

;------------------------------------------------------------
; Timer0 module set up
; Internal Clock = 8MHz, Tcy = 8Mz/4 = 0.5usec 
; for 1 second time delay --> 1sec/0.5usec = 2 x 10^6
; Required Prescale for 1 sec ---> (2^16)*(Prescale)*(0.5x10^-6) = 1sec
;                        ---> Prescale = 30.5 ---> use 32 ---> gives 1.0485sec

	movlw	b'10000100'		; Timer0 --> Enabled two 16-bit read/writable,  Prescale=1:32, run at internal clock. 
							; for overflow = 1.024 sec

	movwf	T0CON			; This gives T_Interrupt time = 1.048 seconds

	bcf		INTCON,TMR0IF		; Clear TMR0 overflow Interrupt Flag bit

	call	Buzzer_OFF	


;--------------------------------------------------------------

; Initializing arrays:
	banksel	AddByteB
	clrf	AddByteB
	clrf	AddByteB+1	
	clrf	AddByteB+2	
	clrf	AddByteB+3	
	clrf	AddByteB+4	
	clrf	AddByteB+5

	banksel	AddByteA
	clrf	AddByteA
	clrf	AddByteA+1	
	clrf	AddByteA+2	
	clrf	AddByteA+3	
	clrf	AddByteA+4	
	clrf	AddByteA+5


;-----------------------
	banksel	countT1
	clrf	countT1
	clrf	countT2
	clrf	countT3
	clrf	countT4
	clrf	countT5
	clrf	countT6
;-----------------------
	banksel	FirstPowered
	clrf	FirstPowered
;----for battery Charger ------------------------------------
	banksel	PORTC
	bcf		TRISC,6			; tristate to output
	bsf		PORTC, 6		; No Charging output
;------------------------------------------------------------
	banksel	ChargingBat
	clrf	ChargingBat

	banksel	PORTBInt_Found
	clrf	PORTBInt_Found
	
	banksel	LessThan1or2V
	clrf 	LessThan1or2V

	banksel	NotChargedBat
	clrf	NotChargedBat

;	call	Init_FuelValues
;-----------------------------------------------------------------
;	return
;-----------------------------------------------------------------

Init_FuelValues

;-----------------------------------------------------------------
;  I_Init ---> 3 bytes
;  example: 1000 mAH = 3E8 mAH in hex 
;		     170mAH = AA hex mAH	
;			  10 mAH = 0A hex mAH  --> tested
;			 100 mAH = 64 hex mAH
;-----------------------------------------------------------------

	banksel	I_Init1_mAH
	movlw	0xAA		; 170 mAH 
	movwf	I_Init1_mAH		; LSB
	movlw	0x00
	movwf	I_Init2_mAH
	movlw	0x00
	movwf	I_Init3_mAH		; MSB


; put this at beginning after test - 	
; store initial currents in 6 bytes
; Unit = mAseconds
; example: I_init_mAH = 1000 mAH = 1000mA x60x60 =  3600000mA in dec =  36EE80 hex in mA
;		            170mAH = 170 x 60x60 = 612000mA in dec = 956A0 hex in mA	
;

; Initial Value of T_CurrentRemain = I_Init/10 = 
; test with 2* Current_Used =2*( 1365322 uAs) = 29AA94 hex

; Now let start with Battery in uAseconds with:
;	 10 mAH = 10000*3600 uASec = 3600000 dec = 2255100 hex
; 	 1000 mAH = 1000*1000*3600 uASeconds =  D693A400 in hex 
;	 170mAH = 170*1000*3600 = 612000000 uAs in dec = 247A6100 hex in uAs

; for 170 mAH battery 
;	banksel	I_remain_uAS
;	movlw	0x00
;	movwf	I_remain_uAS		; LSB
;	movlw	0x61
;	movwf	I_remain_uAS+1
;	movlw	0x7A
;	movwf	I_remain_uAS+2
;	movlw	0x24
;	movwf	I_remain_uAS+3
;	movlw	0x00
;	movwf	I_remain_uAS+4
;	movlw	0x00
;	movwf	I_remain_uAS+5		; MSB
;
;
	banksel	I_Init_uAS
	movlw	0x00
	movwf	I_Init_uAS		; LSB
	movlw	0x61
	movwf	I_Init_uAS+1
	movlw	0x7A
	movwf	I_Init_uAS+2
	movlw	0x24
	movwf	I_Init_uAS+3
	movlw	0x00
	movwf	I_Init_uAS+4
	movlw	0x00
	movwf	I_Init_uAS+5		; MSB
;------------------------------------

	banksel	Current_Used			; Current_used = Total current used
	clrf	Current_Used	; LSB
	clrf	Current_Used+1	
	clrf	Current_Used+2	
	clrf	Current_Used+3	
	clrf	Current_Used+4	
	clrf	Current_Used+5	; MSB

; Initializing current arrays:
	banksel	Current_Used
	clrf	Current_Used	
	clrf	Current_Used+1	
	clrf	Current_Used+2	
	clrf	Current_Used+3	
	clrf	Current_Used+4	
	clrf	Current_Used+5


	return




;/******** Transform binary 40 bits to BCD *****************/
;/	This routine converts 5 registers (=40 bits) in binary to BCD. 
;/
;/  - YBL - 
;/**********************************************************/

Bin48_bcd_volts
Bin48_bcd_currents

bin48dec	
	call	Tclrdig
;	movlw	40		; for Gain =1 --> need only 5 bytes --> 40 bits
	movlw	48		; for gain = 2,4,8 --> need 6 bytes ---> 48 bits

	banksel	bitcnt
	movwf	bitcnt

Tbitlp
	banksel	countT1
	rlcf	countT1		;Shift msb into carry
	rlcf	countT2
	rlcf	countT3
	rlcf	countT4
	rlcf	countT5		; for Gain=1
	rlcf	countT6		; for Gain=2,4,8


	banksel	digitT1
	lfsr	FSR0,digitT1		; load FSR0 with digit1

	banksel	digcnt
	movlw	d'13'		;

	movwf	digcnt
Tadjlp	

;	banksel	INDF0
	rlcf	INDF0		;Shift digit 1 bit left
	movlw 	-d'10'
	addwf 	INDF0,w,0 ;Check and adjust for decimal overflow
	btfsc 	STATUS,0
	
	movwf	INDF0
	movf	POSTINC0,w

	banksel	digcnt
	decfsz	digcnt
	goto	Tadjlp
	decfsz	bitcnt		;Next bit
	goto	Tbitlp
	return

Tclrdig:	
	banksel	digitT1
	clrf	digitT1		; ones
	clrf	digitT2		; tens
	clrf	digitT3		; hundreds
	clrf	digitT4		; thousands
	clrf	digitT5		; Ten_Thousands
	clrf	digitT6		; OneHundreds_Thousands
	clrf	digitT7		; One_million
	clrf	digitT8		; Ten_million
	clrf	digitT9		; 
	clrf	digitT10	; 
	clrf	digitT11	; 
	clrf	digitT12	; 
	clrf	digitT13	; 

	return

;-----------------
	end