#include <avr/io.h>
#include <avr/interrupt.h>


int ms = 0;

int main(){
	//TCC1.CTRLA=0x88;
char i;
	 
	 TCC1_CTRLD = 0x00;
	 TCC1_INTCTRLA = 0x00;
	 TCC1_INTCTRLB = 0x02;
	 //TCC1_CTRLFCLR = 0x00;
	 //TCC1_CTRLFSET = 0x00;
	 //TCC1_CTRLGCLR = 0x00;
	 //TCC1_CTRLGSET = 0x00;
	 TCC1_INTFLAGS = 0xff;
	 //TCC1_CNT = 0x4000;
	 TCC1_PER = 0x3e7f;
	 TCC1_CCA = 0x3e7f;
	 //TCC1_PERBUF = 0x00;
	 //TCC1_CCABUF = 0x00;
	 TCC1_CTRLB = 0x10;
	 TCC1_CTRLA = 0x01;
	while(1);
		

}



ISR(TCC1_CCA_vect)
{
ms ++;

}
