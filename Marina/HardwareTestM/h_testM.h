
//#define BSET(x,m)      ( (x) | (  m   )
//#define BCLR(x,m)      ( (x) & (~(m)) )


// Definiciones para el AT86RF231

//==========================================
#define TRX_STATUS_REG   0x01
//==========================================
// Solo los destados de la operación básica.
#define TRX_ST_P_ON      0x00
#define TRX_ST_BUSY_RX   0x01
#define TRX_ST_BUSY_TX   0x02
#define TRX_ST_RX_ON     0x06
#define TRX_ST_TRX_OFF   0x08
#define TRX_ST_PLL_ON    0x09
#define TRX_ST_SLEEP     0x0F
#define TRX_ST_RX_NOCLK  0x1C
#define TRX_ST_STATE_TRANSITION_IN_PROGRESS   0x1F



//==========================================
#define TRX_STATE_REG    0x02
//==========================================
// Solo los comandos de operación básica.
#define TRX_CMD_NOP            0x00
#define TRX_CMD_TX_START       0x02
#define TRX_CMD_FORCE_TRX_OFF  0x03
#define TRX_CMD_FORCE_PLL_ON   0x04
#define TRX_CMD_RX_ON          0x06
#define TRX_CMD_TRX_OFF        0x08
#define TRX_CMD_PLL_ON         0x09



//==========================================
#define IRQ_MASK_REG     0x0E
#define IRQ_STATUS_REG   0x0F
//==========================================
#define PLL_LOCK_IRQ     0x01
#define PLL_UNLOCK_IRQ   0x02
#define RX_START_IRQ     0x04
#define TRX_END_IRQ      0x08
#define CCA_ED_DONE_IRQ  0x10
#define AMI_IRQ          0x20
#define TRX_UR_IRQ       0x40
#define BAT_LOW_IRQ      0x80






//==========================================
#define TRX_CTRL_0_REG   0x03
//==========================================







//==========================================
#define TRX_CTRL_1_REG   0x04
//==========================================
#define IRQ_2_EXT_EN     0x40
#define TX_AUTO_CRC_ON   0x20
#define IRQ_MASK_MODE    0x02
#define IRQ_POLARITY     0x01
#define SPI_MODE_00      0x00
#define SPI_MODE_TRX_ST  0x04
#define SPI_MODE_RSSI    0x08
#define SPI_MODE_IRQ_ST  0x0c


//==========================================
#define PHY_TX_PWR_REG   0x05
//==========================================

//==========================================
#define TX_CTRL_2_REG    0x0c
//==========================================
#define RX_SAFE_MODE       0x80 
#define OQPSK_DATA_RATE_0  0x02
#define OQPSK_DATA_RATE_1  0x01



//==========================================
#define XAH_CTRL_1        0x17
//==========================================
#define AACK_FLTR_REST_FT 0x20
#define AACK_UPLD_RES_FT  0x10
#define AACK_ACK_TIME     0x04
#define AACK_PROM_MODE    0x02

//==========================================
#define PHY_CC_CCA_REG    0x08
//==========================================




#define RELEASE 3

#define THE_FINAL_COUNT_DOWN ( count_down == 0 )


#define nop() do { __asm__ __volatile__ ("nop"); } while (0)

#define DELAY_500N  { nop() ; nop() ; nop() ; nop() ; \
                      nop() ; nop() ; nop() ; nop() ; }

#define DELAY_1U   { DELAY_500N ; DELAY_500N }

 

#define RF_SPI_WAIT while ((miSPI.STATUS & SPI_IF_bm ) == 0) //hay q mirar si el flag de interrupción está a 1 para poder tx/rx
                                                             //si no, hay q esperar
                                                              

#define BSCALE_VALUE  0
#define BSEL_VALUE   103

#define miUSART USARTC0 //utilizaremos la USART del Puerto C0
#define miUSART_PORT PORTC //el puerto C

/* Target: Internal RC 16MHz (default) 
    * Example (9600bps)  :   - I/O clock = 16MHz
 	*                        - 9600bps can be acheived by 9600bps / 2^0
 	*                        - UBRR = 16MHz/(16*9600)-1 = 103,17
 	*                        - ScaleFactor = 0
	*/
	


#define UART_FIFO_SIZE       512
#define TX_DATA_AVAILABLE    uart_fifo_tx.head != uart_fifo_tx.tail
#define RX_DATA_AVAILABLE    uart_fifo_rx.head != uart_fifo_rx.tail

#define miSPI SPIF        //utilizaremos el SPI del puerto F
#define miSPI_PORT PORTF  //al puerto F le llamo miSPI_PORT

#define NO_CHAR              0x100


#define NEXT_UART_INDEX( ix )  ( ( (ix) + 1) % UART_FIFO_SIZE )

#define FIFO_DATA_FULL( fifo )         (				      \
					NEXT_UART_INDEX( (fifo)->head ) == \
					(fifo)->tail )


#define TX_UART_READY       ( miUSART.STATUS & ( 1 << USART_DREIF_bp ) )
#define RX_UART_DATA_READY  ( miUSART.STATUS & ( 1 << USART_RXCIF_bp  ) )


#define wcp_putchar( x )        _putchar( (x) , NULL )




#define ReadTRXState()   ( SPIRegRead(TRX_STATUS_REG) )
#define RF_IRQ           ( miSPI_PORT.IN & PIN2_bm )   
#define RF_SS_HIGH       miSPI_PORT.OUT |= PIN1_bm      
#define RF_SS_LOW        ( miSPI_PORT.OUT &= ~ PIN1_bm)    



#define RF_SLP_TR_HIGH       miSPI_PORT.OUT |= PIN3_bm;
#define RF_SLP_TR_LOW        miSPI_PORT.OUT &= ~ PIN3_bm;    
#define RF_nRST_HIGH         miSPI_PORT.OUT |= PIN1_bm;      
#define RF_nRST_LOW          miSPI_PORT.OUT &= ~ PIN1_bm;    




typedef unsigned char byte ;

void RFInit();

void IRQ_Handler();

void PrintHelpMessage();

void PrintFrame(byte *buffer);
