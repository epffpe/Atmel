#include "funciones.h"




void SystemInit( void ) {
	//Calibracion del oscilador RC
	OSCCAL=0x84;
	//Puerto B como salida pero PB1 como entrada
	DDRB = 0xFE;
	//flag=0xff;
	//Inicializacion del LCD y configuracion
	LCD_Init();
	LCD_Display_conf();
	//Configuracion para permitir interrupcion por PCINT0/ICP1
	//PCMSK0=(1<<PCINT0);
	//Configuración del Timer0 
	TCCR0B=(1<<CS02) | (1<<CS00);
	TIMSK0=(1<<TOIE0);
	//Configuracion del OutputCompareA del Timer1
	OCR1A=4687;
	sei();

	//Empiezo la cuenta del periodo en cero
	TIM16_WriteTCNT1(0);
	//Activo las interrupciones de InputCapture CompareA y Overflow
	TIMSK1=(1<<ICIE1)|(1<<OCIE1A)|(1<<TOIE1);
	//Configuro el Timer 1 como inputCapture
	TCCR1B=(1<<ICNC1)|(1<<ICES1)|(5<<CS10);

}

unsigned int TIM16_ReadTCNT1( void ) {
	unsigned char sreg;
	unsigned int i;
	//Se salva la Interrupcion Global
	sreg = SREG;
	//Desabilito interrupcion para realizar la lectura
	cli();
	//Lectura el timer counter
	i=TCNT1;
	//Restaura el flag de Interrupcion global
	SREG=sreg;

	return i;
}

void TIM16_WriteTCNT1( unsigned int i) {
	unsigned char sreg;
	//unsigned int i;
	//Se salva la Interrupcion Global
	sreg = SREG;
	//Desabilito interrupcion para realizar la lectura
	cli();
	//Graba en el timer counter i
	TCNT1=i;
	//Restaura el flag de Interrupcion global
	SREG=sreg;
}

void inicio_rpm( void ) {
	//PCICR= (1<<PCIE0);	
}


uint16_t per2rpm(unsigned int per) {
	uint16_t rpm;
	//Modificar para mas general
	/*
	 *	Suponiendo un reloj de 8MHz y que el timer1 se divide en 1024
	 *	1024/8M=128us -> Periodo=128us*per -> freq=1/Periodo -> RPM=freq*60
	 *	RPM=468750/per=46875/per *10
	 */
	 rpm=46875 / (uint16_t)per;
	 rpm*=10;
	return rpm;
}

uint16_t per2freqhz(unsigned int per) {
	//uint16_t freq;

	return (7812 / (uint16_t)per);

}


void cuenta_periodo(void) {
	if (!flag) {
		TIM16_WriteTCNT1(1);
		TIFR1=0xff;
		flag=1;
			
	}else {
		//Calculo las RPM
		//RPM=per2rpm(Periodo);
		RPM=per2freqhz(Periodo);
		flag=0;
	}
	
}


//********************************************
// Rutinas de servicio de interrupcion
//********************************************
/*
 * Timer0 overflow: Genera los tiempos para gestionar el programa
 */
ISR(TIMER0_OVF_vect) {
	LCD_GotoXY(0, 0);
	LCD_enviar_msg("Gases:");
	LCD_GotoXY(0, 1);
	LCD_enviar_msg("Rev:");
	LCD_GotoXY(6, 1);
	utoa(RPM, s, 10);
	LCD_enviar_msg(s);
	LCD_enviar_msg(" rpm      ");
	//if (!flag) inicio_rpm();
}

/*
 * Interrupcion externa por PB1/PCINT0: Comienzo de cuenta de
 * las RPM
 */
/*
ISR(PCINT0_vect) {
	
	//Desactivo esta interrupcion
	PCICR &= ~(1<<PCIE0);
	//Empiezo la cuenta del periodo en cero
	TIM16_WriteTCNT1(0);
	//Activo las interrupciones de InputCapture CompareA y Overflow
	TIMSK1=(1<<ICIE1)|(1<<OCIE1A)|(1<<TOIE1);
	//Configuro el Timer 1 como inputCapture
	TCCR1B=(1<<ICNC1)|(1<<ICES1)|(5<<CS10);
	
}
*/
/*
 * 
 */
ISR(TIMER1_OVF_vect){
	//Desactivo las interrupciones del timer
	/* TIMSK1 = 0;
	 * TCCR1B=0;
	 */
	 if (flag) {
		RPM = 0;
		flag=0;
	}
}

ISR(TIMER1_COMPA_vect) {
	//Desactivo las interrupciones del timer
	/* TIMSK1 = 0;
	 * TCCR1B=0;
	 */
	if (flag) {
		RPM = 0;
		flag=0;
	}
}
/*
 *
 *
ISR(TIMER1_CAPT_vect){
	//Cargo el periodo
	Periodo = ICR1;
	cuenta_periodo();
}
*/
/*
 *
 */
ISR(USART_RX_vect) {

}

/*
 *
 */
ISR(USART_UDRE_vect) {

}

/*
 *
 */
ISR(ADC_vect) {

}
