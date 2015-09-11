;my_lcd.asm
;9th September 1999
;Clock Frequency 3.58 MHz


;Synopsis
;An LCD display driver example for a 4-bit mode 
;LCD display to Processor interface

;LCD to AVR Processor connections:
;PB7 PB6 PB5 PB4 PB3 PB2
;D7  D6  D5  D4  E   RS

;LCD input R/W is grounded so the LCD can only be written to.

.include "m48def.inc"

.def temp=r16
.def temp1=r17
.def low_del=r18
.def hi_del=r19
.def count=r20
.def lcd_cmd=r21
.def lcd_dat=r22



.cseg
.org 0
         rjmp    RESET           ;Reset Handle
	
RESET:   ldi temp, low(RAMEND)
         out SPL, temp          ;Init the Stack Pointer 
 

         ldi temp, 0b11111111   ;configure PORT B for all outputs
         out DDRB, temp         ;except PB0 and PB1

         rcall hi_delay

;**********************************************************
;Main Part of the Program
;**********************************************************

main_loop: rcall init_lcd
           rjmp print_lcd



;**********************************************************
;Init_Lcd: Initializes the 16 X 2 LCD module in 4 bit data
;transfer mode
;**********************************************************
init_lcd:
         ldi lcd_cmd, 3 
         rcall lcd_low_cmd
         rcall hi_delay

         ldi lcd_cmd, 3
         rcall lcd_low_cmd
         rcall low_delay

         ldi lcd_cmd, 3
         rcall lcd_low_cmd
         rcall low_delay
 

         ldi lcd_cmd, $28	; set 4-bit interface
         rcall lcd_all_cmd
         
         ldi lcd_cmd, 8		; set DDRAM address to 00
         rcall lcd_all_cmd

         ldi lcd_cmd, $0c	; 
         rcall lcd_all_cmd

         ldi lcd_cmd, 6
         rcall lcd_all_cmd
         ret

;**********************************************************
;Print_Lcd: Prints strings on the LCD display module
;**********************************************************
print_lcd:
        ldi lcd_cmd, $80
        rcall lcd_all_cmd

        ldi count, 16
        ldi ZH, high(msg1*2)
        ldi ZL, low(msg1*2)

more1:  lpm
        mov lcd_dat, r0
        rcall lcd_all_dat
        adiw ZL, 1
        dec count
        cpi count, 0
        brne more1

        ldi count, 16
        ldi lcd_cmd, $c0
        rcall lcd_all_cmd
more2:  lpm
        mov lcd_dat, r0
        rcall lcd_all_dat
        adiw ZL, 1
        dec count
        cpi count, 0
        brne more2
        
        rcall big_delay

        ldi lcd_cmd, $80
        rcall lcd_all_cmd

        ldi count, 16
        ldi ZH, high(msg2*2)
        ldi ZL, low(msg2*2)

more3:  lpm
        mov lcd_dat, r0
        rcall lcd_all_dat
        adiw ZL, 1
        dec count
        cpi count, 0
        brne more3

        ldi count, 16
        ldi lcd_cmd, $c0
        rcall lcd_all_cmd
more4:  lpm
        mov lcd_dat, r0
        rcall lcd_all_dat
        adiw ZL, 1
        dec count
        cpi count, 0
        brne more4
        
        rcall big_delay
        rjmp print_lcd

;**********************************************************
;Low_Delay: A 250 us delay
;**********************************************************
low_delay:
        push low_del
        push hi_del
        ldi low_del, 20
ld_hi:  ldi hi_del, 10
loop_in:
        dec hi_del
        cpi hi_del, 0
        brne loop_in
        dec low_del
        cpi low_del, 0
        brne ld_hi
        pop hi_del
        pop low_del
        ret

;**********************************************************
;Hi_Delay: A 5 ms delay
;**********************************************************
hi_delay:
        push low_del
        ldi low_del, 25
more_call:
        rcall low_delay
        dec low_del
        cpi low_del, 0
        brne more_call
        pop low_del
        ret

;**********************************************************
;Big_delay: A 1 s delay
;**********************************************************
big_delay:
       ldi low_del, 250
more_big:
        rcall hi_delay
        dec low_del
        cpi low_del, 0
        brne more_big
        ret
       

;**********************************************************
;Lcd_Low_Cmd: Sends a command to higher 4 bits of the LCD.
;The command nibble must be in the lower nibble of the
;variable 'lcd_cmd'
;**********************************************************
lcd_low_cmd:
        mov temp, lcd_cmd
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
        push lcd_cmd
        lsr lcd_cmd
        lsr lcd_cmd
        lsr lcd_cmd
        lsr lcd_cmd
        rcall lcd_low_cmd
        pop lcd_cmd
        andi lcd_cmd, $0f
        rcall lcd_low_cmd
        rcall low_delay
        ret

;**********************************************************
;Lcd_Low_Dat: Sends a data nibble to higher 4 bits of the 
;LCD. The data nibble must be in the lower nibble of the
;variable 'lcd_dat'
;**********************************************************
lcd_low_dat:
        mov temp, lcd_dat
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
;is stored in variable 'lcd_dat'
;**********************************************************
lcd_all_dat:
        push lcd_dat
        lsr lcd_dat
        lsr lcd_dat
        lsr lcd_dat
        lsr lcd_dat
        andi lcd_dat, $0f
        rcall lcd_low_dat
        pop lcd_dat
        andi lcd_dat, $0f
        rcall lcd_low_dat
        rcall low_delay
        ret


;**********************************************************
;Message #1
;**********************************************************
msg1: .db "Honk! Honk!      Honk! Honk!    "
;          12345678123456781234567812345678 
      
;**********************************************************
;Message #2
;**********************************************************
msg2: .db "The Way Morons    Communicate!  "
;          12345678123456781234567812345678 
