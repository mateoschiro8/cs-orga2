
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

%define NULL 			0

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista	[?]
cantidad_total_de_elementos:
        push rbp
        mov rbp,rsp

        xor rax, rax  ; =0

        mov rdi,[rdi] ;accedo  AL head(puntero a nodo)
    contando:
        ; compara rdi con rdi y verifico si es 0 para ver si es nulo
        test rdi,rdi
        jz fin  ; Si es nulo

        ; Sumar la longitud del arreglo en el nodo actual al contador
        add rax, [rdi + 0x18] 

        mov rdi, [rdi] ; Siguiente nodo 

        jmp contando  ; sigo

    fin:
        pop rbp
        ret


;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos_packed:
        push rbp
        mov rbp,rsp

        xor rax, rax  ; =0

        mov rdi,[rdi] ;accedo  AL head(puntero a nodo)
    contandop:
        ; compara rdi con rdi y verifico si es 0 para ver si es nulo
        test rdi,rdi
        jz finp  ; Si es nulo

        ; Sumar la longitud del arreglo en el nodo actual al contador
        add rax, [rdi + 0x11] 

        mov rdi, [rdi] ; Siguiente nodo 

        jmp contandop ; sigo

    finp:
        pop rbp
        ret


