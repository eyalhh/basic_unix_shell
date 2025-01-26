.section .rodata
    prompt: .string "myshell> "
    new_line: .string "\n"
    cd_command: .string "cd"
    exit_command: .string "exit"
.section .text
.align 16
.globl main
.extern cd_builtin
.extern compare
.extern exit_builtin
.extern args_count
.extern parse_the_arguments
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
    movq %r12, %rdi
    call args_count
    call parse_the_arguments
parse_the_arguments:
    pushq %rbp
    movq %rsp, %rbp
    incq %rax
    cmp $6, %rax
    jg ready_the_stack
stack_ready:
    xorq %rdi, %rdi
    xorq %rsi, %rsi
    xorq %rdx, %rdx
    xorq %rcx, %rcx
    xorq %r8, %r8
    xorq %r9, %r9
    xorq %r13, %r13
    incq %r13
    movq %r12, %rdi
_loop:
    cmpb $32, (%r12)
    je found_space
    cmpb $10, (%r12)
    je found_new_line
return_to:
    incq %r12
    jmp _loop
found_space:
    movb $0, (%r12) # set the space to be null char , so that the string will be null terminated.
    incq %r13
    cmp $2, %r13
    je second_argument
    cmp $3, %r13
    je third_argument
    cmp $4, %r13
    je forth_argument
    cmp $5, %r13
    je fifth_argument
    cmp $6, %r13
    je sixth_argument
    jmp insert_to_stack_inverse
ready_the_stack:
    xorq %r15, %r15
    pushq $0 # load the envp into stack
    sub $6, %rax
    lea (%r15,%rax,8), %rax
    subq %rax, %rsp
    jmp stack_ready
second_argument:
    lea 1(%r12), %rsi
    jmp return_to
third_argument:
    lea 1(%r12), %rdx
    jmp return_to
forth_argument:
    lea 1(%r12), %rcx
    jmp return_to
fifth_argument:
    lea 1(%r12), %r8
    jmp return_to
sixth_argument:
    lea 1(%r12), %r9
    jmp return_to
insert_to_stack_inverse:
    lea 1(%r12), %r14
    lea -7(%r13), %r15
    movq %r14, (%rsp, %r15,8)
    jmp return_to
found_new_line:
    movb $0, (%r12)
execute_command:
    # rdi already stores the command name
check_if_cd:
    pushq %rdi
    pushq %rsi
    pushq %rdx
    leaq cd_command(%rip), %rsi
    call compare
    cmp $1, %rax
    je execute_cd
    # check edge cases - implicit cd command using ./ or /
check_slash:
    cmpb $47, (%rdi)
    je check_directory_after
    cmpb $46, (%rdi)
    je dot
    jmp check_if_exit
check_directory_after:
    incq %rdi
    cmpb $0, (%rdi)
    je check_if_exit
    movq %rdi, %rsi
    jmp execute_cd
dot:
    incq %rdi
    jmp check_slash
check_if_exit:
    lea exit_command(%rip), %rsi
    call compare
    cmp $1, %rax
    je execute_exit
    jmp execute_generic_command
execute_cd:
    popq %rdi
    popq %rdi
    popq %rdi
    # now the directory to switch to is at rsi
    pushq %rdi
    movq %rsi, %rdi
    call cd_builtin
    popq %rdi
    jmp start_loop
execute_exit:
    popq %rdx
    popq %rsi
    popq %rdi
    # now the status code is at rsi
    pushq %rdi
    movq %rsi, %rdi
    call exit_builtin
execute_generic_command:
    popq %rdx
    popq %rsi
    popq %rdi
    call exit
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
