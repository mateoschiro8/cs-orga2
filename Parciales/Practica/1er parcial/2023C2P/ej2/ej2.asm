global mezclarColores

section .rodata

; r g b    -> Fuente
; b r g    -> Destino con las componentes del source donde deberian ir ( shift a derecha )
; -> = va a la posicion de 
mascaraShuffleCaso1: db 0x02, 0x00, 0x01, 0x03, 0x06, 0x04, 0x05, 0x07, 0x0A, 0x08, 0x09, 0x0B, 0x0E, 0x0C, 0x0D, 0x0F 

; r g b    -> Fuente
; g b r    -> Destino con las componentes del source donde deberian ir ( shift a izquierda )
; -> = va a la posicion de 
mascaraShuffleCaso2: db 0x01, 0x02, 0x00, 0x03, 0x05, 0x06, 0x04, 0x07, 0x09, 0x0A, 0x08, 0x0B, 0x0D, 0x0E, 0x0C, 0x0F 

mascaraTodos1: times 16 db 0xFF
mascaraTodos128: times 16 db 128
; r g b
mascaraTodosR: db 0x00, 0x00, 0x00, 0x03, 0x04, 0x04, 0x04, 0x07, 0x08, 0x08, 0x08, 0x0B, 0x0C, 0x0C, 0x0C, 0x0F
mascaraTodosG: db 0x01, 0x01, 0x01, 0x03, 0x05, 0x05, 0x05, 0x07, 0x09, 0x09, 0x09, 0x0B, 0x0D, 0x0D, 0x0D, 0x0F
mascaraTodosB: db 0x02, 0x02, 0x02, 0x03, 0x06, 0x06, 0x06, 0x07, 0x0A, 0x0A, 0x0A, 0x0B, 0x0E, 0x0E, 0x0E, 0x0F   
mascaraSacarAlpha: times 4 dd 0x00FFFFFF
;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void mezclarColores(uint8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
; rdi -> puntero X, rsi -> puntero Y, rdx -> width, rcx -> height

mezclarColores:
    ;prologo
    push rbp
    mov rbp, rsp

    mov eax, ecx
    mul edx ; eax -> width * height
    shr eax, 2 ; eax -> width * height / 4 (traemos de a 4 pixeles de memoria)

    xor r8, r8 ; r8 -> offset imgs

    movdqu xmm10, [mascaraShuffleCaso1]
    movdqu xmm11, [mascaraShuffleCaso2]
    movdqu xmm12, [mascaraTodos128]
    movdqu xmm13, [mascaraTodosR]
    movdqu xmm14, [mascaraTodosG]
    movdqu xmm15, [mascaraTodosB]
    
    .ciclo:
        cmp eax, 0
        je .end

        movdqu xmm1, [rdi + r8] ; xmm1 -> 4 pixeles de X
        movdqu xmm2, xmm1 ; xmm2 -> pixeles originales para caso 1
        movdqu xmm3, xmm1 ; xmm3 -> pixeles originales para caso 2

        pshufb xmm2, xmm10 ; Caso 1 shift derecha 
        pshufb xmm3, xmm11 ; Caso 2 shift izquierda 
        
        movdqu xmm4, xmm1 ; xmm4 -> pixeles originales para comparacion 
        movdqu xmm5, xmm1 ; xmm5 -> pixeles originales para comparacion
        movdqu xmm6, xmm1 ; xmm6 -> pixeles originales para comparacion

        ; comparaciones
        pshufb xmm4, xmm13 ; xmm4 todas componentes R
        pshufb xmm5, xmm14 ; xmm5 todas componentes G
        pshufb xmm6, xmm15 ; xmm6 todas componentes B

        ; sumamos 128 para hacer las comparaciones signadas
        paddb xmm4, xmm12
        paddb xmm5, xmm12
        paddb xmm6, xmm12

        ; movs para comparacion segundo caso
        movdqu xmm7, xmm4 ; xmm7 todas componentes R, ya corregido el desplazamiento
        movdqu xmm8, xmm5 ; xmm8 todas componentes G, ya corregido el desplazamiento
        movdqu xmm9, xmm6 ; xmm9 todas componentes B, ya corregido el desplazamiento

        ; pcmpgtb: compare for greater
        pcmpgtb xmm4, xmm5 ; xmm4 -> mascara con 1 donde R > G
        pcmpgtb xmm5, xmm6 ; xmm6 -> mascara con 1 donde G > B
        pand xmm4, xmm5 ; xmm4 -> combina ambas mascaras, R > G > B

        pcmpgtb xmm9, xmm8 ; xmm9 -> mascara con 1 donde B > G
        pcmpgtb xmm8, xmm7 ; xmm8 -> mascara con 1 donde G > R
        pand xmm8, xmm9 ; xmm8 -> combina ambas mascaras, B > G > R

        ; armar mascara para aquellos valores que no caen en ninguna de las condiciones anteriores
        movdqu xmm5, xmm4
        movdqu xmm6, [mascaraTodos1]
        pxor xmm5, xmm6 ; negamos ambas mascaras para quedarnos con las posiciones que no cumplen la condicion
        pxor xmm8, xmm6
        pand xmm5, xmm8 ; and entre la negacion de ambas mascaras da como resultado 1 en las posiciones que no cumplen ninguna de las dos

        pxor xmm8, xmm6 ; vuelve a ser la de antes
        pand xmm5, xmm1 ; solo deja valores que no caen en ninguna de las otras dos condiciones
        pand xmm4, xmm2 ; solo deja valores (ya shifteados) de X que cumplan R > G > B
        pand xmm8, xmm3 ; solo deja valores (ya shifteados) de X que cumplan B > G > R
        
        paddb xmm4, xmm8 
        paddb xmm4, xmm5 ; combina resultados en xmm4

        movdqu xmm6, [mascaraSacarAlpha]
        pand xmm4, xmm6

        movdqu [rsi + r8], xmm4  ; lleva a memoria 

        add r8, 16 ; muevo el offset 4 pixeles
        sub eax, 4 ; disminuye en 4 el total de pixeles
        jmp .ciclo

    .end:
        ; epilogo
        pop rbp
        ret