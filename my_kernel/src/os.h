#ifndef __OS_H__
#define __OS_H__

// Memory Layout
#define KERNEL_BASE_ADD 0x80200000L
// STRING
#define _PROMPT         0x80201260L

// BUFFER
#define SHELL_BUFFER    0x80201270L

// File System
// shell
#define SHELL_FS_ADD    0x80200180L
#define SHELL_LEN             0x68L

#endif