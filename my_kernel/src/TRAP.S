#include "os.h"

.section .text
.global  _TRAP

_TRAP:
SYS_CALL:
    # trap context : a0, a1, t0, t1
    addi sp  , sp, -16
    sw   a0  ,  0(sp)
    sw   a1  ,  4(sp)
    sw   t0  ,  8(sp)
    sw   t1  , 12(sp)         # save trap context

    # trap vector table
    li   t0  ,   0x01
    beq  a0  ,     t0, SYS_PRINT
    li   t0  ,   0x02
    beq  a0  ,     t0, SYS_FORK
    li   t0  ,   0x03
    beq  a0  ,     t0, SYS_EXIT

# id : 1
SYS_PRINT:
    mv   a0  ,   a1
    call UART_PUTS
    j    _end
# id : 2
SYS_FORK:                     
    la   a0  ,   _HELLO_STR
    call _EQUAL
    beqz t0  ,   _b2
_b3:
    # hello
    la   a0  ,   HELLO_FS_ADD # load & run 
    la   a1  ,   APP_BASE_ADD
    addi a1  ,   a1, SHELL_LEN
    li   t0  ,   HELLO_LEN
_loop1:
    beqz t0  ,   end
    lb   t1  ,   0(a0)
    sb   t1  ,   0(a1)
    addi a0  ,     a0, 0x01
    addi a1  ,     a1, 0x01
    addi t0  ,     t0,   -1
    j    _loop1               # load hello
end:
    # task context : a0, a1, t0, t1, sp, sepc
    la   a2  ,   SHELL_TCB
    sw   a0  ,    0(a2)
    sw   a1  ,    4(a2)
    sw   t0  ,    8(a2)
    sw   t1  ,   12(a2)
    sw   sp  ,   16(a2)
    csrr a3  ,      sepc
    sw   a3  ,   20(a2)       # save task context
    la   a2  ,   HELLO_TCB
    lw   a0  ,    0(a2)
    lw   a1  ,    4(a2)
    lw   t0  ,    8(a2)
    lw   t1  ,   12(a2)
    lw   sp  ,   16(a2)       # recover task context
    
    la   a2  ,   APP_BASE_ADD
    addi a2  ,      a2, SHELL_LEN
    csrw sepc,      a2
    sret

_b2:
    mv   a0  ,   a1
    call UART_PUTS
    la   a0  ,   _NOT_FOUND
    call UART_PUTS
    j    _end

# id : 3
SYS_EXIT:
    lw   a0  ,  0(sp)
    lw   a1  ,  4(sp)
    lw   t0  ,  8(sp)
    lw   t1  , 12(sp)
    addi sp  ,    sp,  16     # recover stack

    la   a2  ,  HELLO_TCB
    sw   a0  ,  0(a2)
    sw   a1  ,  4(a2)
    sw   t0  ,  8(a2)
    sw   t1  , 12(a2)
    sw   sp  , 16(a2) 
    csrr a3  , sepc
    sw   a3  , 20(a2)        # save task context

    la   a2  ,  SHELL_TCB
    lw   a0  ,  0(a2)
    lw   a1  ,  4(a2)
    lw   t0  ,  8(a2)
    lw   t1  , 12(a2)
    lw   sp  , 16(a2)
    lw   a3  , 20(a2)
    csrw sepc,    a3        # recover task context (shell)
    j    _end

_end:
    csrr t0  ,  sepc
    addi t0  ,    t0,   4
    csrw sepc,    t0          # set ret pc

    lw   a0  ,  0(sp)
    lw   a1  ,  4(sp)
    lw   t0  ,  8(sp)
    lw   t1  , 12(sp)
    addi sp  ,    sp,  16     # recover trap context
    sret

# FUNC
# judge whether str1(a0) eqauls str2(a1)
# ret : t0 (1 : equal, 0 : not equal)
_EQUAL:
    addi sp  ,    sp, -24
    sw   a0  ,  0(sp)
    sw   a1  ,  4(sp)
    sw   a2  ,  8(sp)
    sw   a3  , 12(sp)
    sw   t0  , 16(sp)
    sw   t1  , 20(sp)       # call context

    mv   a2  , a0
    mv   a3  , a1
_loop2:
    lb   t0  , 0(a2)
    lb   t1  , 0(a3)
    beqz t0  ,  _b1
    addi a2  ,   a2,   0x01
    addi a3  ,   a3,   0x01
    beq  t0  ,   t1, _loop2
    j    _NOT
_b1:
    beqz t1  , _YES
_NOT:
    li   t0  , 0x00
    j    _RET
_YES:
    li   t0  , 0x01
    
_RET:
    lw   a0  ,  0(sp)
    lw   a1  ,  4(sp)
    lw   a2  ,  8(sp)
    lw   a3  , 12(sp)
    lw   t1  , 20(sp)
    addi sp  ,    sp, 24
    ret


    