.section .text
.global  _SHELL

_SHELL:
    la a0, 0x80201210
    ecall
_loop:
    j _loop