;***********************************************************
;***********************************************************
;	Autor: epf Supersonic
;	Descripcion: Programa que calcula las rpm de un motor
;				de helice y lo muestra por una pantalla
;				de texto LCD.
;
;***********************************************************
;***********************************************************

.INCLUDE "m48def.inc"


;***********************************************************
;	DEFINICION DE REGISTROS 
.DEF	TEMP 	=R16
.DEF	ACELERACION	=R3

;**********************************************************
;	CONVERSION BIN TO BCD DE 16BITS


.equ	AtBCD0	=13		;address of tBCD0
.equ	AtBCD2	=15		;address of tBCD1

.def	tBCD0	=r13		;BCD value digits 1 and 0
.def	tBCD1	=r14		;BCD value digits 3 and 2
.def	tBCD2	=r15		;BCD value digit 4
.def	fbinL	=r16		;binary value Low byte
.def	fbinH	=r17		;binary value High byte
.def	cnt16a	=r18		;loop counter
.def	tmp16a	=r19		;temporary value

;**********************************************************
;	CONVERSION BIN TO BCD DE 8BITS

;

.def	fbin	=r16		;8-bit binary value
.def	tBCDL	=r16		;BCD result MSD
.def	tBCDH	=r17		;BCD result LSD


;**********************************************************
;	LCD
;	LCD to AVR Processor connections:
;	PB7 PB6 PB5 PB4 PB3 PB2
;	D7  D6  D5  D4  E   RS

.DEF	LCD_DAT 	=R17
.DEF	LCD_CMD 	=R18
.DEF	LCD_POS		=R19
.EQU	LCD_DB		=PORTB
.EQU	LCD_DDR		=DDRB
.EQU	LCD_RS		=PB2
.EQU	LCD_E		=PB3


;**********************************************************
;	SEÑALES PARA EL RETARDO
.EQU	XTAL	=4000000
.EQU	T40U	=255 - XTAL/25000 + 21 	;FIN CONTAD(255)-40us + 19(INSTRUCCIONES)
.EQU	T2M		=255 - XTAL/500 + 19 + 2
;**********************************************************




;***********************************************************
;---------COMIENZO DEL PROGRAMA PRINCIPAL!!----------------
;***********************************************************

.CSEG
.ORG 0	
	RJMP 	RESET
.ORG	0x0D
	RJMP	TIM1_OVF
.ORG 0x1A
RESET:
	LDI		TEMP, 0x80		;divide el reloj de 8MHz/2
	STS		CLKPR, TEMP
	LDI		TEMP, 0x01
	STS		CLKPR, TEMP

	LDI		TEMP, 0x84		;CALIBRACION DEL OSCILADOR RC
	STS		OSCCAL, TEMP


	LDI		TEMP, LOW(RAMEND)
	OUT		SPL, TEMP
	LDI 	TEMP, HIGH(RAMEND)
	OUT		SPH, TEMP
	LDI		TEMP, 0xFF
	OUT 	DDRB, TEMP
	LDI		TEMP, 0x00
	OUT		DDRD, TEMP
	RCALL	LCD_INIT			;PROCESO INICIALIZACION LCD
	LDI		ZH, HIGH(GASES*2)	;POSICIÓN 0
	LDI		ZL, LOW(GASES*2)
	RCALL	ENVIA_MSG			;ESCRIBE "GASES: "
	LDI		LCD_POS, 0x40
	RCALL	LCD_POSICION
	LDI		ZH, HIGH(REV*2)
	LDI		ZL, LOW(REV*2)
	RCALL	ENVIA_MSG			;ESCRIBE "REV: "
	LDI		TEMP, 0x01			; HABILITA MODO SLLEP
	OUT		SMCR, TEMP
LOOP:
	LDI		TEMP,0xFF			;ACELERACION MOTOR
	MOV		ACELERACION, TEMP
	RCALL	CALC_GASES
	
	RCALL	MEDIR_RPM
	RCALL	CALC_RPM			;PASA LAS REVOLUCIONES AL LCD
			


	RJMP LOOP


;***********************************************************
;---------FIN DEL PROGRAMA PRINCIPAL!!----------------
;***********************************************************






;*************************************************************
;; DECLARACION DE LAS FUNCIONES UTILIZADAS
;
;*************************************************************

;*************************************************************
;	RUTINA DE SERVICIO DE INTERRUPCION DEL TIMER1_OVERFLOW
TIM1_OVF:
	LDI		TEMP, 0x00
	OUT		TCCR0B, TEMP
	STS 	TCCR1B, TEMP
	LDI		YL, LOW(RPML)
	LDI		YH,	HIGH(RPML)
	IN		TEMP,TCNT0
	LDI		R17,250
	MUL		TEMP, R17
	ST		Y+, R0
	ST		Y, R1
	RETI


;*************************************************************
; 	FUNCION PARA MEDIR LAS RPM

MEDIR_RPM:
	LDI 	TEMP, 0x00		;REINICIA LOS CONTADORES
	STS		TCCR1A, TEMP
	STS		TCCR1B, TEMP
	STS		TCCR1C, TEMP
	OUT		TCCR0A, TEMP
	OUT 	TCCR0B, TEMP
	OUT 	TCNT0, TEMP
	LDI		TEMP, 0xF1		;CUENTA 3750(0xFFFF-0x0EA6)=0xF15A(61786)
	STS		TCNT1H, TEMP
	LDI		TEMP, 0x5A
	STS		TCNT1L, TEMP
	
	LDI		TEMP, 0x01
	STS		TIMSK1, TEMP
	LDI		TEMP, 0x07			;HABILITA LA CUENTA DE TIEMPO
	OUT		TCCR0B, TEMP
	LDI		TEMP, 0x04			;HABILITA LA CUENTA DE PULSOS
	STS		TCCR1B, TEMP
	SEI
M_RPM:
	SLEEP
	CLI
	LDI		TEMP, 0x00
	STS		TIMSK1, TEMP
	RET


;*************************************************************
;	FUNCION PARA PRESENTAR EN PANTALLA LA ACELERACION 
;	DE 0 A 100%

CALC_GASES:
	LDI		TEMP, 100
	MUL		ACELERACION,TEMP
	MOVW		dd16uL,R0
	;MOV		dd16uH,R1
	ldi		dv16uL,low(255)
	ldi		dv16uH,high(255)
	rcall	div16u			;result:	$0000 (0)
							;remainder:	$c350 (50,000)
	;MOVW	fbin, dres16uL
	RCALL	bin2BCD8		;tBCDH:tBCDL
	RCALL	ENVIAR_GASES

	RET
;*************************************************************
;	FUNCION QUE MUESTRA EN PANTALLA EL VALOR DE LAS RPM MEDIDAS
;	EL VALOR CALCULADO(16BITS) SE ENCUENTRA EN LA RAM EN LA POSICION 
;	RPMH:RPML Y SE PASA A FORMATO BCD
CALC_RPM:
	LDI		YL, LOW(RPML)
	LDI		YH, HIGH(RPML)
	LD		fbinL,Y+
	LD		fbinH,Y
	rcall	bin2BCD16	;result: tBCD2:tBCD1:tBCD0 = $054321
	RCALL	ENVIA_RPM
	RET

;*************************************************************
; 	RUTINAS PARA EL LCD
;;*************************************************************

;*************************************************************
;	ESCRIBE UN COMANDO DE 4BITS
WRITE_4_CMD:
	MOV		TEMP, LCD_CMD
	SWAP	TEMP
	ANDI TEMP, 0xF0;ORI		TEMP, 0x0F	; CAMBIAR POR ANDI TEMP, 0xF0
	OUT		LCD_DB, TEMP
	CBI		PORTB, LCD_RS	; CAMBIAR POR ORI	TEMP, (1<< LCD_E)|(0 << LCD_RS)
	SBI		PORTB, LCD_E
	CBI		PORTB, LCD_E
	RET

;*************************************************************
;	ESCRIBE UN DATO DE 4BITS
WRITE_4_DAT:
	MOV		TEMP, LCD_DAT
	SWAP	TEMP
	ANDI 	TEMP, 0xF0;ORI		TEMP, 0x0F	; CAMBIAR POR ANDI TEMP, 0xF0
	OUT		LCD_DB, TEMP
	SBI		PORTB, LCD_RS	; CAMBIAR POR ORI	TEMP, (1<< LCD_E)|(1 << LCD_RS)
	SBI		PORTB, LCD_E
	CBI		PORTB, LCD_E
	RET

;*************************************************************
;	ENVIA UN COMANDO DE 8 BITS
ENVIA_CMD:
	LDI		TEMP,0xFF	;HAY QUE CAMBIAR CUANDO CAMBIE EL PATILLAJE
	OUT		LCD_DDR, TEMP
	OUT		DDRB, TEMP
	PUSH	LCD_CMD
	SWAP	LCD_CMD
	ANDI	LCD_CMD, 0x0F
	RCALL	WRITE_4_CMD
	RCALL	TIEMP1U
	POP		LCD_CMD
	ANDI	LCD_CMD, 0x0F
	RCALL	WRITE_4_CMD
	RCALL	TIEMP40U
	RET
;*************************************************************
;	ENVIA UN DATO DE 8 BITS
ENVIA_DAT:
	LDI		TEMP,0xFF	;HAY QUE CAMBIAR CUANDO CAMBIE EL PATILLAJE
	OUT		LCD_DDR, TEMP
	OUT		DDRB, TEMP
	PUSH	LCD_DAT
	SWAP	LCD_DAT
	ANDI	LCD_DAT, 0x0F
	RCALL	WRITE_4_DAT
	RCALL	TIEMP1U
	POP		LCD_DAT
	ANDI	LCD_DAT, 0x0F
	RCALL	WRITE_4_DAT
	RCALL	TIEMP40U
	RET

;*************************************************************
;	RUTINA DE INICIALIZACION DEL LCD
LCD_INIT:
	LDI		TEMP, 0x0A
INIT_T1:
	RCALL	TIEMP2M
	DEC		TEMP
	BRNE	INIT_T1
	LDI		LCD_CMD, 0x3
	RCALL	WRITE_4_CMD
	RCALL	TIEMP2M
	RCALL	TIEMP2M
	LDI		LCD_CMD, 0x3
	RCALL	WRITE_4_CMD
	RCALL	TIEMP40U
	RCALL	TIEMP40U
	RCALL	TIEMP40U
	LDI		LCD_CMD, 0x3
	RCALL	WRITE_4_CMD
	RCALL	TIEMP40U
	LDI		LCD_CMD, 0x2
	RCALL	WRITE_4_CMD
	RCALL	TIEMP40U
	
	LDI		LCD_CMD, 0x28
	RCALL	ENVIA_CMD
	RCALL	TIEMP40U	
	LDI		LCD_CMD, 0x06
	RCALL	ENVIA_CMD
	RCALL	TIEMP40U
	LDI		LCD_CMD, 0x0C
	RCALL	ENVIA_CMD
	RCALL	TIEMP40U
	LDI		LCD_CMD, 0x01
	RCALL	ENVIA_CMD
	RCALL	TIEMP2M
	RET
;*************************************************************
;	ENVIA UN MENSAJE AL LCD

ENVIA_MSG:
	LPM		R0,Z+
	TST		R0
	BREQ	FIN_MSG
	MOV		LCD_DAT, R0
	RCALL	ENVIA_DAT
	RCALL	TIEMP40U
	RJMP	ENVIA_MSG
FIN_MSG:
	RET

;*************************************************************
;	COLOCA EL CURSOR EN LA POSICION INDICADA EN EL REGISTRO LCD_CMD
LCD_POSICION:
	MOV		LCD_CMD, LCD_POS
	ORI		LCD_CMD, 0x80
	RCALL	ENVIA_CMD
	RCALL	TIEMP40U
	RET

;*************************************************************
;	
ENVIA_BCD_16:
	PUSH	LCD_DAT
	ANDI	LCD_DAT, 0xF0
	SWAP	LCD_DAT
	LDI		TEMP, 0x30
	ADD		LCD_DAT,TEMP
	RCALL	ENVIA_DAT
	RCALL	TIEMP40U
	POP		LCD_DAT
ENVIA_BCD_8:
	ANDI	LCD_DAT, 0x0F
	LDI		TEMP, 0x30
	ADD		LCD_DAT, TEMP
	RCALL	ENVIA_DAT
	RCALL	TIEMP40U
	RET
;*************************************************************
;
ENVIAR_GASES: ;tBCDH:tBCDL
	PUSH	tBCDL
	PUSH	tBCDH
	LDI		LCD_POS, 0x0C
	RCALL	LCD_POSICION
	RCALL	TIEMP40U
	MOV		LCD_DAT, tBCDH
	CPI		LCD_DAT,0x0A
	BRMI	GASES2
	LDI		ZL, LOW(FULL*2)
	LDI		ZH, HIGH(FULL*2)
	RCALL	ENVIA_MSG
	POP		tBCDH
	POP		tBCDL
	RJMP	FIN_GASES
GASES2:
	LDI		LCD_DAT, ' '
	RCALL	ENVIA_DAT
	RCALL	TIEMP40U
	POP		LCD_DAT
	RCALL	ENVIA_BCD_8
	POP		LCD_DAT
	;MOV		LCD_DAT,tBCDL
	RCALL	ENVIA_BCD_8
	LDI		LCD_DAT, '%'
	RCALL	ENVIA_DAT
FIN_GASES:
	RCALL	TIEMP40U
	RET

;*************************************************************
;										;123456
ENVIA_RPM: ;result: tBCD2:tBCD1:tBCD0 = $054.321
	LDI		LCD_POS, 0x46
	RCALL	LCD_POSICION
	RCALL	TIEMP40U
	MOV		LCD_DAT, tBCD2
	TST		LCD_DAT
	BREQ	BCD_DIG3
	MOV		TEMP, tBCD2
	ANDI	TEMP, 0xF0
	TST		TEMP
	BREQ	BCD_DIG2
	RCALL	ENVIA_BCD_16
	RJMP	BCD_DIG3
BCD_DIG2:
	ANDI	LCD_DAT, 0x0F
	RCALL	ENVIA_BCD_8
	RJMP	BCD_DIG31
	
BCD_DIG3:
	MOV		LCD_DAT, tBCD1
	ANDI	LCD_DAT, 0xF0
	TST		LCD_DAT
	BREQ	BCD_DIG5
	RJMP	BCD_DIG32
BCD_DIG31:
	MOV		LCD_DAT, tBCD1
	ANDI	LCD_DAT, 0xF0
BCD_DIG32:
	SWAP	LCD_DAT
	RCALL	ENVIA_BCD_8
	LDI		LCD_DAT, '.'
	RCALL	ENVIA_DAT
	RCALL	TIEMP40U
BCD_DIG5:
	MOV		LCD_DAT, tBCD1
	ANDI	LCD_DAT, 0x0F
	RCALL	ENVIA_BCD_8
BCD_DIG67:
	MOV		LCD_DAT, tBCD0
	RCALL	ENVIA_BCD_16
	
	
	LDI		ZH, HIGH(RPM*2)
	LDI		ZL, LOW(RPM*2)
	RCALL	ENVIA_MSG
	RET


;*************************************************************
; 	RUTINAS DE RETARDO
;		TIEMP1U: RETARDA ALGO MAS DE 1us
;		TIEMP40U: RETARDA 4us
;		TIEMP2M: RETARDA 2ms
;*************************************************************
TIEMP1U:
	RET

TIEMP40U:
	PUSH	TEMP
	LDI 	TEMP, 0x00
	OUT		TCCR0A, TEMP
	OUT 	TCCR0B, TEMP
	LDI		TEMP, T40U
	OUT 	TCNT0, TEMP
	LDI		TEMP, 0x01
	OUT 	TIFR0, TEMP
	OUT		TCCR0B, TEMP
LOOP40:
	SBIS 	TIFR0, TOV0
	RJMP	LOOP40
	LDI 	TEMP, 0x00
	OUT		TCCR0B, TEMP
	POP		TEMP
	RET	
	
TIEMP2M:
	PUSH	TEMP
	LDI 	TEMP, 50
CUENTA2:
	RCALL	TIEMP40U
	DEC		TEMP
	BRNE	CUENTA2
	POP		TEMP
	RET



;***************************************************************************
;*
;* "bin2BCD16" - 16-bit Binary to BCD conversion
;*
;* This subroutine converts a 16-bit number (fbinH:fbinL) to a 5-digit 
;* packed BCD number represented by 3 bytes (tBCD2:tBCD1:tBCD0).
;* MSD of the 5-digit number is placed in the lowermost nibble of tBCD2.
;*  
;* Number of words	:25
;* Number of cycles	:751/768 (Min/Max)
;* Low registers used	:3 (tBCD0,tBCD1,tBCD2) 
;* High registers used  :4(fbinL,fbinH,cnt16a,tmp16a)	
;* Pointers used	:Z
;*
;***************************************************************************




;***** Code

bin2BCD16:
	ldi	cnt16a,16	;Init loop counter	
	clr	tBCD2		;clear result (3 bytes)
	clr	tBCD1		
	clr	tBCD0		
	clr	ZH		;clear ZH (not needed for AT90Sxx0x)
bBCDx_1:
	lsl	fbinL		;shift input value
	rol	fbinH		;through all bytes
	rol	tBCD0		;
	rol	tBCD1
	rol	tBCD2
	dec	cnt16a		;decrement loop counter
	brne	bBCDx_2		;if counter not zero
	ret			;   return

bBCDx_2:
	ldi	r30,AtBCD2+1	;Z points to result MSB + 1
bBCDx_3:
	ld	tmp16a,-Z	;get (Z) with pre-decrement
;----------------------------------------------------------------
;For AT90Sxx0x, substitute the above line with:
;
;	dec	ZL
;	ld	tmp16a,Z
;
;----------------------------------------------------------------
	subi	tmp16a,-$03	;add 0x03
	sbrc	tmp16a,3	;if bit 3 not clear
	st	Z,tmp16a	;	store back
	ld	tmp16a,Z	;get (Z)
	subi	tmp16a,-$30	;add 0x30
	sbrc	tmp16a,7	;if bit 7 not clear
	st	Z,tmp16a	;	store back
	cpi	ZL,AtBCD0	;done all three?
	brne	bBCDx_3		;loop again if not
	rjmp	bBCDx_1		


;***************************************************************************
;*
;* "bin2BCD8" - 8-bit Binary to BCD conversion
;*
;* This subroutine converts an 8-bit number (fbin) to a 2-digit 
;* BCD number (tBCDH:tBCDL).
;*  
;* Number of words	:6 + return
;* Number of cycles	:5/50 (Min/Max) + return
;* Low registers used	:None
;* High registers used  :2 (fbin/tBCDL,tBCDH)
;*
;* Included in the code are lines to add/replace for packed BCD output.	
;*
;***************************************************************************


;***** Code

bin2bcd8:
	clr	tBCDH		;clear result MSD
bBCD8_1:
	subi	fbin,10		;input = input - 10
	brcs	bBCD8_2		;abort if carry set
	inc	tBCDH		;inc MSD
;---------------------------------------------------------------------------
;				;Replace the above line with this one
;				;for packed BCD output				
;	subi	tBCDH,-$10 	;tBCDH = tBCDH + 10
;---------------------------------------------------------------------------
	rjmp	bBCD8_1		;loop again
bBCD8_2:
	subi	fbin,-10	;compensate extra subtraction
;---------------------------------------------------------------------------
;				;Add this line for packed BCD output
;	add	fbin,tBCDH	
;---------------------------------------------------------------------------	
	ret

;***************************************************************************
;*
;* "div16u" - 16/16 Bit Unsigned Division
;*
;* This subroutine divides the two 16-bit numbers 
;* "dd8uH:dd8uL" (dividend) and "dv16uH:dv16uL" (divisor). 
;* The result is placed in "dres16uH:dres16uL" and the remainder in
;* "drem16uH:drem16uL".
;*  
;* Number of words	:19
;* Number of cycles	:235/251 (Min/Max)
;* Low registers used	:2 (drem16uL,drem16uH)
;* High registers used  :5 (dres16uL/dd16uL,dres16uH/dd16uH,dv16uL,dv16uH,
;*			    dcnt16u)
;*
;***************************************************************************
;***** Divide Two Unsigned 16-Bit Numbers (50,000/60,000)
;	ldi	dd16uL,low(50000)
;	ldi	dd16uH,high(50000)
;	ldi	dv16uL,low(60000)
;	ldi	dv16uH,high(60000)
;	rcall	div16u		;result:	$0000 (0)
;				;remainder:	$c350 (50,000)
;***** Subroutine Register Variables

.def	drem16uL=r14
.def	drem16uH=r15
.def	dres16uL=r16
.def	dres16uH=r17
.def	dd16uL	=r16
.def	dd16uH	=r17
.def	dv16uL	=r18
.def	dv16uH	=r19
.def	dcnt16u	=r20

;***** Code

div16u:	clr	drem16uL	;clear remainder Low byte
	sub	drem16uH,drem16uH;clear remainder High byte and carry
	ldi	dcnt16u,17	;init loop counter
d16u_1:	rol	dd16uL		;shift left dividend
	rol	dd16uH
	dec	dcnt16u		;decrement counter
	brne	d16u_2		;if done
	ret			;    return
d16u_2:	rol	drem16uL	;shift dividend into remainder
	rol	drem16uH
	sub	drem16uL,dv16uL	;remainder = remainder - divisor
	sbc	drem16uH,dv16uH	;
	brcc	d16u_3		;if result negative
	add	drem16uL,dv16uL	;    restore remainder
	adc	drem16uH,dv16uH
	clc			;    clear carry to be shifted into result
	rjmp	d16u_1		;else
d16u_3:	sec			;    set carry to be shifted into result
	rjmp	d16u_1
	


;*************************************************************
;*************************************************************
;	CONSTANTES Y VARIABLES 
;************************************************************

;*************************************************************
;	MEMORIA FLASH
;		 		 0123456789ABCDEF
GASES:	.DB		"Gases:"
		.DW		0
REV:	.DB		"Rev: "
		.DW		0
RPM:	.DB		" rpm  "
		.DW		0
FULL:	.DB		"100%"
		.DW		0

;*************************************************************
;	MEMORIA RAM
.DSEG
RPML:	.BYTE 1
RPMH:	.BYTE 1
