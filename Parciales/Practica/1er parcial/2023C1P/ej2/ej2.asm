global miraQueCoincidencia

section .rodata

mascaraNegadora: times 16 db 0xFF
floats: dd 0, 0.299, 0.587, 0.114

;########### SECCION DE TEXTO (PROGRAMA)
section .text
;miraQueCoincidencia(uint8_t *A, uint8_t *B, uint32_t N, uint8_t *laCoincidencia)
; rdi -> A, rsi -> B, rdx -> N, rcx -> laCoincidencia 
miraQueCoincidencia:
    push rbp
    mov rbp, rsp

    mov rax, rdx  ; rax -> N
    mul rdx       ; rax -> N*N

    xor r10, r10

    movdqu xmm11, [mascaraNegadora]
    movdqu xmm12, [mascaraNegadora]
    movups xmm13, [floats]

    .loop:
        cmp rax, 0
        je .end

        pxor xmm10, xmm10  ; Resultado

        movdqu xmm0, [rdi + r10]   
        ; xmm0 -> | A3 | R3 | G3 | B3 | A2 | R2 | G2 | B2 | A1 | R1 | G1 | B1 | A0 | R0 | G0 | B0 |

        movdqu xmm1, [rsi + r10]
        ; xmm1 -> | A3 | R3 | G3 | B3 | A2 | R2 | G2 | B2 | A1 | R1 | G1 | B1 | A0 | R0 | G0 | B0 |

        movdqu xmm2, xmm0

        pcmpeqb xmm2, xmm1  ; Comparo los pixeles, tengo 1s donde los pixeles son iguales 
        movdqu xmm3, xmm2
        
        ; Caso pixeles distintos
        pxor xmm3, xmm11  ; Niego mascara, tengo 1s donde los pixeles son distintos

        pand xmm12, xmm3   ; Mascara con todos 255 donde son distintos

        paddb xmm10, xmm12  ; Guardo en xmm10 255 en todos lugares donde los pixeles sean distintos


        ; Caso pixeles iguales

        movdqu xmm9, xmm0
        
        ; xmm9 -> | A3 | R3 | G3 | B3 | A2 | R2 | G2 | B2 | A1 | R1 | G1 | B1 | A0 | R0 | G0 | B0 |
        
        ; pmovzxbd : Zero extend 4 packed 8-bit integers to 4 packed 32-bit integers

        pmovzxbd xmm4, xmm9   ; xmm4 -> |   A0   |   R0   |   G0   |   B0   |  

        psrldq xmm9, 4
        ; xmm9 -> | 00 | 00 | 00 | 00 | A3 | R3 | G3 | B3 | A2 | R2 | G2 | B2 | A1 | R1 | G1 | B1 |


        pmovzxbd xmm5, xmm9   ; xmm5 -> |   A1   |   R1   |   G1   |   B1   |  

        psrldq xmm9, 4
        ; xmm9 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | A3 | R3 | G3 | B3 | A2 | R2 | G2 | B2 |

        
        pmovzxbd xmm6, xmm9   ; xmm6 -> |   A2   |   R2   |   G2   |   B2   |  

        psrldq xmm9, 4
        ; xmm9 ->  | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | A3 | R3 | G3 | B3 |


        pmovzxbd xmm7, xmm9   ; xmm7 -> |   A3   |   R3   |   G3   |   B3   |  


        ; cvtdq2ps: Convert packed doubleword integers to packed single precision floating-point values

        cvtdq2ps xmm4, xmm4
        cvtdq2ps xmm5, xmm5
        cvtdq2ps xmm6, xmm6
        cvtdq2ps xmm7, xmm7

        ; xmm13 ->  |  0000  |  0.299  |  0.587  |  0.114  |

        mulps xmm4, xmm13  ; xmm4 -> |    00    | R0*0.299 | G0*0.587 | B0*0.114 |
        mulps xmm5, xmm13  ; xmm5 -> |    00    | R1*0.299 | G1*0.587 | B1*0.114 |
        mulps xmm6, xmm13  ; xmm6 -> |    00    | R2*0.299 | G2*0.587 | B2*0.114 |
        mulps xmm7, xmm13  ; xmm7 -> |    00    | R3*0.299 | G3*0.587 | B3*0.114 |

        ; cvttps2dq: Convert with truncation packed single precision floating-point values to packed signed doubleword integer values 

        cvttps2dq xmm4, xmm4
        cvttps2dq xmm5, xmm5
        cvttps2dq xmm6, xmm6
        cvttps2dq xmm7, xmm7

        ; phaddd: Packed horizontal add
        phaddd xmm4, xmm4   ;   x0 =  R0*0.299 + G0*0.587 + B0*0.114 
        phaddd xmm4, xmm4   ; xmm4 -> |    x0    |    x0    |    x0    |    x0    |

        phaddd xmm5, xmm5   ;   x1 =  R1*0.299 + G1*0.587 + B1*0.114 
        phaddd xmm5, xmm5   ; xmm5 -> |    x1    |    x1    |    x1    |    x1    |

        phaddd xmm6, xmm6   ;   x2 =  R2*0.299 + G2*0.587 + B2*0.114 
        phaddd xmm6, xmm6   ; xmm6 -> |    x2    |    x2    |    x2    |    x2    |

        phaddd xmm7, xmm7   ;   x3 =  R3*0.299 + G3*0.587 + B3*0.114 
        phaddd xmm7, xmm7   ; xmm7 -> |    x3    |    x3    |    x3    |    x3    |



        ; packusdw: 







        movdqu [rcx + r10], xmm10

        add r10, 16
        sub rax, 4
        jmp .loop

    .end:
        pop rbp
        ret
