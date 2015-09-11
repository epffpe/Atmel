/*
 *                                
 * Descripción:    Librería Grafica para KS0108 y compatibles basada en LCD's.
 * 
 */

#include <inttypes.h>
#include <avr/pgmspace.h>

#ifndef	KS0108_H
#define KS0108_H

// Puertos.- Definicion de "sobrenombres" para los puertos ocupados para el manejo del LCD.

#define LCD_CMD_PORT		PORTB//PORTC 		// Registro de salida de comando.
#define LCD_CMD_DIR			DDRB//DDRC  		// Registro de dirección de datos para el registro de comandos.

#define LCD_DATA_IN			PIND   //PINB		// Registro de entrada de datos.
#define LCD_DATA_OUT		PORTD  //PORTB		// Resgistro de salida de datos.
#define LCD_DATA_DIR		DDRD   //DDRB 		// Registro de dirección para el puerto de datos.

// Defnición de los bits del puertro de comandos.

#define D_I					0x00		// D/I comando datos/instrucción.
#define R_W					0x01		// R/W comando lectura/escritura.
#define EN					0x02		// EN  bit Enable
#define CSEL1				0x03		// CS1 Bit de selección del Chip IC1.
#define CSEL2				0x04		// CS2 Bit de selción del chip IC2.

// Chips
#define CHIP1				0x00
#define CHIP2				0x01

// Definición de los codigos de intrucción de la LCD.

#define LCD_ON				0x3F // Código para encender LCD.
#define LCD_OFF				0x3E // Código para apagar LCD.
#define LCD_SET_ADD			0x40 // Código para posicionarse en la primera localidad (X0) de la LCD.
#define LCD_SET_PAGE		0xB8 // Código para situarse en la página 0 de la LCD.
#define LCD_DISP_START		0xC0 // Código que especifica la línea que será la superior en la pantalla. En este caso es línea 0.

// Configuración de Colores de la LCD.

#define BLACK				0xFF
#define WHITE				0x00

// Índice de Fuentes.
 
#define FONT_LENGTH			0 // Largo.
#define FONT_FIXED_WIDTH	2 // Ajuste de anchura.
#define FONT_HEIGHT			3 // Altura.
#define FONT_FIRST_CHAR		4 // Primer carácter.
#define FONT_CHAR_COUNT		5 // Contador de carácter.
#define FONT_WIDTH_TABLE	6 // Tabla de ancho de fuente.


/*******La palabra reservada typedef se utiliza para asignar un alias (otro nombre) a un tipo. 
No crea ningún nuevo tipo, solo define un nuevo identificador para un tipo que ya tiene su propio identificador
(el identificador puede ser un nombre o una expresión compleja que contiene al nombre).***********/

typedef struct { 	uint8_t x;	uint8_t y;	uint8_t page;} lcdCoord; //Define la Estructura dentro de los paréntesis
//como la palabra lcdCoord. Esta estructura se define la página y la localidad.  

typedef uint8_t (*ks0108FontCallback)(const uint8_t*);


// PROTOTIPO DE FUNCIONES.

// Funciones Gráficas.

void ks0108DrawLine(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2, uint8_t color); // Fución para dibujar una línea.
void ks0108DrawRect(uint8_t x, uint8_t y, uint8_t width, uint8_t height, uint8_t color); // Fución para dibujar un rectángulo.
void ks0108DrawRoundRect(uint8_t x, uint8_t y, uint8_t width, uint8_t height, uint8_t radius, uint8_t color); // Fución para dibujar un rectángulo redondeado. 
void ks0108FillRect(uint8_t x, uint8_t y, uint8_t width, uint8_t height, uint8_t color); // Fución para dibujar un rectángulo sombreado.
void ks0108InvertRect(uint8_t x, uint8_t y, uint8_t width, uint8_t height);// Fución para invertir un rectángulo dibujado.
void ks0108SetInverted(uint8_t invert); 
void ks0108SetDot(uint8_t x, uint8_t y, uint8_t color);// Fución para colocar un punto.

#define ks0108DrawVertLine(x, y, length, color) {ks0108FillRect(x, y, 0, length, color);} // Define la función para dibujar una línea vertical apartir de la función de un Rectángulo sombreado. 
#define ks0108DrawHoriLine(x, y, length, color) {ks0108FillRect(x, y, length, 0, color);} // Define la función para dibujar una línea horizontal apartir de la función de un Rectángulo sombreado.
#define ks0108DrawCircle(xCenter, yCenter, radius, color) {ks0108DrawRoundRect(xCenter-radius, yCenter-radius, 2*radius, 2*radius, radius, color);} // Define la función para dibujar un círculo apartir de la función de un Rectángulo redondeado.
#define ks0108ClearScreen() {ks0108FillRect(0, 0, 127, 63, WHITE);} // Define la función para limpiar la pantalla, posicionándose en la primera cordenada (x=0, y=0) y formando un rectángulo a todo lo ancho y largo de la pantalla.

// Funciones para la fuente de caracteres.

uint8_t ks0108ReadFontData(const uint8_t* ptr);		//Servicio repetitivo de lectura estandard.
void ks0108SelectFont(const char* font, ks0108FontCallback callback, uint8_t color);// Selección de fuente y color.
int ks0108PutChar(char c);//Colocación de un caracter.
void ks0108Puts(char* str);//impresión de una cadena.
void ks0108Puts_P(PGM_P str);
uint8_t ks0108CharWidth(char c);//Determinación del ancho del caracter.
uint16_t ks0108StringWidth(char* str);//Asiganción de el tamaño de una cadena de caracteres.
uint16_t ks0108StringWidth_P(PGM_P str);

// Control Functions
void ks0108GotoXY(uint8_t x, uint8_t y); //Posiciona el cursor en la cordenada dada por (x,y).
void ks0108Init(uint8_t invert);
inline uint8_t ks0108ReadData(void); // Función para leer dato de la LCD.
void ks0108WriteCommand(uint8_t cmd, uint8_t chip); // Prototipo para determinar comando y chip a activar en la LCD.
void ks0108WriteData(uint8_t data); // Función para escribir un dato en la LCD.

#endif
