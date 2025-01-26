.section .text
.align 16
compare:
    pushq %rbp
    movq %rsp, %rbp
    xorq %r12, %r12
    // pointer to str1 in rdi
    // pointer to str2 in rsi
    // length of str1,str2 in rdx
loop:
    cmp %r12, %rdx
    je equal
    movzbq (%rdi, %r12), %r10
    movzbq (%rsi, %r12), %r11
    cmpq %r10, %r11
    jne not_equal
    incq %r12
    jmp loop
not_equal:
    mov $0, %rax
    movq %rbp, %rsp
    popq %rbp
    ret
equal:
    mov $1, %rax
    movq %rbp, %rsp
    popq %rbp
    ret
