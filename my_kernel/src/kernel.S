#include "platform.h"
#include "os.h"

.section .text
.global  _start
.global  sys_print

_start:
    # kernel (S mode)
    la   a0   , KERNEL
    call UART_PUTS
_scsr_set:
    la   t0     , _TRAP
    csrw stvec  , t0
    la   t0     , _SHELL
    csrw sepc   , t0
    li   t0     , (1 << 5) | (1 << 1) | 1
    csrw sstatus, t0
    li   t0     , (1 << 1) | (1 << 5) | (1 << 9)
    csrw sie    , t0
_task_init:
    # set task control block (pc, sp, a0, t0)
    li t0, 0x80308000
    li t1, 0
    la t2, _app0 # app1
    sw t2, 0(t0)
    la t2, 0x80300000
    sw t2,  4(t0)
    sw t1,  8(t0)
    sw t1, 12(t0)
    la t2, _app1 # app2
    sw t2, 16(t0)
    la t2, 0x80304000
    sw t2, 20(t0)
    sw t1, 24(t0)
    sw t1, 28(t0)

    li   sp      , 0x80300000 # app0 user stack (8kb)
    li   t0      , 0x80302000
    csrw sscratch, t0         # app0 kernel stack (8kb)
    # app1 user stack : 0x80304000; app1 kernel stack : 0x80306000
_enter_U:
    li   t4     , 0 # task flag (app0 : 0; app1 : 1)
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
    .asciz "Welcome to Elkernel!\n"
PROMPT:
    .align 4
    .asciz "$ "