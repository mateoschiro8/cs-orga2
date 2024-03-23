%define SYS_WRITE 1
%define SYS_EXIT 60

section .data
    msg db 'Luca LU:208/22, Feli LU:84/22, Mateo LU:657/22. Estamos de vuelta (somos recursantes)',0xa
    len equ $ - msg

section .text
    global _start
_start:
    mov rdx, len
    mov rsi, msg
    mov rdi, 1
    mov rax, SYS_WRITE
    syscall
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall