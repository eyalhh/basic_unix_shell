.section .rodata
    binary_command_file: .string "/bin/"
    prompt: .string "myshell> "
    new_line: .string "\n"
    cd_command: .string "cd"
    exit_command: .string "exit"

.section .bss
    binary_file: .space 1024
    buffer: .space 1024
    argv: .space 8200

.section .text
.align 16
.globl main
.extern cd_builtin
.extern compare
.extern exit_builtin
.extern parse_the_arguments
.extern concatenate
.extern trim
.extern error_handler
.extern print
.extern read

main:
    pushq %rbp
    movq %rsp, %rbp
    xorq %rcx, %rcx

start_loop:
    lea prompt(%rip), %rdi
    mov $9, %rsi
    call print
    leaq buffer(%rip), %rdi
    mov $1024, %rsi
    call read
    leaq buffer(%rip), %rdi

parse_the_arguments:
    pushq %rbp
    movq %rsp, %rbp
    incq %rax
    xorq %rdi, %rdi
    xorq %rsi, %rsi
    xorq %rdx, %rdx
    xorq %rcx, %rcx
    xorq %r8, %r8
    xorq %r9, %r9
    xorq %r13, %r13
    leaq buffer(%rip), %rdi
    leaq argv(%rip), %r15
    call trim

first_arg:
    cmpb $0, (%rdi)
    jne assign_first
    incq %rdi
    jmp first_arg

assign_first:
    movq %rdi, (%r15)

_loop:
    cmpb $32, (%rdi)
    je found_space
    cmpb $10, (%rdi)
    je found_new_line

return_to:
    incq %rdi
    jmp _loop

found_space:
    movb $0, (%rdi) # set the space to be null char , so that the string will be null terminated.
    incq %r13
    jmp set_argv

found_new_line:
    movb $0, (%rdi)
    incq %r13
    movq $0, (%r15, %r13,8)
    jmp execute_command

set_argv:
    lea 1(%rdi), %r14
    movq %r14, (%r15,%r13,8)
    jmp return_to

execute_command:
    leaq buffer(%rip), %rdi
    leaq argv(%rip), %rsi
    xorq %rdx, %rdx

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
    call cd_builtin
    jmp start_loop

dot:
    incq %rdi
    # if its a dot it can either be ./ or .. (to indicate cd ..)
    cmpb $47, (%rdi) # if its a slash
    je check_directory_after
    cmpb $46, (%rdi) # if its a dot
    jne execute_generic_command
    incq %rdi
    cmpb $0, (%rdi)
    jne execute_generic_command
    popq %rdx
    popq %rsi
    popq %rdi
    movq %rdi, %rsi
    call cd_builtin
    jmp start_loop

check_if_exit:
    popq %rdx
    popq %rsi
    popq %rdi
    pushq %rdi
    pushq %rsi
    pushq %rdx
    lea exit_command(%rip), %rsi
    call compare
    cmp $1, %rax
    je execute_exit
    jmp execute_generic_command

execute_cd:
    popq %rdx
    popq %rsi
    popq %rdi
    # now the directory to switch to is at **rsi
    pushq %rdi
    movq 8(%rsi), %rdi
    call cd_builtin
    popq %rdi
    jmp start_loop

execute_exit:
    popq %rdx
    popq %rsi
    popq %rdi
    movq 8(%rsi), %rdi
    call exit_builtin

execute_generic_command:
    popq %rdx
    popq %rsi
    popq %rdi
    # everything is stored as required, e.g name of command in rdi, the following args passed with the c calling convention.
    # we could just fork into a child process and then execve syscall and be done with it
    # we would need to store the full path of the command in rdi so:
    pushq %rsi
    pushq %rdx
    movq %rdi, %rsi
    leaq binary_file(%rip), %rdx
    leaq binary_command_file(%rip), %rdi
    call concatenate
    # concatenate stores the concatenated string in rdx
    movq %rdx, %rdi
    popq %rdx
    popq %rsi
    mov $57, %rax
    syscall # fork system call
    cmp $0, %rax
    je child_process

parent_process:
    movq %rax, %rdi
    mov $61, %rax # syscall for wait4
    xorq %rsi, %rsi
    syscall
    jmp start_loop

child_process:
    mov $59, %rax # syscall for execve
    syscall
    # handling errors
    call error_handler


