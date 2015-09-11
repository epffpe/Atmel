/*

wangguanfu
2009-08-06

*/


#include"english_16x8.h"
#include "lcd.h"
#include "Font_24x16.h"
//#include <util/delay.h>
#include "delay.h"


/*------------------------- Speed dependant settings -------------------------*/

/* If processor works on high frequency delay has to be increased, it can be 
   increased by factor 2^N by this constant                                   */
#define DELAY_2N    4

/*---------------------- Graphic LCD size definitions ------------------------*/

#define WIDTH       320                 /* Screen Width (en pixels)           */
#define HEIGHT      240                 /* Screen Hight (en pixels)           */
#define BPP         16                  /* Bits per pixel                     */
#define BYPP        ((BPP+7)/8)         /* Bytes per pixel                    */

/*--------------- Graphic LCD interface hardware definitions -----------------*/

/* Pin ENABLE 0 o 1  MIRAR                                                      */
#define LCD_EN(x)   ((x) ? (LCD_BL_PORT |= 1<<LCD_BL_BIT) : (LCD_BL_PORT &= ~(1<<LCD_BL_BIT)));
/* Pin CS  0 o 1                                                   */
#define LCD_CS(x)   ((x) ? (LCD_CS_PORT |= 1<<LCD_CS_BIT) : (LCD_CS_PORT &= ~(1<<LCD_CS_BIT)));
/* Pin RS  0 o 1                                                   */
#define LCD_RS(x)   ((x) ? (LCD_RS_PORT |= 1<<LCD_RS_BIT) : (LCD_RS_PORT &= ~(1<<LCD_RS_BIT)));
/* Pin WR  0 o 1                                                   */
#define LCD_WR(x)   ((x) ? (LCD_WR_PORT |= 1<<LCD_WR_BIT) : (LCD_WR_PORT &= ~(1<<LCD_WR_BIT)));
/* Pin RD  0 o 1                                                   */
#define LCD_RD(x)   ((x) ? (LCD_RD_PORT |= 1<<LCD_RD_BIT) : (LCD_RD_PORT &= ~(1<<LCD_RD_BIT)));


void LCD_WR_DATA16(unsigned int data)//写积存器数据
{
     LCD_RD_H();
	 LCD_RS_H();
     LCD_CS_L();  
     LCD_WR_L();
	 
     DATA_LCD_PORT=data>>8;
     delay_us(1);
     LCD_WR_H();
     LCD_WR_L();
	 delay_us(1);
     DATA_LCD_PORT=data&0XFF; 
	 delay_us(1);
     LCD_WR_H();
     LCD_CS_H();
  
}
void LCD_WR_REG16(unsigned int index)//写积存器命令
{
     LCD_RD_H();
	 LCD_RS_L();
     LCD_CS_L();  
     LCD_WR_L();
	 delay_us(1);
     DATA_LCD_PORT=index>>8; 
	 delay_us(1);
     LCD_WR_H();
     LCD_WR_L();
	 delay_us(1);
     DATA_LCD_PORT=index&0XFF; 
	 delay_us(1);
     LCD_WR_H();
     LCD_CS_H();
}

void LCD_WR_REG(unsigned int index,unsigned int data)
{
     LCD_WR_REG16(index);
     LCD_WR_DATA16(data);
}


void LCD_Init(void)
{
	     LCD_PORT_INI();
	     LCD_RST_L();//硬件复位
	     delay_ms(100);
	     LCD_RST_H();
	     delay_ms(100); 
	//initializing funciton 1 
		 LCD_WR_REG(0x00E3,0x3008);        
	     LCD_WR_REG(0x00E7,0x0012);
	     LCD_WR_REG(0x00Ef,0x1231); 	// Set the internal timing;    
         LCD_WR_REG(0x00,0x0001);
         LCD_WR_REG(0x01, 0x0000); // set SS and SM bit
         LCD_WR_REG(0x02, 0x0700); // set 1 line inversion
        // LCD_WR_REG(0x03, 0x10B0); // set GRAM write direction and BGR=1.
#if   ID_AM==000       
	     LCD_WR_REG(0x0003,0x1000);//屏幕旋转控制 TFM=0,TRI=0,SWAP=1,16 bits system interface  swap RGB to BRG，此处ORG和HWM 为0
#elif ID_AM==001        
	     LCD_WR_REG(0x0003,0x1008);      
#elif ID_AM==010  
	     LCD_WR_REG(0x0003,0x1010);        
#elif ID_AM==011
	     LCD_WR_REG(0x0003,0x1018);
#elif ID_AM==100  
	     LCD_WR_REG(0x0003,0x1020);      
#elif ID_AM==101  
	     LCD_WR_REG(0x0003,0x1028);      
#elif ID_AM==110  
	     LCD_WR_REG(0x0003,0x1030);      
#elif ID_AM==111  
	     LCD_WR_REG(0x0003,0x1038);
#endif    
        LCD_WR_REG(0x04, 0x0000); // Resize register
         LCD_WR_REG(0x08, 0x0404); // set the back porch and front porch
         LCD_WR_REG(0x09, 0x0000); // set non-display area refresh cycle ISC[3:0]
         LCD_WR_REG(0x0A, 0x0000); // FMARK function
        // LCD_WR_REG(0x0C, 0x0000); // RGB interface setting
        // LCD_WR_REG(0x0D, 0x0000); // Frame marker Position
        // LCD_WR_REG(0x0F, 0x0000); // RGB interface polarity
//Power On sequence //
         LCD_WR_REG(0x10, 0x0080); // SAP, BT[3:0], AP, DSTB, SLP, STB
         LCD_WR_REG(0x11, 0x0007); // DC1[2:0], DC0[2:0], VC[2:0]
         LCD_WR_REG(0x12, 0x0000); // VREG1OUT voltage
         LCD_WR_REG(0x13, 0x0000); // VDV[4:0] for VCOM amplitude
	 LCD_WR_REG(0x07, 0x0001); // 
		 
         delay_ms(2000); // Dis-charge capacitor power voltage
         
         LCD_WR_REG(0x10, 0x1590); // SAP, BT[3:0], AP, DSTB, SLP, STB
         LCD_WR_REG(0x11, 0x0227); // DC1[2:0], DC0[2:0], VC[2:0]
         delay_ms(1000); // Delay 50ms
        
         LCD_WR_REG(0x12, 0x001e); // Internal reference voltage= Vci;
         delay_ms(1000); // Delay 50ms
         LCD_WR_REG(0x13, 0x1500); // Set VDV[4:0] for VCOM amplitude
         LCD_WR_REG(0x29, 0x0028); // Set VCM[5:0] for VCOMH
         LCD_WR_REG(0x2B, 0x000f); // Set Frame Rate
         delay_ms(500); // Delay 50ms
         
#if   ID_AM==000         
	     LCD_WR_REG(0x0020,0x00ef);//GRAM水平起始位置
	     LCD_WR_REG(0x0021,0x013f);      
#elif ID_AM==001
	     LCD_WR_REG(0x0020,0x00ef);
	     LCD_WR_REG(0x0021,0x013f);      
#elif ID_AM==010
	     LCD_WR_REG(0x0020,0x0000);
	     LCD_WR_REG(0x0021,0x013f);      
#elif ID_AM==011
	     LCD_WR_REG(0x0020,0x0000);
	     LCD_WR_REG(0x0021,0x013f);       
#elif ID_AM==100
	     LCD_WR_REG(0x0020,0x00ef);
	     LCD_WR_REG(0x0021,0x0000);      
#elif ID_AM==101  
	     LCD_WR_REG(0x0020,0x00ef);
	     LCD_WR_REG(0x0021,0x0000);      
#elif ID_AM==110
	     LCD_WR_REG(0x0020,0x0000);
	     LCD_WR_REG(0x0021,0x0000);      
#elif ID_AM==111
	     LCD_WR_REG(0x0020,0x0000);
	     LCD_WR_REG(0x0021,0x0000);         
#endif  
// ----------- Adjust the Gamma Curve ----------//
		LCD_WR_REG(0x0030,0x0007);
		LCD_WR_REG(0x0031,0x0707);
		LCD_WR_REG(0x0032,0x0107);
		LCD_WR_REG(0x0035,0x0206);
		LCD_WR_REG(0x0036,0x0406);
		LCD_WR_REG(0x0037,0x0101);
		LCD_WR_REG(0x0038,0x0101);
		LCD_WR_REG(0x0039,0x0207);
		LCD_WR_REG(0x003C,0x0504);
		LCD_WR_REG(0x003D,0x0806);
	

		 
//------------------ Set GRAM area ---------------//
         LCD_WR_REG(0x0050, 0x0000); // Horizontal GRAM Start Address
         LCD_WR_REG(0x0051, 0x00EF); // Horizontal GRAM End Address
         LCD_WR_REG(0x0052, 0x0000); // Vertical GRAM Start Address
         LCD_WR_REG(0x0053, 0x013F); // Vertical GRAM Start Address
         LCD_WR_REG(0x0060, 0x2700); // Gate Scan Line
         LCD_WR_REG(0x0061, 0x0001); // NDL,VLE, REV
         LCD_WR_REG(0x006A, 0x0000); // set scrolling line
//-------------- Partial Display Control ---------//
         LCD_WR_REG(0x80, 0x0000);
         LCD_WR_REG(0x81, 0x0000);
         LCD_WR_REG(0x82, 0x0000);
         LCD_WR_REG(0x83, 0x0000);
         LCD_WR_REG(0x84, 0x0000);
         LCD_WR_REG(0x85, 0x0000);
//-------------- Panel Control -------------------//
         LCD_WR_REG(0x90, 0x0010);
         LCD_WR_REG(0x92, 0x0600);
         LCD_WR_REG(0x93, 0x0003);
         LCD_WR_REG(0x95, 0x0110);
         LCD_WR_REG(0x97, 0x0000);
         LCD_WR_REG(0x98, 0x0000);
		 
         LCD_WR_REG(0x07, 0x0173); // 262K color and display ON   0133
		 LCD_Clear(0);
		 delay_ms(2000); // Delay 5ms
		 
		 LCD_BL_H();
  
}


/**********************************************
函数名：Lcd全屏擦除函数
功能：将Lcd整屏擦为指定颜色
入口参数：color 指定Lcd全屏颜色 RGB(5-6-5)
返回值：无
***********************************************/
void LCD_Clear(unsigned int Color)
{
  unsigned long index = 0;
  
  LCD_WR_REG(0x0020,0x0000);//GRAM水平起始位置
  LCD_WR_REG(0x0021,00000);      

  LCD_WR_REG(0x0050,0x00);//水平 GRAM起始位置
  LCD_WR_REG(0x0051,239);//水平GRAM终止位置
  LCD_WR_REG(0x0052,0x00);//垂直GRAM起始位置
  LCD_WR_REG(0x0053,319);//垂直GRAM终止位置 
  LCD_WR_REG16(0x0022);
  
  LCD_RD_H();
  LCD_RS_H();
  LCD_CS_L();   
  for(index = 0; index < 76800; index++)
  {
   // LCD_WR_DATA16(Color);
 
     LCD_WR_L();
     DATA_LCD_PORT=Color>>8; 
     LCD_WR_H();
     LCD_WR_L();
     DATA_LCD_PORT=Color&0XFF; 
     LCD_WR_H();
 
   
  } 
   LCD_CS_H();
}

void LCD_write_english(unsigned char data,unsigned int color,unsigned int xcolor)//写字符
{

  unsigned char avl,i,n;
   LCD_WR_REG16(0x0022);  
  for (i=0;i<16;i++)
  { 
      avl=pgm_read_byte( &english[data-32][i]);
	  for (n=0;n<8;n++)
	   {
	     if(avl&0x80) LCD_WR_DATA16(color);
             else LCD_WR_DATA16(xcolor);
           
	     avl<<=1;
	   }
	}
}
void LCD_write_english_string(unsigned int x,unsigned int y,unsigned char *s,unsigned int color,unsigned int xcolor)//英文字符串显示
{
 unsigned int k=0;
 while (*s) 
  {
     Lcd_SetBox(y,x+k,15,8);
     LCD_write_english( *s,color,xcolor);
     k=k+8;
     s++;
  
  }

}  

void LCD_write_SUM(unsigned int x,unsigned int y,unsigned char SUM,unsigned int color,unsigned int xcolor)//写数字
{

  unsigned char avl,i,n;
   Lcd_SetBox(y,x,15,8);
   LCD_WR_REG16(0x0022);  
  for (i=0;i<16;i++)
  { 
      avl=pgm_read_byte( &english[SUM+16][i]);
	  for (n=0;n<8;n++)
	   {
	     if(avl&0x80) LCD_WR_DATA16(color);
             else LCD_WR_DATA16(xcolor);
           
	     avl<<=1;
	   }
	}
}
/**********************************************
函数名：Lcd块选函数
功能：选定Lcd上指定的矩形区域

注意：xStart和 yStart随着屏幕的旋转而改变，位置是矩形框的四个角

入口参数：xStart x方向的起始点
          ySrart y方向的终止点
          xLong 要选定矩形的x方向长度
          yLong  要选定矩形的y方向长度
返回值：无
***********************************************/
void Lcd_SetBox(unsigned int xStart,unsigned int yStart,unsigned int xLong,unsigned int yLong)
{
  
#if ID_AM==000    
	LCD_SetCursor(xStart+xLong-1,312-yStart+yLong-1);

#elif ID_AM==001
	LCD_SetCursor(xStart+xLong-1,312-yStart+yLong-1);
     
#elif ID_AM==010
	LCD_SetCursor(xStart,312-yStart+yLong-1);
     
#elif ID_AM==011 
	LCD_SetCursor(xStart,312-yStart+yLong-1);
     
#elif ID_AM==100
	LCD_SetCursor(xStart+xLong-1,312-yStart);     
     
#elif ID_AM==101
	LCD_SetCursor(xStart+xLong-1,312-yStart);     
     
#elif ID_AM==110
	LCD_SetCursor(xStart,312-yStart); 
     
#elif ID_AM==111
	LCD_SetCursor(xStart,312-yStart);  
     
#endif
     
	LCD_WR_REG(0x0050,xStart);//水平 GRAM起始位置
	LCD_WR_REG(0x0051,xStart+xLong-1);//水平GRAM终止位置
	LCD_WR_REG(0x0052,312-yStart);//垂直GRAM起始位置
	LCD_WR_REG(0x0053,312-yStart+yLong-1);//垂直GRAM终止位置 
}


/*************************************************
函数名：Lcd光标起点定位函数
功能：指定320240液晶上的一点作为写数据的起始点
入口参数：x 坐标 0~239
          y 坐标 0~319
返回值：无
*************************************************/
void LCD_SetCursor(unsigned int Xpos, unsigned int Ypos)
{
 // CLR_RS;
  LCD_WR_REG(0x20, Xpos);
  LCD_WR_REG(0x21, Ypos);
}

/*
void Test_tu(void)
{
   unsigned int i;
  // unsigned char  val;
  LCD_WR_REG(0x0020,20);//Lcd光标GRAM水平起始位置
  LCD_WR_REG(0x0021,105); //Lcd光标垂直GRAM起始位置     

  LCD_WR_REG(0x0050,20);//水平 GRAM起始位置
  LCD_WR_REG(0x0051,207);//水平GRAM终止位置
  LCD_WR_REG(0x0052,105);//垂直GRAM起始位置
  LCD_WR_REG(0x0053,207);//垂直GRAM终止位置 
  LCD_WR_REG16(0x0022);
    	
   LCD_RD_H();
   LCD_RS_H();
   LCD_CS_L(); 
  for (i=0;i<21218;)
  { 

     LCD_WR_L();
	 //LCD_WR_L();
     DATA_LCD_PORT=pgm_read_byte(&gImage[i++]);
     LCD_WR_H();

     LCD_WR_L();
	 //LCD_WR_L();
     DATA_LCD_PORT=pgm_read_byte(&gImage[i++]);
     LCD_WR_H(); 

	}
   LCD_CS_H();
}

*/

 void  GUI_Point(unsigned int x, unsigned int y,unsigned int color) 
 {
     LCD_WR_REG(0x0020,x);//Lcd光标GRAM水平起始位置
     LCD_WR_REG(0x0021,y); //Lcd光标垂直GRAM起始位置     

   //  LCD_WR_REG(0x0050,x);//水平 GRAM起始位置
   //  LCD_WR_REG(0x0051,x);//水平GRAM终止位置
   //  LCD_WR_REG(0x0052,y);//垂直GRAM起始位置
   //  LCD_WR_REG(0x0053,y);//垂直GRAM终止位置 
	 LCD_WR_REG16(0x0022); 
	 LCD_WR_DATA16(color);   
	 
	 
 
 }

void Test(void)
{       
        unsigned long n,i;
       LCD_WR_REG(0x0020,0x0000);//GRAM水平起始位置
       LCD_WR_REG(0x0021,0x0000); 
        for(i=0;i<7;i++)
          
        {       
        
            
	        LCD_WR_REG(0x0050,0x00);//水平 GRAM起始位置
	        LCD_WR_REG(0x0051,239);//水平GRAM终止位置
	        LCD_WR_REG(0x0052,0x00);//垂直GRAM起始位置
	        LCD_WR_REG(0x0053,319);//垂直GRAM终止位置 
           
            LCD_WR_REG16(0x0022);       
                for(n=0;n<76800;n++)
                { 
                  
                  
                  if(i==0)LCD_WR_DATA16(BLUE);   
                  if(i==1)LCD_WR_DATA16(RED); 
                  if(i==2)LCD_WR_DATA16(GREEN);
                  if(i==3)LCD_WR_DATA16(CYAN); 
                  if(i==4)LCD_WR_DATA16(MAGENTA); 
                  if(i==5)LCD_WR_DATA16(YELLOW);
				  
                  if(i==6)LCD_WR_DATA16(BLACK); 
                }    
                 delay_ms(100);                   
        }       
}

/**********************************************/



/*---------------------------- Variables Locales -----------------------------*/

/******************************************************************************/
static volatile unsigned short TextColor = Black, BackColor = White;


/************************ Funciones auxiliares locales ************************/

/*******************************************************************************
* Delay in while loop cycles                                                   *
*   Parametros:    cnt:    numero de ciclos de retardo                         *
*   Return:                                                                    *
*******************************************************************************/

static void delay (unsigned int cnt) {

  cnt <<= DELAY_2N;
  while (cnt--);
}


void wait()
{
    return;
}



void wait_delay(unsigned int count)
{
  while(count--);
}


/*******************************************************************************
* Enviar 1 byte, funcion de bajo nivel                                         *
*   Parametro:    byte:   byte a enviar                                        *
*   Return:                                                                    *
*******************************************************************************/

static inline unsigned char lcd_send (unsigned short byte) {
	DATA_LCD_DDR = 0xFF;
	DATA_LCD_PORT = byte >> 8;
	LCD_WR(0)
	LCD_WR(1)
	DATA_LCD_PORT = byte & 0xFF;
	LCD_WR(0)
	LCD_WR(1)
	return(1);
}


/*******************************************************************************
* Recibir 1 byte, funcion de bajo nivel                                        *
*   Parametro:                                                                 *
*   Return:     id: Dato de 16bits que se lee                                   *
*******************************************************************************/

static inline unsigned short lcd_read (void) {
  unsigned short id;
	DATA_LCD_DDR = 0x00;
	LCD_RD(0)
	id=DATA_LCD_PIN &0x00FF;
	LCD_RD(1)
	LCD_RD(0)
	id=(id << 8) | (DATA_LCD_PIN &0x00FF);
	LCD_RD(1)
  	return(id); 
}

/*******************************************************************************
* Escribir un comando al controlador LCD                                       *
*   Parametro:    c:      comando a enviar                                     *
*   Return:                                                                    *
*******************************************************************************/

static inline void wr_cmd (unsigned char c) {

  LCD_RS(0)
  LCD_RD(1)
  lcd_send(c);
}


/*******************************************************************************
* Write data to LCD controller                                                 *
*   Parameter:    c:      data to be written                                   *
*   Return:                                                                    *
*******************************************************************************/

static inline void wr_dat (unsigned short c) {

  LCD_RS(1)
  LCD_RD(1)
  lcd_send(c);
}

/*******************************************************************************
* Read data from LCD controller                                                *
*   Parameter:                                                                 *
*   Return:               read data                                            *
*******************************************************************************/

static inline unsigned short rd_dat (void) {
  unsigned short val = 0;

  LCD_RS(1)
  LCD_WR(1)
  //LCD_RD(0);
  val = lcd_read();
  //LCD_RD(1);
  return val;
}

/*******************************************************************************
* Start of data writing to LCD controller                                      *
*   Parameter:                                                                 *
*   Return:                                                                    *
*******************************************************************************/

static inline void wr_dat_start (void) {

  LCD_RS(1)
}


/*******************************************************************************
* Stop of data writing to LCD controller                                       *
*   Parameter:                                                                 *
*   Return:                                                                    *
*******************************************************************************/

static inline void wr_dat_stop (void) {

  LCD_CS(1)
}


/*******************************************************************************
* Data writing to LCD controller                                               *
*   Parameter:    c:      data to be written                                   *
*   Return:                                                                    *
*******************************************************************************/

static inline void wr_dat_only (unsigned short c) {

  lcd_send(c);
  //LCD_WR(0);
  //wait();
  //LCD_WR(1);
}

/*******************************************************************************
* Write to LCD register                                                        *
*   Parameter:    reg:    register to be read                                  *
*                 val:    value to write to register                           *
*******************************************************************************/

static inline void wr_reg (unsigned char reg, unsigned short val) {

  LCD_CS(0)
  wr_cmd(reg);
  wr_dat(val);
  LCD_CS(1)
}


/*******************************************************************************
* Read from LCD register                                                       *
*   Parameter:    reg:    register to be read                                  *
*   Return:               value read from register                             *
*******************************************************************************/

static unsigned short rd_reg (unsigned short reg) {
  unsigned short val = 0;

  LCD_CS(0)
  wr_cmd(reg);
  val = rd_dat(); 
  LCD_CS(1)
  return (val);
}


/************************ Exported functions **********************************/

/*******************************************************************************
* Initialize the Graphic LCD controller                                        *
*   Parameter:                                                                 *
*   Return:                                                                    *
*******************************************************************************/

void GLCD_Init (void) { 
  static unsigned short driverCode;

  /* Configure the LCD Control pins                                           */
  //LPC_GPIO0->FIODIR   |= 0x03f80000;
  ///LPC_GPIO0->FIOSET    = 0x03f80000;	
	DDRD&=~(0x20);
	PORTD|=0xFF;
	//LCD_OUPUT();

  delay(5);                             /* Delay 50 ms                        */

  driverCode = rd_reg(0x00);

  if(driverCode == 0x4531)				//2.8" TFT LCD Module,DriverIC is LGDP4531
  {
  	wr_reg(0x00,0x0001);
  	wr_reg(0x10,0x0628);
  	wr_reg(0x12,0x0006);
  	wr_reg(0x13,0x0A32);
  	wr_reg(0x11,0x0040);
  	wr_reg(0x15,0x0050);
  	wr_reg(0x12,0x0016);
  	delay(15);
  	wr_reg(0x10,0x5660);
  	delay(15);
  	wr_reg(0x13,0x2A4E);
  	wr_reg(0x01,0x0100);
  	wr_reg(0x02,0x0300);
	
  	wr_reg(0x03,0x1030);
	
  	wr_reg(0x08,0x0202);
  	wr_reg(0x0A,0x0000);
  	wr_reg(0x30,0x0000);
  	wr_reg(0x31,0x0402);
  	wr_reg(0x32,0x0106);
  	wr_reg(0x33,0x0700);
  	wr_reg(0x34,0x0104);
  	wr_reg(0x35,0x0301);
  	wr_reg(0x36,0x0707);
  	wr_reg(0x37,0x0305);
  	wr_reg(0x38,0x0208);
  	wr_reg(0x39,0x0F0B);
  	delay(15);
  	wr_reg(0x41,0x0002);
  	wr_reg(0x60,0x2700);
  	wr_reg(0x61,0x0001);
  	wr_reg(0x90,0x0119);
  	wr_reg(0x92,0x010A);
  	wr_reg(0x93,0x0004);
  	wr_reg(0xA0,0x0100);
  	delay(15);
  	wr_reg(0xA0,0x0000);
  	delay(20);
  }
  else if(driverCode == 0x9320)		 //3.2" TFT LCD Module,DriverIC is ILI9320
  {
    /* Start Initial Sequence --------------------------------------------------*/
	wr_reg(0xE5, 0x8000);                 /* Set the internal vcore voltage     */
	wr_reg(0x00, 0x0001);                 /* Start internal OSC                 */
	wr_reg(0x01, 0x0100);                 /* Set SS and SM bit                  */
	wr_reg(0x02, 0x0700);                 /* Set 1 line inversion               */
	wr_reg(0x03, 0x1030);                 /* Set GRAM write direction and BGR=1 */
	wr_reg(0x04, 0x0000);                 /* Resize register                    */
	wr_reg(0x08, 0x0202);                 /* 2 lines each, back and front porch */
	wr_reg(0x09, 0x0000);                 /* Set non-disp area refresh cyc ISC  */
	wr_reg(0x0A, 0x0000);                 /* FMARK function                     */
	wr_reg(0x0C, 0x0000);                 /* RGB interface setting              */
	wr_reg(0x0D, 0x0000);                 /* Frame marker Position              */
	wr_reg(0x0F, 0x0000);                 /* RGB interface polarity             */
	
	/* Power On sequence -------------------------------------------------------*/
	wr_reg(0x10, 0x0000);                 /* Reset Power Control 1              */
	wr_reg(0x11, 0x0000);                 /* Reset Power Control 2              */
	wr_reg(0x12, 0x0000);                 /* Reset Power Control 3              */
	wr_reg(0x13, 0x0000);                 /* Reset Power Control 4              */
	delay(20);                            /* Discharge cap power voltage (200ms)*/
    wr_reg(0x10, 0x17B0);                 /* SAP, BT[3:0], AP, DSTB, SLP, STB   */
	wr_reg(0x11, 0x0137);                 /* DC1[2:0], DC0[2:0], VC[2:0]        */
	delay(5);                             /* Delay 50 ms                        */
	wr_reg(0x12, 0x0139);                 /* VREG1OUT voltage                   */
	delay(5);                             /* Delay 50 ms                        */
	wr_reg(0x13, 0x1D00);                 /* VDV[4:0] for VCOM amplitude        */
	wr_reg(0x29, 0x0013);                 /* VCM[4:0] for VCOMH                 */
	delay(5);                             /* Delay 50 ms                        */
	wr_reg(0x20, 0x0000);                 /* GRAM horizontal Address            */
	wr_reg(0x21, 0x0000);                 /* GRAM Vertical Address              */
	
	/* Adjust the Gamma Curve --------------------------------------------------*/
	wr_reg(0x30, 0x0006);
	wr_reg(0x31, 0x0101);
	wr_reg(0x32, 0x0003);
	wr_reg(0x35, 0x0106);
	wr_reg(0x36, 0x0B02);
	wr_reg(0x37, 0x0302);
	wr_reg(0x38, 0x0707);
	wr_reg(0x39, 0x0007);
	wr_reg(0x3C, 0x0600);
	wr_reg(0x3D, 0x020B);
	  
	/* Set GRAM area -----------------------------------------------------------*/
	wr_reg(0x50, 0x0000);                 /* Horizontal GRAM Start Address      */
	wr_reg(0x51, (HEIGHT-1));             /* Horizontal GRAM End   Address      */
	wr_reg(0x52, 0x0000);                 /* Vertical   GRAM Start Address      */
	wr_reg(0x53, (WIDTH-1));              /* Vertical   GRAM End   Address      */
	wr_reg(0x60, 0x2700);                 /* Gate Scan Line                     */
	wr_reg(0x61, 0x0001);                 /* NDL,VLE, REV                       */
	wr_reg(0x6A, 0x0000);                 /* Set scrolling line                 */
	
	/* Partial Display Control -------------------------------------------------*/
	wr_reg(0x80, 0x0000);
	wr_reg(0x81, 0x0000);
	wr_reg(0x82, 0x0000);
	wr_reg(0x83, 0x0000);
	wr_reg(0x84, 0x0000);
	wr_reg(0x85, 0x0000);
	
	/* Panel Control -----------------------------------------------------------*/
	wr_reg(0x90, 0x0010);
	wr_reg(0x92, 0x0000);
	wr_reg(0x93, 0x0003);
	wr_reg(0x95, 0x0110);
	wr_reg(0x97, 0x0000);
	wr_reg(0x98, 0x0000);
  }
  /* Set GRAM write direction and BGR = 1
     I/D=10 (Horizontal : increment, Vertical : increment)
     AM=1 (address is updated in vertical writing direction)                  */
  wr_reg(0x03, 0x1038);

  wr_reg(0x07, 0x0173);                 /* 262K color and display ON          */ 
}


/*******************************************************************************
* Set draw window region to whole screen                                       *
*   Parameter:                                                                 *
*   Return:                                                                    *
*******************************************************************************/

void GLCD_WindowMax (void) {

  wr_reg(0x50, 0);                      /* Horizontal GRAM Start Address      */
  wr_reg(0x51, HEIGHT-1);               /* Horizontal GRAM End   Address (-1) */
  wr_reg(0x52, 0);                      /* Vertical   GRAM Start Address      */
  wr_reg(0x53, WIDTH-1);                /* Vertical   GRAM End   Address (-1) */
}


/*******************************************************************************
* Draw a pixel in foreground color                                             *
*   Parameter:      x:        horizontal position                              *
*                   y:        vertical position                                *
*   Return:                                                                    *
*******************************************************************************/

void GLCD_PutPixel (unsigned int x, unsigned int y) {

  wr_reg(0x20, y);
  wr_reg(0x21, WIDTH-1-x);
  LCD_CS(0)
  wr_cmd(0x22);
  wr_dat(TextColor);
  LCD_CS(1)
}


/*******************************************************************************
* Set foreground color                                                         *
*   Parameter:      color:    foreground color                                 *
*   Return:                                                                    *
*******************************************************************************/

void GLCD_SetTextColor (unsigned short color) {

  TextColor = color;
}


/*******************************************************************************
* Set background color                                                         *
*   Parameter:      color:    background color                                 *
*   Return:                                                                    *
*******************************************************************************/

void GLCD_SetBackColor (unsigned short color) {

  BackColor = color;
}


/*******************************************************************************
* Clear display                                                                *
*   Parameter:      color:    display clearing color                           *
*   Return:                                                                    *
*******************************************************************************/

void GLCD_Clear (unsigned short color) {
  unsigned long   i;

  GLCD_WindowMax();

  wr_reg(0x20, 0);
  wr_reg(0x21, 0);
  LCD_CS(0)
  wr_cmd(0x22);
  wr_dat_start();
  for(i = 0; i < ((unsigned long)WIDTH * (unsigned long)HEIGHT); i++)
    wr_dat_only(color);
  wr_dat_stop();
}


/*******************************************************************************
* Draw character on given position                                             *
*   Parameter:      x:        horizontal position                              *
*                   y:        vertical position                                *
*                   c:        pointer to character bitmap                      *
*   Return:                                                                    *
*******************************************************************************/

void GLCD_DrawChar (unsigned int x, unsigned int y, unsigned short *c) {
  int idx = 0, i, j;

  x = WIDTH-x-CHAR_W;
  wr_reg(0x50, y);                      /* Horizontal GRAM Start Address      */
  wr_reg(0x51, y+CHAR_H-1);             /* Horizontal GRAM End   Address (-1) */
  wr_reg(0x52, x);                      /* Vertical   GRAM Start Address      */
  wr_reg(0x53, x+CHAR_W-1);             /* Vertical   GRAM End   Address (-1) */

  wr_reg(0x20, y);
  wr_reg(0x21, x);
  LCD_CS(0)
  wr_cmd(0x22);
  wr_dat_start();
  for (j = 0; j < CHAR_H; j++) {
    for (i = CHAR_W-1; i >= 0; i--) {
      if((c[idx] & (1 << i)) == 0x00) {
        wr_dat_only(BackColor);
      } else {
        wr_dat_only(TextColor);
      }
    }
    c++;
  }
  wr_dat_stop();
}


/*******************************************************************************
* Disply character on given line                                               *
*   Parameter:      ln:       line number                                      *
*                   col:      column number                                    *
*                   c:        ascii character                                  *
*   Return:                                                                    *
*******************************************************************************/

void GLCD_DisplayChar (unsigned int ln, unsigned int col, unsigned char c) {

  c -= 32;
  GLCD_DrawChar(col * CHAR_W, ln * CHAR_H, (unsigned short *)&Font_24x16[c * CHAR_H]);
}


/*******************************************************************************
* Disply string on given line                                                  *
*   Parameter:      ln:       line number                                      *
*                   col:      column number                                    *
*                   s:        pointer to string                                *
*   Return:                                                                    *
*******************************************************************************/

void GLCD_DisplayString (unsigned int ln, unsigned int col, unsigned char *s) {

  GLCD_WindowMax();
  while (*s) {
    GLCD_DisplayChar(ln, col++, *s++);
  }
}


/*******************************************************************************
* Clear given line                                                             *
*   Parameter:      ln:       line number                                      *
*   Return:                                                                    *
*******************************************************************************/

void GLCD_ClearLn (unsigned int ln) {

  GLCD_WindowMax();
  GLCD_DisplayString(ln, 0, (unsigned char *)"                    ");
}

/*******************************************************************************
* Draw bargraph                                                                *
*   Parameter:      x:        horizontal position                              *
*                   y:        vertical position                                *
*                   w:        maximum width of bargraph (in pixels)            *
*                   val:      value of active bargraph (in 1/1024)             *
*   Return:                                                                    *
*******************************************************************************/

void GLCD_Bargraph (unsigned int x, unsigned int y, unsigned int w, unsigned int h, unsigned int val) {
  int i,j;

  x = WIDTH-x-w;
  wr_reg(0x50, y);                      /* Horizontal GRAM Start Address      */
  wr_reg(0x51, y+CHAR_H-1);             /* Horizontal GRAM End   Address (-1) */
  wr_reg(0x52, x);                      /* Vertical   GRAM Start Address      */
  wr_reg(0x53, x+w-1);                  /* Vertical   GRAM End   Address (-1) */

  val = (val * w) >> 10;                /* Scale value for 24x12 characters   */
  wr_reg(0x20, y);
  wr_reg(0x21, x);
  LCD_CS(0)
  wr_cmd(0x22);
  wr_dat_start();
  for (i = 0; i < h; i++) {
    for (j = w-1; j >= 0; j--) {
      if(j >= val) {
        wr_dat_only(BackColor);
      } else {
        wr_dat_only(TextColor);
      }
    }
  }
  wr_dat_stop();
}


/*******************************************************************************
* Display graphical bitmap image at position x horizontally and y vertically   *
* (This function is optimized for 16 bits per pixel format, it has to be       *
*  adapted for any other bits per pixel format)                                *
*   Parameter:      x:        horizontal position                              *
*                   y:        vertical position                                *
*                   w:        width of bitmap                                  *
*                   h:        height of bitmap                                 *
*                   bitmap:   address at which the bitmap data resides         *
*   Return:                                                                    *
*******************************************************************************/

void GLCD_Bitmap (unsigned int x, unsigned int y, unsigned int w, unsigned int h, unsigned char *bitmap) {
  unsigned int    i, j;
  unsigned short *bitmap_ptr = (unsigned short *)bitmap;

  x = WIDTH-x-w;
  wr_reg(0x50, y);                      /* Horizontal GRAM Start Address      */
  wr_reg(0x51, y+h-1);                  /* Horizontal GRAM End   Address (-1) */
  wr_reg(0x52, x);                      /* Vertical   GRAM Start Address      */
  wr_reg(0x53, x+w-1);                  /* Vertical   GRAM End   Address (-1) */

  wr_reg(0x20, y);
  wr_reg(0x21, x);
  LCD_CS(0)
  wr_cmd(0x22);
  wr_dat_start();
  for (j = 0; j < h; j++) {
    bitmap_ptr += w-1;
    for (i = 0; i < w; i++) {
      wr_dat_only(*bitmap_ptr--);
    }
    bitmap_ptr += w+1;
  }
  wr_dat_stop();
}


/*******************************************************************************
* Display graphical bmp file image at position x horizontally and y vertically *
* (This function is optimized for 16 bits per pixel format, it has to be       *
*  adapted for any other bits per pixel format)                                *
*   Parameter:      x:        horizontal position                              *
*                   y:        vertical position                                *
*                   w:        width of bitmap                                  *
*                   h:        height of bitmap                                 *
*                   bmp:      address at which the bmp data resides            *
*   Return:                                                                    *
*******************************************************************************/

void GLCD_Bmp (unsigned int x, unsigned int y, unsigned int w, unsigned int h, unsigned char *bmp) {
  unsigned int    i, j;
  unsigned short *bitmap_ptr = (unsigned short *)bmp;

  x = WIDTH-x-w;
  wr_reg(0x50, y);                      /* Horizontal GRAM Start Address      */
  wr_reg(0x51, y+h-1);                  /* Horizontal GRAM End   Address (-1) */
  wr_reg(0x52, x);                      /* Vertical   GRAM Start Address      */
  wr_reg(0x53, x+w-1);                  /* Vertical   GRAM End   Address (-1) */

  wr_reg(0x20, y);
  wr_reg(0x21, x);
  LCD_CS(0)
  wr_cmd(0x22);
  wr_dat_start();
  bitmap_ptr += ((unsigned long)h*(unsigned long)w)-1;
  for (j = 0; j < h; j++) {
    for (i = 0; i < w; i++) {
      wr_dat_only(*bitmap_ptr--);
    }
  }
  wr_dat_stop();
}

/******************************************************************************/
/******************************************************************************/
