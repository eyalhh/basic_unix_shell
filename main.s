.section .rodata
    prompt: .string "myshell> "
.section .text
.align 16
.globl main
extern cd
extern compare
main:
    pushq %rbp
    movq %rsp, %rbp
    xorq %rcx, %rcx
start_loop:

print:
    pushq %rbp
    movq %rsp, %rbp
    mov $1, %rax ; write syscall
    mov $1, $rdi ; file descriptor of stdout
    ; char* buffer stored in rsi
    ; length of buffer stored in rdx
    syscall
    movq %rbp, %rsp
    popq %rbp
    ret
read:

exit_program:
    mov $60, %rax
    mov $0, %rbx
    syscall
