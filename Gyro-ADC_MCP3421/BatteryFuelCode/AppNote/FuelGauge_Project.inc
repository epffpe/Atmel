;/****************************************/
;/*  File Name: FuelGauge_Project.inc
;/***************************************/


#define	sw_1_dir	TRISC,7			;Scroll Push-button switch S1, RRC7 on PCB
#define	sw_1		PORTC,7

#define	sw_2_dir	TRISB,0			;Select Push-button switch S2, RB0 on PCB
#define	sw_2		PORTB,0

#define	sw_3_dir	TRISB,1			;Select Push-button switch S3, RB1 on PCB
#define	sw_3		PORTB,1

#define	sw_4_dir	TRISB,2			;Select Push-button switch S3, RB1 on PCB
#define	sw_4		PORTB,2



#define SCL_dir		TRISA,4			; I2C SCL & SDA ...
#define SCLK_I2C	PORTA,4
#define SDA_dir		TRISA,5
#define SDA_I2C		PORTA,5


; define test points
#define Sync_LED11	PORTD,6
#define TP16_LED12	PORTD,7
#define TP17_LED13	PORTD,3



#define		DELAYTIME	.50			;Debounce Delay Constant ~10ms

