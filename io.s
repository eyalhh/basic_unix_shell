.section .text
.globl print
.globl read
.align 16

print:
    pushq %rbp
    movq %rsp, %rbp
    mov $1, %rax # write syscall
    # length of buffer stored in rsi
    movq %rsi, %rdx
    # char* buffer stored in rdi
    movq %rdi, %rsi
    mov $1, %rdi # file descriptor of stdout
    syscall
    movq %rbp, %rsp
    popq %rbp
    ret

read:
    pushq %rbp
    movq %rsp, %rbp
    # size of buffer is at rsi
    movq %rsi, %rdx
    # buffer pointer is at rdi
    movq %rdi, %rsi
    # file descriptor of 0 (stdin)
    movq $0, %rdi
    # syscall read
    movq $0, %rax
    syscall
    movq %rbp, %rsp
    popq %rbp
    ret
