.section .rodata
    eyal: .string "eyal\0"
.section .text
.align 16
.globl compare
.globl args_count
.globl concatenate
compare:
    pushq %rbp
    movq %rsp, %rbp
    xorq %r12, %r12
    # pointer to str1 in rdi
    # pointer to str2 in rsi
    call length
    # rax gets length of str1
    movq %rax, %r14
    pushq %rdi
    movq %rsi, %rdi
    call length
    movq %rax, %r15
    cmpq %r14, %r15
    popq %rdi
    jne not_equal

loop:
    cmp %r12, %r14
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
length:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rdi
    # char* str stored in rdi - count until \0
    xorq %rax, %rax
loop__:
    cmpb $0, (%rdi)
    je return_from_length
    incq %rax
    incq %rdi
    jmp loop__
return_from_length:
    popq %rdi
    movq %rbp, %rsp
    popq %rbp
    ret
concatenate:
    pushq %rbp
    movq %rsp, %rbp
    # str1 at rdi
    # str2 at rsi
    # stoer pointer to rdi+rsi in rdx
    pushq %rdi
    pushq %rsi
loop___:
    cmpb $0, (%rdi)
    je reach_end_of_str1
    movb (%rdi), %bl
    movb %bl, (%rdx)
    incq %rdx
    incq %rdi
    jmp loop___
reach_end_of_str1:
    movb (%rsi), %bl
    movb %bl, (%rdx)
    cmpb $0, %bl
    je reach_end_of_str2
    incq %rsi
    incq %rdx
    jmp reach_end_of_str1
reach_end_of_str2:
    popq %rsi
    popq %rdi
    movq %rbp, %rsp
    popq %rbp
    ret

