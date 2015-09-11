#include <avr/io.h>
#include <avr/interrupt.h>



		.global TIMER1_CAPT_vect
TIMER1_CAPT_vect:
		PUSH      R24            
		PUSH      R25
;Periodo = ICR1;
.extern Periodo
.extern flag
.extern RPM
   		LDS     R24,ICR1L ;0x0086     
   		LDS     R25,ICR1H ; 0x0087     
   		STS     Periodo+1,R25     
   		STS     Periodo,R24
		LDS		R24,flag 
		TST		R24
		BRNE    SIGUIENTE
		STS		TCNT1H, R24	;_SFR_MEM8(TCNT1H), R24
		STS		TCNT1L, R24
		SER		R24
		OUT 	_SFR_IO_ADDR(TIFR1), R24
		STS		flag, R24
		RJMP	FIN
.extern per2rpm
.extern per2freqhz
SIGUIENTE:
		LDS 	R24, Periodo
		LDS		R25, Periodo+1
		RCALL	per2rpm
		STS		RPM+1, R25
		STS		RPM, R24
		CLR		R24	
		STS		flag, R24
FIN:
		POP		R25
		POP		R24
		RETI

