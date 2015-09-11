//*****************************************************************************
//
// File Name	: 'main.c'
// Title		: ADC single conversion witn interrupt after conversion
//
//*****************************************************************************
#include <stdio.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <avr/sleep.h>
#include "lcd_lib.h"
#define F_CPU 4E6
//adjust LCDsendChar() function for stream
static int LCDsendstream(char c, FILE *stream);
//----set output stream to LCD-------
static FILE lcd_str = FDEV_SETUP_STREAM(LCDsendstream, NULL, _FDEV_SETUP_WRITE);


void delay1s(void);
void adc_init(void);
void adc_start_conversion(uint8_t);
static int LCDsendstream(char c , FILE *stream);
void init(void);

//current channel
uint8_t ch;
//strings for LCD stored in Flash memory
const uint8_t LDR[] PROGMEM="LDR:\0";
const uint8_t POT[] PROGMEM="POT:\0";
const uint8_t CLRROW[] PROGMEM="                \0";

const uint8_t *LCDXY[] ={
		LDR,	//for ADC0
		POT};	//for ADC1


//*****************************************************************************
//
//  ADC module initialization 
//
//*****************************************************************************
void adc_init(void)
{
//select reference voltage
//AVCC with external capacitor at AREF pin
ADMUX|=(0<<REFS1)|(1<<REFS0);
//set prescaller and enable ADC
ADCSRA|=(1<<ADEN)|(1<<ADIE);//enable ADC with dummy conversion
//set sleep mode for ADC noise reduction conversion
set_sleep_mode(SLEEP_MODE_ADC);
}
//*****************************************************************************
//
//  ADC single conversion routine 
//
//*****************************************************************************
void adc_start_conversion(uint8_t channel)
{
//remember current ADC channel;
ch=channel;
//set ADC channel
ADMUX=(ADMUX&0xF0)|channel;
//Start conversionio with Interupt after conversion
//enable global interrupts
sei();
ADCSRA |= (1<<ADSC)|(1<<ADIE);
}

//*****************************************************************************
//
//  delay 1s 
//
//*****************************************************************************

//delay 1s
void delay1s(void)
{
	uint8_t i;
	for(i=0;i<100;i++)
	{
		_delay_ms(10);
	}
}

//*****************************************************************************
//
//  Set LCD stream function 
//
//*****************************************************************************
static int LCDsendstream(char c , FILE *stream)
{
LCDsendChar(c);
return 0;
}

//*****************************************************************************
//
//  init AVR
//
//*****************************************************************************

void init(void)
{
	//init stream
	stdout = &lcd_str;
	//init LCD
	LCDinit();//init LCD bit, dual line, cursor right
	LCDclr();//clears LCD
	LCDGotoXY(0, 0);//Cursor Home
	//Init ADC
	adc_init();
}

//*****************************************************************************
//
//  ADC conversion complete service routine 
//
//*****************************************************************************
ISR(ADC_vect)
{
	uint16_t adc_value;
	adc_value = ADCL;  
	/*shift from low level to high level ADC, from 8bit to 10bit*/
	adc_value += (ADCH<<8);
	CopyStringtoLCD(CLRROW, 0, ch );
	CopyStringtoLCD(LCDXY[(ch)], 0, ch );
	printf("%d", adc_value);
}

//*****************************************************************************
//
//  run analog digital converter, timer. 
//
//*****************************************************************************
int main(void)
{
	init();
	printf("ADC Test");
	delay1s();
	while(1)//loop demos
	{
	//read LDR
	adc_start_conversion(0);
	_delay_ms(30);
	//read potentiometer
	adc_start_conversion(1);
	_delay_ms(30);
	//continue infinitely
	}
	return 0;
}
