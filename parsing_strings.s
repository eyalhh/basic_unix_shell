.section .text
.align 16
.globl compare
.globl args_count
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
args_count:
    pushq %rbp
    movq %rsp, %rbp
    xorq %rax, %rax
_loop:
    # buffer is stored in rdi
    movb (%rdi), %bl
    cmp $0x20, %bl
    je increment_rax
    cmp $0xA, %bl
    je return_from_count_args
    incq %rdi
    jmp _loop
increment_rax:
    incq %rax
    incq %rdi
    jmp _loop
return_from_count_args:
    movq %rbp, %rsp
    popq %rbp
    ret
