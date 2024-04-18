#ifndef __OS_H__
#define __OS_H__

// Memory Layout
#define KERNEL_BASE_ADD 0x80200000L
#define KERNEL_STACK    0x80200000L // 8 KB down

#define SHELL_KSTACK    0x80210000L // 8 KB down 
#define SHELL_TCB       0x80210000L //      up

#define HELLO_KSTACK    0x80220000L // 8 KB down
#define HELLO_TCB       0x80220000L //      up

#define APP_BASE_ADD    0x80300000L

// STRING
#define _HELLO_STR      0x800013b0L
#define _HELLO_WORLD    0x800013c0L
#define _PROMPT         0x800013d0L

// BUFFER
#define SHELL_BUFFER    0x800013e0L

// File System
// shell
#define SHELL_FS_ADD    0x80000254L
#define SHELL_LEN             0x5cL
// hello
#define HELLO_FS_ADD    0x800002b0L
#define HELLO_LEN             0x10L

#endif