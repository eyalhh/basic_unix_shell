.section .rodata
    prompt: .string "myshell> "
    new_line: .string "\n"
.section .text
.align 16
.globl main
.extern cd
.extern compare
main:
    pushq %rbp
    movq %rsp, %rbp
    xorq %rcx, %rcx
    subq $1024, %rsp # create memory for buffer
start_loop:
    lea prompt(%rip), %rdi
    mov $9, %rsi
    call print
    movq %rsp, %r12
    # read gets buffer in rdi, size in rsi
    movq %r12, %rdi
    mov $1024, %rsi
    call read
    jmp start_loop

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
exit_program:
    mov $60, %rax
    mov $0, %rbx
    syscall
