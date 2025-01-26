.section .text
.globl main
main:

exit_program:
    mov $60, %rax
    mov $0, %rbx
    syscall
