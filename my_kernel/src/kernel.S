#include "platform.h"
#include "os.h"

.section .text
.global  _start

_start:
    # kernel (S mode)
_scsr_set:
    la   t0     , _TRAP
    csrw stvec  ,    t0
    la   t0     , APP_BASE_ADD
    csrw sepc   ,    t0
    li   t0     , (1 << 5) | (1 << 1) | 1
    csrw sstatus,    t0
    li   t0     , (1 << 1) | (1 << 5) | (1 << 9)
    csrw sie    ,    t0
_load_shell:
    la   a0     , SHELL_FS_ADD
    la   a1     , APP_BASE_ADD
    li   t0     , SHELL_LEN
_loop:
    lb   t1     ,  0(a0)
    sb   t1     ,  0(a1)
    addi a0     ,    a0, 0x01
    addi a1     ,    a1, 0x01
    addi t0     ,    t0, -1
    beqz t0     , _init_thread
    j    _loop # load shell byte by byte
_init_thread:
    # shell init
    la   a0     , SHELL_TCB
    li   a1     ,  0x00
    sw   a1     ,  0(a0)
    sw   a1     ,  4(a0)
    sw   a1     ,  8(a0)
    sw   a1     , 12(a0)
    sw   a1     , 20(a0)
    la   a1     , SHELL_KSTACK
    sw   a1     , 16(a0)
    # hello init
    la   a0     , HELLO_TCB
    li   a1     ,  0x00
    sw   a1     ,  0(a0)
    sw   a1     ,  4(a0)
    sw   a1     ,  8(a0)
    sw   a1     , 12(a0)
    sw   a1     , 20(a0)
    la   a1     , HELLO_KSTACK
    sw   a1     , 16(a0)
    # fib10 init
    la   a0     , FIB10_TCB
    li   a1     ,  0x00
    sw   a1     ,  0(a0)
    sw   a1     ,  4(a0)
    sw   a1     ,  8(a0)
    sw   a1     , 12(a0)
    sw   a1     , 20(a0)
    la   a1     , FIB10_KSTACK
    sw   a1     , 16(a0)
    # enter shell
    la   sp     , SHELL_KSTACK
    la   a0     , _THREAD_INIT
    call UART_PUTS
    la   a0     , KERNEL
    call UART_PUTS
    sret

.section .data
KERNEL:
    .align 4
    .asciz "Welcome to Elkernel!"