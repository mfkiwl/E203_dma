/////////////////////////////////////////////////////////////////////////////////////////
// Author: Yang Wenxi, copyright 2020
// E-mail: vencifreeman16@sjtu.edu.cn
// School: Shanghai Jiao Tong University
// File Name: dma
// Details: These file has 4 functions: init, config, CTRrt and interrupt functions.
// Release History:
// - Version 0.1 20/06/21: Create;
// - Version 0.2 20/06/25: Finish.
/////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include <string.h>
#include "encoding.h"
#include <unistd.h>
#include "stdatomic.h"
#include "dma.h"

void dma_init(void);
uint32_t dma_config(uint32_t srcAddr, uint32_t dstAddr, uint32_t len);
void dma_start(void);
void dma_interrput(void);

void handle_m_ext_interrupt(void) {
  DMA_REG_8(DMA_REG_CTR) = 0x80;
}

void dma_init(void) {
  DMA_REG_8(DMA_REG_CTR) = 0xc0;  // 模块使能与中断使能 1100_0000
}

uint32_t dma_config(uint32_t srcAddr, uint32_t dstAddr, uint32_t len) {
  DMA_REG_32(DMA_REG_SRC) = srcAddr;  // 源地址
  DMA_REG_32(DMA_REG_DST) = dstAddr;  // 目的地址
  DMA_REG_32(DMA_REG_LEN) = len;  // 数据长度，128
  return 0;
}

void dma_start(void) {
  DMA_REG_8(DMA_REG_CTR) = 0xe0;  // 开始标志位拉高 1110_0000
}

void dma_interrput(void) {
  DMA_REG_8(DMA_REG_CTR) = 0xf0;  // 中断标志位拉低 1111_0000
}

int main(int argc, char **argv) {
  set_csr(mie, MIP_MEIP);
  set_csr(mstatus, MSTATUS_MIE);

  dma_init();
  dma_config(0x20000000, 0x30000000, 0x00000080);
  dma_start();
  dma_interrupt();
  return 0;
}