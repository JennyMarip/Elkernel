#include "platform.h"

.section .text
.global  UART_PUTS

UART_PUTS:
    # call context : a0, a1, t0, t1, t2
    addi sp,    sp, -20
    sw   a0,  0(sp)
    sw   a1,  4(sp)
    sw   t0,  8(sp)
    sw   t1, 12(sp)
    sw   t2, 16(sp) # save call context

    mv   t0,    a0
    la   a0,  UART0
loop:
    lb   t1,  0(t0)
    beqz t1,  done

wait:
    la   a0,  LSR
    lb   t2,  0(a0)
    andi t2,    t2, (1 << 5)
    beqz t2,  wait
    
    la   a0,  UART0
    sb   t1,  0(a0)
    addi t0,    t0, 1
    j    loop
done:
    lw   a0,  0(sp)
    lw   a1,  4(sp)
    lw   t0,  8(sp)
    lw   t1, 12(sp)
    lw   t2, 16(sp)
    addi sp,    sp, 20 # recover call context
    ret


