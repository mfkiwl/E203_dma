TARGET = dma
CFLAGS += -O2

BSP_BASE = ../../bsp

C_SRCS += dma.c
HEADERS += dma.c

include $(BSP_BASE)/$(BOARD)/env/common.mk
