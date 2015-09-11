
;/****************************************/
;/*  File Name: Binary_To_BCDConversion.asm
;/***************************************/

;/* This routine converts Binary to Decimal 
;/* The results will be displayed on LCD
;			  Ver 1.0
;             Date: 7-27-2007
;             AIPD
;			  Microchip Technology Inc    
;/***************************************/ 


	list p=18f4550
	#include <p18f4550.inc>
	#include	Binary_To_BCDConversion.inc


BinToBCD_VAR	UDATA
LSD	res	1
MsD	res	1
MSD	res 1




NumH		RES 1
NumL		RES 1
TenK		RES 1
Thou		RES 1
Hund		RES 1
Tens		RES 1
Ones		RES 1

;/---- The following vatiables are defined in Main routine ------/
;countT1		RES 1		;lsb
;countT2		RES 1	
;countT3		RES 1	
;countT4		RES 1	
;countT5		RES 1			;msb for gain=1
;countT6		RES 1			;msb for gain = 8,4,2

;/--------------------------------------------------------------/
	code

;---------------- Binary (8-bit) to BCD -----------------------
;		255 = highest possible result

bin_bcd
;bin8_bcd
	banksel	MSD
	clrf	MSD
	clrf	MsD
	movwf	LSD		;move W value from "FuelGauge_Write_LCD.asm " to LSD

ghundreth	
	movlw	.100		;subtract 100 from LSD
	subwf	LSD,W
	btfss	STATUS,C	;is value greater then 100
	bra		gtenth		;NO goto tenths
	movwf	LSD			;YES, move subtraction result into LSD
	incf	MSD,F		;increment hundreths
	bra		ghundreth	
gtenth
	movlw	.10			;take care of tenths
	subwf	LSD,W
	btfss	STATUS,C
	bra		over		;finished conversion
	movwf	LSD
	incf	MsD,F		;increment tenths position
	bra		gtenth
over					;0 - 9, high nibble = 3 for LCD
	movf	MSD,W		;get BCD values ready for LCD display
	xorlw	0x30		;convert to LCD digit
	movwf	MSD
	movf	MsD,W
	xorlw	0x30		;convert to LCD digit
	movwf	MsD
	movf	LSD,W
	xorlw	0x30		;convert to LCD digit
	movwf	LSD
	retlw	0

;---------------- Binary (16-bit) to BCD -----------------------
;		xxx = highest possible result
bin16_bcd
;/***************************************************************
; Takes number in NumH:NumL 
; Returns decimal in 
; TenK:Thou:Hund:Tens:Ones 
;****************************************************************/
		banksel	NumH
        swapf   NumH,W 
        andlw   0x0F
        addlw   0xF0
        movwf   Thou 
        addwf   Thou,F 
        addlw   0xE2 
        movwf   Hund 
        addlw   0x32 
        movwf   Ones 

        movf    NumH,W 
        andlw   0x0F 
        addwf   Hund,F 
        addwf   Hund,F 
        addwf   Ones,F 
        addlw   0xE9 
        movwf   Tens 
        addwf   Tens,F 
        addwf   Tens,F 

        swapf   NumL,W 
        andlw   0x0F 
        addwf   Tens,F 
        addwf   Ones,F 

        rlcf     Tens,F 
        rlcf     Ones,F 
        comf    Ones,F 
        rlcf     Ones,F 

        movf    NumL,W 
        andlw   0x0F 
        addwf   Ones,F 
        rlcf     Thou,F 

        movlw   0x07 
        movwf   TenK 

        movlw   0x0A                 
Lb1: 
        decf    Tens,F 
        addwf   Ones,F 
        btfss   STATUS,C 
         bra   Lb1 
Lb2: 
        decf    Hund,F 
        addwf   Tens,F 
        btfss   STATUS,C 
         bra   Lb2 
Lb3: 
        decf    Thou,F 
        addwf   Hund,F 
        btfss   STATUS,C
         bra   	Lb3 
Lb4: 
        decf    TenK,F 
        addwf   Thou,F 
        btfss   STATUS,C 
         bra   Lb4 

        retlw   0


;/******** Transform binary 24 bits to BCD *****************/
;/ This routine is not used here, but keep here for future use
;/  - YBL - 
;/**********************************************************/
;Bin24_bcd
;
;
;bin24dec	
;	call	clrdig
;	movlw	24		;24 bits to do
;	movwf	bitcnt
;;	btfsc	STATUS,0
;;	movlw	b'0000000'
;;	RLCF	W
;bitlp
;;	banksel	count0
;	rlcf	count0		;Shift msb into carry
;	rlcf	count1
;	rlcf	count2
;
;;	banksel	digit1
;	lfsr	FSR0,digit1		; load FSR0 with digit1
;
;;	banksel	digcnt
;	movlw	d'8'		;8 digits to do
;	movwf	digcnt
;adjlp	
;	rlcf	INDF0		;Shift digit 1 bit left
;	movlw 	-d'10'
;	addwf 	INDF0,w,0 ;Check and adjust for decimal overflow
;	btfsc 	STATUS,0
;	
;;skpnc
;	movwf	INDF0
;	movf	POSTINC0,w
;
;;	banksel	digcnt
;	decfsz	digcnt
;	goto	adjlp
;	decfsz	bitcnt		;Next bit
;	goto	bitlp
;	return
;
;clrdig:	
;;	banksel	digit1
;	clrf	digit1		; ones
;	clrf	digit2		; tens
;	clrf	digit3		; hundreds
;	clrf	digit4		; thousands
;	clrf	digit5		; Ten_Thousands
;	clrf	digit6		; OneHundreds_Thousands
;	clrf	digit7		; One_million
;	clrf	digit8		; Ten_million
;	return
	

	end
