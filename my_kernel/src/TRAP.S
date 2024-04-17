.section .text
.global  _TRAP

_TRAP:
SYS_CALL:
    li   t0  , 0x01
    beq  a0  , t0, SYS_PRINT # print

SYS_PRINT: # id : 1
    csrr t0  , sepc
    addi t0  , t0, 4
    csrw sepc, t0
    mv   a0  , a1
    call UART_PUTS
    sret

    