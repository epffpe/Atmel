#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdlib.h>
#include <stdint.h>
#include "LCD.h"
unsigned int Periodo;
uint16_t RPM;
unsigned char flag;
char s[6];


void SystemInit( void );
unsigned int TIM16_ReadTCNT1( void );
void TIM16_WriteTCNT1( unsigned int i);
void inicio_rpm( void );
uint16_t per2rpm(unsigned int per);
uint16_t per2freqhz(unsigned int per);
void cuenta_periodo(void);
