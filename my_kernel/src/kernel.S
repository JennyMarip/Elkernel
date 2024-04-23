#include "platform.h"
#include "os.h"

.section .text
.global  _start

_start:
    # kernel (S mode)
    la   sp     , KERNEL_STACK
_PageTable_set:
    la   t0     , SPTBR
    li   t1     , (1 << 11)
    add  t0     , t0, t1 
    li   a0     , (0x80241 << 10) | (0x01)
    sw   a0     , 0(t0) # SEC1
    la   t0     , SPTBR
    li   t1     , (1 << 8)
    add  t0     , t0, t1
    li   a0     , (0x80242 << 10) | (0x01)
    sw   a0     , 0(t0) # SEC2
    la   t0     , SEC1
    li   t1     , (0x200 << 2)
    add  t0     , t0, t1
    li   a0     , (0x80200 << 10) | (0x0f)
    sw   a0     , 0(t0) # 0x80200
    la   t0     , SEC1
    li   t1     , (0x1ff << 2)
    add  t0     , t0, t1
    li   a0     , (0x801ff << 10) | (0x0f)
    sw   a0     , 0(t0) # 0x8020f
    la   t0     , SEC1
    li   t1     , (0x210 << 2)
    add  t0     , t0, t1
    li   a0     , (0x80210 << 10) | (0x0f)
    sw   a0     , 0(t0) # 0x80210
    la   t0     , SEC1
    li   t1     , (0x220 << 2)
    add  t0     , t0, t1
    li   a0     , (0x80220 << 10) | (0x0f)
    sw   a0     , 0(t0) # 0x80220
    la   t0     , SEC1
    li   t1     , (0x230 << 2)
    add  t0     , t0, t1
    li   a0     , (0x80230 << 10) | (0x0f)
    sw   a0     , 0(t0) # 0x80230
    la   t0     , SEC1
    li   t1     , (0x300 << 2)
    add  t0     , t0, t1
    li   a0     , (0x80300 << 10) | (0x0f)
    sw   a0     , 0(t0) # 0x80300
    la   t0     , SEC1
    li   t1     , (0x01 << 2)
    add  t0     , t0, t1
    li   a0     , (0x80001 << 10) | (0x0f)
    sw   a0     , 0(t0) # 0x80001
    la   t0     , SEC1
    li   t1     , 0x00
    add  t0     , t0, t1
    li   a0     , (0x80000 << 10) | (0x0f)
    sw   a0     , 0(t0) # 0x80000
    la   t0     , SEC2
    li   t1     , 0x00
    add  t0     , t0, t1
    li   a0     , (0x10000 << 10) | (0x0f)
    sw   a0     , 0(t0) # 0x10000

_scsr_set:
    la   t0     , _TRAP
    csrw stvec  ,    t0
    la   t0     , APP_BASE_ADD
    csrw sepc   ,    t0
    li   t0     , (1 << 11) | (1 << 5) | (1 << 1) | 1
    csrw sstatus,    t0
    li   t0     , (1 << 1) | (1 << 5) | (1 << 9)
    csrw sie    ,    t0
    li   t0     , (1 << 31) | 0x80240
    csrw satp   ,    t0 # Sv32
    la   a0     ,  _HELLO_STR
    call UART_PUTS
    li   a0     , 0x01 # test

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