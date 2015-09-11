#include <avr/io.h>
#include <avr/interrupt.h>

int ms = 0;
int ms2 = 0;
int sec = 0;
int cont = 0;

int main(){
//char i;

  // Inicialización de Timer1
 TCC1.CTRLC = TC1_CMPA_bm ;//0x01;                  // habilitamos el comparador A
 //TCC1.CTRLC = 0x02;                  // habilitamos el comparador B

 //TCC1.CTRLD = 0x00;
 //TCC1.INTCTRLA = 0x00;               // no vamos a manejar las interrupciones ni por overflow ni error
 TCC1.INTCTRLB = TC1_CCAINTLVL1_bm; //0x02;               // habilitamos las interrupciones del canal A a nivel medio (10)
 //TCC1.INTCTRLB = 0x08;               // habilitamos las interrupciones del canal B a nivel medio (10)

 TCC1.INTFLAGS = 0xff;               // borramos los flags

 //TCC1.CNT = 0x4000;
 //TCC1.PER = 0x3e7f;                  // vamos a contar de 0 a 15999 (0x3e7f)
 //TCC1.CCA = 0x3e7f;                  // vamos a contar de 0 a 15999 (0x3e7f)
 TCC1.PER = 200;
 TCC1.CCA = 200;
 //TCC1.CCB = 0x3e7f;                  // vamos a contar de 0 a 15999 (0x3e7f)

 //TCC1.PERBUF = 0x00;
 //TCC1.CCABUF = 0x00;

 TCC1.CTRLB = TC1_CCAEN_bm | TC1_WGMODE0_bm; //0x11;                  // habilitar el canal A (CCAEN) y WGMODE = 001.
 //TCC1.CTRLB = 0x21;                // habilitar el canal B (CCBEN)     "

 //TCC1.CTRLA = 0x01;                  // DIV1
 TCC1.CTRLA = TC1_CLKSEL0_bm;              

 PMIC.CTRL |= PMIC_MEDLVLEX_bm;  //(1<<PMIC_MEDLVLEX_bp); // //; //habilitamos las interrupciones a nivel medio (10)
 sei();
	 
	while(1){
		sec = ms+1;
	};

}

ISR(TCC1_CCA_vect)
{

	ms ++;
	if (ms==1000) {
		sec++;
		ms=0;
	}
}
	

