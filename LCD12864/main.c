/*
 * Descripción:  Programa de Librería Demo para KS0108. 
 * El analizador lógico tiene la característica de que cuando se presiona un push boton, este lleva el pin del 
 * puerto a '0' lógico. Si se requiere que el pulso en la pantalla reaccione cuando se envía '1' lógico, es 
 * necesario cambiar las condiciones de su activación.
 */

#include <inttypes.h>
#include <avr/io.h>
#include <avr/pgmspace.h>


#include "ks0108.h"
#include "arial_bold_14.h"
#include "Arial8.h" 
#include "SC.h"
#include "Bitmap.h"
#include "timers.h"

#define canal4  0x04 
#define canal5  0x05       


/***** DECLARACIÓN DEFUNCIONES*****/

int convierte (unsigned char); //Función de conversión de la señal anlógica.
void menu(void); //función de despliegue del menu. 

/*****DECLARACIÓN DE VARIABLES*****/

unsigned char w,tecleo, tecleo_1; 
int amplitud, Yant, Yant2;

   
int main(void) 

{	/***********Configuración de los registros de datos y comandos*************/

   DDRC=0x00; //Parte alta como entrada y parte baja como salida.
   PORTC=0x0F;// Puerto C se utiliza para entradas al ADC y control del push Back.
   PORTB=0xE0;   // Puerto B resistencias en pull-up solo PB5-PB7, para control de los push1 y push2.
   TCCR0 = (1<<CS01); //preescalamiento del timer0 a clk/8
   

	// Espera un momento en lo que se inicializa el Display
	
	for(volatile uint16_t i=0; i<15000; i++);
	
	// Inicilalización de la LCD
	
	ks0108Init(0); //Inicializa la LCD en la coordenada 0 pagina 0.
	delay(SEG/10);
	   
	LoadBitmap(LOGOAG); //Carga el mapa de bits para desplegar en pantalla.
			  
    delay(3*SEG);// Retardo de aprox. 3s. SEG== 3906.
MENU:	
	menu();// Llama a la función para desplegar el menu de opciones.
	
	
	for(;;)
	{
	
	/******Segmento de la programación para el Osciloscopio.*******/
	
		if((PINB & 0XC0)==0x80) //Condición para seleccionar la opción en el menu de osciloscopio.
		{
			ks0108ClearScreen();	//Función para limpiar pantalla.
			ks0108SelectFont(Arial_Bold_14, ks0108ReadFontData, BLACK); //Selección del tipo de fuente.
			
			// Instrucción para situarce en la coordenada específica.
			ks0108GotoXY(40,27);
			
			// Instrucción para colocar un texto en pantalla, con el tamaño de fuente elejida.
			ks0108Puts_P(PSTR("Prueba 1"));
			
			ks0108DrawRoundRect(34, 25, 67, 15, 6, BLACK); // Dibuja un rectángulo redondeado.
			ks0108DrawRect(0,0,127,63,BLACK);	//Dibuja el marco alrededor de la pantalla.
			ks0108DrawLine(16, 8, 16, 60, BLACK); // Eje Y
			ks0108DrawLine(10, 55, 120, 55, BLACK); // Eje X2
			
			delay(SEG2);	//Aguarda un segundo de tiempo
			
			ks0108FillRect(30, 24, 73, 18, WHITE);// Borra el Letrero de Prueba 1.
			//ks0108DrawLine(10, 33, 120, 33, BLACK); // Eje X1
			
			ks0108SelectFont(Arial8, ks0108ReadFontData, BLACK); // Selecciona fuente Arial N°8
			// Instrucción para situarce en la coordenada específica.
			ks0108GotoXY(27,2);
			// Instrucción para colocar un texto en pantalla, con el tamaño de fuente elejida.
			ks0108Puts_P(PSTR("Osciloscopio Ver. 1.0"));
			
			ks0108GotoXY(1,42);
			ks0108Puts_P(PSTR("Ch2"));
			
			ks0108GotoXY(1,19);
			ks0108Puts_P(PSTR("Ch1"));
			
			//Inicialización del ADC.
			
			ADCSRA = _BV(ADPS2)|_BV(ADPS1)|_BV(ADEN);//preescalamiento a CPU/64, habilitacion del ADC
			ADMUX=_BV(REFS0)|_BV(ADLAR); // SE UTILIZA LA REFERENCIA DE avcc CON CAPACITOR EXTERNO y 8bits de resolución.
			//ADMUX =ADMUX|0x00; //Y justifica la conversión a la derecha (ADLAR) para 10 bits de resolución
			
			
			for(;;)
			{
				for(w=16; w<120;w++) // se asigna w un amplio de 105 puntos, que es el correpondiente a lo largo del eje x.
									// Esto se hace para que siempre se este barriendo los ejes X.
				{
					if((PINC&0x01)==0x00)// Si se presiona el boton de Back, regresa al menu para elegir una opción.
						goto MENU;
					//Graficación sobre el eje X2	
					amplitud= convierte(canal5);
					ks0108SetDot(w, (55-amplitud), BLACK);// Coloca un punto en el rango que le corresponde a la conversion. 
										
					if(w>16)//Si w ya esta en almenos en el segundo punto
						ks0108DrawLine(w-1, (55-Yant2), w, (55-amplitud), BLACK); //dibuja una línea del punto anterior al 
																					//punto actual. 
					Yant2= amplitud;//Respalda la abscisa anterior.
					
					//Graficación sobre el eje X1
					amplitud= convierte(canal4);
					ks0108SetDot(w, (33-amplitud), BLACK);// Coloca un punto en el rango que le corresponde a la conversion. 
					
					if(w>16)
						ks0108DrawLine(w-1, (33-Yant), w, (33-amplitud), BLACK);
					Yant= amplitud;
					delay(186);
					
				}
				ks0108FillRect(17,35,104,19,WHITE);// Borra lo dibujado en los 2 eje X...
				ks0108FillRect(17,13,104,20,WHITE);
				w=16; // y vuelve a barrer el eje X.	
			}
		}
		
		/******Segmento de la programación para el Analizador Lógico.*******/
 
		if ((PINB & 0XC0)==0x40)//Condición para seleccionar la opción en el menu de analizador lógico.
		{
			ks0108ClearScreen();	
			ks0108SelectFont(Arial_Bold_14, ks0108ReadFontData, BLACK);
			
			// Instrucción para situarce en la coordenada específica.
			ks0108GotoXY(40,27);
			
			// Instrucción para colocar un texto en pantalla, con el tamaño de fuente elejida.
			ks0108Puts_P(PSTR("Prueba 2"));
			
			ks0108DrawRoundRect(34, 25, 67, 15, 6, BLACK); // Dibuja un rectángulo redondeado.
			ks0108DrawRect(0,0,127,63,BLACK);	//Dibuja el marco alrededor de la pantalla.
			ks0108DrawLine(16, 8, 16, 60, BLACK); // Eje Y
			ks0108DrawLine(10, 55, 120, 55, BLACK); // Eje X2
			
			delay(SEG2);	//Aguarda un segundo de tiempo
			
			ks0108FillRect(30, 24, 73, 18, WHITE);// Borra el Letrero de Prueba 1.
			ks0108DrawLine(10, 33, 120, 33, BLACK); // Eje X1
			
			ks0108SelectFont(Arial8, ks0108ReadFontData, BLACK); // Selecciona fuente Arial N°8
			// Instrucción para situarce en la coordenada específica.
			ks0108GotoXY(32,2);
			// Instrucción para colocar un texto en pantalla, con el tamaño de fuente elejida.
			ks0108Puts_P(PSTR("Analizador Logico"));
			
			
			ks0108GotoXY(42,11);
			// Instrucción para colocar un texto en pantalla, con el tamaño de fuente elejida.
			ks0108Puts_P(PSTR("Version 1.0"));
			
			
			
			ks0108GotoXY(1,42);
			ks0108Puts_P(PSTR("Ch2"));
			
			
			ks0108GotoXY(1,19);
			ks0108Puts_P(PSTR("Ch1"));
		
			for (;;)
			{
				for(w=16; w<120;w++) // se asigna w un amplio de 105 puntos, que es el correpondiente a lo largo del eje x.
				{	
					if((PINC&0x01)==0x00)//Si se presiona este boton
						goto MENU;
						
					if ((PINB|0x3F) == 0x7F || (PINB|0x3F)==0x3F) // Señal de detección de 1 lógico para el canal 2.
					{
						if (tecleo ==0) //  Si la señal viene de tomar un valor 0 a 1 lógico...  
							ks0108DrawLine(w, 45, w, 55, BLACK);	//Dibuja el flanco de subida hasta el valor 1 lógico.
						ks0108SetDot(w, 45, BLACK);	//Grafica los puntos en la posición marcado por w en el nivel de 1 lógico 
						tecleo=1; // Asigna valor unitario la variable para que no se dibujen líneas verticales después de 
							  // que se tiene presente la señal.
					}
					if (((PINB|0x3F) == 0xFF || (PINB|0x3F)==0xBF) && tecleo==1) // Condición para dibujar el flanco de bajada del pulso detectado.
												//Si no se detecta señal en el puerto y además se viene de un valor logico 1,
												//se debe dibujar el flanco de bajada.
					{
						ks0108DrawLine(w, 45, w, 55, BLACK);
						tecleo=0;
					}
	
					if ((PINB|0x3F) == 0xBF || (PINB|0x3F)==0x3F) // Señal de detección de 1 lógico para el canal 1.
					{
						if (tecleo_1 ==0) //  Si la señal viene de tomar un valor 0 a 1 lógico,  
							ks0108DrawLine(w, 23, w, 33, BLACK);	//Dibuja una linea vertical hasta el valor 1 lógico.
						ks0108SetDot(w, 23, BLACK);	//Grafica los puntos en la posición marcado por w en el nivel de 1 lógico 
						tecleo_1=1; // Asigna valor unitario la variable para que no se dibujen líneas verticales después de 
							  // que se tiene presente la señal.
					}
					if (((PINB|0x3F)== 0xFF || (PINB|0x3F)==0x7F) && tecleo_1==1) // Condición para dibujar el flanco de bajada del pulso detectado.
												//Si no se detecta señal en el puerto y además se viene de un valor logico 1,
												//se debe dibujar el flanco de bajada.
					{
						ks0108DrawLine(w, 23, w, 33, BLACK);
						tecleo_1=0;
					}
				
					delay(186); // Retardo, el timer esta escalado a 8, asi que se se desborda cada 256us, si se quiere 
							//una base de tiempo sobre el eje x de 5s, a cada pixel de la LCD, le toca 186*256us.
				}
				ks0108FillRect(17,45,104,9,WHITE);// Borra lo dibujado en los 2 eje X...
				ks0108FillRect(17,23,104,9,WHITE);
				w=16; // y vuelve a barrer el eje X.	
			}
		}
	}
}

/**************Segmento de Funciones************************/

void menu(void)
{
	ks0108ClearScreen();

	// Seleción de la Fuente de N° 8.
	
	ks0108SelectFont(Arial_Bold_14, ks0108ReadFontData, BLACK);		
	ks0108GotoXY(0,15);
	ks0108Puts_P(PSTR("Selecciona 1 opcion"));
	ks0108SelectFont(Arial8, ks0108ReadFontData, BLACK);
	
	ks0108GotoXY(15,35);
	ks0108Puts_P(PSTR("1. Osciloscopio"));
	
	ks0108GotoXY(15,45);
	ks0108Puts_P(PSTR("2. Analizador Logico"));

}

int convierte(unsigned char canal)
{
    unsigned int entero=0;//en 32 bits para resultado del escalamiento.
	unsigned int result=0;//en 16 bits para ADCH y ADCL.
		ADMUX=ADMUX & 0xF8;//Limpia la selección del canal.
		ADMUX=ADMUX|canal; // Selección del canal.
		ADCSRA |= _BV(ADSC);//comienza la conversion del canal seleccionado. 
		loop_until_bit_is_clear(ADCSRA,ADSC);//espera a que la conversión se haya realizado.
		result=ADCH;
		entero = (result*0x14)/0xFF;//resultado de la multiplicaciÓn. Se multiplica por 14H=20D,
									//es la amplitud m+axima en pixeles que la señal puede tomar.
		return(entero);
		
}


		



