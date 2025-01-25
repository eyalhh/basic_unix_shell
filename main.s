.section .text
.globl main
main:
    mov $60, %rax
    mov $1, %rbx
    syscall
