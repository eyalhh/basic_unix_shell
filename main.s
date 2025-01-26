.section .text
.globl main
extern cd
main:

exit_program:
    mov $60, %rax
    mov $0, %rbx
    syscall
