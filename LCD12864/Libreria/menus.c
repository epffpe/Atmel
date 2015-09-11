
#include "menus.h"
#define Menu1_1  "1  -Informacion"
#define Menu1_2  "2-Voltmetro"
#define Menu1_3  "3-Espectro"
#define Menu1_4	 "4-Osciloscopio"
#define Menu1_5  "5- -----"
#define Menu1_6  "6- -----"
#define Menu1_7  "7- RS-232"
#define Menu1_8  "8- "

void main_menu(void){
  
        ks0108ClearScreen();
       
        ks0108SelectFont(Arial8, ks0108ReadFontData, BLACK);
       
        
        ks0108GotoXY(8,18);
	    ks0108Puts(Menu1_1);
		ks0108GotoXY(8,28);
	    ks0108Puts(Menu1_2);
        ks0108GotoXY(8,38);
	    ks0108Puts(Menu1_3);
		ks0108GotoXY(8,48);
	    ks0108Puts(Menu1_4);
        
		ks0108GotoXY(71,18);
	    ks0108Puts(Menu1_5);
        ks0108GotoXY(71,28);
	    ks0108Puts(Menu1_6);
		ks0108GotoXY(71,38);
	    ks0108Puts(Menu1_7);
        ks0108GotoXY(71,48);
	    ks0108Puts(Menu1_8);
 
        ks0108DrawRect(0,0,127,62,BLACK);
        ks0108DrawRoundRect(2, 11, 123, 49, 8, BLACK);
        ks0108GotoXY(40,2);
	    ks0108Puts("**MENU**");
        old_menu=0;
       
}




/*********************************************************************
 *    Rutina que borra la selección anterior
 *
 *********************************************************************/ 
   
void deselect_menu(void){
        switch (old_menu){    
                case 1:
                case 2:
                case 3:
                case 4:
                   ks0108InvertRect(7,(17+((old_menu-1)*10)),61,8);
			
                break;
                
                case 5:
                case 6:
                case 7:
                case 8:         
                   ks0108InvertRect(70,(17+((old_menu-5)*10)),51,8);
				
                break;
                
        }      
}
   
   
/*********************************************************************
 *    Rutina que hace una selección del menú actual
 *
 *********************************************************************/ 
   
void select_menu(unsigned char select){

        deselect_menu();          

       switch (select){    
                case 1:
                case 2:
                case 3:
                case 4:
                   ks0108InvertRect(7,(17+((select-1)*10)),61,8);
				old_menu = select;
                break;
                
                case 5:
                case 6:
                case 7:
                case 8:         
                   ks0108InvertRect(70,(17+((select-5)*10)),51,8);
				old_menu = select;
                break;
                
        }      
        
}


