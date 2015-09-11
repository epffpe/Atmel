;/**************************************************************/
;/*  File Name: FuelGauge_Buzzer.asm
;/***************************************/
;/------ This routine On and Off Buzzer:
;
;       Ver 1.0
;       Date: 7-28-2007
;		AIPD
;		Microchip Technology Inc 
;/************************************************************/


#include 	p18f4550.inc
#include	FuelGauge_Project.inc
#include	FuelGauge_Buzzer.inc


;	global	Buzzer_ON, Buzzer_OFF, Buzzer1p2KHz_ON, Buzzer1p1KHz_ON, Buzzer1p1To1p5KHz_ON
;	extern	delay_100ms, delay_1s

	code

;/* This routin is called from main routin (FuelGaugeDemo_Main.asm) 
;   This routin beeps the buzzer
;*/
 

Buzzer_OFF
	banksel T2CON
	BCF		T2CON, TMR2ON	; TURN OFF TMR2
	banksel	PORTC
	BCF		PORTC,2		; MAKE LOW VOLTAGE AT RC2 
	RETURN
	
Buzzer_ON

; ------ Set PWM Duty Cycle -----------------------------------------
; for 50% duty cycle of 1.923 kHz ---> 0.26 ms
; Duty Cycle = CCPR1L:CCP1CON<5,4>(Tosc)(TMR2 Prescale)
; Duty Cycle = 0.26 ms for 50 % of 1.923 kHz
; CCPR1L:CCP1CON<5,4> = 0.26 ms / [(Tosc)(TMR2 Prescale)] = 130
; CCPR1L:CCP1CON<5,4> = 00111111:00

;  Setting up PWM for Buzzer
;  f_buzzer = 2 kHz

	banksel	T2CON
	movlw	b'0000111'	; Timer2 Prescale = x16
	movwf	T2CON
; Set PWM Period
;	movlw	.64			; let PR2 = 64 --> PWM freq = 1.923 kHz
	movlw	.88			; let PR2 = 88 --> PWM freq = 1.4 kHz
	movwf	PR2

	banksel	CCP1CON
 	movlw	b'00001100'	; CCP1CON(5,4> = <0,0>, Single PWM output, Standard mode
	movwf	CCP1CON 	; PWM Output = RC2

	banksel	CCPR1L
;	movlw	b'00100000'	; CCPR1L ---> for 1.923 kHz 	
	movlw	b'00110000'	; CCPR1L ---> for 1.4 kHz	

	movwf	CCPR1L		; for Duty Cycle = 0.52 ms (50 %)

	BSF		INTCON, GIE		; SET GLOBAL INTERRUPT BIT
	BSF		T2CON, TMR2ON	; TMR2 STARTS TO INCREMENT
	RETURN		

Buzzer1p2KHz_ON

; ------ Set PWM Duty Cycle -----------------------------------------
; for 50% duty cycle of 1.923 kHz ---> 0.26 ms
; Duty Cycle = CCPR1L:CCP1CON<5,4>(Tosc)(TMR2 Prescale)
; Duty Cycle = 0.26 ms for 50 % of 1.923 kHz
; CCPR1L:CCP1CON<5,4> = 0.26 ms / [(Tosc)(TMR2 Prescale)] = 130
; CCPR1L:CCP1CON<5,4> = 00111111:00

;  Setting up PWM for Buzzer
;  f_buzzer = 2 kHz

	banksel	T2CON
	movlw	b'0000111'	; Timer2 Prescale = x16
	movwf	T2CON
; Set PWM Period
;	movlw	.64			; let PR2 = 64 --> PWM freq = 1.923 kHz
	movlw	.88			; let PR2 = 88 --> PWM freq = 1.4 kHz
	movlw	.103		; let PR2 = 103 --> PWM freq = 1.2 kHz
	movwf	PR2

	banksel	CCP1CON
 	movlw	b'00001100'	; CCP1CON(5,4> = <0,0>, Single PWM output, Standard mode
	movwf	CCP1CON 	; PWM Output = RC2

	banksel	CCPR1L
;	movlw	b'00100000'	; CCPR1L ---> for 1.923 kHz 	
	movlw	b'00110000'	; CCPR1L ---> for 1.4 kHz	

	movwf	CCPR1L		; for Duty Cycle = 0.52 ms (50 %)

	BSF		INTCON, GIE		; SET GLOBAL INTERRUPT BIT
	BSF		T2CON, TMR2ON	; TMR2 STARTS TO INCREMENT
	RETURN		


Buzzer1p1KHz_ON

; ------ Set PWM Duty Cycle -----------------------------------------
; for 50% duty cycle of 1.923 kHz ---> 0.26 ms
; Duty Cycle = CCPR1L:CCP1CON<5,4>(Tosc)(TMR2 Prescale)
; Duty Cycle = 0.26 ms for 50 % of 1.923 kHz
; CCPR1L:CCP1CON<5,4> = 0.26 ms / [(Tosc)(TMR2 Prescale)] = 130
; CCPR1L:CCP1CON<5,4> = 00111111:00

;  Setting up PWM for Buzzer
;  f_buzzer = 2 kHz

	banksel	T2CON
	movlw	b'0000111'	; Timer2 Prescale = x16
	movwf	T2CON
; Set PWM Period
;	movlw	.64			; let PR2 = 64 --> PWM freq = 1.923 kHz
;	movlw	.88			; let PR2 = 88 --> PWM freq = 1.4 kHz
;	movlw	.103		; let PR2 = 103 --> PWM freq = 1.2 kHz
	movlw	.113		; let PR2 = 103 --> PWM freq = 1.1 kHz

	movwf	PR2

	banksel	CCP1CON
 	movlw	b'00001100'	; CCP1CON(5,4> = <0,0>, Single PWM output, Standard mode
	movwf	CCP1CON 	; PWM Output = RC2

	banksel	CCPR1L
;	movlw	b'00100000'	; CCPR1L ---> for 1.923 kHz 	
	movlw	b'00110000'	; CCPR1L ---> for 1.4 kHz	

	movwf	CCPR1L		; for Duty Cycle = 0.52 ms (50 %)

	BSF		INTCON, GIE		; SET GLOBAL INTERRUPT BIT
	BSF		T2CON, TMR2ON	; TMR2 STARTS TO INCREMENT
	RETURN		


BuzzerStartUp_ON

; ------ Set PWM Duty Cycle -----------------------------------------
; for 50% duty cycle of 1.923 kHz ---> 0.26 ms
; Duty Cycle = CCPR1L:CCP1CON<5,4>(Tosc)(TMR2 Prescale)
; Duty Cycle = 0.26 ms for 50 % of 1.923 kHz
; CCPR1L:CCP1CON<5,4> = 0.26 ms / [(Tosc)(TMR2 Prescale)] = 130
; CCPR1L:CCP1CON<5,4> = 00111111:00

;  Setting up PWM for Buzzer
;  f_buzzer = 2 kHz

	banksel	T2CON
	movlw	b'0000111'	; Timer2 Prescale = x16
	movwf	T2CON
; Set PWM Period
;	movlw	.64			; let PR2 = 64 --> PWM freq = 1.923 kHz
;	movlw	.88			; let PR2 = 88 --> PWM freq = 1.4 kHz
;	movlw	.103		; let PR2 = 103 --> PWM freq = 1.2 kHz
;	movlw	.113		; let PR2 = 103 --> PWM freq = 1.1 kHz
	movlw	.250		; let PR2 = 213 --> PWM freq = ?  kHz


	movwf	PR2

	banksel	CCP1CON
 	movlw	b'00001100'	; CCP1CON(5,4> = <0,0>, Single PWM output, Standard mode
	movwf	CCP1CON 	; PWM Output = RC2

	banksel	CCPR1L
	movlw	b'00100000'	; CCPR1L ---> for 1.923 kHz 	
;	movlw	b'00110000'	; CCPR1L ---> for 1.4 kHz	

	movwf	CCPR1L		; for Duty Cycle = 0.52 ms (50 %)

	call 	delay_100ms
;-----------------------------------------------------------

	BSF		INTCON, GIE		; SET GLOBAL INTERRUPT BIT
	BSF		T2CON, TMR2ON	; TMR2 STARTS TO INCREMENT
	RETURN		





Buzzer1p1To1p5KHz_ON

; ------ Set PWM Duty Cycle -----------------------------------------
; for 50% duty cycle of 1.923 kHz ---> 0.26 ms
; Duty Cycle = CCPR1L:CCP1CON<5,4>(Tosc)(TMR2 Prescale)
; Duty Cycle = 0.26 ms for 50 % of 1.923 kHz
; CCPR1L:CCP1CON<5,4> = 0.26 ms / [(Tosc)(TMR2 Prescale)] = 130
; CCPR1L:CCP1CON<5,4> = 00111111:00

;  Setting up PWM for Buzzer
;  f_buzzer = 2 kHz

	banksel	T2CON
	movlw	b'0000111'	; Timer2 Prescale = x16
	movwf	T2CON
; Set PWM Period
;	movlw	.64			; let PR2 = 64 --> PWM freq = 1.923 kHz
;	movlw	.88			; let PR2 = 88 --> PWM freq = 1.4 kHz
;	movlw	.103		; let PR2 = 103 --> PWM freq = 1.2 kHz
	movlw	.113		; let PR2 = 103 --> PWM freq = 1.1 kHz
	
	movlw	.150		; 
	movwf	PR2

	banksel	CCP1CON
 	movlw	b'00001100'	; CCP1CON(5,4> = <0,0>, Single PWM output, Standard mode
	movwf	CCP1CON 	; PWM Output = RC2

	banksel	CCPR1L
;	movlw	b'00100000'	; CCPR1L ---> for 1.923 kHz 	
	movlw	b'00110000'	; CCPR1L ---> for 1.4 kHz	
	movwf	CCPR1L		; for Duty Cycle = 0.52 ms (50 %)

;	call 	delay_1s
	call 	delay_100ms

;	movlw	.111		; let PR2 = 103 --> PWM freq = 1.1 kHz
	movlw	.151		; let PR2 = 103 --> PWM freq = 1.1 kHz
	movwf	PR2
;	call 	delay_1s
	call 	delay_100ms

;	movlw	.108		; let PR2 = 103 --> PWM freq = 1.1 kHz
	movlw	.152		; let PR2 = 103 --> PWM freq = 1.1 kHz
	movwf	PR2
	call 	delay_1s

	movlw	.200		; let PR2 = 103 --> PWM freq = 1.1 kHz
	movwf	PR2
	call 	delay_100ms

	call 	delay_100ms


	BSF		INTCON, GIE		; SET GLOBAL INTERRUPT BIT
	BSF		T2CON, TMR2ON	; TMR2 STARTS TO INCREMENT
	RETURN	

	
	End