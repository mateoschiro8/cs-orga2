%define orderingTableOffsetTableSize    0
%define orderingTableOffsetTable        8
%define orderingTableSize               16

%define nodoDisplayListOffsetPrimitiva  0
%define nodoDisplayListOffsetX          8
%define nodoDisplayListOffsetY          9
%define nodoDisplayListOffsetZ          10
%define nodoDisplayListOffsetSiguiente  16
%define nodoDisplayListSize             24

%define nodoOrderingTableOffsetDisplayElement   0
%define nodoOrderingTableOffsetSiguiente        8
%define nodoOrderingTableSize                   16


section .text

global inicializar_OT_asm
global calcular_z_asm
global ordenar_display_list_asm

extern malloc
extern free


;########### SECCION DE TEXTO (PROGRAMA)

; ordering_table_t* inicializar_OT(uint8_t table_size);
; table_size -> rdi
inicializar_OT_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13

    mov r12, rdi  ; r12 -> table size

    ; Pido en memoria el tamaño del struct
    mov rdi, orderingTableSize
    call malloc

    mov r13, rax  ; r13 -> puntero al OT

    mov [r13 + orderingTableOffsetTableSize], r12  ; Tamaño de la tabla
    
    mov rdi, r12  ; r12 -> table size
    shl rdi, 3   ; rdi -> rdi * 8 (cantidad de celdas de tabla * tamaño de cada celda (punteros))

    cmp rdi, 0
    je .tablaSinElementos

    call malloc

    xor r10, r10

    .miniloopPosicionesNulas:
        ; loop para poner todas las posiciones en 0
        cmp r12, 0
        je .endMiniloopPosicionesNulas

        dec r12
        mov [rax + r12 * 8], r10
        
        jmp .miniloopPosicionesNulas
    
    ; rax -> puntero a tabla
    ; r13 -> puntero a struct

    .endMiniloopPosicionesNulas:
        mov [r13 + orderingTableOffsetTable], rax       ; Puntero a la tabla
        jmp .end

    .tablaSinElementos:

        xor r10, r10  ; Para puntero nulo
        mov [r13 + orderingTableOffsetTable], r10       ; Puntero a la tabla

    .end:
        mov rax, r13

        pop r13
        pop r12
        pop rbp
        ret

; void* calcular_z_asm(nodo_display_list_t* nodo, uint8_t z_size);
; nodoDisplayList -> rdi,  z_size -> rsi
calcular_z_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13     

    mov r12, rdi    ; r12 -> displayList
    mov r13, rsi    ; r13 -> z_size

    .loop:
        cmp r12, 0  ; Puntero nulo
        je .end

        mov rdi, [r12 + nodoDisplayListOffsetX]   ; Parametro x
        mov rsi, [r12 + nodoDisplayListOffsetY]   ; Parametro y

        mov rdx, r13   ; Parametro z_size

        mov rax, [r12 + nodoDisplayListOffsetPrimitiva]  ; Funcion primitiva

        call rax   ; Llamo a primitiva

        ; rax -> z

        mov [r12 + nodoDisplayListOffsetZ], al  ; Cargo z en el nodo

        mov r12, [r12 + nodoDisplayListOffsetSiguiente] ; Me meto en el siguiente

        jmp .loop

    .end:

        pop r13
        pop r12
        pop rbp
        ret


; void* ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) ;
; orderingTable -> rdi,    nodoDisplayList -> rsi
ordenar_display_list_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    mov r12, rdi    ; r12 -> orderingTable
    mov r13, rsi    ; r13 -> nodoDisplayList

    .loop:
        cmp r13, 0   ; r13 -> puntero a nodoDisplayList
        je .end

        mov rdi, r13    ; nodoDisplayList
        mov rsi, [r12 + orderingTableOffsetTableSize]  ; tableSize

        call calcular_z_asm     ; Le calculo el z al nodo

        xor r10, r10
        mov r10b, [r13 + nodoDisplayListOffsetZ]     ; r10 -> z del nodo

        ; Traigo la tabla
        mov r14, [r12 + orderingTableOffsetTable]   

        ; r14 -> array de nodo_ot_t*

        mov r11, r10  ; Z del nodo para iterar


        push r11
        sub rsp, 8

        ; Traigo el puntero en esa posicion del arreglo
        mov r15, [r14 + r11 * 8]

        mov rdi, nodoOrderingTableSize  ; Pido la memoria para crear ese nodo
        call malloc

        add rsp, 8
        pop r11

        ; Armo el nodo
        xor r10, r10
        mov [rax + nodoOrderingTableOffsetDisplayElement], r13
        mov [rax + nodoOrderingTableOffsetSiguiente], r10
        
        cmp r15, 0
        jne .miniloop

        ; Es el primer nodo de esa posicion

        mov [r14 + r11 * 8], rax

        mov r13, [r13 + nodoDisplayListOffsetSiguiente]

        jmp .loop 

        .miniloop:

            ; No es el primer nodo de esa posicion

            cmp r15, 0
            je .miniend

            mov r8, r15  ; me guardo el nodo que estoy visitando
            mov r15, [r15 + nodoOrderingTableOffsetSiguiente] ; voy al siguiente

            jmp .miniloop

        .miniend:

            ; ya estoy en un puntero nulo, y tengo en r8 el ultimo
            mov [r8 + nodoOrderingTableOffsetSiguiente], rax  ; agrego el de ahora como siguiente
            
            mov r13, [r13 + nodoDisplayListOffsetSiguiente]

            jmp .loop

    .end:
        pop r15
        pop r14
        pop r13
        pop r12

        pop rbp
        ret


