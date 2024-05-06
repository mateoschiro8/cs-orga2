
; -------------- ANDA MASO MASO (no anda) ---------------

global miraQueCoincidencia

section .rodata

mascaraNegadora: times 16 db 0xFF
floats: dd 0.114, 0.587, 0.299, 0 

dejar1ComponentePixel0: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF 
dejar1ComponentePixel1: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00
dejar1ComponentePixel2: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
dejar1ComponentePixel3: db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

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
    xor r11, r11

    movdqu xmm11, [mascaraNegadora]
    movdqu xmm12, [mascaraNegadora]
    movups xmm13, [floats]

    .loop:
        cmp rax, 0
        je .end

        pxor xmm10, xmm10  ; Resultado

        movdqu xmm0, [rdi + r10]   
        ; xmm0 -> | B3 | G3 | R3 | A3 | B2 | G2 | R2 | A2 | B1 | G1 | R1 | A1 | B0 | G0 | R0 | A0 |

        movdqu xmm1, [rsi + r10]
        ; xmm1 -> | B3 | G3 | R3 | A3 | B2 | G2 | R2 | A2 | B1 | G1 | R1 | A1 | B0 | G0 | R0 | A0 |

        movdqu xmm2, xmm0

        pcmpeqb xmm2, xmm1  ; Comparo los pixeles, tengo 1s donde los pixeles son iguales 
        movdqu xmm3, xmm2
        
        ; Caso pixeles distintos
        pxor xmm3, xmm11  ; Niego mascara, tengo 1s donde los pixeles son distintos

        movdqu xmm4, xmm11
        movdqu xmm5, xmm11
        movdqu xmm6, xmm11
        movdqu xmm7, xmm11

        movdqu xmm14, [dejar1ComponentePixel0]
        pand xmm4, xmm14 ; xmm4 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x0 |

        movdqu xmm14, [dejar1ComponentePixel1]
        pand xmm5, xmm14 ; xmm5 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x1 | 00 | 00 | 00 | 00 |

        movdqu xmm14, [dejar1ComponentePixel2]
        pand xmm6, xmm14 ; xmm6 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x2 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 |

        movdqu xmm14, [dejar1ComponentePixel3]
        pand xmm7, xmm14 ; xmm7 -> | 00 | 00 | 00 | x3 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 |


        ; xmm3 -> mascara con 1s donde los pixeles son distintos
        ; aplico mascara, shifteo y sumo
        pand xmm4, xmm3
        pand xmm5, xmm3
        pand xmm6, xmm3
        pand xmm7, xmm3

        psrldq xmm4, 3  ; xmm4 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x0 | 00 | 00 | 00 |
        pslldq xmm5, 2  ; xmm5 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x1 | 00 | 00 |
        pslldq xmm6, 7  ; xmm6 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x2 | 00 |
        pslldq xmm7, 12 ; xmm7 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x3 |

        paddb xmm10, xmm4
        paddb xmm10, xmm5
        paddb xmm10, xmm6
        paddb xmm10, xmm7


        ; Caso pixeles iguales

        movdqu xmm9, xmm0
        
        ; xmm9 -> | B3 | G3 | R3 | A3 | B2 | G2 | R2 | A2 | B1 | G1 | R1 | A1 | B0 | G0 | R0 | A0 |

        ; pmovzxbd : Zero extend 4 packed 8-bit integers to 4 packed 32-bit integers

        pmovzxbd xmm4, xmm9   ; xmm4 -> |   B0   |   G0   |   R0   |   A0   |  

        psrldq xmm9, 4
        ; xmm9 -> | 00 | 00 | 00 | 00 | B3 | G3 | R3 | A3 | B2 | G2 | R2 | A2 | B1 | G1 | R1 | A1 |


        pmovzxbd xmm5, xmm9   ; xmm5 -> |   B1   |   G1   |   R1   |   A1   |  

        psrldq xmm9, 4
        ; xmm9 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | B3 | G3 | R3 | A3 | B2 | G2 | R2 | A2 |

        
        pmovzxbd xmm6, xmm9   ; xmm6 -> |   B2   |   G2   |   R2   |   A2   |  

        psrldq xmm9, 4
        ; xmm9 ->  | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | B3 | G3 | R3 | A3 |


        pmovzxbd xmm7, xmm9   ; xmm7 -> |   B3   |   G3   |   R3   |   A3   |  


        ; cvttpd2pi: Convert packed doubleword integers to packed single precision floating-point values

        cvtdq2ps xmm4, xmm4
        cvtdq2ps xmm5, xmm5
        cvtdq2ps xmm6, xmm6
        cvtdq2ps xmm7, xmm7

        ; xmm13 ->  |  0.114  |  0.587  |  0.299  |  0000  |

        mulps xmm4, xmm13  ; xmm4 -> | B0*0.114 | G0*0.587 | R0*0.299 |    00    |
        mulps xmm5, xmm13  ; xmm5 -> | B1*0.114 | G1*0.587 | R1*0.299 |    00    |
        mulps xmm6, xmm13  ; xmm6 -> | B2*0.114 | G2*0.587 | R2*0.299 |    00    |
        mulps xmm7, xmm13  ; xmm7 -> | B3*0.114 | G3*0.587 | R3*0.299 |    00    |

        ; cvttps2dq: Convert with truncation packed single precision floating-point values to packed signed doubleword integer values 
        ; cvtps2dq: Convert packed single precision floating-point values to packed signed doubleword integers

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


        ; packssdw: Converts packed signed doubleword integers into packed signed word integers
        packssdw xmm4, xmm4  ; xmm4 -> |  x0  |  x0  |  x0  |  x0  |  x0  |  x0  |  x0  |  x0  |
        packssdw xmm5, xmm5  ; xmm5 -> |  x1  |  x1  |  x1  |  x1  |  x1  |  x1  |  x1  |  x1  |
        packssdw xmm6, xmm6  ; xmm6 -> |  x2  |  x2  |  x2  |  x2  |  x2  |  x2  |  x2  |  x2  |
        packssdw xmm7, xmm7  ; xmm7 -> |  x3  |  x3  |  x3  |  x3  |  x3  |  x3  |  x3  |  x3  |


        ; packuswb: Converts signed word integers into unsigned byte integers
        packuswb xmm4, xmm4  ; xmm4 -> | x0 | x0 | x0 | x0 | x0 | x0 | x0 | x0 | x0 | x0 | x0 | x0 | x0 | x0 | x0 | x0 |
        packuswb xmm5, xmm5  ; xmm5 -> | x1 | x1 | x1 | x1 | x1 | x1 | x1 | x1 | x1 | x1 | x1 | x1 | x1 | x1 | x1 | x1 |
        packuswb xmm6, xmm6  ; xmm6 -> | x2 | x2 | x2 | x2 | x2 | x2 | x2 | x2 | x2 | x2 | x2 | x2 | x2 | x2 | x2 | x2 |
        packuswb xmm7, xmm7  ; xmm7 -> | x3 | x3 | x3 | x3 | x3 | x3 | x3 | x3 | x3 | x3 | x3 | x3 | x3 | x3 | x3 | x3 |

        ; Saco componentes que no corresponden
        movdqu xmm14, [dejar1ComponentePixel0]
        pand xmm4, xmm14 ; xmm4 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x0 |

        movdqu xmm14, [dejar1ComponentePixel1]
        pand xmm5, xmm14 ; xmm5 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x1 | 00 | 00 | 00 | 00 |

        movdqu xmm14, [dejar1ComponentePixel2]
        pand xmm6, xmm14 ; xmm6 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x2 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 |

        movdqu xmm14, [dejar1ComponentePixel3]
        pand xmm7, xmm14 ; xmm7 -> | 00 | 00 | 00 | x3 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 |


        ; xmm2 -> mascara con 1s donde los pixeles son iguales
        ; aplico mascara, shifteo y sumo
        pand xmm4, xmm2
        pand xmm5, xmm2
        pand xmm6, xmm2
        pand xmm7, xmm2

        psrldq xmm4, 3  ; xmm4 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x0 | 00 | 00 | 00 |
        pslldq xmm5, 2  ; xmm5 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x1 | 00 | 00 |
        pslldq xmm6, 7  ; xmm6 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x2 | 00 |
        pslldq xmm7, 12 ; xmm7 -> | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | x3 |

        paddb xmm10, xmm4
        paddb xmm10, xmm5
        paddb xmm10, xmm6
        paddb xmm10, xmm7

        psrldq xmm10, 12

        movd [rcx + r11], xmm10

        add r10, 16
        add r11, 4
        sub rax, 4
        jmp .loop

    .end:
        pop rbp
        ret
