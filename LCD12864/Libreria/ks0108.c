/*
 * 
 * Descripción:    Librería Grafica para KS0108 y compatibles basada en LCD's.
 * 
 */

#include <inttypes.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include "ks0108.h"

//********NOTA: uint8_t== Unsigned char.***************//

lcdCoord			ks0108Coord; //Define ks0108Coord como una estructura, en donde se solicita coordenadas (X,Y) y la página.
uint8_t				ks0108Inverted=0; 
ks0108FontCallback	ks0108FontRead;
uint8_t				ks0108FontColor;
const uint8_t*		ks0108Font;

void ks0108DrawLine(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2, uint8_t color) {
	uint8_t length, i, y, yAlt, xTmp, yTmp;
	int16_t m;
	
	//
	// vertical line
	//
	if(x1 == x2) {
		// x1|y1 must be the upper point
		if(y1 > y2) {
			yTmp = y1;
			y1 = y2;
			y2 = yTmp;
		}
		ks0108DrawVertLine(x1, y1, y2-y1, color);
	
	//
	// horizontal line
	//
	} else if(y1 == y2) {	
		// x1|y1 must be the left point
		if(x1 > x2) {
			xTmp = x1;
			x1 = x2;
			x2 = xTmp;
		}
		ks0108DrawHoriLine(x1, y1, x2-x1, color);
	
	//
	// schiefe line :)
	//
	} else {
		// angle >= 45°
		if((y2-y1) >= (x2-x1) || (y1-y2) >= (x2-x1)) {
			// x1 must be smaller than x2
			if(x1 > x2) {
				xTmp = x1;
				yTmp = y1;
				x1 = x2;
				y1 = y2;
				x2 = xTmp;
				y2 = yTmp;
			}
		
			length = x2-x1;		// not really the length :)
			m = ((y2-y1)*200)/length;
			yAlt = y1;
			
			for(i=0; i<=length; i++) {
				y = ((m*i)/200)+y1;
				
				if((m*i)%200 >= 100)
					y++;
				else if((m*i)%200 <= -100)
					y--;
				
				ks0108DrawLine(x1+i, yAlt, x1+i, y, color);
				
				if(length <= (y2-y1) && y1 < y2)
					yAlt = y+1;
				else if(length <= (y1-y2) && y1 > y2)
					yAlt = y-1;
				else
					yAlt = y;
			}
		
		// angle < 45°
		} else {
			// y1 must be smaller than y2
			if(y1 > y2) {
				xTmp = x1;
				yTmp = y1;
				x1 = x2;
				y1 = y2;
				x2 = xTmp;
				y2 = yTmp;
			}
			
			length = y2-y1;
			m = ((x2-x1)*200)/length;
			yAlt = x1;
			
			for(i=0; i<=length; i++) {
				y = ((m*i)/200)+x1;
				
				if((m*i)%200 >= 100)
					y++;
				else if((m*i)%200 <= -100)
					y--;
				
				ks0108DrawLine(yAlt, y1+i, y, y1+i, color);
				if(length <= (x2-x1) && x1 < x2)
					yAlt = y+1;
				else if(length <= (x1-x2) && x1 > x2)
					yAlt = y-1;
				else
					yAlt = y;
			}
		}
	}
}

void ks0108DrawRect(uint8_t x, uint8_t y, uint8_t width, uint8_t height, uint8_t color) {
	ks0108DrawHoriLine(x, y, width, color);				// top
	ks0108DrawHoriLine(x, y+height, width, color);		// bottom
	ks0108DrawVertLine(x, y, height, color);			// left
	ks0108DrawVertLine(x+width, y, height, color);		// right
}

void ks0108DrawRoundRect(uint8_t x, uint8_t y, uint8_t width, uint8_t height, uint8_t radius, uint8_t color) {
  	int16_t tSwitch, x1 = 0, y1 = radius;
  	tSwitch = 3 - 2 * radius;
	
	while (x1 <= y1) {
	    ks0108SetDot(x+radius - x1, y+radius - y1, color);
	    ks0108SetDot(x+radius - y1, y+radius - x1, color);

	    ks0108SetDot(x+width-radius + x1, y+radius - y1, color);
	    ks0108SetDot(x+width-radius + y1, y+radius - x1, color);
	    
	    ks0108SetDot(x+width-radius + x1, y+height-radius + y1, color);
	    ks0108SetDot(x+width-radius + y1, y+height-radius + x1, color);

	    ks0108SetDot(x+radius - x1, y+height-radius + y1, color);
	    ks0108SetDot(x+radius - y1, y+height-radius + x1, color);

	    if (tSwitch < 0) {
	    	tSwitch += (4 * x1 + 6);
	    } else {
	    	tSwitch += (4 * (x1 - y1) + 10);
	    	y1--;
	    }
	    x1++;
	}
	  	
	ks0108DrawHoriLine(x+radius, y, width-(2*radius), color);			// top
	ks0108DrawHoriLine(x+radius, y+height, width-(2*radius), color);	// bottom
	ks0108DrawVertLine(x, y+radius, height-(2*radius), color);			// left
	ks0108DrawVertLine(x+width, y+radius, height-(2*radius), color);	// right
}

/*
 * Hardware-Functions 
 */
void ks0108FillRect(uint8_t x, uint8_t y, uint8_t width, uint8_t height, uint8_t color) {
	uint8_t mask, pageOffset, h, i, data;
	height++;
	
	pageOffset = y%8;
	y -= pageOffset;
	mask = 0xFF;
	if(height < 8-pageOffset) {
		mask >>= (8-height);
		h = height;
	} else {
		h = 8-pageOffset;
	}
	mask <<= pageOffset;
	
	ks0108GotoXY(x, y);
	for(i=0; i<=width; i++) {
		data = ks0108ReadData();
		
		if(color == BLACK) {
			data |= mask;
		} else {
			data &= ~mask;
		}

		ks0108WriteData(data);
	}
	
	while(h+8 <= height) {
		h += 8;
		y += 8;
		ks0108GotoXY(x, y);
		
		for(i=0; i<=width; i++) {
			ks0108WriteData(color);
		}
	}
	
	if(h < height) {
		mask = ~(0xFF << (height-h));
		ks0108GotoXY(x, y+8);
		
		for(i=0; i<=width; i++) {
			data = ks0108ReadData();
		
			if(color == BLACK) {
				data |= mask;
			} else {
				data &= ~mask;
			}
	
			ks0108WriteData(data);
		}
	}
}

void ks0108InvertRect(uint8_t x, uint8_t y, uint8_t width, uint8_t height) {
	uint8_t mask, pageOffset, h, i, data, tmpData;
	height++;
	
	pageOffset = y%8;
	y -= pageOffset;
	mask = 0xFF;
	if(height < 8-pageOffset) {
		mask >>= (8-height);
		h = height;
	} else {
		h = 8-pageOffset;
	}
	mask <<= pageOffset;
	
	ks0108GotoXY(x, y);
	for(i=0; i<=width; i++) {
		data = ks0108ReadData();
		tmpData = ~data;
		data = (tmpData & mask) | (data & ~mask);
		ks0108WriteData(data);
	}
	
	while(h+8 <= height) {
		h += 8;
		y += 8;
		ks0108GotoXY(x, y);
		
		for(i=0; i<=width; i++) {
			data = ks0108ReadData();
			ks0108WriteData(~data);
		}
	}
	
	if(h < height) {
		mask = ~(0xFF << (height-h));
		ks0108GotoXY(x, y+8);
		
		for(i=0; i<=width; i++) {
			data = ks0108ReadData();
			tmpData = ~data;
			data = (tmpData & mask) | (data & ~mask);
			ks0108WriteData(data);
		}
	}
}

void ks0108SetInverted(uint8_t invert) {
	if(ks0108Inverted != invert) {
		ks0108InvertRect(0,0,127,63);
		ks0108Inverted = invert;
	}
}

/*****FUNCIÓN PARA ESCRIBIR UN PUNTO EN LA LCD.******/

void ks0108SetDot(uint8_t x, uint8_t y, uint8_t color) /*Esta función maneja un envío de tres parámetros, los cuales
														son de tipo caractér sin signo, en donde corresponden a las
														coordenas (x,y), y el color que se requiere el punto.*/	 
{
	uint8_t data; /* En data se respalda el estado del byte que conforma los 8 pixeles que determinan 
				  las coordenadas (X,Y).*/
	
	ks0108GotoXY(x, y-y%8);	// Llama a la función para situar el punto en la coordenada indicada por (x,y).
	data = ks0108ReadData();	/* Llamado a la función de petición de lectura de una localidad de la LCD. Se lee antes
								de escribir el estado del punto para saber su condición.*/
	
	if(color == BLACK) 	
	{
		data |= 0x01 << (y%8);	// instrucción para colocar el punto, es decir, encender el pixel.
	} else {
		data &= ~(0x01 << (y%8));	// instrucción para limpiar el punto, es decir, apagar el pixel.
	}
	
	ks0108WriteData(data);	//Llamado de la función para escribir el dato.
}

//
// Font Functions
//

uint8_t ks0108ReadFontData(const uint8_t* ptr) {
	return pgm_read_byte(ptr);
}

void ks0108SelectFont(const char* font, ks0108FontCallback callback, uint8_t color) {
	ks0108Font = font;
	ks0108FontRead = callback;
	ks0108FontColor = color;
}

int ks0108PutChar(char c) {
	uint8_t width = 0;
	uint8_t height = ks0108FontRead(ks0108Font+FONT_HEIGHT);
	uint8_t bytes = (height+7)/8;
	
	uint8_t firstChar = ks0108FontRead(ks0108Font+FONT_FIRST_CHAR);
	uint8_t charCount = ks0108FontRead(ks0108Font+FONT_CHAR_COUNT);
	
	uint16_t index = 0;
	uint8_t x = ks0108Coord.x, y = ks0108Coord.y;
	
	if(c < firstChar || c >= (firstChar+charCount)) {
		return 1;
	}
	c-= firstChar;
	
	// read width data, to get the index
	for(uint8_t i=0; i<c; i++) {
		index += ks0108FontRead(ks0108Font+FONT_WIDTH_TABLE+i);
	}
	index = index*bytes+charCount+FONT_WIDTH_TABLE;
	width = ks0108FontRead(ks0108Font+FONT_WIDTH_TABLE+c);
	
	// last but not least, draw the character
	for(uint8_t i=0; i<bytes; i++) {
		uint8_t page = i*width;
		for(uint8_t j=0; j<width; j++) {
			uint8_t data = ks0108FontRead(ks0108Font+index+page+j);
			
			if(height < (i+1)*8) {
				data >>= (i+1)*8-height;
			}
			
			if(ks0108FontColor == BLACK) {
				ks0108WriteData(data);
			} else {
				ks0108WriteData(~data);
			}
		}
		// 1px gap between chars
		if(ks0108FontColor == BLACK) {
			ks0108WriteData(0x00);
		} else {
			ks0108WriteData(0xFF);
		}
		ks0108GotoXY(x, ks0108Coord.y+8);
	}
	ks0108GotoXY(x+width+1, y);
	
	return 0;
}

void ks0108Puts(char* str) {
	int x = ks0108Coord.x;
	while(*str != 0) {
		if(*str == '\n') {
			ks0108GotoXY(x, ks0108Coord.y+ks0108FontRead(ks0108Font+FONT_HEIGHT));
		} else {
			ks0108PutChar(*str);
		}
		str++;
	}
}

void ks0108Puts_P(PGM_P str) {
	int x = ks0108Coord.x;
	while(pgm_read_byte(str) != 0) {
		if(pgm_read_byte(str) == '\n') {
			ks0108GotoXY(x, ks0108Coord.y+ks0108FontRead(ks0108Font+FONT_HEIGHT));
		} else {
			ks0108PutChar(pgm_read_byte(str));
		}
		str++;
	}
}

uint8_t ks0108CharWidth(char c) {
	uint8_t width = 0;
	uint8_t firstChar = ks0108FontRead(ks0108Font+FONT_FIRST_CHAR);
	uint8_t charCount = ks0108FontRead(ks0108Font+FONT_CHAR_COUNT);
	
	// read width data
	if(c >= firstChar && c < (firstChar+charCount)) {
		c -= firstChar;
		width = ks0108FontRead(ks0108Font+FONT_WIDTH_TABLE+c)+1;
	}
	
	return width;
}

uint16_t ks0108StringWidth(char* str) {
	uint16_t width = 0;
	
	while(*str != 0) {
		width += ks0108CharWidth(*str++);
	}
	
	return width;
}

uint16_t ks0108StringWidth_P(PGM_P str) {
	uint16_t width = 0;
	
	while(pgm_read_byte(str) != 0) {
		width += ks0108CharWidth(pgm_read_byte(str++));
	}
	
	return width;
}

//////********FUNCIÓN PARA POSICIONARSE EN UNA COORDENADA ESPECIFICA DE LA LCD.*********///////////

void ks0108GotoXY(uint8_t x, uint8_t y) {
	uint8_t chip = CHIP1, cmd;
	
	if(x > 127) x = 0;	//Con estas dos instrucciones IF, lo que se pretende es que si se envían unas coordenadas fuera del 
	if(y > 63)  y = 0; //rango de trabajo de la LCD, estas coordenadas se ajusten al inicio de la LCD, esto para evitar 
						//escrituras erróneas en la memorias del LCD. Además de ser visible en el comportamiento de lo que 
						//ocurre en la LCD y así el programador pueda ajustar el error.
	
	ks0108Coord.x = x;	// Instrucción para salvar las nuevas coordenadas dentro de la estructura de tipo lcdCoord, dentro 
	ks0108Coord.y = y; //  de las variables propias de la estructura ks0108Coord.
	ks0108Coord.page = y/8; // Se divide entre 8 la coordenada "Y" para saber en que página se debe dibujar. Una página esta
							//compuesta por 8 líneas. Así Y0 le corresponden de la línea 0hasta la línea 7. 
	
	if(x >= 64) {		// Rutina para determinar si se va a graficar en el lado derecho de la LCD. Cada mitad de la LCD
		x -= 64;		// esta compuesta por un ancho de 64 puntos, por lo tanto, si X>= 64, se respalda el valor de CHIP2=0x01, 
		chip = CHIP2;	// que corresponde al valor de seleccionar el lado derecho de la pantalla; se resta 64 al valor de "X" 
	}					// para saber en que columna ( coordenada x) del lado derecho se va a graficar.
	
	cmd = LCD_SET_ADD | x; // LCD_SET_ADD= 40H. El cual corresponde al valor del COMANDO de la Coordenada "X" cero (columna 0); 
						   // se realiza un enmascaramiento con el nuevo valor de la coordenada "X", para posicionarse en la columna
						   // deseada.
	ks0108WriteCommand(cmd, chip);	// Se hace llamado a la función que introduce los comandos y activación de chip que determina el 
									// lado a ocupar de la LCD.
	
	cmd = LCD_SET_PAGE | ks0108Coord.page;	// Inicialmente LCD_SET_PAGE= 0xB8. Se realiza un enmascaramiento con el valor de 
											// La página en donde se desea dibujar y se envía este comando a las dos mitades 
	ks0108WriteCommand(cmd, CHIP1);	 //que posee la LCD.
	ks0108WriteCommand(cmd, CHIP2);
}

			/****************FUNCIÓN PARA INICIALIZAR PANTALLA**********************/

void ks0108Init(uint8_t invert)
{
	ks0108Coord.x = 0;			//Inicializa coordenadas (X,Y) y página.
	ks0108Coord.y = 0;
	ks0108Coord.page = 0;
	
	ks0108Inverted = invert;
	
	LCD_CMD_DIR = 0x1F;					// Redirecciona puerto de datos como Salida para generar comandos de inicialización.
	ks0108WriteCommand(LCD_ON, CHIP1);	// escribe comandos de encendido de la LCD, chip1 y chip2.
	ks0108WriteCommand(LCD_ON, CHIP2);
	
	ks0108WriteCommand(LCD_DISP_START, CHIP1);		// Escribe comando de inicio en línea 0.
	ks0108WriteCommand(LCD_DISP_START, CHIP2);
	ks0108ClearScreen();							// Rutina de limpieza de LCD.
	ks0108GotoXY(0,0);						// Ve a coordenada inicial (0,0).
}

/////////*****FUNCIÓN PARA HABILITAR LA LCD.******///////////

inline void ks0108Enable(void) 

{
	LCD_CMD_PORT |= 0x01 << EN;			// Activa el 3° bit del puerto de datos.ENABLE en alto.
	asm volatile("nop\n\t"				//Pérdida de tiempo; el enable necesita un tiempo min. de activación para 
				 "nop\n\t"				// que la LCD asimile las intrucciones o datos que se le envían.
				 "nop\n\t"
				 ::);
	LCD_CMD_PORT &= ~(0x01 << EN);	// Deshabilitación del ENABLE una vez que se asimilo el comando o datos po la LCD.
	for(volatile uint8_t i=0; i<10; i++);		// Retardo para esperar el establecimiento de la LCD.
}

////////******FUNCIÓN DE LECTURA DE DATOS DE LA LCD.*****////////

uint8_t ks0108DoReadData(uint8_t first)
{
	uint8_t data;	// Variable en donde se respalda el valor del pixel (de los 8 pixeles).
	volatile uint8_t i;
	
	LCD_DATA_OUT = 0x00;	//Se limpia el puerto de datos.
	LCD_DATA_DIR = 0x00;	// Redireccionamiento del puerto de datos. Ahora como entrada.
	
	if(ks0108Coord.x < 64) //Condición para determinar en que mitad de la pantalla se encuentra el dato. 
	{
		LCD_CMD_PORT &= ~(0x01 << CSEL2);	// Si la coordenada "X" < 64, el dato esta en la 1° mitad de la LCD
		LCD_CMD_PORT |= 0x01 << CSEL1;		// y Selecciona chip 1.
	} 
	else if(ks0108Coord.x >= 64) 			//De otra manera el dato se encuentra en la 2° mitad de la pantalla.
	{
		LCD_CMD_PORT &= ~(0x01 << CSEL1);		
		LCD_CMD_PORT |= 0x01 << CSEL2;		// Por lo tanto selecciona chip2.		
	}
	if(ks0108Coord.x == 64 && first) 	//Si "X"= 64, se trata de la 2° mitad de la LCD, pero posicionada en
	{									// la 1° columna de la 2° parte de la LCD.
		ks0108WriteCommand(LCD_SET_ADD, CHIP2); 	//Función para 1° columna, chip2. Segunda mitad.
	}
	
	LCD_CMD_PORT |= 0x01 << D_I;	// Establece comando de modo datos a la LCD. D/I = 1
	LCD_CMD_PORT |= 0x01 << R_W;	// Se Establece lectura de datos de la LCD. R/W = 1
	
	LCD_CMD_PORT |= 0x01 << EN;		// Se activa Enable para asimilar los comandos.
	asm volatile("nop\n\t"
				   "nop\n\t"			//Tiempo de espera de activación del Enable.
				   "nop\n\t"
				 ::);
	
	data = LCD_DATA_IN;				// Respaldo de la Lectura del dato de la coordenada previamente situada por ks0108GotoXY. 			 
	
	LCD_CMD_PORT &= ~(0x01 << EN); //Deshabilita Enable.
	for(i=0; i<10; i++);			// Retardo para esperar el establecimiento de la LCD.
	
	LCD_DATA_DIR = 0xFF; //Redirecciona puerto de datos a salida.
	
	ks0108GotoXY(ks0108Coord.x, ks0108Coord.y); // Posicionamiento en la coordenada que se leyó.
	
	if(ks0108Inverted)	//Condición para cuando se trabaja con la función de invertido, si la función de invertido 
		data = ~data;	// esta activada, entonces e dato debe ser el complemento de lo que se leyó.
	return data;
}

////////******FUNCIÓN DE PETICIÓN DE LECTURA******////////

inline uint8_t ks0108ReadData(void)
{
	ks0108DoReadData(1);			// Petición de lectura de dato.
	return ks0108DoReadData(0);	// Envío del dato leído.
}

/********FUNCIÖN PARA AJUStAR COMANDOS Y LADO A OCUPAR EN LA LCD.***********/

void ks0108WriteCommand(uint8_t cmd, uint8_t chip) // Los parámetros que se pasan  a esta función corresponden al comando
													//para regir el comportamiento de la LCD (uint8_t cmd) y la activación
													//del chip (uint8_t chip) que determina la mitad de la LCD donde
													//se desea dibujar.

{
	if(chip == CHIP1) // Si chip igual a CHIP1, se desea dibujar en la parte izquierda de la LCD.
	{
		LCD_CMD_PORT &= ~(0x01 << CSEL2);			// Se deselecciona CHIP2. 
		LCD_CMD_PORT |= 0x01 << CSEL1;				// Se selceccióna CHIP1.
	} 
	else if(chip == CHIP2) //Condición para seleccionar la parte derecha de la LCD.
	{
		LCD_CMD_PORT &= ~(0x01 << CSEL1);			// se deseleccciona chip 1
		LCD_CMD_PORT |= 0x01 << CSEL2;				// Se selecciona Chip 2
	}
	
	LCD_CMD_PORT &= ~(0x01 << D_I);				// Selecciona modo de instrucción. D/I = 0
	LCD_CMD_PORT &= ~(0x01 << R_W);				// Se habilita escritura de la LCD. R/W = 0
	LCD_DATA_DIR = 0xFF;							// Se redirecciona el bus de datos. Puerto como salida.
	LCD_DATA_OUT = cmd;								// Escribe comando en el puerto de datos.
	ks0108Enable();									// Habilita Pantalla.
	LCD_DATA_OUT = 0x00;							// Se redirecciona el bus. Puerto como entrada.
}

////////******FUNCIÓN DE ESCRITURA DE 1 PUNTO EN LA LCD******////////

void ks0108WriteData(uint8_t data) 
{
	uint8_t displayData, yOffset, cmdPort;

#ifdef DEBUG
	volatile uint16_t i;
	for(i=0; i<5000; i++);
#endif

	if(ks0108Coord.x >= 128) // Si "X" es mayor al largo de la pantalla, no hagas nada y regresa.
		return;

	if(ks0108Coord.x < 64) 
	{										// "X"< 64, se requiere colocar el punto en la 1° mitad de la pantalla.					
		LCD_CMD_PORT &= ~(0x01 << CSEL2);	// por lo tanto selecciona chip1 (1° mitad del LCD).
		LCD_CMD_PORT |= 0x01 << CSEL1;				
	} 
	else if(ks0108Coord.x >= 64) 		// "X"> 64, se requiere colocar el punto en la 1° mitad de la pantalla.
	{
		LCD_CMD_PORT &= ~(0x01 << CSEL1);			
		LCD_CMD_PORT |= 0x01 << CSEL2;		// por lo tanto selecciona chip2 (2° mitad del LCD).
	}
	if(ks0108Coord.x == 64)	// Para "X"= 64, llama a la función para mandar comando y situarse en la columna "0" 
		ks0108WriteCommand(LCD_SET_ADD, CHIP2); // de la segunda mitad de la LCD.
	
	LCD_CMD_PORT |= 0x01 << D_I;			// comando de datos. D/I = 1
	LCD_CMD_PORT &= ~(0x01 << R_W);		// comando de escritura. R/W = 0
	LCD_DATA_DIR = 0xFF;					// direccionamiento del puerto de datos, ahora como salida.
	
	yOffset = ks0108Coord.y%8;		// respalda la coordenada "Y" y saber en que grupo de renglón esta.
	
	if(yOffset != 0) 		
	{
		/********** Rutina para la 1° mitad de la pantalla. Página 1.***********/
		
		cmdPort = LCD_CMD_PORT;				// Salva el estado del puerto de comandos
		displayData = ks0108ReadData();		// Llama a la función de lectura de dato, para saber su estado.
		
		LCD_CMD_PORT = cmdPort;				// Restaura el valor del puerto de comando.
		LCD_DATA_DIR = 0xFF;				// y el puerto de datos.
		
		displayData |= data << yOffset;		// Enmascara el dato a escribir con el estado de la coordenada, para 
											// establecer el valor real que se va a escribir. 
		
		
		if(ks0108Inverted) //Condición para cuando se trabaja con modo invertido.
			displayData = ~displayData;
		LCD_DATA_OUT = displayData;					// Escribe dato.
		ks0108Enable();								// Habilita Enable.
		
		/********** Rutina para la 2° mitad de la pantalla. Página 2.***********/
		
		ks0108GotoXY(ks0108Coord.x, ks0108Coord.y+8); //Se posiciona en la coordenada que se desea escribir.
		
		displayData = ks0108ReadData();		//Se lee el estado de la coordenada.
		
		LCD_CMD_PORT = cmdPort;						// Se reStaura el puerto de comando.
		LCD_DATA_DIR = 0xFF;						// Se configura el puerto de datos como salida.
		
		displayData |= data >> (8-yOffset);	// Enmascara el dato a escribir con el estado de la coordenada, para 
											   // establecer el valor real que se va a escribir. 		
		
		if(ks0108Inverted)
			displayData = ~displayData;
		LCD_DATA_OUT = displayData;					// Escribe Dato.
		ks0108Enable();								// habilita enable.
		
		ks0108GotoXY(ks0108Coord.x+1, ks0108Coord.y-8);	// Ve a la siguiente coordenada.
	} else {						//Rutina para cuando se trabaja en modo invertido.
		if(ks0108Inverted)
			data = ~data;
		LCD_DATA_OUT = data;						// Escribe dato.
		ks0108Enable();								// Habilita Pantalla.
		ks0108Coord.x++;
	}
	LCD_DATA_OUT = 0x00;				// Redirecciona puerto de datos.
}


void write_BMP(void){}
