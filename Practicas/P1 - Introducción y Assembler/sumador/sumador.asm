%define SYS_EXIT 60

extern print_uint64

section	.data

section	.text
	global _start

_start:                

    xor rbx, rbx
    mov rbx, -100
    xor rcx, rcx
    mov rcx, 100

    add rcx, rbx 

_tmp:
    xor rdi, rdi

    mov dil, cl
    call print_uint64

    mov	eax, 1	    
	int	0x80 

_end:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
    