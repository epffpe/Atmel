
.EQU LCD_RS =  0    ;define MCU pin connected to LCD RS
.EQU LCD_RW =  1    ;define MCU pin connected to LCD R/W
.EQU LCD_E=  2   ;define MCU pin connected to LCD E
.EQU LCD_D0=   0   ;define MCU pin connected to LCD D0
.EQU LCD_D1=   1   ;define MCU pin connected to LCD D1
.EQU LCD_D2=   2   ;define MCU pin connected to LCD D1
.EQU LCD_D3=   3   ;define MCU pin connected to LCD D2
.EQU LCD_D4=   4   ;define MCU pin connected to LCD D3
.EQU LCD_D5=   5   ;define MCU pin connected to LCD D4
.EQU LCD_D6=   6   ;define MCU pin connected to LCD D5
.EQU LCD_D7=   7   ;define MCU pin connected to LCD D6
;.EQU LDP= PORTD   ;define MCU port connected to LCD data pins
.EQU LCD_DB=PORTD
;.EQU LCP= PORTB   ;define MCU port connected to LCD control pins
.EQU LCD_CB=PORTB
.EQU LDDR= DDRD   ;define MCU direction register for port connected to LCD data pins
.EQU LCDR= DDRB   ;define MCU direction register for port connected to LCD control pins

.EQU LCD_CLR  =           0   ;DB0: clear display
.EQU LCD_HOME  =          1   ;DB1: return to home position
.EQU LCD_ENTRY_MODE =     2   ;DB2: set entry mode
.EQU LCD_ENTRY_INC  =     1   ;DB1: increment
.EQU LCD_ENTRY_SHIFT=     0   ;DB2: shift
.EQU LCD_ON_CTRL=         3   ;DB3: turn lcd/cursor on
.EQU LCD_ON_DISPLAY =     2   ;DB2: turn display on
.EQU LCD_ON_CURSOR =      1   ;DB1: turn cursor on
.EQU LCD_ON_BLINK =       0   ;DB0: blinking cursor
.EQU LCD_MOVE   =         4   ;DB4: move cursor/display
.EQU LCD_MOVE_DISP   =    3   ;DB3: move display (0-> move cursor)
.EQU LCD_MOVE_RIGHT =     2   ;DB2: move right (0-> left)
.EQU LCD_FUNCTION   =     5   ;DB5: function set
.EQU LCD_FUNCTION_8BIT  = 4   ;DB4: set 8BIT mode (0->4BIT mode)
.EQU LCD_FUNCTION_2LINES =3   ;DB3: two lines (0->one line)
.EQU LCD_FUNCTION_10DOTS =2   ;DB2: 5x10 font (0->5x7 font)
.EQU LCD_CGRAM          = 6   ;DB6: set CG RAM address
.EQU LCD_DDRAM=			  7

; reading:
.EQU LCD_BUSY=            7   ;DB7: LCD is busy
.EQU LCD_LINES  =       2   ;visible lines
.EQU LCD_LINE_LENGTH  =    16   ;line length (in characters)
; cursor position to DDRAM mapping
.EQU LCD_LINE0_DDRAMADDR =     0x00
.EQU LCD_LINE1_DDRAMADDR =     0x40
.EQU LCD_LINE2_DDRAMADDR =     0x14
.EQU LCD_LINE3_DDRAMADDR =     0x54
; progress bar defines
.EQU PROGRESSPIXELS_PER_CHAR =  6
