global maximosYMinimos_asm

section .data 

mascaraPares:   db 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0XFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00
mascaraImpares: db 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0X00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00
mascaraShift:   db 1, 2, 0, 3, 5, 6, 4, 7, 9, 10, 8, 11, 13, 14, 12, 15

section .text

; maximosYMinimos_asm(uint8_t *src, uint8_t *dst, uint32_t width, uint32_t height)
;  src      -> rdi 
;  dst      -> rsi  
;  width    -> rdx  
;  height   -> rcx

maximosYMinimos_asm:
    push rbp 
    mov rbp, rsp

    ; Me traigo el alto y el ancho, y los multiplico (quedan guardados en rax)
    mov r9, rdx
    mov rax, rcx
    mul r9

    ; Lo divido por 4 (para trabajar de a 4 pixeles) y lo guardo en r9
    shr rax, 2
    mov r9, rax

    ; Me traigo las máscaras para los pixeles pares, impares y el shift
    movdqu xmm6, [mascaraPares]
    movdqu xmm7, [mascaraImpares]
    movdqu xmm8, [mascaraShift]

    looper:

        ; Comparo la cantidad de pixeles restantes
        cmp r9, 0
        je endd

        ; Traigo 4 pixeles, y los copio en xmm1 y xmm3
        movdqu xmm0, [rdi]
        movdqu xmm1, xmm0
        movdqu xmm3, xmm0

        ; Tengo entonces en xmm1 lo siguiente:

        ; xmm1 : | R0 | G0 | B0 | A0 | R1 | G1 | B1 | A1 | R2 | G2 | B2 | A2 | R3 | G3 | B3 | A3 |

        ; Y aplico shuffle con la siguiente máscara guardada en xmm8:

        ; xmm8 : |  1 |  2 |  0 |  3 |  5 |  6 |  4 |  7 |  9 | 10 | 8 | 11 | 13 | 14 | 12 | 15 |

        ; Resultando en:

        ; xmm1 : | B0 | R0 | G0 | A0 | B1 | R1 | G1 | A1 | B2 | R2 | G2 | A2 | B3 | R3 | G3 | A3 |

        pshufb xmm1, xmm8

        ; Copio el resultado en xmm2
        movdqu xmm2, xmm1

        ; xmm2 : | B0 | R0 | G0 | A0 | B1 | R1 | G1 | A1 | B2 | R2 | G2 | A2 | B3 | R3 | G3 | A3 |

        pshufb xmm2, xmm8

        ; Tengo entonces en xmm2 lo siguiente:

        ; xmm2 : | B0 | R0 | G0 | A0 | B1 | R1 | G1 | A1 | B2 | R2 | G2 | A2 | B3 | R3 | G3 | A3 |

        ; Y aplico shuffle con la siguiente máscara guardada en xmm8:

        ; xmm8 : |  1 |  2 |  0 |  3 |  5 |  6 |  4 |  7 |  9 | 10 | 8 | 11 | 13 | 14 | 12 | 15 |

        ; Resultando en:

        ; xmm2 : | G0 | B0 | R0 | A0 | G1 | B1 | R1 | A1 | G2 | B2 | R2 | A2 | G3 | B3 | R3 | A3 |

        ; ----------------------------------------------------------------------------------------

        ; Me quedan entonces los siguientes registros:

        ; xmm0 : | R0 | G0 | B0 | A0 | R1 | G1 | B1 | A1 | R2 | G2 | B2 | A2 | R3 | G3 | B3 | A3 |
        ; xmm1 : | B0 | R0 | G0 | A0 | B1 | R1 | G1 | A1 | B2 | R2 | G2 | A2 | B3 | R3 | G3 | A3 |
        ; xmm2 : | G0 | B0 | R0 | A0 | G1 | B1 | R1 | A1 | G2 | B2 | R2 | A2 | G3 | B3 | R3 | A3 |

        ; Queda encontrar el máximo para las posiciones pares y el mínimo para las impares

        ; pmaxub y pminub se quedan en cada byte del destino con el máximo y mínimo valor de los bytes 
        ; de los operandos. Hacerlo dos veces es suficiente para asegurarse quedarse con el maximo/minimo de los 3

        pmaxub xmm0, xmm1
        pmaxub xmm0, xmm2

        pminub xmm3, xmm1
        pminub xmm3, xmm2

        ; Utilizamos las máscaras para eliminar los bytes que no nos interesan (pares e impares), 
        ; y unimos los resultados en un solo registro 
        pand xmm0, xmm6
        pand xmm3, xmm7

        paddb xmm0, xmm3

        ; Cargamos a memoria, avanzamos los punteros y loopeamos
        movdqu [rsi], xmm0
        add rsi, 16
        add rdi, 16
        dec r9
        jmp looper

    endd:
        pop rbp
        ret