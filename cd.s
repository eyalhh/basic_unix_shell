.section .rodata
    no_file_or_directory_error: .string "Error: No such file or directory\n"
    out_of_memory_error: .string "Error: Out of memory\n"
    permission_denied_error .string "Error: Permission denied\n"
    bad_address_error: .string "Error: Bad address\n"
    not_a_directory_error: .string "Error: Not a directory\n"
.section .text
.align 16
cd:
    pushq %rbp
    movq %rsp, %rbp
    ; pointer to string is in %rdi
    mov $80, %rax
    syscall
    testq $rax, %rax
    jns success
    neg %rax ; negative error code stored in %rax
    cmp $2, %rax
    lea no_file_or_directory_error(%rip), %rsi
    je handle_error
    cmp $12, %rax ; errorcode for out of memory
    lea out_of_memory_error(%rip), %rsi
    je handle_error
    cmp $13, %rax
    lea permission_denied_error(%rip), %rsi
    je handle_error
    cmp $14, %rax
    lea bad_address_error(%rip), %rsi
    je handle_error
    cmp $20, %rax
    lea not_a_directory_error(%rip), %rsi
    je handle_error
    jmp success



handle_error:
    mov $1, %rax ; write syscall
    mov $2, %rdi ; write to stderr the error
    ; error string stored in %rsi
    mov $33, %rdx
    syscall
    movq %rbp, %rsp
    popq %rbp
    ret

success:
    movq %rbp, %rsp
    popq %rbp
    ret