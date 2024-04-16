.section .text
.global  _TRAP

_TRAP:
    csrr t0  , sepc
    addi t0  , t0, 4
    csrw sepc, t0
    call UART_PUTS
    sret

    