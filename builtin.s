.section .rodata
    operation_not_permitted_error: .string "Error: Operation not permitted\n"
    no_file_or_directory_error: .string "Error: No such file or directory\n"
    argument_list_too_long_error: .string "Error: Argument list too long\n"
    exec_format_error: .string "Error: Exec format error\n"
    out_of_memory_error: .string "Error: Out of memory\n"
    permission_denied_error: .string "Error: Permission denied\n"
    bad_address_error: .string "Error: Bad address\n"
    not_a_directory_error: .string "Error: Not a directory\n"
    invalid_argument_error: .string "Error: Invalid argument\n"

.section .text
.align 16
.globl cd_builtin
.globl exit_builtin
.globl error_handler
.extern length

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
    cmp $1, %rax
    lea operation_not_permitted_error(%rip), %rsi
    mov $31, %rdx
    je handle_error
    cmp $2, %rax
    lea no_file_or_directory_error(%rip), %rsi
    mov $33, %rdx
    je handle_error
    cmp $7, %rax
    lea argument_list_too_long_error(%rip), %rsi
    mov $30, %rdx
    je handle_error
    cmp $8, %rax
    lea exec_format_error(%rip), %rsi
    mov $24, %rdx
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
    cmp $22, %rax
    lea invalid_argument_error(%rip), %rsi
    mov $24, %rdx
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
    pushq %rbp
    movq %rsp, %rbp
    # gets status code in rdi -> pointer to a string with this value
    call length
    movq %rax, %r12
    xorq %rbx, %rbx
    mov $1, %rax
    mov $0, %r10
    mov $10, %r14
    xorq %r11, %r11

get_to_end:
    cmpb $0, (%rdi)
    je reached_end_of_status_code
    incq %rdi
    jmp get_to_end

reached_end_of_status_code:
    cmpq %r10, %r12
    je got_number
    lea -1(%r12), %r9
    cmpq %r9, %r10
    je check_for_minus
return_from_checking:
    pushq %rax
    decq %rdi
    movb (%rdi), %bl
    subb $48, %bl
    # now in bl we have the actually digit
    mulq %rbx
    # result stored in rax
    addq %rax, %r11
    # we would now return to original value of rax
    popq %rax
    mulq %r14
    incq %r10
    jmp reached_end_of_status_code

got_number:
    # number is at accumulator r11
    mov $60, %rax
    movq %r11, %rdi
    syscall

check_for_minus:
    decq %rdi
    cmpb $45, (%rdi)
    je found_minus
    incq %rdi
    jmp return_from_checking

found_minus:
    neg %r11
    jmp got_number
