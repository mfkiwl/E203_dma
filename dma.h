////////////////////////////////////////////////////////////////////////////////
// Author: Venci Freeman, copyright (c) 2020
// E-mail: vencifreeman16@sjtu.edu.cn
// School: Shanghai Jiao Tong University
// File Name: dma.h
// Details: 
// Release History:
// - Version 0.1 20/06/22: Create.
////////////////////////////////////////////////////////////////////////////////

#ifndef _HBIRD_DMA_H
#define _HBIRD_DMA_H

/*register offsets*/
#define DMA_REG_SRC             0x00
#define DMA_REG_DST             0x04
#define DMA_REG_LEN             0x08
#define DMA_REG_CTR             0x0c
//#define DMA_REG_SR              0x10

#define DMA_CTR_EN            (1 << 7)
#define DMA_CTR_IE            (1 << 6)
#define DMA_CTR_STA           (1 << 5)
#define DMA_CTR_IRQ           (1 << 4)

//#define DMA_SR_IF             (1 << 1)
//#define DMA_SR_TIP            (1 << 0)

#if 0
/*fileds*/

#define DMA_CTR_ENABLE          1
#define DMA_CTR_DISABLE         0 

#define DMA_CTR_INTEN           1
#define DMA_CTR_INTDIS          0

#define DMA_TXR_RFS             1       //read from slave
#define DMA_TXR_WTS             0       //write to slave

#define DMA

/**/i

#endif

#endif /* _HBIRD_SPI_H */