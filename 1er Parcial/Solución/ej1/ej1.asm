section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp

%define offsetData              0
%define offsetNext              8
%define offsetPrev              16
%define offsetFirst             0
%define offsetLast              8
%define offsetMonto             0
%define offsetAprobado          1
%define offsetPagador           8
%define offsetCobrador          16
%define offsetCantAprobados     0
%define offsetCantRechazados    1
%define offsetPagosAprobados    8   
%define offsetPagosRechazados   16

;########### SECCION DE TEXTO (PROGRAMA)

;   typedef struct s_list
;   {
;       struct s_listElem *first;
;       struct s_listElem *last;
;   } list_t;

;   typedef struct s_listElem
;   {
;       pago_t *data;
;       struct s_listElem *next;
;       struct s_listElem *prev;
;   } listElem_t;

;   typedef struct
;   {
;       uint8_t monto;
;       uint8_t aprobado;
;       char *pagador;
;       char *cobrador;
;   } pago_t;

; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
;   pList   -> rdi
;   usuario -> rsi
contar_pagos_aprobados_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    ; Me traigo los punteros al inicio y al final
    mov r12, [rdi + offsetFirst]
    mov r13, [rdi + offsetLast]

    xor r14, r14

    mov r15, rsi

    .ciclo:
    
        ; Si el puntero es nulo (ya terminé), voy al final
        cmp r12, 0
        je .end

        ; Dentro de un pago, me fijo si el cobrador es el usuario
        mov r9, [r12 + offsetData]
        mov rdi, [r9 + offsetCobrador]
        mov rsi, r15
        call strcmp

        ; Si es el cobrador, me fijo si el pago está aprobado
        cmp rax, 0
        jne .finCiclo
            
        mov r9, [r12 + offsetData]    
        mov r8b, [r9 + offsetAprobado]

        cmp r8b, 1
        jne .finCiclo
        add r14, 1
            
        .finCiclo:

            ; Avanzo el puntero
            mov r12, [r12 + offsetNext]

            jmp .ciclo 

    .end:

        ; Muevo el resultado donde corresponde
        mov rax, r14

        pop r15
        pop r14
        pop r13
        pop r12

        pop rbp
        ret


; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
;   pList   -> rdi
;   usuario -> rsi
; Igual al de arriba, cambiando la condición de si el pago no está aprobado 
contar_pagos_rechazados_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    ; Me traigo los punteros al inicio y al final
    mov r12, [rdi + offsetFirst]
    mov r13, [rdi + offsetLast]

    xor r14, r14

    mov r15, rsi

    .ciclo:
    
        ; Si el puntero es nulo (ya terminé), voy al final
        cmp r12, 0
        je .end

        ; Dentro de un pago, me fijo si el cobrador es el usuario
        mov r9, [r12 + offsetData]
        mov rdi, [r9 + offsetCobrador]
        mov rsi, r15
        call strcmp

        ; Si es el cobrador, me fijo si el pago está desaprobado
        cmp rax, 0
        jne .finCiclo
            
        mov r9, [r12 + offsetData]    
        mov r8b, [r9 + offsetAprobado]

        cmp r8b, 0
        jne .finCiclo
        add r14, 1
            
        .finCiclo:

            ; Avanzo el puntero
            mov r12, [r12 + offsetNext]

            jmp .ciclo 

    .end:

        ; Muevo el resultado donde corresponde
        mov rax, r14

        pop r15
        pop r14
        pop r13
        pop r12

        pop rbp
        ret


; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
;   pList   -> rdi
;   usuario -> rsi

;   typedef struct
;   {
;       uint8_t cant_aprobados;
;       uint8_t cant_rechazados;
;       pago_t **aprobados;
;       pago_t **rechazados;
;   } pagoSplitted_t;

split_pagos_usuario_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15    
    push rbx
    sub rsp, 8

    mov r12, rdi
    mov r13, rsi

    ; Tengo que devolver un puntero a un struct pagoSplitted, que tiene tamaño de 24 bytes
    ; Pido esa memoria, así arranco a acomodar las cosas
    
    mov rdi, 24
    call malloc

    ; Y en rbx empiezo a armar todo
    mov rbx, rax

    ; Cuento la cantidad de pagos aprobados y desaprobados del usuario
    ; Que ocurrente tener esta función a mano que hace justo eso

    mov rdi, r12
    mov rsi, r13

    call contar_pagos_aprobados_asm

    mov r14, rax

    ; Guardo los aprobados en el struct
    mov [rbx + offsetCantAprobados], r14b

    mov rdi, r12
    mov rsi, r13

    call contar_pagos_rechazados_asm

    mov r15, rax

    ; Guardo los rechazados en el struct
    mov [rbx + offsetCantRechazados], r15b

    ; Tengo entonces en r14 la cantidad de pagos aprobados y en r15 la cantidad de rechazados

    ; Tengo que armar ahora los arreglos de los punteros a los pagos

    ; Meto r12 (rdi original -> list_t* pList) y r13 (rsi original -> char* usuario) en la pila 
    ; porque me quedé sin registros. Mas tarde los paso a buscar

    push r12
    push r13

    ; En r12 voy a meter el puntero a los pagos aprobados, y en r13 a los rechazados

    ; Pido las respectivas memorias con malloc. En r14 y r15 tengo las respectivos cantidades

    ; Memoria para aprobados
    shl r14, 3    ; Multiplico por 8 (cantidad de bytes = cantidad de pagos * tamaño de pago)
    mov rdi, r14
    call malloc
    mov r12, rax

    ; Memoria para rechazados
    shl r15, 3    ; Multiplico por 8 (cantidad de bytes = cantidad de pagos * tamaño de pago)
    mov rdi, r15
    call malloc
    mov r13, rax

    ; Y guardo los punteros en el struct
    mov [rbx + offsetPagosAprobados], r12
    mov [rbx + offsetPagosRechazados], r13

    ; Ahora tengo que loopear por todos los pagos, e ir agregando cada uno donde corresponda
    
    ; Recupero r12 (rdi original -> list_t* pList) y r13 (rsi original -> char* usuario)
    ; pero los guardo en r14 y r15

    pop r15  ; char* usuario
    pop r14  ; list_t* pList

    ; Me copio el ciclo de los pagos

    ; Me traigo el puntero al inicio
    mov r14, [r14 + offsetFirst] 

    .ciclo:
    
        ; Si el puntero es nulo (ya terminé), voy al final
        cmp r14, 0
        je .end

        ; Dentro de un pago, me fijo si el cobrador es el usuario
        mov r9, [r14 + offsetData]
        mov rdi, [r9 + offsetCobrador]
        mov rsi, r15
        call strcmp

        ; Si es el cobrador, me fijo si el pago está desaprobado
        cmp rax, 0
        jne .finCiclo
            
        mov r9, [r14 + offsetData]    
        mov r8b, [r9 + offsetAprobado]

        cmp r8b, 1
        jne .noAprobado
        jmp .aprobado

        .aprobado:
            ; En r12 tengo el puntero a los aprobados
            ; Guardo el pago, y lo avanzo
            mov [r12], r9
            add r12, 8   
            jmp .finCiclo

        .noAprobado:
            ; En r13 tengo el puntero a los rechazados
            ; Guardo el pago, y lo avanzo
            mov [r13], r9
            add r13, 8   
            jmp .finCiclo
            
        .finCiclo:

            ; Avanzo el puntero
            mov r14, [r14 + offsetNext]
            jmp .ciclo 

    .end:    

        ; Pongo el puntero que devuelve donde corresponde
        mov rax, rbx

        add rsp, 8
        pop rbx
        pop r15
        pop r14
        pop r13
        pop r12

        pop rbp
        ret
