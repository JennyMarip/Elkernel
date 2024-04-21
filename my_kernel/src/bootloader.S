#include "platform.h"
#include "os.h"

.section .text
.global  _start

_start:
    la   sp, KERNEL_STACK
    # bootloader (M mode)
    # info
    la   a0, TIME_INT
    addi a0, a0, 0x20
    call UART_PUTS
_uart_init:
    # w IER
    la   a0, IER
    li   t0, 0x00
    sw   t0, 0(a0)
    # r LCR
    la   a0, LCR
    lw   t0, 0(a0)
    # w LCR
    ori  t0, t0, (1 << 7)
    sw   t0, 0(a0)
    # w DLL
    la   a0, DLL
    li   t0, 0x03
    sw   t0, 0(a0)
    # w DLM
    la   a0, DLM
    li   t0, 0x00
    sw   t0, 0(a0)
    # w LCR
    li   t0, 0x00
    ori  t0, t0, (3 << 0)
    la   a0, LCR
    sw   t0, 0(a0)
    # w IER
    la   a0, IER
    lw   t0, 0(a0)
    ori  t0, t0, (1 << 0)
    sw   t0, 0(a0)
    # info
    la   a0, TIME_INT
    addi a0, a0, 0x40
    call UART_PUTS
_plic_init:
    la   a0, UART_PRIORITY
    li   t0, 0x01
    sw   t0, 0(a0) # set priority
    la   a0, UART_MENABLE
    li   t0, (1 << 10)
    sw   t0, 0(a0) # interrupt enable
    la   a0, UART_MTHRESHOLD
    li   t0, 0
    sw   t0, 0(a0)
    # info
    la   a0, TIME_INT
    addi a0, a0, 0x60
    call UART_PUTS
_mcsr_set:
    li   t0     , (1 << 11) | (1 << 7) | (1 << 3) | (1 << 1) | 1
    csrw mstatus, t0
    li   t0     , (1 << 11) | (1 << 7) | (1 << 3)
    csrw mie    , t0
    la   t0     , _Interrupt
    csrw mtvec  , t0
    la   t0     , KERNEL_BASE_ADD
    csrw mepc   , t0 # kernel entry
    li   t0     , (1 << 8)
    csrw medeleg, t0 # deleg exception to S

# timer_init:
#     li   a1     , 0x0
#     li   a0     , 50000000 # 1 second = 10 ^ 7
#     la   t0     , MTIME_CMP
#     li   t1     , -1
#     sw   t1     , 0(t0)
#     sw   a1     , 4(t0)
#     sw   a0     , 0(t0)

    mret

# interrupt vector (M)
_Interrupt:
# trap context : a0, a1, t0, t1
    addi sp, sp, -16
    sw   a0,  0(sp)
    sw   a1,  4(sp)
    sw   t0,  8(sp)
    sw   t1, 12(sp)  # save trap context
_claim:
    la   a0, UART_CLAIM
    lw   t0, 0(a0)   # claim
    beqz t0, _claim
_handler:
    la   a0, UART0
    lb   t1, 0(a0)
    li   t2, 0x0d
    beq  t1, t2, _enter 
    la   a0, UART0
    sb   t1, 0(a0)   # print
    la   a0, SHELL_BUFFER
add_loop:
    addi a0, a0, 0x01
    lb   t2, 0(a0)
    beqz t2, _b1
    j    add_loop
_b1:
    sb   t1, 0(a0)
    j    _complete
_enter:
    la   a0, SHELL_BUFFER
    li   t2, 1
    sb   t2, 0(a0)
    la   a0, TIME_INT
    lb   t2, 0(a0)
    la   a0, UART0
    sb   t2, 0(a0)   # enter & change line

_complete:
    la   a0, UART_COMPLETE
    sw   t0, 0(a0)   # complete

    la   a0, SHELL_BUFFER

    lw   a0,  0(sp)
    lw   a1,  4(sp)
    lw   t0,  8(sp)
    lw   t1, 12(sp)
    addi sp,  sp, 16 # recover trap context
    mret

    la   t5, 0x80308000
    beqz t4, _1_to_2

    # app1 to app0
    sw   t3, 16(t5)
    sw   sp, 20(t5)
    sw   a0, 24(t5)
    sw   t0, 28(t5)
    j    _set_timer
_1_to_2: # app0 to app1
    sw   t3,  0(t5)
    sw   sp,  4(t5)
    sw   a0,  8(t5)
    sw   t0, 12(t5)

_set_timer:
    # update mtimecmp a1:a0
    la   t0, MTIME_CMP
    li   a1, 0
    lw   a0, 0(t0)
    li   t2, 50000000
    add  a0, a0, t2
    li   t1, -1
    sw   t1, 0(t0)
    sw   a1, 4(t0)
    sw   a0, 0(t0)

    la   t0, TIME_INT
    la   a0, UART0
_loop:
    lb   t1, 0(t0)
    beqz t1, _end
    sb   t1, 0(a0)
    addi t0, t0, 1
    j    _loop

_end:
    beqz t4, _1_to_2_
    lw   t3, 0(t5)
    lw   sp, 4(t5)
    lw   a0, 8(t5)
    lw   t0, 12(t5)
    li   t4, 0
    j    _ret
_1_to_2_:
    lw   t3, 16(t5)
    lw   sp, 20(t5)
    lw   a0, 24(t5)
    lw   t0, 28(t5)
    li   t4, 1
_ret:
    csrw mepc, t3
    mret
    
.section .data
TIME_INT:
    .align 4
    .asciz "\ntimer interrupt!\n"
ELKERNEL:
    .align 4
    .asciz "Initializing Elkernel...\n"
UART_INIT:
    .align 4
    .asciz "***** Init Uart *****\n"
PLIC_INIT:
    .align 4
    .asciz "***** Init PLIC *****\n"
THREAD_INIT:
    .align 4
    .asciz "**** Init Thread ****\n"
NOT_FOUND:
    .align 4
    .asciz ": Command Not Found"
HELLO_:
    .align 4
    .asciz "hello"
HELLO:
    .align 4
    .asciz "Hello, world!"
PROMPT:
    .align 4
    .asciz "\n$ "

