global templosClasicos
global cuantosTemplosClasicos

extern malloc

section .rodata

%define temploOffsetLargo   0
%define temploOffsetNombre  8
%define temploOffsetCorto  16

%define temploSize 24

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; rdi -> temploArr,     rsi -> temploArr_len
templosClasicos:
    push rbp
    mov rbp, rsp

    push r12
    push r13

    mov r12, rdi   ; Preservo datos
    mov r13, rsi

    call cuantosTemplosClasicos

    xor r10, r10
    add r10, temploSize 
    mul r10   ; Rax -> cant templos clasicos * tamaño cada templo (24)
    mov rdi, rax
    call malloc
    mov r11, rax
    ; r11 -> puntero al array de templos clasicos

    mov rdi, r12  ; Restauro datos
    mov rsi, r13

    .loop:
        cmp rsi, 0
        je .end

        xor r8, r8
        xor r9, r9

        mov r8b, [rdi + temploOffsetCorto] ; r8 = N -> Lado corto
        mov r9b, [rdi + temploOffsetLargo] ; r9 = M -> Lado largo

        shl r8, 1  ; r8 -> 2*n
        inc r8     ; r8 -> 2*n + 1

        cmp r8, r9   
        jne .siguiente  ; Si no son iguales

        mov r10, [rdi + temploOffsetLargo]
        mov [r11 + temploOffsetLargo], r10

        mov r10, [rdi + temploOffsetNombre]
        mov [r11 + temploOffsetNombre], r10

        mov r10, [rdi + temploOffsetCorto]
        mov [r11 + temploOffsetCorto], r10        

        add r11, temploSize

        .siguiente:
            add rdi, temploSize
            dec rsi
            jmp .loop


    .end:
        pop r13
        pop r12

        pop rbp
        ret

; rdi -> temploArr,     rsi -> temploArr_len
cuantosTemplosClasicos:
    push rbp
    mov rbp, rsp

    xor rax, rax   ; Contador en 0

    .loop:
        cmp rsi, 0
        je .end

        xor r8, r8
        xor r9, r9

        mov r8b, [rdi + temploOffsetCorto] ; r8 = N -> Lado corto
        mov r9b, [rdi + temploOffsetLargo] ; r9 = M -> Lado largo

        shl r8, 1  ; r8 -> 2*n
        inc r8     ; r8 -> 2*n + 1

        cmp r8, r9   
        jne .siguiente  ; Si no son iguales

        inc rax   ; +1 templo clasico

        .siguiente:
            add rdi, temploSize
            dec rsi
            jmp .loop

    .end:
        pop rbp
        ret

