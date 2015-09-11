;************************************************************************
;*	Microchip Technology Inc. 2007
;*	Assembler version: 1.0
;*	Filename:
;*		FuelGauge_MathLib.asm

;/****** 48 bit unsigned substraction **********************************/
;------------------------------------------------------------------------
; SubtractByteA - SubtractByteB = SubtractByteA 
; This routin can be easly modified for 8 / 16 / 32 / 64 bits
; Modifed by Youbok for A(6 bytes) - B (6 bytes) = A (6 bytes)
;  Carry  = 0: Success --> A > B or A == B
;  Carry  = 1: Fail --->  A < B
; SubtractByteA+5 --> MSB
; SubtractByteA --> LSB


;-------------------------------------------------------------------------
;       Ver 1.0
;       Date: 7-28-2007
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

;------------------------------------------------------------------------
;*	03/15/07
;************************************************************************

	list 		p=18f4550
	#include 	<p18f4550.inc>
	#include	FuelGauge_Project.inc
	#include	FuelGauge_MathLib.inc


#define		_C	STATUS,0

	errorlevel	-302


;/-----------------------------------------------------/
;/* Following vars are used in Subtraction routine. 

MATH_VAR	UDATA
SubtractByteA	res 6
SubtractByteB	res 6


;/* Following vars are used in Multiplication routine. 

BitCount	res 1

;/* Following vars are used in Division routine. 

Shift1		res 1
Shift2		res 1
Shift3		res 1
Shift4		res 1
Shift5		res 1
Shift6		res 1

Rem1		res 1
Rem2		res 1
Rem3		res 1
Count		res 1


;/*------------------------------------------------------------------*/

	

;LCDMath_CODE	code

	code

;/*********************************************************************/
Subtract_6Bytes_6Bytes   
	banksel	SubtractByteA
	bcf		STATUS,C	; clear our routine return flag	
;	movf    Current_Used,W    	; substract first LSB bytes
	movf    SubtractByteB,W    	; substract first LSB bytes
    subwf   SubtractByteA,F    	; a1 - b1 --&gt; a1
						; a > b --&gt; c=1
						; a = b --&gt; c=1
						; a < b --&gt; c=0 we have BORROW
	btfsc	STATUS,C	; have BORROW ?
	goto	NO_BORROW1	; 1 NO
						; 0 YES, so substract 1 from the next LSB
	movlw	.1
	subwf	SubtractByteA+1,F
	btfsc	STATUS,C	; have also BORROW here ?
	goto	NO_BORROW1	; 1
						; 0 YES, so substract more, 1 from next
	movlw	.1
	subwf	SubtractByteA+2,F
	btfsc	STATUS,C	; still BORROW ?
	goto	NO_BORROW1	; 1
						; 0 YES, substract 1 from the last

; added
	movlw	.1
	subwf	SubtractByteA+3,F
	btfsc	STATUS,C	; still BORROW ?
	goto	NO_BORROW1	; 1
						; 0 YES, substract 1 from the last

	movlw	.1
	subwf	SubtractByteA+4,F
	btfsc	STATUS,C	; still BORROW ?
	goto	NO_BORROW1	; 1
						; 0 YES, substract 1 from the last

;------------------
	movlw	.1
	subwf	SubtractByteA+5,F		

	btfsc	STATUS,C	
	goto	NO_BORROW1
	bsf		STATUS,C	; if another BORROW, the substraction result is negative
						; so return quick with CARRY = 1
	return


NO_BORROW1

;	movf    Current_Used+1,w     	; the same manner ...	
	movf    SubtractByteB+1,w     	; the same manner ...	
 
    subwf   SubtractByteA+1,f     	
	btfsc	STATUS,C	
	goto	NO_BORROW2	

	movlw	.1
	subwf	SubtractByteA+2,F
	btfsc	STATUS,C	
	goto	NO_BORROW2	

	movlw	.1
	subwf	SubtractByteA+3,F
	btfsc	STATUS,C	
	goto	NO_BORROW2	

	movlw	.1
	subwf	SubtractByteA+4,F
	btfsc	STATUS,C	
	goto	NO_BORROW2	


	movlw	.1
	subwf	SubtractByteA+5,F		
	btfsc	STATUS,C	
	goto	NO_BORROW2
	bsf		STATUS,C	
	return


NO_BORROW2
;	movf    Current_Used+2,w     	
 	movf    SubtractByteB+2,w     	

    subwf   SubtractByteA+2,f     	
	btfsc	STATUS,C	
	goto	NO_BORROW3	

	movlw	.1
	subwf	SubtractByteA+3,F
	btfsc	STATUS,C
	goto	NO_BORROW3

	movlw	.1
	subwf	SubtractByteA+4,F
	btfsc	STATUS,C
	goto	NO_BORROW3


	movlw	.1
	subwf	SubtractByteA+5,F
	btfsc	STATUS,C
	goto	NO_BORROW3
	bsf		STATUS,C

	return

NO_BORROW3
;	movf    Current_Used+3,w    
	movf    SubtractByteB+3,w    

    subwf   SubtractByteA+3,f    
	btfsc	STATUS,C
	goto	NO_BORROW4

	movlw	.1
	subwf	SubtractByteA+4,F
	btfsc	STATUS,C
	goto	NO_BORROW4

	movlw	.1
	subwf	SubtractByteA+5,F
	btfsc	STATUS,C
	goto	NO_BORROW4
	bsf		STATUS,C
	return

NO_BORROW4
;	movf    Current_Used+4,w
	movf    SubtractByteB+4,w    
    
    subwf   SubtractByteA+4,f    
	btfsc	STATUS,C
	goto	NO_BORROW5

	movlw	.1
	subwf	SubtractByteA+5,F
	btfsc	STATUS,C
	goto	NO_BORROW5
	bsf		STATUS,C
	return

NO_BORROW5
;	movf    Current_Used+5,w
	movf    SubtractByteB+5,w    
    
    subwf   SubtractByteA+5,f    
	btfsc	STATUS,C
	goto	NO_BORROW6
	bsf		STATUS,C
	return

NO_BORROW6
	bcf		STATUS,C
	return
;/**************************************************************************/

;/**************************************************************************/
Multiply_24x24Bits_ADC

;--------------------------------------------------------------------------
;	24 bits x 24 bits multiplication using PIC18F4550
; 	This routin multiplies the ADC code by LSB. 
;	The result of this multiplication is an input amplitude.
; 
;       Results: 
;			Product1 + Product2 + Product3 + Product4 + Product5 + Product6  
;			for 18 bit MCP3421, Product1 and Product2 registers have all 0's.
; 			So, it needds to take care of Product3 - 4 - 5 - 6 only. 
;
;       Multiplicand:
;				Multipland1 + Multipland2 + Multipland3
;       Multiplier:
;				Multiplier1 + Multiplier2 + Multiplier3
;
;        BitCount:24
;       
; Note: This routin is also contain "Multiply_3x3bytes". 
;	   to	multiply with pre-given 3 bytes x 3 bytes variables
; 
;		3-21-2007, Youbok Lee
;----------------------------------------------------

;---------------------------------------------------------------------------------------------



; preload values to test

; Multiplicand used for testing
;	banksel	Multipland1
;  	MOVLW   0x01
;	MOVWF   Multipland1
;	MOVLW   0xFF
;	MOVWF   Multipland2
;	MOVLW   0xFF
;	MOVWF   Multipland3
;

	banksel	Gain_Selected
	btfsc	Gain_Selected,0
	goto	Its_Gain_2
	btfsc	Gain_Selected,1
	goto	Its_Gain_4
	btfsc	Gain_Selected,2
	goto	Its_Gain_8

Its_Gain_1

	banksel	IsitForU5_Volt
	btfss	IsitForU5_Volt,0		; for battery voltage--> LSB x2 because the circuit uses a voltage divider
	bra		NotScaledBy2_G1

U5_x2Voltage_G1
	banksel	Multiplier1						; 003d09h = 15625 in Decimal --> 15625 x 10^-9 V
	MOVLW   0x00							; 15625 x2 = 7A12h
	MOVWF   Multiplier1
	MOVLW   0x7A
	MOVWF   Multiplier2
	MOVLW   0x12
	MOVWF   Multiplier3
	bra		Start_Multiply

NotScaledBy2_G1
	banksel	Multiplier1						; 003d09h = 15625 in Decimal --> 15625 x 10^-9 V
	MOVLW   0x00
	MOVWF   Multiplier1
	MOVLW   0x3D
	MOVWF   Multiplier2
	MOVLW   0x09
	MOVWF   Multiplier3
	bra		Start_Multiply


Its_Gain_2
	banksel	IsitForU5_Volt
	btfss	IsitForU5_Volt,0		; for battery voltage--> LSB x2 because the circuit uses a voltage divider
	bra		NotScaledBy2_G2

U5_x2Voltage_G2
	banksel	Multiplier1						; LSB/2 = 7.8125 uV in Decimal --> 78125 x 10^-10 V
	MOVLW   0x02							; 01312Dh x 2 = 02625Ah
	MOVWF   Multiplier1
	MOVLW   0x62
	MOVWF   Multiplier2
	MOVLW   0x5A
	MOVWF   Multiplier3
	bra		Start_Multiply

NotScaledBy2_G2
	banksel	Multiplier1						; LSB/2 = 7.8125 uV in Decimal --> 78125 x 10^-10 V
	MOVLW   0x01
	MOVWF   Multiplier1
	MOVLW   0x31
	MOVWF   Multiplier2
	MOVLW   0x2D
	MOVWF   Multiplier3
	bra		Start_Multiply


Its_Gain_4
	banksel	IsitForU5_Volt
	btfss	IsitForU5_Volt,0		; for battery voltage--> LSB x2 because the circuit uses a voltage divider
	bra		NotScaledBy2_G4

U5_x2Voltage_G4

	banksel	Multiplier1						; LSB/4 = 3.90625 uV in Decimal --> 390625 x 10^-11 V
	MOVLW   0x0B							; 05F5E1h x 2 = 05EBC2h
	MOVWF   Multiplier1
	MOVLW   0xEB
	MOVWF   Multiplier2
	MOVLW   0xC2
	MOVWF   Multiplier3
	bra		Start_Multiply

NotScaledBy2_G4


	banksel	Multiplier1						; LSB/4 = 3.90625 uV in Decimal --> 390625 x 10^-11 V
	MOVLW   0x05
	MOVWF   Multiplier1
	MOVLW   0xF5
	MOVWF   Multiplier2
	MOVLW   0xE1
	MOVWF   Multiplier3
	bra		Start_Multiply

Its_Gain_8
	banksel	IsitForU5_Volt
	btfss	IsitForU5_Volt,0		; for battery voltage--> LSB x2 because the circuit uses a voltage divider
	bra		NotScaledBy2_G8

U5_x2Voltage_G8
	banksel	Multiplier1						; LSB/8 = 1.953125 uV in Decimal --> 1953125 x 10^-12 V
	MOVLW   0x3B							; 1DCD65h x 2 = 3B9ACAh
	MOVWF   Multiplier1
	MOVLW   0x9A
	MOVWF   Multiplier2
	MOVLW   0xCA
	MOVWF   Multiplier3
	bra		Start_Multiply


NotScaledBy2_G8
	banksel	Multiplier1						; LSB/8 = 1.953125 uV in Decimal --> 1953125 x 10^-12 V
	MOVLW   0x1D
	MOVWF   Multiplier1
	MOVLW   0xCD
	MOVWF   Multiplier2
	MOVLW   0x65
	MOVWF   Multiplier3
	bra		Start_Multiply

;*/***************************************************************/

Multiply_3x3bytes			; Multiplying routine with pre-defined 3 bytes x 3 bytes varaibles


Start_Multiply

	banksel	Product1
  	CLRF    Product1         ; clear destination
	CLRF    Product2
	CLRF    Product3
	CLRF    Product4         ; clear destination
	CLRF    Product5
	CLRF    Product6

        
	banksel	BitCount
	MOVLW   D'24'
	MOVWF   BitCount        ; number of bits



	banksel	Multiplier1
	RRCF    Multiplier1,F     ; shift out to carry
	RRCF    Multiplier2,F     ; next multiplier bit
	RRCF    Multiplier3,F

ADD_LOOP_24x24

	BTFSS   STATUS,C        ; if carry is set we must add multipland
                                ; to the product
	GOTO  	SKIP_LOOP_24x24 ; nope, skip this bit
            
	banksel Multipland3  
	MOVF    Multipland3,W  ; get LSB of multiplicand
	ADDWF   Product3,F     ; add it to the lsb of the product
  
	MOVF    Multipland2,W  ; middle byte
	BTFSC   STATUS,C        ; check carry for overflow
	INCFSZ  Multipland2,W  ; if carry set we add one to the source 
	ADDWF   Product2,F     ; and add it  (if not zero, in
                           ; that case mulitpland = 0xff->0x00 )
        
	MOVF   	Multipland1,W    ; MSB byte
	BTFSC   STATUS,C        ; check carry
	INCFSZ  Multipland1,W
	banksel	Product1
	ADDWF   Product1,F       ; handle overflow

SKIP_LOOP_24x24
        ; note carry contains most significant bit of
        ; addition here

        ; shift in carry and shift out
        ; next multiplier bit, starting from less
        ; significant bit

	banksel	Product1
	RRCF     Product1,F
	RRCF     Product2,F
	RRCF     Product3,F

	banksel	 Multiplier1
	RRCF     Multiplier1,F     ; shift out to carry
	RRCF     Multiplier2,F     ; next multiplier bit
	RRCF     Multiplier3,F

	movff    Multiplier1, Product4
	movff    Multiplier2, Product5
	movff    Multiplier3, Product6
 
	
	banksel	BitCount
	DECFSZ  BitCount,F
	GOTO    ADD_LOOP_24x24	
	RETURN


;/********************************************************************/

Divide_6by_3Bytes

; This routin performs a 48 by 24 bits division


;Inputs:
;	Dividend - Dividend:6	(0 - least significant!)
;	Divisor	 - Test:3		(0 - least significant!)
;Temporary:
;	Counter	 - Count
;	Shift	 - Shift:6
;Output:
;	Quotient - Dividend:6	(0 - least significant!)
;	Remainder- Rem:3	(0 - least significant!)

; Tested successfull for the PIC18F4550
; Date: April 9, 2007
; Youbok Lee

;--------- Output: --------------- 
	; Dividend6: MSB
	; Dividend1: LSB
; -------- Inputs  ---------------
;	 Divisor3	; MSB
; 	 Divisor1	; LSB

; 	 Product6 ; MSB
; 	 Product1 ; LSB
;---------------------------------
;**************************************************************************


;---------------------------------------------------
; SUBROUTINE - 48 by 24 BITs DIVISION


	banksel	Count
	movlw 	.48
	movwf 	Count


;----------------
;	banksel	Product1
;	movff	Product1,countT6	; MSB for gain =2,4,8
;	movff	Product2,countT5	; MSB for gain =1
;	movff	Product3,countT4
;	movff	Product4,countT3
;	movff	Product5,countT2
;	movff	Product6,countT1
;;------------------
;
;
;	movff Dividend+0, Shift+0
;	movff Dividend+1, Shift+1
;	movff Dividend+2, Shift+2
;	movff Dividend+3, Shift+3
;	movff Dividend+4, Shift+4
;	movff Dividend+5, Shift+5
;
;------------------------
 	banksel	Shift1
	movff 	Product6, Shift1			; LSB --> it is a true LSB --> confirmed !
	movff 	Product5, Shift2
	movff 	Product4, Shift3
	movff 	Product3, Shift4
	movff 	Product2, Shift5
	movff 	Product1, Shift6			; MSB ?

	banksel	Dividend1
	clrf 	Dividend1
	clrf 	Dividend2
	clrf 	Dividend3
	clrf 	Dividend4
	clrf 	Dividend5
	clrf 	Dividend6

	banksel Rem3
	clrf 	Rem3
	clrf 	Rem2
	clrf 	Rem1
;-----------------
dloop
	bcf 	STATUS, C

	banksel	Shift1
	rlcf 	Shift1
	rlcf 	Shift2
	rlcf 	Shift3
	rlcf 	Shift4
	rlcf 	Shift5
	rlcf 	Shift6
	rlcf 	Rem1
	rlcf 	Rem2
	rlcf 	Rem3

	banksel	Divisor3
	movf 	Divisor3, w

	banksel	Rem3
	subwf 	Rem3, w

	btfss 	STATUS, Z
	bra 	nochk

	banksel	Divisor2
	movf 	Divisor2,w

	banksel	Rem2
	subwf 	Rem2,w

	btfss 	STATUS, Z
	bra 	nochk

	banksel	Divisor1
	movf 	Divisor1,w

	banksel	Rem1
	subwf 	Rem1,w
nochk
	btfss 	STATUS, C
	bra 	nogo


	banksel	Divisor1
	movf 	Divisor1,w

	banksel	Rem1
	subwf 	Rem1
;----------------------------
	btfsc STATUS, C
	bra		nodec_remainM

	banksel	Rem2
	decf 	Rem2, f
	movf 	Rem2, w
	xorlw 	0xff
	btfsc 	STATUS, Z
	decf 	Rem3, f
nodec_remainM

	banksel	Divisor2
	movf 	Divisor2, w

	banksel	Rem2
	subwf 	Rem2, f
	btfss 	STATUS, C
	decf 	Rem3, f

	banksel	Divisor3
	movf 	Divisor3, w

	banksel	Rem3
	subwf 	Rem3, f
	bsf 	STATUS, C
nogo
	banksel Dividend1
	rlcf 	Dividend1
	rlcf 	Dividend2
	rlcf 	Dividend3
	rlcf 	Dividend4
	rlcf 	Dividend5
	rlcf 	Dividend6

	banksel	Count
	decfsz 	Count, f
	goto 	dloop
    return

;/******************************************************************************/
Add_Two_6Bytes
;/******* This routin addes  6 bytes + 6 bytes *********/

;------------- Binary Addition --------------------------
; Binary addition of two 6 registers:
;	             AddByteA_6 -AddByteA_5 - AddByteA_4 -AddByteA_3 -AddByteA_2 -AddByteA_1
;              + AddByteB_6 -AddByteB_5 - AddByteB_4 -AddByteB_3 -AddByteB_2 -AddByteB_1
;---------------------------------------------------------------------------
; results = Carry_fromAdd + AddByteB_6 -AddByteB_5 - AddByteB_4 -AddByteB_3 -AddByteB_2 -AddByteB_1
; result is stored in AddByteB
;
;--------------------------------------------------------


	banksel	Carry_fromAdd
	clrf	Carry_fromAdd
;----------------------------------

	banksel	AddByteA
	movf	AddByteA,w
    addwf   AddByteB,f

	movf    AddByteA+1,w
	btfsc   STATUS,C
	incfsz 	AddByteA+1,w
	addwf 	AddByteB+1,f
	
	movf    AddByteA+2,w
	btfsc   STATUS,C
	incfsz 	AddByteA+2,w
	addwf 	AddByteB+2,f
	
	movf    AddByteA+3,w
	btfsc   STATUS,C
	incfsz 	AddByteA+3,w
	addwf 	AddByteB+3,f
	
	movf    AddByteA+4,w
	btfsc   STATUS,C
	incfsz 	AddByteA+4,w
	addwf 	AddByteB+4,f

	movf    AddByteA+5,w
	btfsc   STATUS,C
	incfsz 	AddByteA+5,w
	addwf 	AddByteB+5,f

	
	btfsc   STATUS,C
	bsf		Carry_fromAdd,0
	return
;------------------------------------


	end
