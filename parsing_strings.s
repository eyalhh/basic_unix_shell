.section .text
.align 16
.globl compare
.globl concatenate
.globl trim
.globl length

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
    # now with the second string
    call length
    # rax gets length of str2
    movq %rax, %r13
    cmpq %r14, %r13
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
    # store pointer to rdi+rsi in rdx
    pushq %rdi
    pushq %rsi
    pushq %rdx

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
    popq %rdx
    popq %rsi
    popq %rdi
    movq %rbp, %rsp
    popq %rbp
    ret

trim:
    # char* str is passed on rdi
    pushq %rbp
    movq %rsp, %rbp
    pushq %rdi

loop____:
    cmpb $10, (%rdi)
    je reached_end_of_str
    incq %rdi
    jmp loop____

reached_end_of_str:
    decq %rdi
    cmpb $32, (%rdi)
    jne return_from_trim
    movb $10, (%rdi)
    jmp reached_end_of_str

return_from_trim:
    popq %rdi
    movq %rbp, %rsp
    popq %rbp
    ret
