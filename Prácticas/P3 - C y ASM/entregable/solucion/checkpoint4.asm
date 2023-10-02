extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
    ;prologo
    push rbp
    mov rbp, rsp

    ; Setear rax en 0
    xor rax, rax ;=0

.loop:
    ; Chequear que ningun char sea null
    cmp byte [rdi], 0
    je .check_b

    cmp byte [rsi], 0
    je .check_a

    ; Cargo en al y en bl el char apuntado actualmente
    mov al, byte [rdi]
    mov bl, byte [rsi]
    
    ; Compara al y bl
    cmp al, bl
    
    ; Si son diferentes salto
    jne .not_equal

    ; Aumentar los punteros
    inc rdi
    inc rsi
    
    ; Vuelve a comparar
    jmp .loop

.not_equal:
    ; Se fija si a >= b
    jae .greater
    mov rax, 1
    jmp .end

.check_a:
    ; Si estamos acá, es porque b es nulo
    cmp byte [rdi], 0
    je .equal
    mov rax , -1
    jmp .end

.check_b:
    ; Si estamos acá, es porque a es nulo
    cmp byte [rsi], 0
    je .equal
    mov rax , 1
    jmp .end

.greater:
    ; Si a > b, salta a .greater
    mov rax, -1
    jmp .end

.equal:
    ; rax=0;
    xor rax, rax
    jmp .end

.end:
    pop rbp
    ret

; char* strClone(char* a)
strClone:
    ;prologo
    push rbp
    mov rbp, rsp

    ;inicializo contador en 0.
    xor r12,r12 

    ;Guardar el puntero al char en un registro temporal para calcular su size
    mov r13, rdi
    
    ; Chequear la cantidad de caracteres del string
.size:
    cmp byte [r13], 0
    je .continue

    ;Incrementar el contador de size
    inc r12

    ;Incrementar el puntero del char
    inc r13

    jmp .size

.continue:
    ; Reestablecer el valor del puntero temporal al inicio del string
    mov r13, rdi

    inc r12
    inc r12

    ; Mover el tamaño al registro de pasaje de parámetros y llamar a malloc
    mov rdi, r12
    call malloc
    
    ; Guardar la posición de inicio de la memoria reservada en el heap
    mov r14, rax

    ; Iniciar loop para copiar caracteres
    xor r15, r15

.copy:
    ; Mover a un registro temporal (de 8 bits) el valor actual del string
    mov dl, [r13 + r15]

    ; Copiar el carácter a la posición apuntada por r14 (memoria reservada en el heap por malloc)
    mov [r14 + r15], dl

    ; Incrementar el contador de posición
    inc r15

    ; Continuar copiando hasta que hayas copiado todos los caracteres
    cmp r15, r12
    jl .copy

.end3:
    mov byte [r14 + r15], '\0'
    pop rbp
    ret
    
; void strDelete(char* a)
strDelete:

    test rdi,rdi 
    jz .end2
    call free

.end2:
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	ret

; uint32_t strLen(char* a)
strLen:
    ;prologo
    push rbp
    mov rbp, rsp

    xor rax,rax

 .size2:   
    cmp byte [rdi], 0
    je .final

    ;Incrementar el contador de size
    inc rax

    ;Incrementar el puntero del char
    inc rdi

    jmp .size2

.final:
    pop rbp
	ret


