global mezclarColores

section .rodata

mascaraTransp: db  0xFF,0xFF,0xFF,0x00,0xFF,0xFF,0xFF,0x00,0xFF,0xFF,0xFF,0x00,0xFF,0xFF,0xFF,0x00 

mascaraCaso1:  db  2, 0, 1, 3, 6, 4, 5, 7, 10, 8, 9, 11, 14, 12, 13, 15
mascaraCaso2:  db  1, 2, 0, 3, 5, 6, 4, 7, 9, 10, 8, 11, 13, 14, 12, 15
mascaraCaso3:  db  2, 1, 0, 3, 6, 5, 4, 7, 10, 9, 8, 11, 14, 13, 12, 15

mascara1pixel:  db 0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
mascara2pixel:  db 0x00,0x00,0x00,0x00,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
mascara3pixel:  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00
mascara4pixel:  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xFF,0xFF,0xFF,0x00

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void mezclarColores(uint8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
;  X (src)  -> rdi 
;  Y (dst)  -> rsi  
;  width    -> rdx  
;  height   -> rcx
mezclarColores:
    push rbp
    mov rbp, rsp

    ; Me traigo el alto y el ancho, y los multiplico (quedan guardados en rax)
    mov r10, rdx
    mov rax, rcx
    mul r10

    ; Lo divido por 4 (para trabajar de a 4 pixeles) y lo guardo en r10
    shr rax, 2
    mov r10, rax

    ; Me guardo máscaras que voy a usar para las mezclas
    movdqu xmm8,  [mascaraTransp]
    movdqu xmm9,  [mascaraCaso1]
    movdqu xmm10, [mascaraCaso2]

    movdqu xmm15, [mascaraCaso3]

    movdqu xmm11, [mascara1pixel]
    movdqu xmm12, [mascara2pixel]
    movdqu xmm13, [mascara3pixel]
    movdqu xmm14, [mascara4pixel]

    ciclo:

        ; Comparo la cantidad de pixeles restantes
        cmp r10, 0
        je endd

        ; Me traigo los primeros 4 pixeles
        movdqu xmm0, [rdi]

        ; xmm0 = | R0 | G0 | B0 | A0 | R1 | G1 | B1 | A1 | R2 | G2 | B2 | A2 | R3 | G3 | B3 | A3 |

        ; Borro las transparencias y me lo copio en xmm3
        pand xmm0, xmm8
        movdqu xmm3, xmm0

        ; xmm0 = | R0 | G0 | B0 | 00 | R1 | G1 | B1 | 00 | R2 | G2 | B2 | 00 | R3 | G3 | B3 | 00 |

        ; Necesito averiguar cuál es el mas grande dentro de cada pixel


        ; Puedo aplicar shuffle con alguna de las máscaras. Por ej, la de caso 1, guardada en xmm9:

        ; xmm9 : |  1 |  2 |  0 |  3 |  5 |  6 |  4 |  7 |  9 | 10 | 8 | 11 | 13 | 14 | 12 | 15 |

        ; Resultando en:

        ; xmm1 : | B0 | R0 | G0 | 00 | B1 | R1 | G1 | 00 | B2 | R2 | G2 | 00 | B3 | R3 | G3 | 00 |

        pshufb xmm0, xmm9

        ; Copio el resultado en xmm2
        movdqu xmm2, xmm1

        ; xmm2 : | B0 | R0 | G0 | 00 | B1 | R1 | G1 | 00 | B2 | R2 | G2 | 00 | B3 | R3 | G3 | 00 |

        pshufb xmm2, xmm8

        ; Tengo entonces en xmm2 lo siguiente:

        ; xmm2 : | B0 | R0 | G0 | 00 | B1 | R1 | G1 | 00 | B2 | R2 | G2 | 00 | B3 | R3 | G3 | 00 |

        ; Y aplico shuffle con la siguiente misma máscara

        ; Resultando en:

        ; xmm2 : | G0 | B0 | R0 | 00 | G1 | B1 | R1 | 00 | G2 | B2 | R2 | 00 | G3 | B3 | R3 | 00 |

        ; ----------------------------------------------------------------------------------------

        ; Me quedan entonces los siguientes registros:

        ; xmm0 : | R0 | G0 | B0 | 00 | R1 | G1 | B1 | 00 | R2 | G2 | B2 | 00 | R3 | G3 | B3 | 00 |
        ; xmm1 : | B0 | R0 | G0 | 00 | B1 | R1 | G1 | 00 | B2 | R2 | G2 | 00 | B3 | R3 | G3 | 00 |
        ; xmm2 : | G0 | B0 | R0 | 00 | G1 | B1 | R1 | 00 | G2 | B2 | R2 | 00 | G3 | B3 | R3 | 00 |

        ; pmaxub se queda en cada byte del destino con el máximo valor de los bytes de los operandos. 
        ; Hacerlo dos veces es suficiente para asegurarse quedarse con el maximo de los 3

        pmaxub xmm0, xmm1
        pmaxub xmm0, xmm2

        ; Tengo entonces

        ; xmm0 : | z0 | z0 | z0 | 00 | z1 | z1 | z1 | 00 | z2 | z2 | z2 | 00 | z3 | z3 | z3 | 00 |

        ; Donde zi es max(Ri, Gi, Bi)

        ; Y con un espíritu que creo que dista un poco de la idea de SIMD, voy a extraer cada pixel,
        ; fijarme cuál de las tres componentes es la mayor, y tomar una decisión respecto a eso

        ; En xmm4 y xmm5 voy a ir armando el resultado
        pxor xmm4, xmm4
        pxor xmm5, xmm5

        primerPixel:

            pextrb r8, xmm0, 0xF  ; z0

            pextrb r9, xmm3, 0xF  ; R0
            cmp r8, r9
            je .R0mayor

            pextrb r9, xmm3, 0xE  ; G0   
            cmp r8, r9
            je .G0mayor

            pextrb r9, xmm3, 0xD  ; B0   
            cmp r8, r9
            je .B0mayor

            .R0mayor:
                ; Caso 1
                ; Copio en xmm5 el original, borro los otros pixeles, le hago el shuffle y lo sumo al final
                movdqu xmm5, xmm3
                pand xmm5, xmm11
                pshufb xmm5, xmm9
                paddb xmm4, xmm5
                jmp segundoPixel

            .G0mayor:
                ; Caso 2
                ; Copio en xmm5 el original, borro los otros pixeles y lo sumo al final
                movdqu xmm5, xmm3
                pand xmm5, xmm11
                pshufb xmm5, xmm15
                paddb xmm4, xmm5
                jmp segundoPixel

            .B0mayor:
                ; Copio en xmm5 el original, borro los otros pixeles, le hago el shuffle y lo sumo al final
                movdqu xmm5, xmm3
                pand xmm5, xmm11
                pshufb xmm5, xmm10
                paddb xmm4, xmm5
                jmp segundoPixel

        segundoPixel:

            pextrb r8, xmm0, 0xB  ; z1

            pextrb r9, xmm3, 0xB  ; R1
            cmp r8, r9
            je .R1mayor

            pextrb r9, xmm3, 0xA  ; G1   
            cmp r8, r9
            je .G1mayor

            pextrb r9, xmm3, 0x9  ; B1   
            cmp r8, r9
            je .B1mayor

            .R1mayor:
                ; Caso 1
                ; Copio en xmm5 el original, borro los otros pixeles, le hago el shuffle y lo sumo al final
                movdqu xmm5, xmm3
                pand xmm5, xmm12
                pshufb xmm5, xmm9
                paddb xmm4, xmm5
                jmp tercerPixel

            .G1mayor:
                ; Caso 2
                ; Copio en xmm5 el original, borro los otros pixeles y lo sumo al final
                movdqu xmm5, xmm3
                pand xmm5, xmm12
                pshufb xmm5, xmm15
                paddb xmm4, xmm5
                jmp tercerPixel

            .B1mayor:
                ; Copio en xmm5 el original, borro los otros pixeles, le hago el shuffle y lo sumo al final
                movdqu xmm5, xmm3
                pand xmm5, xmm12
                pshufb xmm5, xmm10
                paddb xmm4, xmm5
                jmp tercerPixel

        tercerPixel:

            pextrb r8, xmm0, 0x7  ; z2

            pextrb r9, xmm3, 0x7  ; R2
            cmp r8, r9
            je .R2mayor

            pextrb r9, xmm3, 0x6  ; G2   
            cmp r8, r9
            je .G2mayor

            pextrb r9, xmm3, 0x5  ; B2   
            cmp r8, r9
            je .B2mayor

            .R2mayor:
                ; Caso 1
                ; Copio en xmm5 el original, borro los otros pixeles, le hago el shuffle y lo sumo al final
                movdqu xmm5, xmm3
                pand xmm5, xmm13
                pshufb xmm5, xmm9
                paddb xmm4, xmm5
                jmp cuartoPixel

            .G2mayor:
                ; Caso 2
                ; Copio en xmm5 el original, borro los otros pixeles y lo sumo al final
                movdqu xmm5, xmm3
                pand xmm5, xmm13
                pshufb xmm5, xmm15
                paddb xmm4, xmm5
                jmp cuartoPixel

            .B2mayor:
                ; Copio en xmm5 el original, borro los otros pixeles, le hago el shuffle y lo sumo al final
                movdqu xmm5, xmm3
                pand xmm5, xmm13
                pshufb xmm5, xmm10
                paddb xmm4, xmm5
                jmp cuartoPixel

        cuartoPixel:

            pextrb r8, xmm0, 0x3  ; z3

            pextrb r9, xmm3, 0x3  ; R3
            cmp r8, r9
            je .R3mayor

            pextrb r9, xmm3, 0x2  ; G3   
            cmp r8, r9
            je .G3mayor

            pextrb r9, xmm3, 0x1  ; B3   
            cmp r8, r9
            je .B3mayor

            .R3mayor:
                ; Caso 1
                ; Copio en xmm5 el original, borro los otros pixeles, le hago el shuffle y lo sumo al final
                movdqu xmm5, xmm3
                pand xmm5, xmm14
                pshufb xmm5, xmm9
                paddb xmm4, xmm5
                jmp endCiclo

            .G3mayor:
                ; Caso 2
                ; Copio en xmm5 el original, borro los otros pixeles y lo sumo al final
                movdqu xmm5, xmm3
                pand xmm5, xmm14
                pshufb xmm5, xmm15
                paddb xmm4, xmm5
                jmp endCiclo

            .B3mayor:
                ; Copio en xmm5 el original, borro los otros pixeles, le hago el shuffle y lo sumo al final
                movdqu xmm5, xmm3
                pand xmm5, xmm14
                pshufb xmm5, xmm10
                paddb xmm4, xmm5
                jmp endCiclo

        endCiclo:    

            ; Cargo a memoria, avanzo los punteros y loopeo
            movdqu [rsi], xmm4
            add rdi, 16
            add rsi, 16
            dec r10
            jmp ciclo    

    endd:
        pop rbp
        ret
