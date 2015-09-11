
/************************************************************************

  Chequeador de hardware del WCP

  2011/Roberto Esper-Chaín Falcón (Marina Martín Ramos)

************************************************************************/

// Includes  
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

#include "h_testM.h"



typedef struct {
  unsigned char buffer[UART_FIFO_SIZE];
  unsigned int  head;
  unsigned int  tail;
} uart_fifo_t;

uart_fifo_t  uart_fifo_tx ,
             uart_fifo_rx ;




typedef enum appl_st{
  IDLE         ,
  RST_IDLE     ,
  RST_ST1      ,
  RST_ST2      ,
  CNF_ST       ,
  PLL_ON_CMD   ,
  PLL_ON_WAIT  ,
  TX_COMMAND   ,
  TX_WAIT      ,
  WAIT_CMD     ,
  RX_ON_CMD    ,
  RX_ON  
  
} appl_st_t;



// PROTOTIPOS
static int _putchar(char c, FILE *s) ;

void InsertFIFO( unsigned char c, uart_fifo_t *uf);


void ParseCH(unsigned char c);


// REDIRECCION DE PRINTF

static FILE wcpstdout = FDEV_SETUP_STREAM(_putchar, NULL,
                                             _FDEV_SETUP_WRITE);
 



// Globales.
volatile unsigned char PLL_LOCK_CP;
volatile unsigned int ms;
volatile unsigned int count_down;
volatile unsigned int print_timer;
volatile unsigned int time_out;
volatile unsigned char RF_PHY_STATUS ;

byte RxFrame[160];
byte Frame[20] = { 0x0F, 0xFE, 0xED, 0xC0, 0xDE, 
		   0xAA, 0xAA, 0xAA, 0x00, 0x00,
		   0xc0, 0xc0, 0x55, 0x55, 0x55,
		   0x00, 0x00, 0x00, 0x00, 0x00};

appl_st_t APP_ST;
byte HELP_MSG;


// Interrupciones 

ISR(TCC1_CCA_vect)  
{
  ms ++;
  if (count_down!=0) count_down--;
  if (time_out!=0) time_out--;
  if (print_timer!=0) print_timer--;
}

// Funciones



void SPIRegWrite(char reg,char d) 
{
  unsigned char aux;
  
  aux = (reg | 0xC0) ;
  RF_SS_LOW ;
  miSPI.DATA = aux;
  RF_SPI_WAIT;
  RF_PHY_STATUS = miSPI.DATA;
  DELAY_500N;
  miSPI.DATA = d;
  RF_SPI_WAIT;
  aux = miSPI.DATA;
  RF_SS_HIGH;
  
}

unsigned char SPIRegRead(char reg )
{
  unsigned char aux;

  aux = ( (reg & 0x3F) | 0x80) ;
  RF_SS_LOW ;
  miSPI.DATA = aux;
  RF_SPI_WAIT;
  RF_PHY_STATUS = miSPI.DATA;
  DELAY_500N;
  miSPI.DATA = 0xFF;
  RF_SPI_WAIT;
  aux = miSPI.DATA;
  RF_SS_HIGH;
  return aux;

}

void SPIFrameWrite(byte *buffer)
{
  unsigned char c,aux;

  RF_SS_LOW ;

  miSPI.DATA = 0x60;
  RF_SPI_WAIT;
  RF_PHY_STATUS = miSPI.DATA;
  DELAY_500N;

  miSPI.DATA = buffer[0];
  RF_SPI_WAIT;
  aux = miSPI.DATA;
  DELAY_500N;

  for (c=1;c<=(buffer[0]&0x7F); c++){

    miSPI.DATA = buffer[c];
    RF_SPI_WAIT;
    aux=miSPI.DATA;
    DELAY_500N;

  }
  
  RF_SS_HIGH;
}



unsigned char SPIFrameRead(byte *buffer)
{
  unsigned char c;
  RF_SS_LOW ;

  miSPI.DATA= 0x20;
  RF_SPI_WAIT;
  RF_PHY_STATUS = miSPI.DATA;
  DELAY_500N;

  miSPI.DATA = 0xFF;
  RF_SPI_WAIT;
  buffer[0] = miSPI.DATA;
  DELAY_500N;

  for (c=1;c<=((buffer[0]&0x7F)+3); c++){

    miSPI.DATA = 0xFF;
    RF_SPI_WAIT;
    buffer[c]=miSPI.DATA;
    DELAY_500N;
  }
  
  RF_SS_HIGH;

  return c;

}

static int _putchar(char c, FILE *s)
{
  if (c== '\n')
    InsertFIFO('\r',&uart_fifo_tx);
  InsertFIFO(c,&uart_fifo_tx);
  return 0;
}



void InsertFIFO( unsigned char c, uart_fifo_t *uf )
{
  if (!FIFO_DATA_FULL( uf )) {
    uf->buffer[uf->head]= c;
    uf->head = NEXT_UART_INDEX( uf->head );
  }
}

unsigned char ExtractFIFO(uart_fifo_t *uf )
{
  unsigned char aux;
  
  aux = uf->buffer[uf->tail];
  uf->tail = NEXT_UART_INDEX( uf->tail );
  return aux;
}

unsigned int wcp_getchar( )
{
  if (RX_DATA_AVAILABLE) {
    return ( (unsigned int) ExtractFIFO( &uart_fifo_rx ) );
  }
  return NO_CHAR;
}


void uart_task()
{

  if (TX_DATA_AVAILABLE) {
    if (TX_UART_READY) {
      miUSART.DATA = ExtractFIFO( & uart_fifo_tx );
    }
  }
  if (RX_UART_DATA_READY) {
    InsertFIFO(miUSART.DATA, &uart_fifo_rx );
  }
  
}

void ResetRF() 
{

  // Power on reset
  PLL_LOCK_CP = 0;
  RF_SLP_TR_HIGH;
  RF_nRST_HIGH;
  RF_SS_HIGH ;
  count_down = 2;
  while (count_down!=0) ;
  RF_SLP_TR_LOW;
  count_down = 2;
  while (count_down!=0) ;
  RF_nRST_LOW;
  DELAY_1U;
  RF_nRST_HIGH;
  DELAY_1U;
  SPIRegWrite(0x03,0x19);
  printf("Reset (%02x)",RF_PHY_STATUS);
  SPIRegWrite(0x02,0x03);
  printf("(%02x)\n\r",RF_PHY_STATUS);
}

// Funciones

void InitMCU( )
{

 PLL_LOCK_CP = 0;

  // Inicialización de Timer1
 TCC1.CTRLC = TC1_CMPA_bm ;          // habilitamos el comparador A 0x01

 //TCC1.INTCTRLA = 0x00;               // no vamos a manejar las interrupciones ni por overflow ni error
 TCC1.INTCTRLB = TC1_CCAINTLVL1_bm;  // habilitamos las interrupciones del canal A a nivel medio (10)

 TCC1.INTFLAGS = 0xff;               // borramos los flags

 //TCC1.CNT = 0x4000;
 TCC1.PER = 0xFF;                  // vamos a contar de 0 a 15999 (0x3e7f)
 TCC1.CCA = 0xFF; //0x3e7f;                  // vamos a contar de 0 a 15999 (0x3e7f)
 
 TCC1.CTRLB = TC1_CCAEN_bm | TC1_WGMODE0_bm; // habilitar el canal A (CCAEN) y WGMODE = 001.

 TCC1.CTRLA = TC1_CLKSEL0_bm; // 0x01 // DIV1


 PMIC.CTRL |= PMIC_MEDLVLEX_bm; //(1<<PMIC_MEDLVLEX_bp); //  habilitamos las interrupciones a nivel medio (10)
 //PMIC.STATUS |= PMIC_MEDLVLEX_bm;
  sei();

 ms = 0;


  
  // Inicialización de la USARTC0
 
 miUSART_PORT.DIRSET   = PIN3_bm;   // Pin 3 (TXD0) como salida.
 miUSART_PORT.DIRCLR   = PIN2_bm;   // Pin 2 (RXD0) como entrada.

                                  // USARTC0, 8 Data bits, No Parity, 1 Stop bit.
 miUSART.CTRLC = USART_CMODE_ASYNCHRONOUS_gc | USART_PMODE_DISABLED_gc  | USART_CHSIZE_8BIT_gc;

 miUSART.BAUDCTRLA = BSEL_VALUE; 

                                  
 miUSART.CTRLB |= USART_RXEN_bm;
 miUSART.CTRLB |= USART_TXEN_bm ;// Habilitar tanto la RX como la TX
 
 //miUSART.CTRLA = USART_RXCINTLVL_MED_gc | USART_TXCINTLVL_MED_gc | USART_DREINTLVL_MED_gc ; // nivel de interrupión medio
 //miUSART.DATA = 0x00;

  uart_fifo_tx.head = 0;
  uart_fifo_tx.tail = 0;
  uart_fifo_rx.head = 0;
  uart_fifo_rx.tail = 0;

  stdout = & wcpstdout ; // Redirección de printf

  printf("Estado INICIAL:");


  // INICIALIZACIÓN DEL SPI


  miSPI.CTRL = SPI_ENABLE_bm|SPI_PRESCALER0_bm; //  |SPI_MASTER_bm
  //miSPI.INTCTRL = SPI_INTLVL1_bm;//interrupciones habilitadas con nivel de interrupción medio
  miSPI.STATUS = 0x00; //todo está preparado para recibir o transmitir
  //miSPI.DATA = 0x00;   //lo inicializamos a 0

  miSPI_PORT.DIRSET = PIN4_bm; //COMO SALIDA, nSS
  miSPI_PORT.DIRSET = PIN5_bm; //COMO SALIDA, MOSI
  miSPI_PORT.DIRCLR = PIN6_bm; //COMO ENTRADA, MISO
  miSPI_PORT.DIRSET = PIN7_bm; //COMO SALIDA, SCLK
 
  
  // INICIALIZACIÓN DEL TRANSCEPTOR RF Y PINES SPI

  RF_SS_HIGH;
  RF_SLP_TR_LOW ;
  RF_nRST_HIGH;
  //miSPI_PORT.DIRSET = PIN1_bm; //COMO SALIDA, nRST
  //miSPI_PORT.DIRCLR = PIN2_bm; //COMO ENTRADA, IRQ
  //miSPI_PORT.DIRSET = PIN3_bm; //COMO SALIDA, SLP_TR
 
  
  APP_ST = IDLE;
  HELP_MSG = 0;
  time_out=0;
  count_down=0;
  HELP_MSG=0;
  print_timer=0;
  sei();
  
}


void ReadID()
{
  printf("ID = 0x%02x-%02x-%02x-%02x\n\r", 
	 SPIRegRead(0x1c),SPIRegRead(0x1d),
	 SPIRegRead(0x1e),SPIRegRead(0x1f));
}


void RFApp() 
{

  byte aux;

  
  if (count_down!= 0 ) return;
  switch (APP_ST) {
  case IDLE:
    return;
  case RST_IDLE:
    PLL_LOCK_CP = 0;
    RF_SLP_TR_HIGH;
    RF_nRST_HIGH;
    RF_SS_HIGH ;
    count_down = 4;
    APP_ST = RST_ST1;
    break;
  case RST_ST1:
    RF_SLP_TR_LOW;
    count_down = 4;
    APP_ST = RST_ST2;
    break;
  case RST_ST2:
    RF_nRST_LOW;
    DELAY_1U;
    RF_nRST_HIGH;
    DELAY_1U;
    SPIRegWrite(0x03,0x19);
    printf("Reset (%02x)",RF_PHY_STATUS);
    SPIRegWrite(0x02,0x03);
    printf("(%02x)\n\r",RF_PHY_STATUS);
    APP_ST = CNF_ST;
    break;
  case CNF_ST:
    RFInit( );
    APP_ST = IDLE;
    if (RF_PHY_STATUS != TRX_ST_TRX_OFF) {
      printf("Reset fallido, no llego a TRX_OFF (ST=0x%02x)\n\r",RF_PHY_STATUS);
    }
    break;
  case PLL_ON_CMD:
    SPIRegWrite(TRX_STATE_REG,TRX_CMD_PLL_ON);
    APP_ST= PLL_ON_WAIT ;
    time_out = 20;
  case PLL_ON_WAIT:
    if (PLL_LOCK_CP) {
      APP_ST = TX_COMMAND;
      return ;
    }
    if (time_out==0) {
      printf("PLL_ON: Time out\n\n");
      APP_ST=IDLE;
    }
    break;
  case TX_COMMAND:
    SPIFrameWrite(Frame);
    SPIRegWrite(TRX_STATE_REG,TRX_CMD_TX_START);
    printf("TX 0x%02x (PHY=0x%02x)\n\r",Frame[9],RF_PHY_STATUS);
    Frame[9]++;
    APP_ST = TX_WAIT;
    time_out= 20;
  case TX_WAIT:
    aux = ReadTRXState() ;
    if (aux == TRX_ST_PLL_ON ) {
      APP_ST= PLL_ON_WAIT;
      count_down=200;
      return;
    }
    if (time_out==0) {
      printf("TX ERROR: STATE=0x%02x\n\r",aux);
      APP_ST=IDLE;
    }
    break;
  case RX_ON_CMD:
    SPIRegWrite(TRX_STATE_REG,TRX_CMD_RX_ON);
    APP_ST=RX_ON;
    break;
  case RX_ON:
    aux=SPIRegRead(TRX_STATUS_REG);
    break;
  default: 
    APP_ST = IDLE;
  }
    
}



void ParseCH(unsigned char c)
{
  switch( c )  {
  case 'V':
  case 'v': 
    printf("WCP V0.3 R%d\n\r",RELEASE);
  break;
  case 'X':
  case 'x':
    APP_ST = RST_IDLE;
  break;
  case 'I':
  case 'i':
    ReadID() ;
  break;
  case 'P':
  case 'p':                                
    printf("[PA=0x%02x]",PORTA.IN);    
    printf("[PB=0x%02x]",PORTB.IN);    
    printf("[PC=0x%02x]",PORTC.IN);    
    printf("[PD=0x%02x]",PORTD.IN);             
    printf("[PE=0x%02x]",PORTE.IN);    
    printf("[PF=0x%02x]",PORTF.IN);
    printf("[PH=0x%02x]",PORTH.IN);
	printf("[PJ=0x%02x]",PORTJ.IN);
	printf("[PK=0x%02x]",PORTK.IN);
	printf("[PQ=0x%02x]",PORTQ.IN);
	printf("[PR=0x%02x]\n\r",PORTR.IN);

    break;
  case 'L':
  case 'l':
    printf("RST=%c ",(miSPI_PORT.IN & 0x02)? 'H':'L');
    printf("INT=%c\n\r",(miSPI_PORT.IN & 0x04)? 'H':'L');
    printf("SLP=%c ",(miSPI_PORT.IN & 0x08)? 'H':'L');
	printf("SS=%c ",(miSPI_PORT.IN & 0x10)? 'H':'L');
	printf("MOSI=%c ",(miSPI_PORT.IN & 0x20)? 'H':'L');
	printf("SCK=%c ",(miSPI_PORT.IN & 0x40)? 'H':'L');
	printf("MISO=%c ",(miSPI_PORT.IN & 0x80)? 'H':'L');
    break;
  case 'S':
  case 's':
    printf("Estado del TRX=0x%02x\n\r",SPIRegRead(TRX_STATUS_REG));
  break;
  case 'E':
  case 'e':
    APP_ST = IDLE;
    printf("Transmision parada\n\r");
    break;
  case 'H':
  case 'h':
    HELP_MSG=1;
    break;
  case '\n':
    wcp_putchar('\n');
    wcp_putchar('\r');
    break;
  case 'T':
  case 't':
    printf("Entrando en modo transmisor\r\n");
    APP_ST=PLL_ON_CMD;
    break;
  case 'R':
  case 'r':
    printf("Entrando en modo recepcion\r\n");
    APP_ST=RX_ON_CMD;
    break;
  default:
    wcp_putchar(c);
    break;
  }
}


int  main()
{
  unsigned int rd;
  InitMCU();

  printf("HARD_RESET\n");
  ResetRF();

  while ( 1 ) {

    rd = wcp_getchar();
    if ( rd != NO_CHAR ) {
      unsigned char c;
      c = (unsigned char) ( rd & 0x0FF );
      ParseCH( c );
    }
    uart_task();
    
    if (RF_IRQ)
      IRQ_Handler();
    if (HELP_MSG)
      PrintHelpMessage();
    RFApp();
  }
  return 0;
}



void RFInit()
{
  //byte aux;
  

  // Inicialización de máscaras de interrupción
  SPIRegWrite(IRQ_MASK_REG,PLL_LOCK_IRQ|PLL_UNLOCK_IRQ|TRX_END_IRQ);
  SPIRegWrite(TRX_CTRL_1_REG, TX_AUTO_CRC_ON  |
	                      SPI_MODE_TRX_ST ) ;

                              
  
  // Ajuste de la potencia de salida (a tope +4dBm)
  SPIRegWrite(PHY_TX_PWR_REG,0x00);
  
  // Ajuste de la frecuencia de salida
  //SPIRegWrite(CC_CTRL_1_REG,0x00);

  // Canal (el PHY_CC_CCA_REG por defecto está; CCA_REQUEST=0, CCA_MODE=01 y canal 11 (2405Hz) por defecto)
  //aux=SPIRegRead(PHY_CC_CCA_REG);
  //aux=BCLR(aux,0x1f); 
  //SPIRegWrite(PHY_CC_CCA_REG,aux);

  // Ajuste de la modulación  
  //SPIRegWrite(TX_CTRL_2, OQPSK_SCRAM_EN );
  
  // Modo Promiscuo
  //SPIRegWrite(XAH_CTRL_1,AACK_PROM_MODE);

  
}


void PrintHelpMessage()
{
  if (print_timer!=0) return;

  switch (HELP_MSG)  {
  case 1:
    printf("Wireless CPU V0.3 %d\n\r",RELEASE);
    break;
  case 2:
    printf("\n\rLista de comandos\r\n ");
    break;
  case 3:
    printf("======================================\n\r");
    break;
  case 4:
    printf("  V: Version\n\r  H: Esta ayuda\n\r");
    break;
  case 5:
    printf("  X: Reset\n\r  I: Lee ID de dispositivo\n\r");
    break;
  case 6:
    printf("  P: Imprime el estado de los puertos\n\r");
    break;
  case 7:
    printf("  E: Parar transmision\n\r");
    break;
  case 8:
    printf("  L: Lee el estado de las lineas\n\r");
    break;
  case 9:
    printf("  S: Lee el estado del transceptor\n\r");
    break;
  case 10:
    printf("  R: Modo escucha\n\r");
    break;
  case 11:
    printf("  T: Inicia transmision\n\r");
    break;
  case 12:
    printf("======================================\n\r");
  default:
    HELP_MSG = 0;
    return;
  }
  HELP_MSG++;
  print_timer=10;
}




void PrintFrame(byte *buffer)
{
  int i,j;

  printf("Rx ");
  for (i=0;i<8;i++) {
    if (buffer[i]!=Frame[i]) {
      printf("Error ");
      for (j=0;j<i;j++)
	printf(" %02x",buffer[j]);
      printf(" !%02x! (%02x)\n\r",buffer[j],Frame[j]);
      return ;
    }
  }
  printf (" ID=0x%02x  LQI=%d ED=%ddBm\n\r",buffer[9],buffer[16],
	  (buffer[17]-100));
  printf("\n\r");
  
  
}


void IRQ_Handler()
{
  byte i_flags;
  i_flags = SPIRegRead(IRQ_STATUS_REG);

  if ( i_flags & PLL_LOCK_IRQ ) {
    printf("PLL_LOCK_IRQ\n\r");
	PLL_LOCK_CP = 1;
  }

  if ( i_flags & PLL_UNLOCK_IRQ ) {
    printf("PLL_UNLOCK_IRQ\n\r");
	PLL_LOCK_CP = 0;
  }

  if ( i_flags & RX_START_IRQ ) {
    printf("RX_START_IRQ\n\r");
  }

  if ( i_flags & TRX_END_IRQ ) {
    printf("TRX_END_IRQ\n\r");
    if (APP_ST==RX_ON) {
      SPIFrameRead(RxFrame);
      PrintFrame(RxFrame);
    }
  }

  if ( i_flags & CCA_ED_DONE_IRQ ) {
    printf("CCA_ED_DONE_IRQ\n\r");
  }

  if ( i_flags & AMI_IRQ ) {
    printf("AMI_IRQ\n\r");
  }

  if ( i_flags & TRX_UR_IRQ ) {
    printf("TRX_UR_IRQ\n\r");
  }

  if ( i_flags & BAT_LOW_IRQ ) {
    printf("BAT_LOW_IRQ\n\r");
  }


}

