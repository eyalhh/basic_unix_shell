.section .rodata
    no_file_or_directory_error: .string "Error: No such file or directory\n"
    out_of_memory_error: .string "Error: Out of memory\n"
    permission_denied_error: .string "Error: Permission denied\n"
    bad_address_error: .string "Error: Bad address\n"
    not_a_directory_error: .string "Error: Not a directory\n"
.section .text
.align 16
.globl cd_builtin
.globl exit_builtin
.globl error_handler
cd_builtin:
    pushq %rbp
    movq %rsp, %rbp
    # pointer to string is in %rdi
    mov $80, %rax
    syscall
    testq %rax, %rax
    jns success
    call error_handler
    movq %rbp, %rsp
    popq %rbp
    ret
error_handler:
    pushq %rbp
    movq %rsp, %rbp
    neg %rax # negative error code stored in %rax
    cmp $2, %rax
    lea no_file_or_directory_error(%rip), %rsi
    mov $33, %rdx
    je handle_error
    cmp $12, %rax
    lea out_of_memory_error(%rip), %rsi
    mov $21, %rdx
    je handle_error
    cmp $13, %rax
    lea permission_denied_error(%rip), %rsi
    mov $26, %rdx
    je handle_error
    cmp $14, %rax
    lea bad_address_error(%rip), %rsi
    mov $19, %rdx
    je handle_error
    cmp $20, %rax
    lea not_a_directory_error(%rip), %rsi
    mov $23, %rdx
    je handle_error
    jmp success



handle_error:
    mov $1, %rax # write syscall
    mov $2, %rdi # write to stderr the error
    # error string stored in %rsi
    # length of error string stored in $rdx
    syscall
    movq %rbp, %rsp
    popq %rbp
    ret

success:
    movq %rbp, %rsp
    popq %rbp
    ret
exit_builtin:
    # gets status code in rdi
    mov $60, %rax
    movq %rdi, %rbx
    syscall
