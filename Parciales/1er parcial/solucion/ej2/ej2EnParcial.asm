global YUYV_to_RGBA

section .rodata

mascaraShuffleSeparacion1: db 0x00, 0x01, 0x03, 0xFF, 0x02, 0x01, 0x03, 0xFF, 0x04, 0x05, 0x07, 0xFF, 0x06, 0x05 , 0x07, 0xFF
mascaraRestar128AUyV: dd 0, 128, 128, 0
mascaraPonerNegativo: dd 1.0, -1.0, 1.0, -1.0

mascaraDejarSolo2daDouble: dd 0, 0xFFFFFFFF, 0, 0

floats: dd 1.732446, 0.337633, 1.370705, 0.698001

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void YUYV_to_RGBA( int8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
; rdi -> X,     rsi -> Y,      rdx -> width,        rcx -> height           
YUYV_to_RGBA:
    push rbp
    mov rbp, rsp

    mov rax, rdx   ; rax -> width 
    mul rcx ; rax -> width * height

    movdqu xmm11, [mascaraDejarSolo2daDouble]
    movdqu xmm12, [mascaraShuffleSeparacion1]
    movdqu xmm13, [mascaraRestar128AUyV]
    movups xmm14, [floats]
    movups xmm15, [mascaraPonerNegativo]

    .loop:
        cmp rax, 0
        je .end

        movdqu xmm0, [rdi]   ; Traigo 4 structs YUYV

        ; xmm0 : | V3 | Y3_2 | U3 | Y3_1 | V2 | Y2_2 | U2 | Y2_1 | V1 | Y1_2 | U1 | Y1_1 | V0 | Y0_2 | U0 | Y0_1 |  
        ;        0x0F                                                                                       0x00  

        movdqu xmm1, xmm0

        pshufb xmm1, xmm12

        ; Renombre: El struct YUYV0 se convierte en YUV0 y YUV1, YUYV1 se convierte en YUV2 y YUV3

        ; xmm1 : | 00 | V3 | U3 | Y3 | 00 | V2 | U2 | Y2 | 00 | V1 | U1 | Y1 | 00 | V0 | U0 | Y0 |
        ;        0x0F                                                                      0x00

        ; Extiendo de byte a doubleword 
        pmovzxbd xmm2, xmm1

        ; xmm2 : |  00  |  V0  |  U0  |  Y0  |

        movdqu xmm4, xmm1

        ; xmm4 : | 00 | V3 | U3 | Y3 | 00 | V2 | U2 | Y2 | 00 | V1 | U1 | Y1 | 00 | V0 | U0 | Y0 |
        ;        0x0F                                                                      0x00

        ; Shift double quadword right logical
        psrldq xmm4, 4

        ; xmm4 : | 00 | 00 | 00 | 00 | 00 | V3 | U3 | Y3 | 00 | V2 | U2 | Y2 | 00 | V1 | U1 | Y1 |
        ;        0x0F                                                                       0x00

        pmovzxbd xmm3, xmm4

        ; xmm3 : |  00  |  V1  |  U1  |  Y1  |
        
        ; Tengo entonces

        ; xmm2 : |  00  |  V0  |  U0  |  Y0  |
        ; xmm3 : |  00  |  V1  |  U1  |  Y1  |

        ; xmm13 : |  00  |  128  |  128  |  00  |

        psubd xmm2, xmm13
        psubd xmm3, xmm13

        ; xmm2 : |  00  |  V0 - 128  |  U0 - 128  |  Y0  |
        ; xmm3 : |  00  |  V1 - 128  |  U1 - 128  |  Y1  |

        ; A ESTA ALTURA YA SE RESTARON LOS 128

        ; xmm2 : |  00  |  V0   |  U0   |  Y0  |
        ; xmm3 : |  00  |  V1   |  U1   |  Y1  |

        pshufd xmm5, xmm2, 0b10100101
        pshufd xmm6, xmm3, 0b10100101

        ; xmm5 : |  V0  |  V0   |  U0   |  U0  |
        ; xmm6 : |  V1  |  V1   |  U1   |  U1  |

        ; xmm14 : | 0.698001 | 1.370705 | 0.337633 | 1.732446 |

        mulps xmm5, xmm14
        mulps xmm6, xmm14

        ; xmm5 : |  V0 * 0.698001 |  V0 * 1.370705  |  U0 * 0.337633 |  U0 * 1.732446  |
        ; xmm6 : |  V1 * 0.698001 |  V1 * 1.370705  |  U1 * 0.337633 |  U1 * 1.732446  |

        ; A esta altura me di cuenta que V y U son iguales para los dos pixeles que estoy trabajando ahora

        ; El registro que quiero armar de cada pixel tiene que tener la forma
        ;  |  A  |  R  |  G  |  B  |
        ;                      0x00

        ; Armo registros con todas Y
        pshufd xmm7, xmm2, 0b11000000
        pshufd xmm8, xmm3, 0b11000000

        ; xmm7 : |  00  |  Y0   |  Y0   |  Y0  |
        ; xmm8 : |  00  |  Y1   |  Y1   |  Y1  |

        ;       |   A   |   R   |   G   |   B   |

        ; xmm15 : |  -1  |  1  |  -1   |    1  |

        mulps xmm5, xmm15
        mulps xmm6, xmm15

        ; xmm5 : |  - 0.698001 * V0  |  1.370705 * V0  |  - 0.337633 * U0  |  1.732446 * U0  |
        ; xmm6 : |  - 0.698001 * V1  |  1.370705 * V1  |  - 0.337633 * U1  |  1.732446 * U1  |

        paddd xmm7, xmm5
        paddd xmm8, xmm5

        ; xmm7 : |  - 0.698001 * V0  |  Y0 + 1.370705 * V0  |  Y0 - 0.337633 * U0  |  Y0 + 1.732446 * U0  |
        ; xmm8 : |  - 0.698001 * V1  |  Y1 + 1.370705 * V1  |  Y1 - 0.337633 * U1  |  Y1 + 1.732446 * U1  |

        ;       |   A   |   R   |   G   |   B   |

        ; R y B quedaron listos, queda armar G

        ; Armo un registro con - 0.698001 * V en todas las posiciones 

        pshufd  xmm9, xmm7, 0b11111111
        pshufd xmm10, xmm8, 0b11111111

        ;  xmm9 : |  - 0.698001 * V0  |  - 0.698001 * V0  |  - 0.698001 * V0  |  - 0.698001 * V0  |
        ; xmm10 : |  - 0.698001 * V1  |  - 0.698001 * V1  |  - 0.698001 * V1  |  - 0.698001 * V1  |

        ; Y uso una mascara para sacarme de encima los que no me sirven

        ; xmm9 : |  0  |  0  |  0xFFFFFFFF  |  0  |

        pand  xmm9, xmm11
        pand xmm10, xmm11

        ;  xmm9 : |  0  |  0  |  - 0.698001 * V0  |  0  |
        ; xmm10 : |  0  |  0  |  - 0.698001 * V1  |  0  |

        ; Y ahora puedo sumarlos 

        paddd xmm7, xmm9
        paddd xmm8, xmm10

        ; xmm7 : |  - 0.698001 * V0  |  Y0 + 1.370705 * V0  |  Y0 - 0.337633 * U0 - 0.698001 * V0  |  Y0 + 1.732446 * U0  |
        ; xmm8 : |  - 0.698001 * V1  |  Y1 + 1.370705 * V1  |  Y1 - 0.337633 * U1 - 0.698001 * V1  |  Y1 + 1.732446 * U1  |        

        ;       |   A   |   R   |   G   |   B   |

        ; Ahora solo me quedaría:
            ; Sacar el A con una máscara
            ; Convertir los floats a doubles
            ; Convertir los doubles a bytes
            ; Cargar a memoria ambos pixeles

            ; Y ver el caso cuando U = V = 127, que no lo contemplé


            ; Pero me quedé sin tiempo




        sub rax, 1  ; 1 struct menos procesado :D 
        jmp .loop


    .end:
        pop rbp
        ret
