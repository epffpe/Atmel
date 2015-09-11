;Synopsis
;An LCD display driver example for a 4-bit mode 
;LCD display to Processor interface

;LCD to AVR Processor connections:
;PB7 PB6 PB5 PB4 PB3 PB2
;D7  D6  D5  D4  E   RS

;LCD input R/W is grounded so the LCD can only be written to.

.include "m48def.inc"
.INCLUDE "LCD_DEF.ASM"
.def TEMP=r16
.def TEMP1=r17
.def LOW_DEL=r18
.def HI_DEL=r19
.def COUNT=r20
.def LCD_CMD=r21
.def LCD_DAT=r22

.ORG 0
	RJMP	RESET

.ORG		0x01A

RESET:
	LDI		TEMP, HIGH(RAMEND)	;INICIALIZA LA PILA
	OUT		SPH, TEMP
	LDI		TEMP, LOW(RAMEND)
	OUT		SPL, TEMP

	LDI	TEMP, 0xFF	;CONFIGURA EL PUERTO DE LCD_DATOS DE SALIDA
	OUT	LDDR, TEMP
	LDI	TEMP, (1<<LCD_RS)|(1<<LCD_RW)|(1<<LCD_E)	;CONFIGURA EL PUERTO DE LCD_CONTROL DE SALIDA
	OUT	LCDR, TEMP	
	
	RCALL 	HI_DELAY
	;LDI		LCD_CMD, 0x38
	;RCALL	LCD_COMANDO
	;LDI		LCD_DAT, '0'
	;RCALL	LCD_DATO

;**********************************************************
;Main Part of the Program
;**********************************************************

main_loop: 
	RCALL 	LCD_INIT
    RJMP	LCD_MENSAJE


;**********************************************************
;LCD_INIT: INICIALIZA 16 X 2 LCD MODULO EN 4 bit data
;transfer mode
;**********************************************************
LCD_INIT:
         ldi LCD_CMD, 0x38 
         rcall LCD_COMANDO
         rcall HI_DELAY

         ldi LCD_CMD, 0x38
         rcall LCD_COMANDO
         rcall LOW_DELAY

         ldi LCD_CMD, 0x38
         rcall LCD_COMANDO
         rcall LOW_DELAY

		 ldi LCD_CMD, 0x38
         rcall LCD_COMANDO
		 rcall LOW_DELAY
         
		 ldi LCD_CMD, 0x06		; ENTRY MODE SET
         rcall LCD_COMANDO
		 rcall LOW_DELAY

         ldi LCD_CMD, 0x0C		; DISPLAY ON
         rcall LCD_COMANDO
		 rcall LOW_DELAY

         ldi LCD_CMD, 0x01
         rcall LCD_COMANDO
		 rcall HI_DELAY
         ret


;**********************************************************
;LCD_MENSAJE: Prints strings on the LCD display module
;**********************************************************
LCD_MENSAJE:
        ldi LCD_CMD, $80	;SELECCIONA LA DIRECCION 0 DE LA DDRAM
        rcall LCD_COMANDO
		rcall LOW_DELAY

        ldi COUNT, 16
        ldi ZH, high(msg1*2)
        ldi ZL, low(msg1*2)

MAS1:  	lpm
        mov LCD_DAT, r0
        rcall LCD_DATO
		rcall LOW_DELAY
        adiw ZL, 1
        dec COUNT
        cpi COUNT, 0
        brne MAS1

        ldi COUNT, 16
        ldi LCD_CMD, $c0	;LINEA 2
        rcall LCD_COMANDO
		rcall LOW_DELAY
MAS2:  	lpm
        mov LCD_DAT, r0
        rcall LCD_DATO
		rcall LOW_DELAY
        adiw ZL, 1
        dec COUNT
        cpi COUNT, 0
        brne MAS2
        
        rcall big_delay

        ldi LCD_CMD, $80	;SELECCIONA LA DIRECCION 0 DE LA DDRAM
        rcall LCD_COMANDO
		rcall LOW_DELAY

        ldi COUNT, 16
        ldi ZH, high(msg2*2)
        ldi ZL, low(msg2*2)

MAS3:  	lpm
        mov LCD_DAT, r0
        rcall LCD_DATO
		rcall LOW_DELAY
        adiw ZL, 1
        dec COUNT
        cpi COUNT, 0
        brne MAS3

        ldi COUNT, 16
        ldi LCD_CMD, $c0	;LINEA 2
        rcall LCD_COMANDO
		rcall LOW_DELAY
MAS4:  	lpm
        mov LCD_DAT, r0
        rcall LCD_DATO
		rcall LOW_DELAY
        adiw ZL, 1
        dec COUNT
        cpi COUNT, 0
        brne MAS4
        
        rcall big_delay
        rjmp LCD_MENSAJE
;**********************************************************
;LCD_COMANDO ENVIA UN COMANDO AL LCD
;LCD_DATO ENVIA DATOAS AL LCD
;
;**********************************************************
LCD_COMANDO:
	LDI	TEMP, 0xFF	;CONFIGURA EL PUERTO DE LCD_DATOS DE SALIDA
	OUT	LDDR, TEMP
	LDI	TEMP, (1<<LCD_RS)|(1<<LCD_RW)|(1<<LCD_E)	;CONFIGURA EL PUERTO DE LCD_CONTROL DE SALIDA
	OUT	LCDR, TEMP	
;	MOV	TEMP, LCD_CMD	;PONE EL COMANDO EN EL PUERTO
	OUT	LCD_DB, LCD_CMD
	LDI	TEMP, (0<<LCD_E)|(0<<LCD_RW)|(0<<LCD_RS) ;DESACTIVA LCD_RS
	OUT	LCD_CB, TEMP
	LDI	TEMP, (1<<LCD_E)|(0<<LCD_RW)|(0<<LCD_RS) ;ACTIVA LCD_E
	OUT	LCD_CB, TEMP
	LDI	TEMP, (0<<LCD_E)|(0<<LCD_RW)|(0<<LCD_RS) ;DESACTIVA LCD_E
	OUT	LCD_CB, TEMP
	RET

LCD_DATO:
	LDI	TEMP, 0xFF	;CONFIGURA EL PUERTO DE LCD_DATOS DE SALIDA
	OUT	LDDR, TEMP
	LDI	TEMP, (1<<LCD_RS)|(1<<LCD_RW)|(1<<LCD_E)	;CONFIGURA EL PUERTO DE LCD_CONTROL DE SALIDA
	OUT	LCDR, TEMP	
;	MOV	TEMP, LCD_DAT	;PONE EL COMANDO EN EL PUERTO
	OUT	LCD_DB, LCD_DAT
	LDI	TEMP, (0<<LCD_E)|(0<<LCD_RW)|(1<<LCD_RS) ;ACTIVA LCD_RS
	OUT	LCD_CB, TEMP
	LDI	TEMP, (1<<LCD_E)|(0<<LCD_RW)|(1<<LCD_RS) ;ACTIVA LCD_E Y LCD_RS
	OUT	LCD_CB, TEMP
	LDI	TEMP, (0<<LCD_E)|(0<<LCD_RW)|(0<<LCD_RS) ;DESACTIVA LCD_E Y LCD_RS
	OUT	LCD_CB, TEMP
	RET




;**********************************************************
;Low_Delay: A 250 us delay
;**********************************************************
LOW_DELAY:
        push LOW_DEL
        push HI_DEL
        ldi LOW_DEL, 22
ld_hi:  ldi HI_DEL, 10
loop_in:
        dec HI_DEL
		cpi HI_DEL, 0
        brne loop_in
        dec LOW_DEL
        cpi LOW_DEL, 0
        brne ld_hi
        pop HI_DEL
        pop LOW_DEL
        ret

;**********************************************************
;Hi_Delay: A 5 ms delay
;**********************************************************
HI_DELAY:
        push LOW_DEL
        ldi LOW_DEL, 25
more_call:
        rcall LOW_DELAY
        dec LOW_DEL
        cpi LOW_DEL, 0
        brne more_call
        pop LOW_DEL
        ret

;**********************************************************
;Big_delay: A 1 s delay
;**********************************************************
BIG_DELAY:
       ldi LOW_DEL, 250
more_big:
        rcall HI_DELAY
        dec LOW_DEL
        cpi LOW_DEL, 0
        brne more_big
        ret




;**********************************************************
;Message #1
;**********************************************************
msg1: .db "Gases:       35%Rev:   3.000 rpm"
;          12345678123456781234567812345678 
      
;**********************************************************
;Message #2
;**********************************************************
msg2: .db "Gases:       99%Rev:  12.300 rpm"
;          12345678123456781234567812345678 


	
	
	
	.EXIT



;**********************************************************
;Init_Lcd: Initializes the 16 X 2 LCD module in 4 bit data
;transfer mode
;**********************************************************
init_lcd:
         ldi LCD_CMD, 3 
         rcall lcd_low_cmd
         rcall hi_delay

         ldi LCD_CMD, 3
         rcall lcd_low_cmd
         rcall low_delay

         ldi LCD_CMD, 3
         rcall lcd_low_cmd
         rcall low_delay
 

         ldi LCD_CMD, $28	; set 4-bit interface
         rcall lcd_all_cmd
         
         ldi LCD_CMD, 8		; set DDRAM address to 00
         rcall lcd_all_cmd

         ldi LCD_CMD, $0c	; 
         rcall lcd_all_cmd

         ldi LCD_CMD, 6
         rcall lcd_all_cmd
         ret


;**********************************************************
;Print_Lcd: Prints strings on the LCD display module
;**********************************************************
print_lcd:
        ldi LCD_CMD, $80
        rcall lcd_all_cmd

        ldi COUNT, 16
        ldi ZH, high(msg1*2)
        ldi ZL, low(msg1*2)

more1:  lpm
        mov LCD_DAT, r0
        rcall lcd_all_dat
        adiw ZL, 1
        dec COUNT
        cpi COUNT, 0
        brne more1

        ldi COUNT, 16
        ldi LCD_CMD, $c0
        rcall lcd_all_cmd
more2:  lpm
        mov LCD_DAT, r0
        rcall lcd_all_dat
        adiw ZL, 1
        dec COUNT
        cpi COUNT, 0
        brne more2
        
        rcall big_delay

        ldi LCD_CMD, $80
        rcall lcd_all_cmd

        ldi COUNT, 16
        ldi ZH, high(msg2*2)
        ldi ZL, low(msg2*2)

more3:  lpm
        mov LCD_DAT, r0
        rcall lcd_all_dat
        adiw ZL, 1
        dec COUNT
        cpi COUNT, 0
        brne more3

        ldi COUNT, 16
        ldi LCD_CMD, $c0
        rcall lcd_all_cmd
more4:  lpm
        mov LCD_DAT, r0
        rcall lcd_all_dat
        adiw ZL, 1
        dec COUNT
        cpi COUNT, 0
        brne more4
        
        rcall big_delay
        rjmp print_lcd


;**********************************************************
;Lcd_Low_Cmd: Sends a command to higher 4 bits of the LCD.
;The command nibble must be in the lower nibble of the
;variable 'LCD_CMD'
;**********************************************************
lcd_low_cmd:
        mov temp, LCD_CMD
        lsl temp
        lsl temp
        lsl temp
        lsl temp
        andi temp, $f0
        out PORTB, temp
        ori temp, $08
        out PORTB, temp
        andi temp, $f7
        out PORTB, temp
        ret

;**********************************************************
;Lcd_All_Cmd: sends an 8 bit command to the LCD
;**********************************************************
lcd_all_cmd:
        push LCD_CMD
        lsr LCD_CMD
        lsr LCD_CMD
        lsr LCD_CMD
        lsr LCD_CMD
        rcall lcd_low_cmd
        pop LCD_CMD
        andi LCD_CMD, $0f
        rcall lcd_low_cmd
        rcall low_delay
        ret

;**********************************************************
;Lcd_Low_Dat: Sends a data nibble to higher 4 bits of the 
;LCD. The data nibble must be in the lower nibble of the
;variable 'LCD_DAT'
;**********************************************************
lcd_low_dat:
        mov temp, LCD_DAT
        lsl temp
        lsl temp
        lsl temp
        lsl temp
        andi temp, $f0
        ori temp, 4
        out PORTB, temp
        ori temp, 8
        out PORTB, temp
        andi temp, $f7
        out PORTB, temp
        ret

;**********************************************************
;Lcd_All_Dat: Sends a data byte to the LCD. The data byte
;is stored in variable 'LCD_DAT'
;**********************************************************
lcd_all_dat:
        push LCD_DAT
        lsr LCD_DAT
        lsr LCD_DAT
        lsr LCD_DAT
        lsr LCD_DAT
        andi LCD_DAT, $0f
        rcall lcd_low_dat
        pop LCD_DAT
        andi LCD_DAT, $0f
        rcall lcd_low_dat
        rcall low_delay
        ret


