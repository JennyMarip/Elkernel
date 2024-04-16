#include "platform.h"

.section .text
.global  UART_PUTS

UART_PUTS:
    mv   t0, a0
    la   a0, UART0
loop:
    lb   t1, 0(t0)
    beqz t1, done

wait:
    la   a0, LSR
    lb   t2, 0(a0)
    andi t2, t2, (1 << 5)
    beqz t2, wait
    
    la   a0, UART0
    sb   t1, 0(a0)
    addi t0, t0, 1
    j    loop
done:
    ret


