.section .text
.global  _TRAP

_TRAP:
SYS_CALL:
    # trap context : a0, a1, t0, t1
    addi sp  , sp, -16
    sw   a0  ,  0(sp)
    sw   a1  ,  4(sp)
    sw   t0  ,  8(sp)
    sw   t1  , 12(sp)    # save trap context

    li   t0  ,  0x01
    beq  a0  ,  t0, SYS_PRINT

SYS_PRINT:               # id : 1
    mv   a0  , a1
    call UART_PUTS

    csrr t0  , sepc
    addi t0  , t0, 4
    csrw sepc, t0        # set ret pc

    lw   a0  ,  0(sp)
    lw   a1  ,  4(sp)
    lw   t0  ,  8(sp)
    lw   t1  , 12(sp)
    addi sp  , sp,  16   # recover trap context
    sret

    