#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include <stdlib.h> //para las funciones de utoa
#include "LCDlib.h"
#include "serie.h"

uint8_t pulsos;
uint16_t RPM;
char s[6];

void SistIni(void);
void inicia_cuenta(void);
uint16_t pulsos2freq(uint8_t pulsos);
uint16_t pulsos2rpm(uint8_t pulsos);
