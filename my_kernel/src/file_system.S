#include "os.h"

.section .text
.global  _SHELL
.global  atom_loop

# program1 : shell
_SHELL:
    li   a0, 0x01
    la   a1, _PROMPT
    ecall         # $
atom_loop:
    la   a0, SHELL_BUFFER
    lb   t0, 0(a0)
    li   t1, 0x01
    beq  t0, t1, read_buffer
    j    atom_loop
# enter
read_buffer:
    la   a1, SHELL_BUFFER
    addi a1, a1, 1
    li   a0, 0x02 # call fork
    ecall
    
    la   a0, SHELL_BUFFER
flush_buffer:
    lb   t0, 0(a0)
    beqz t0, _SHELL
    li   t1, 0x00
    sb   t1, 0(a0)
    addi a0, a0, 0x01
    j    flush_buffer
# program2 : hello
_HELLO:
    li   a0, 0x01
    la   a1, _HELLO_WORLD
    ecall
    li   a0, 0x03
    ecall
