/*

wangguanfu
2009-10-15

*/

#include "int.h"
#include "lcd.h"
volatile unsigned char val1=0;

void Init_INT0(void)
{
	SREG |= 0x80 ;//ʹ��ȫ���ж�
	MCUCR |= 0x02 ;//�½����ж�
	GICR=(1<<INT0) ;//
	
}


SIGNAL( SIG_INTERRUPT0 )
{
	cli();
	
   // if(val1)
	//{
	// val1=0;
	 DISEN_EXCLK;//��ֹ�ⲿCLK��ʹ��Ƭ��WR��TFT WR����	
	 DISEN_245;//��ֹ�ⲿ�����ߣ�ʹ��Ƭ��������TFT����������	
     DATA_OUPUT();//�����������׼���������ߵ�TFT
	 LCD_WR_REG(0x0020,0);//
	 LCD_WR_REG(0x0021,0);//
	 LCD_WR_REG(0x0050,0x00);//ˮƽ GRAM��ʼλ��
	 LCD_WR_REG(0x0051,239);//ˮƽGRAM��ֹλ��
	 LCD_WR_REG(0x0052,0x00);//��ֱGRAM��ʼλ��
	 LCD_WR_REG(0x0053,319);//��ֱGRAM��ֹλ�� 
	 LCD_WR_REG(0x0003,0x1028); 
	 LCD_WR_REG16(0x0022);
	 
     LCD_CS_L();//����ʹ��
	 DATA_INPUT();//���������룬׼�������ⲿ�����ߵ�TFT	
	 LCD_RS_H();//����ʹ��
	 LCD_WR_L();//ʹ���ⲿʱ��
	 EN_EXCLK;//ʹ���ⲿCLK
	 EN_245;//ʹ���ⲿ�����ߣ���TFT����������	
	/* }
	 else 
	 {
	 val1=1;
	 DISEN_EXCLK;//��ֹ�ⲿCLK��ʹ��Ƭ��WR��TFT WR����	
	 DISEN_245;//��ֹ�ⲿ�����ߣ�ʹ��Ƭ��������TFT����������	
     DATA_OUPUT();//�����������׼���������ߵ�TFT
	 LCD_WR_REG(0x0003,0x1018);
	 //LCD_write_english_string(20,206,"Guanfu_Wang 2010-01-01",RED,BLACK);
	 LCD_write_english_string(100,222,"OV7670 Demo Rev3.0",RED,BLACK);
	 
	 }
	 */
	 sei();
}
