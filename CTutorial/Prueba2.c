#include <avr/io.h>

unsigned char z;

int main(){
	DDRB=0xFF;
	
	while (1){
		z=PINC;
		PORTB= 12/z;
	}
	return 0;
}
