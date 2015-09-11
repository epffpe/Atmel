#include <avr/io.h>

int main() {
	OSCCAL=0x9D;
	DDRD=0xff;
	PORTD=0;
	while(1) {
		
		PORTD = 0;
		PORTD = 0xff;
	}
return 0;

}
