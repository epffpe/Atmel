#include <avr/io.h>
/*rutina de retardo utilizando el timer0
hacer la siguiente configuracion para modificar el 
preescalamiento y las interrupciones, en este caso
el timer se desborda cada 256 us y para un argumento
de tipo entero no signado se tiene un retardo maximo de 
16.77 segundos

	TCCR0 = (1<<CS01); //preescalamiento del timer0 a clk/8
	TIMSK = 0x00; //sin interrupciones	ckl=8Mhz
*/
void delay(unsigned int delay){
	unsigned int i;
	unsigned char tmp;
	TCNT0 = 0x00; //limpieza del timer0
	for(i=0;i<delay;i++){
		do{
			tmp=TIFR;//lee registro de banderas
			tmp=tmp&(1<<TOV0);//enmascara TOV0 0x01
		}while(tmp==0);//mientras no se desborde
		tmp=(1<<TOV0);//enmascara TOV0 0x01
		TIFR=TIFR|tmp;//escribe al registro de banderas
	}
}