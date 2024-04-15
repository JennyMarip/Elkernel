#ifndef __PLATFORM_H__
#define __PLATFORM_H__

// UART
#define UART0           0x10000000L
#define IER             0x10000001L
#define LCR             0x10000003L
#define DLL             0x10000000L
#define DLM             0x10000001L

// PLIC
#define UART_PRIORITY   0x0c000028L
#define UART_MENABLE    0x0c002000L
#define UART_MTHRESHOLD 0x0c200000L
#define UART_CLAIM      0x0c200004L
#define UART_COMPLETE   0x0c200004L

// TIMER
#define MTIME_CMP       0x2004000L

#endif