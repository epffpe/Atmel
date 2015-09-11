#include <avr/io.h>
#include "funciones.h"

unsigned char gases;
int T;
void ADCinit( void );
char leer8ADC( void );
int leerADC ( void );
