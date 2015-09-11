#include <avr/io.h>				;required for register definitions

.extern pinbits					;external variable

.global InitPort				;make accesible globally

InitPort:					;function name  

	push r18				;save register value

	lds r18, pinbits			;load variable to r18

	out _SFR_IO_ADDR(DDRD), r18	;set pins as output

	pop r18				;restore register

	ret					;return from subroutine

.global sendpinbits				;make global

sendpinbits:					;function name

	push r18				;save register value

	lds r18, pinbits			;load variable to r18

	out _SFR_IO_ADDR(PORTD), r18	;pins to High

	pop r18				;restore register

	ret					;return from subroutine


 
