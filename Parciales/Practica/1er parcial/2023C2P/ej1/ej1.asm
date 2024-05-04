%define listOffsetPago 0
%define listOffsetNext 8

%define pagoOffsetMonto     0
%define pagoOffsetAprobado  1
%define pagoOffsetPagador   8
%define pagoOffsetCobrador 16

%define sizePagoSplitted  24

%define pagoSplittedOffsetCantAprobados     0
%define pagoSplittedOffsetCantRechazados    1
%define pagoSplittedOffsetPagosAprobados    8
%define pagoSplittedOffsetPagosRechazados  16

section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp

;########### SECCION DE TEXTO (PROGRAMA)

; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
; pList -> rdi,    usuario -> rsi
contar_pagos_aprobados_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15
 
    mov r14, rdi    ; r14 -> pList
    mov r15, rsi    ; r15 -> usuario

    xor r13, r13  ; Contador en 0

    mov r14, [r14]  ; Primer elemento de la lista

    .loop:
        cmp r14, 0  ; Veo si el puntero es nulo
        je .end

        mov r12, [r14 + listOffsetPago] ; Datos del pago

        mov rdi, [r12 + pagoOffsetCobrador] ; Cobrador del pago
        mov rsi, r15                        ; Usuario

        call strcmp

        cmp rax, 0   ; Si el usuario es el cobrador
        jne .siguiente

        mov al, byte [r12 + pagoOffsetAprobado]
        cmp al, 1    ; Si fue aprobado
        jne .siguiente

        inc r13  ; +1 pago aprobado

        .siguiente:
            mov r14, [r14 + listOffsetNext] ; Me meto en el siguiente pago
            jmp .loop

    .end:

        mov rax, r13  ; Devuelvo el resultado

        pop r15
        pop r14
        pop r13
        pop r12

        pop rbp
        ret

; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
; pList -> rdi,    usuario -> rsi
contar_pagos_rechazados_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15
 
    mov r14, rdi    ; r14 -> pList
    mov r15, rsi    ; r15 -> usuario

    xor r13, r13  ; Contador en 0

    mov r14, [r14]  ; Primer elemento de la lista

    .loop:
        cmp r14, 0  ; Veo si el puntero es nulo
        je .end

        mov r12, [r14 + listOffsetPago] ; Datos del pago

        mov rdi, [r12 + pagoOffsetCobrador] ; Cobrador del pago
        mov rsi, r15                        ; Usuario

        call strcmp
        
        cmp rax, 0   ; Si el usuario es el cobrador
        jne .siguiente

        mov al, byte [r12 + pagoOffsetAprobado]
        cmp al, 0    ; Si no fue aprobado
        jne .siguiente

        inc r13  ; +1 pago rechazado

        .siguiente:
            mov r14, [r14 + listOffsetNext] ; Me meto en el siguiente pago
            jmp .loop

    .end:

        mov rax, r13  ; Devuelvo el resultado 

        pop r15
        pop r14
        pop r13
        pop r12

        pop rbp
        ret

; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
; pList -> rdi,    usuario -> rsi
split_pagos_usuario_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8

    mov r14, rdi   ; Guardo valores
    mov r15, rsi

    call contar_pagos_aprobados_asm
    mov r12, rax   ; r12 -> cant pagos aprobados

    mov rdi, r14   ; Restauro valores
    mov rsi, r15

    call contar_pagos_rechazados_asm
    mov r13, rax   ; r13 -> cant pagos rechazados

    mov rdi, sizePagoSplitted   ; Memoria para el struct
    call malloc  
    mov rbx, rax ; rbx -> pagoSplitted  

    mov byte [rbx + pagoSplittedOffsetCantAprobados],  r12b
    mov byte [rbx + pagoSplittedOffsetCantRechazados], r13b

    ; Pido memoria para los pagos aprobados y rechazados
    ; Pagos aprobados
    shl r12, 3  ; Cantidad de pagos * tamaño de puntero (8)
    mov rdi, r12
    call malloc
    mov r12, rax  ; r12 -> pagos aprobados
    mov [rbx + pagoSplittedOffsetPagosAprobados], r12

    ; Pagos rechazadps
    shl r13, 3  ; Cantidad de pagos * tamaño de puntero
    mov rdi, r13
    call malloc
    mov r13, rax  ; r13 -> pagos rechazados
    mov [rbx + pagoSplittedOffsetPagosRechazados], r13

    add rsp, 8
    push rbx   ; Lo pusheo y alineo pila, después lo vuelvo a buscar

    mov r14, [r14]  ; Primer elemento de la lista

    .loop:
        cmp r14, 0  ; Veo si el puntero es nulo
        je .end

        mov rbx, [r14 + listOffsetPago] ; Datos del pago

        mov rdi, [rbx + pagoOffsetCobrador] ; Cobrador del pago
        mov rsi, r15                        ; Usuario

        call strcmp
        
        cmp rax, 0   ; Si el usuario es el cobrador
        jne .siguiente

        mov al, byte [rbx + pagoOffsetAprobado]
        cmp al, 1    ; Si no fue aprobado
        jne .noAprobado

        .aprobado:
            mov [r12], rbx   ; Agrego el pago y avanzo
            add r12, 8
            jmp .siguiente

        .noAprobado:
            mov [r13], rbx   ; Agrego el pago y avanzo
            add r13, 8
            
            .siguiente:
                mov r14, [r14 + listOffsetNext] ; Me meto en el siguiente pago
                jmp .loop


    .end:

        pop rax   ; Estaba rbp en el tope, lo guardo en rax para devolver

        pop rbx
        pop r15
        pop r14
        pop r13
        pop r12

        pop rbp
        ret
