#include "platform.h"
#include "os.h"

.section .text
.global  _start
.global  sys_print

_start:
    # kernel (S mode)
_scsr_set:
    la   t0     , _TRAP
    csrw stvec  , t0
    la   t0     , APP_BASE_ADD
    csrw sepc   , t0
    li   t0     , (1 << 5) | (1 << 1) | 1
    csrw sstatus, t0
    li   t0     , (1 << 1) | (1 << 5) | (1 << 9)
    csrw sie    , t0
_load_shell:
    la   a0     , SHELL_FS_ADD
    la   a1     , APP_BASE_ADD
    li   t0     , SHELL_LEN
_loop:
    lb   t1     , 0(a0)
    sb   t1     , 0(a1)
    addi a0     , a0, 0x01
    addi a1     , a1, 0x01
    addi t0     , t0, -1
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
    # enter shell
    la   sp     , SHELL_KSTACK
    la   a0     , _THREAD_INIT
    call UART_PUTS
    la   a0     , KERNEL
    call UART_PUTS
    sret

# trap vector
_trap_entry:
    mv   t0, sp
    csrr t1, sscratch
    mv   sp, t1 # change stack (user -> kernel)

    addi sp, sp, -8
    sw   t0, 0(sp)
    sw   ra, 4(sp) # trap context

    csrr t0, scause
    srli t1, t0, 31
    beqz t1, _Exception

_Interrupt: # interrupt
    la   a0, KERNEL
    call sys_print
_end:
    j _end

_Exception: # exception
    csrr t0  , sepc
    addi t0  , t0, 4
    csrw sepc, t0
    sfence.vma
    mv   a0  , a1
    call sys_print    # trap handler

    lw   t0      , 0(sp)
    lw   ra      , 4(sp)
    addi sp      , sp, 8
    csrw sscratch, sp
    mv   sp      , t0 # change stack (kernel -> user)
    sret

# user mode app
_app0:
    li t0, 200000000 # delay
_app0_loop:
    addi t0, t0, -1
    beqz t0, app0_print
    j    _app0_loop
app0_print:
    la   a0, KERNEL
    addi a0, a0, 32
    call _print
    j    _app0

_app1:
    li t0, 200000000 # delay
_app1_loop:
    addi t0, t0, -1
    beqz t0, app1_print
    j    _app1_loop
app1_print:
    la   a0, KERNEL
    addi a0, a0, 64
    call _print
    j    _app1

# user lib func(@para1 : str addr in a0)
_print:
    addi sp, sp, -8
    sw   a0, 0(sp)
    sw   a1, 4(sp)

    mv a1, a0
    li a0, 1
    ecall

    lw   a0, 0(sp)
    lw   a1, 4(sp)
    addi sp, sp, 8
    ret

# ---打印字符串函数 (id : 1)---
sys_print:
    addi sp, sp, -12
    sw   t0, 0(sp)
    sw   t1, 4(sp)
    sw   a0, 8(sp)

    mv t0, a0
    la a0, UART0   # uart base address
loop:
    lb   t1, 0(t0)    # 读取字符串中的一个字符
    beqz t1, done     # 如果字符为0，则跳转到结束
    sb   t1, 0(a0)    # 输出字符到串口
    addi t0, t0, 1    # 增加字符串地址
    j    loop         # 继续打印下一个字符
done:
    lw   a0, 8(sp)    # 恢复 a0 寄存器的值
    lw   t1, 4(sp)    # 恢复 t1 寄存器的值
    lw   t0, 0(sp)    # 恢复 t0 寄存器的值
    addi sp, sp, 12   # 释放栈空间
    li   a0, 0
    ret

.section .data
KERNEL:
    .align 4
    .asciz "Welcome to Elkernel!"