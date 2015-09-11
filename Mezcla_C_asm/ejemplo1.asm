NAME get_port
	#include "avr/io.h"
	PUBLIC get_port
	RSEG CODE

get_port;
	IN 		R16, PIND
	SWAP	R16
	OUT		PORTB, R16
	RET
END
