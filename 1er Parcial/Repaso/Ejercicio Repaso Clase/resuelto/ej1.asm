global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm

;########### SECCION DE TEXTO (PROGRAMA)
section .text

extern calloc
extern strcmp

;<<<REMOVE>>>
; extern acumuladoPorCliente
extern en_blacklist
extern blacklistComercios
;<<<REMOVE END>>>

;   typedef struct pago {
;       uint8_t monto;              1 byte
;       char* comercio;             8 bytes
;       uint8_t cliente;            1 byte
;       uint8_t aprobado;           1 byte
;   } pago_t; 

; Defino los offsets
%define offsetMonto     0
%define offsetComercio  8
%define offsetCliente   16
%define offsetAprobado  17
%define tamañoPago      24

; uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos)
;   cantidadDePagos -> rdi
;   arr_pagos -> rsi

acumuladoPorCliente_asm:
    push rbp
    mov rbp, rsp

    ; Pusheo los registros que voy a usar
    push r12
    push r13
    push r14 
    push r15

    ; Guardo los parámetros en registros aparte
    mov r14, rdi  ; cantidadDePagos
    mov r15, rsi  ; arr_pagos

    ; Pido la memoria, 10 unidades de 32 bits (4 bytes) iniciadas en 0
    mov rdi, 10
    mov rsi, 4
    call calloc

    ; Tengo en rax el puntero al arreglo de clientes

    ; Pongo en 0 los registros a utilizar
    xor r12, r12
    xor rdi, rdi

    ciclo1:

        ; Comparo la cantidad de pagos que me quedan
        cmp r14, 0
        je end

        ; Me fijo si está aprobado
        cmp byte [r15 + offsetAprobado], 1

        ; Si no está aprobado, paso al que sigue
        jne proxIteracion

        ; Si está aprobado, obtengo los datos
        mov r12b, [r15 + offsetCliente]      ; Cliente
        mov dil, [r15 + offsetMonto]         ; Monto

        ; Actualizo el monto
        add [rax + r12 * 4], dil

        proxIteracion:
            ; Disminuyo la cantidad de pagos restantes y avanzo el puntero
            sub r14, 1
            add r15, tamañoPago
            jmp ciclo1

    end: 
        pop r15
        pop r14
        pop r13
        pop r12 

        pop rbp
	    ret


; cuint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n);
;   comercio -> rdi
;   lista_comercio -> rsi
;   n -> rdx
en_blacklist_asm:
    push rbp
    mov rbp, rsp
	
    push r12
    push r13
    push r14

    sub rsp, 8

    mov r12, rdi  ; Comercio a chequear
    mov r13, rsi  ; Lista de comercios
    mov r14, rdx  ; Cantidad de comercios

    xor rax, rax

    ciclo: 

        ; Comparo las palabras restantes
        cmp r14, 0
        je noEncontre

        ; Disminuyo la cantidad de restantes (para poder usarlo para indexar)
        sub r14, 1

        ; Comparo la string
        mov rdi, r12
        mov rsi, [r13 + r14]
        call strcmp

        ; Comparo si ya encontré un match
        cmp rax, 0
        je encontre
        jmp ciclo

    encontre:
        mov rax, 1
        jmp end2

    noEncontre:
        mov rax, 0
        jmp end2

    end2:

        add rsp, 8

        pop r14
        pop r13
        pop r12

        pop rbp
        ret

;(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios)
;   cantidad_pagos  -> rdi
;   arr_pagos       -> rsi 
;   arr_comercios   -> rdx
;   size_comercios  -> rcx
pagosEnBlacklist:       ; Auxiliar, mismos parámetros que blacklist_comercios
    push rbp
    mov rbp, rsp
	
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8

    mov r12, rdi    ; cantidad_pagos
    mov r13, rsi    ; arr_pagos
    mov r14, rdx    ; arr_comercios
    mov r15, rcx    ; size_comercios

    xor rbx, rbx

    ciclo3:
        ; Comparo los pagos restantes
        cmp r12, 0
        je end5

        sub r12, 1

        ; uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n);
        mov rdi, [r13 + offsetComercio + r12]
        mov rsi, r14
        mov rdx, r15
        call en_blacklist_asm
        add rbx, rax

        jmp ciclo3

    end5:

        add rsp, 8
        pop rbx
        pop r15
        pop r14
        pop r13
        pop r12

        pop rbp
        ret

; pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios)
;   cantidad_pagos  -> rdi
;   arr_pagos       -> rsi 
;   arr_comercios   -> rdx
;   size_comercios  -> rcx
blacklistComercios_asm:
    push rbp
    mov rbp, rsp
	
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8

    mov r12, rdi    ; cantidad_pagos
    mov r13, rsi    ; arr_pagos
    mov r14, rdx    ; arr_comercios
    mov r15, rcx    ; size_comercios

    call pagosEnBlacklist
        
    ; Pido la memoria necesaria
    mov rdi, rax
    mov rsi, 8
    call calloc
    
    mov rbx, rax

    ciclo4:
        ; Comparo los pagos restantes
        cmp r12, 0
        je end3

        sub r12, 1

        ; uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n);
        mov rdi, [r13 + offsetComercio + r12]
        mov rsi, r14
        mov rdx, r15
        call en_blacklist_asm
            
        cmp rax, 1
        jne finCiclo4

        mov [rbx], r13
        add rbx, 8

        finCiclo4:
            add r13, tamañoPago
            jmp ciclo4

    end3:

        mov rax, rbx
        
        add rsp, 8
        pop rbx
        pop r15
        pop r14
        pop r13
        pop r12

        pop rbp
        ret
