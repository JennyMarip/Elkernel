#ifndef __OS_H__
#define __OS_H__

// Memory Layout
#define KERNEL_BASE_ADD 0x80200000L
#define SHELL_KSTACK    0x80210000L // 8 KB down 
#define SHELL_TCB       0x80210000L //      up
#define APP_BASE_ADD    0x80300000L

// STRING
#define _HELLO_WORLD    0x802011f0L
#define _PROMPT         0x80201200L

// BUFFER
#define SHELL_BUFFER    0x80201210L

// File System
// shell
#define SHELL_FS_ADD    0x80000228L
#define SHELL_LEN             0x68L

#endif