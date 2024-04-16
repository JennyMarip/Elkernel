#include "os.h"

.section .text
.global  _SHELL
.global  atom_loop

_SHELL:
    la a0, _PROMPT
    ecall  # $
atom_loop:

    li   t6, 10000
_loop:
    addi t6, t6, -1
    beqz t6, loop_end
    j    _loop
loop_end:

    la  a0, SHELL_BUFFER
    lb  t4, 0(a0)
    li  t5, 0x01
    beq t4, t5, read_buffer
    j   atom_loop
read_buffer:
    la   a0, SHELL_BUFFER
    addi a0, a0, 1
    ecall
    
    la   a0, SHELL_BUFFER
flush_buffer:
    lb   t4, 0(a0)
    beqz t4, _SHELL
    li   t5, 0x00
    sb   t5, 0(a0)
    addi a0, a0, 0x01
    j    flush_buffer