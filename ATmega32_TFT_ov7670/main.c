/*

wangguanfu
2010-04-27

*/



#include <avr/io.h>
#include <avr/interrupt.h>
#include "lcd.h"
#include "ov7670.H"
#include "int.H"
#include "delay.h"
#include "FAT.h"
#include "config.h"

unsigned int image_count = 0 ,image_all = 0 ;



extern uint16 SectorsPerClust;//ÿ��������

extern uint8  FAT32_Enable;

void disp_image(void)
  {
    WORD count= 1 ,i =0   ;
	uint8 *buffer ;
	uint8 type ,x , rgb,first ,color_byte,byte1,byte2,byte3 ;
	uint16 y ,color,tmp_color ;
    uint32 p;				//��ָʾֵ			//cluster
	type = 1 ;
	struct FileInfoStruct FileInfo;//�ļ���Ϣ

    struct direntry BMPInfo;	//Ҫ���ŵ�mp3�ļ���Ϣ		//the mp3 file item whichi will be played
	
	 LCD_WR_REG(0x0050,0);//ˮƽ GRAM��ʼλ��
     LCD_WR_REG(0x0051,239);//ˮƽGRAM��ֹλ��
     LCD_WR_REG(0x0052,0);//��ֱGRAM��ʼλ��
     LCD_WR_REG(0x0053,319);//��ֱGRAM��ֹλ�� 
	
	if( image_all == 0 )    //��ȡ��ͼƬ��
	  {
         image_count =  0 ;
	     byte1 = Search(&BMPInfo,&image_count,&type) ;
		 image_all = image_count ;		 
		 image_count = 1 ;
		 		 
		 /*
	     image_count = 0 ;
         Search(&BMPInfo,&image_count,&type) ;
		 image_all = image_count ;
		 GUI_sprintf_chartohex(10,300,0x00,0xffff,0x0000) ;
		 GUI_sprintf_chartohex(30,300,image_count,0xffff,0x0000) ;
		 GUI_sprintf_chartohex(60,300,image_all,0xffff,0x0000) ;
		 */
	  }
	else  
      {		
          byte1 = Search(&BMPInfo,&image_count,&type) ;
      }	
	 
	 
	 
	p = BMPInfo.deStartCluster+(((uint32)BMPInfo.deHighClust)<<16);//���ļ��״�	//the first cluster of the file
	
	x = 0 ;
	y = 319 ;
	rgb = 0 ;
	count = 0 ;
	first = 0 ;
	buffer=malloc(512);	
	while(1)
	 {
		i = 0 ;
	
	    for( ; i < SectorsPerClust ; i++ )      //��
	     {
	 
	        FAT_LoadPartCluster(p,i,buffer);//��һ������	//read a sector
	   
	        if(i==0 && first==0) { count= buffer[0x0a] ; color_byte = buffer[0x1c] / 8  ;  first = 1 ; } 
	        else { count=0 ; }
	   
	        while(count<512)  //��ȡһ��512���� (SectorsPerClust ÿ��������)
	          {
		   
		        if(color_byte == 3)   //24λ��ɫͼ
		          {
                      switch ( rgb ) 
                        {
			               case 0 : tmp_color = buffer[count]>>3 ;
			                        color |= tmp_color;
					                break ;
					  
			               case 1 : tmp_color = buffer[count]>>2 ;
			                        tmp_color <<= 5 ;
			                        color |= tmp_color ;
					                break ;
					   
       			           case 2 : tmp_color = buffer[count]>>3 ;
			                        tmp_color <<= 11 ;
			                        color |= tmp_color ;
					                 break ;			
			            }
			
                      rgb ++ ;
			      }
		        else
		          {
			          if(color_byte==2)  //16λ��ɫͼ
				        {
				          switch ( rgb )
					        {
					          case 0 : byte1 = buffer[count] ;
								       break ; 
								   
						      case 1 :    
								       color = buffer[count] ;
								       color<<=8 ;
								       color |= byte1 ;
								       break ;
					     
					        }
					      rgb ++ ;
				    
				        }
				      else 
				        {
				          if(color_byte==4) //32λ��ɫͼ
				            {
				              switch ( rgb )
					            {
					              case 0 :  byte1 = buffer[count] ;
								            break ; 
								   
						          case 1 :  byte2 = buffer[count] ;
                                            break ;
									   
							      case 2 :  byte3 = buffer[count] ;
							                break ;
									   
							      case 3 :  tmp_color = byte1 >> 3 ;
			                                color |= tmp_color;
									        tmp_color = byte2 >>2 ;
			                                tmp_color <<= 5 ;
			                                color |= tmp_color ;
									        tmp_color = byte3 >>3 ;
			                                tmp_color <<= 11 ;
			                                color |= tmp_color ;
									        break ;
					     
					            }
					           rgb ++ ;
				    
				            }
				     
				        }   
			 
			       }
           
		   count ++ ;
		   
		   if(rgb == color_byte)        //��ȡ1���������ݺ���ʾ
		     {
			   // GUI_Point(x, y,color) ;
				
				    LCD_WR_REG(0x0020,239-x);//Lcd���GRAMˮƽ��ʼλ��
                    LCD_WR_REG(0x0021,319-y); //Lcd��괹ֱGRAM��ʼλ��     

	                LCD_WR_REG16(0x0022); 
	                LCD_WR_DATA16(color);
				
				color = 0x00 ;
			    x++ ;
			    if(x>=240)
				  {
				    y-- ;
					
					if( y<=0 )
		              {
					    
						free(buffer) ;
			            return ;
			          }
					x = 0 ;
				  }
		        
				rgb = 0 ;
			 }
			 
			
		}
	   
	 }  // ��ȡ��һ������
	 
	 free(buffer) ;
	 p=FAT_NextCluster(p);//����һ������			//read next cluster
	 buffer=malloc(512);	
	
	if(p == 0x0fffffff || p == 0x0ffffff8 || (FAT32_Enable == 0 && p == 0xffff))//����޺������������	//no more cluster
		{
		        free(buffer) ;
				return ;
		}
	 
  }
		
	free(buffer) ;
  
 }


//CPU��ʼ��//
int main(void) 
{
  unsigned char i, x,retry=0,kn=0,Sensor_ID;
  uint8 ok,er,r1 ;
  uint32 capacity ;
  unsigned int y ;;
	EXCLK_DDR|=1<<EXCLK_BIT ;//en_exclk �������
	HC245_OE_DDR|=1<<HC245_OE_BIT;//en_245�������
	DDRD&=~(0x20);
	PORTD|=0X20;
	
	DISEN_EXCLK;//��ֹ�ⲿCLK��ʹ��Ƭ��WR��TFT WR����	
	DISEN_245;//��ֹ�ⲿ�����ߣ�ʹ��Ƭ��������TFT����������
	
	DATA_OUPUT(); //�����������׼���������ߵ�TFT
    LCD_Init();
	MMC_SD_Init();//��ʼ��spi��
	delay_ms(3000);
	//GUI_Point(0, 0,0xffff) ;
	LCD_write_english_string(20,150,"Guanfu Wang  20100902",RED,BLACK);
	LCD_write_english_string(20,170,"Atmega32 & OTM3225A FOR OV7670 REV4.0",GREEN,BLACK);
	
	if(PIND&0X20)
	{
	   kn=0;
		LCD_write_english_string(20,190,"OV7670 Init......",BLUE,BLACK);
	
	   while(1!=OV7670_init());//��ʼ��ov7660
	  // while(1!=rdOV7670Reg(0x0b, &Sensor_ID));//��ID
	//delay_ms(1000);
	   LCD_write_english_string(20,190,"OV7670 Init  0K  ",RED,BLACK);
	   delay_ms(1000);
	   LCD_Clear(0);
       DATA_INPUT(); 
	   Init_INT0();
	
	}
	else
	{
	  kn=1;
	  LCD_write_english_string(20,190,"TF Card Init......",BLUE,BLACK);
	//OSCCAL = 0x00;//��СRC��Ƶ��
	   while(MMC_SD_Reset()&(retry<21))//��ʼ��SD��					//sd card initialize
	   {
		  retry++;
		  if(retry>20)
		  {
             LCD_write_english_string(20,190,"TF Card Init....NG",BLUE,BLACK);
		  
		  }	
	   } 
	   LCD_write_english_string(20,190,"TF Card Init....OK",BLUE,BLACK);  
	   LCD_write_english_string(20,210,"FAT Init......",BLUE,BLACK);
	   while(FAT_Init()){}//��ʼ���ļ�ϵͳ ֧��FAT16��FAT32	//initialize file system  FAT16 and FAT32 are supported
       SearchInit();  //�����ļ���ʼ��
	   LCD_write_english_string(20,210,"FAT Init....OK",BLUE,BLACK);
	}
	

    while(1)
    {	
	    if(kn)
		{
		 disp_image() ;
		 delay_ms(20000) ;
		 delay_ms(20000) ;
		                              //Print_hz(72,30,16,"������ʾ����",0xffff,0x0000) ;
		 if(image_count<image_all)
		    {
		      image_count ++ ;
		    }
		 else 
		    {
			  image_count = 1 ;
			} 
	     }
		 /*
		 else if(0==rdOV7670Reg(0x0b, &Sensor_ID))//��ID
		 {
		 
		  cli();
	      DISEN_EXCLK;//��ֹ�ⲿCLK��ʹ��Ƭ��WR��TFT WR����	
	      DISEN_245;//��ֹ�ⲿ�����ߣ�ʹ��Ƭ��������TFT����������
	      DATA_OUPUT(); //�����������׼���������ߵ�TFT
	      LCD_WR_REG(0x0003,0x1018);
	      LCD_Clear(0);
	      LCD_write_english_string(20,100,"Please install the sensor board...",BLUE,BLACK);
	       while(1!=OV7670_init());//��ʼ��������ģ��
          LCD_write_english_string(20,100,"Sensor OV7670 Init  0K            ",RED,BLACK);
	      delay_ms(3000);
	       LCD_Clear(0);
          DATA_INPUT(); 
	  
		   sei();
		 }
		*/ 
	
	}

}

