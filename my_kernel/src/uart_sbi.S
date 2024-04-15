#include "platform.h"

.section .text
.global UART_PUTS

UART_PUTS:
    mv t0, a0
    la a0, UART0
loop:
    lb t1, 0(t0)
    beqz t1, done
    sb t1, 0(a0)
    addi t0, t0,1
    j loop
done:
    ret


