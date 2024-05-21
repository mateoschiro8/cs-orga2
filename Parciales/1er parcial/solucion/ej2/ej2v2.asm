global YUYV_to_RGBA

section .rodata

mascaraDW128EnUyV: dd 0, 128, 0, 128
mascaraANDSacarA: dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000
mascaraANDSoloPixelBajo: dd 0xFFFFFFFF, 0x00000000, 0x00000000, 0x00000000
mascaraAND8bitsMenosSignCadaComponente: times 4 dd 0x000000FF

mascaraResultadoUyVIgualesA127: dd 0xFF00FF7F, 0xFF00FF7F, 0x00000000, 0x00000000 

floatsMascaraV: dd 0.0       , -0.698001, 1.370705, 0.0 
floatsMascaraU: dd 1.732446  , -0.337633, 0.0     , 0.0 
floatsMascaraA255: dd 0.0       , 0.0      , 0.0   , 255.0
;                     B          G          R         A

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; YUYV
; VYUY
;void YUYV_to_RGBA( int8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
; rdi -> X,     rsi -> Y,      rdx -> width,        rcx -> height           
YUYV_to_RGBA:
    push rbp
    mov rbp, rsp

    mov rax, rcx
    mul rdx ; rax -> width * height
    
    xor r8, r8 ; r8 -> offset input
    xor r9, r9 ; r9 -> offset output

    movdqu xmm9,  [mascaraAND8bitsMenosSignCadaComponente]
    movdqu xmm10, [mascaraDW128EnUyV]
    movups xmm11, [floatsMascaraV]
    movups xmm12, [floatsMascaraU]
    movups xmm13, [floatsMascaraA255]
    movdqu xmm14, [mascaraANDSacarA]
    movdqu xmm15, [mascaraANDSoloPixelBajo]

    ; trabajamos de a un pixel YUYV, dos pixeles RGBA como resultado
    .loop:
        cmp rax, 0
        je .end

        movd xmm0, [rdi + r8]  ; Traemos 1 struct Y1 U Y2 V
        
        ; xmm0 : | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | V0 | Y20 | U0 | Y10 |
        ;                                                                                      0x0
    
        pmovzxbd xmm0, xmm0 ; zero extend byte - dword
        
        ; xmm0 : |  V  |  Y2  |  U   |  Y1  |
        ;                               0x0

        ; Guardamos en xmm1 para comparacion de caso U = V = 127
        movdqu xmm1, xmm0 ;  xmm1 : |  V  |  Y2  |  U  |  Y1  |

        psubd xmm0, xmm10

        ; xmm0 : | V - 128 |  Y2  | U - 128 |  Y1  |
        ;                                      0x0
        
        ; A ESTA ALTURA YA SE RESTARON LOS 128

        ; xmm0 : |  V  |  Y2  |  U  |  Y1  |
        ;                              0x0

        ; Comparacion de caso U = V = 127
        
        pxor xmm7, xmm7 ; xmm7 -> va a mandar el resultado a memoria si son iguales
        
        psrldq xmm1, 4 ; ;  xmm1 : |  0  |  V  |  Y2  |  U  |
        
        movd ecx, xmm1 ; ecx -> componente U del pixel YUYV  
        
        psrldq xmm1, 8 ;  xmm1 : |  0  |  0  |  0  |  V  |

        movd edx, xmm1 ; edx -> componente V del pixel YUYV  
        
        cmp ecx, 127 
        jne .sigueLoop
        cmp edx, 127
        jne .sigueLoop

        movdqu xmm7, [mascaraResultadoUyVIgualesA127]
        jmp .endLoop

        .sigueLoop:

            cvtdq2ps xmm0, xmm0 ; xmm0 -> YUYV en float

            ; Hacemos shuffle para separar los structs

            pshufd xmm1, xmm0, 0b00110100
            pshufd xmm2, xmm0, 0b10110110

            ; xmm1 : |  Y1  |  V  |  U  |  Y1  |
            ; xmm2 : |  Y2  |  V  |  U  |  Y2  |
            ;                              0x0

            ; pixel: |  A  |  R  |  G  |  B  |   
            ;                            0x0
            
            ; armamos registros con todas Y para cada pixel

            ; xmm3 - 4 - 5 -> pixel 1
            
            pshufd xmm3, xmm1, 0b00000000
            pshufd xmm4, xmm1, 0b00101000 
            pshufd xmm5, xmm1, 0b00000101
            
            ; xmm3 : |  Y1  |  Y1  |  Y1  |  Y1  |
            ; xmm4 : |  Y1  |   V  |  V   |  Y1  |
            ; xmm5 : |  Y1  |  Y1  |  U   |  U  |
            
            ; xmm11 : |     0 | 1.370705 | -0.698001 |       0  |
            ; xmm12 : |     0 |        0 | -0.337633 | 1.732446 |

            ; pixel: |   A    |    R    |     G     |    B    |   
            ;                                           0x0
            
            mulps xmm4, xmm11
            mulps xmm5, xmm12

            ; xmm3 : |    Y1     |       Y1     |        Y1      |       Y1      |
            ; xmm4 : |     0     | 1.370705 * V |  -0.698001 * V |       0       | 
            ; xmm5 : |     0     |      0       | -0.337633 * U  | 1.732446 * U  |

            addps xmm3, xmm4
            addps xmm3, xmm5    

            ; xmm3 : |   Y1   | Y1 + 1.370705 * V  | Y1 - 0.698001 * V - 0.337633 * U  | Y1 + 1.732446 * U |

            pand xmm3, xmm14

            ; xmm3 : |   00   | Y1 + 1.370705 * V  | Y1 - 0.698001 * V - 0.337633 * U  | Y1 + 1.732446 * U |

            addps xmm3, xmm13

            ; xmm3 : |   255   | Y1 + 1.370705 * V  | Y1 - 0.698001 * V - 0.337633 * U  | Y1 + 1.732446 * U |

            

            ; xmm6 - 7 - 8 -> pixel 2
            
            pshufd xmm6, xmm2, 0b00000000
            pshufd xmm7, xmm2, 0b00101000 
            pshufd xmm8, xmm2, 0b00000101      
    
            
            ; xmm6 : |  Y2  |  Y2  |  Y2  |  Y2  |
            ; xmm7 : |  Y2  |   V  |  V   |  Y2  |
            ; xmm8 : |  Y2  |  Y2  |  U   |  U  |
            
            ; xmm11 : |     0 | 1.370705 | -0.698001 |       0  |
            ; xmm12 : |     0 |        0 | -0.337633 | 1.732446 |

            ; pixel: |   A    |    R    |     G     |    B    |   
            ;                                           0x0
            
            mulps xmm7, xmm11
            mulps xmm8, xmm12

            ; xmm6 : |    Y2     |       Y2     |        Y2      |       Y2      |
            ; xmm7 : |     0     | 1.370705 * V |  -0.698001 * V |       0       | 
            ; xmm8 : |     0    |       0       | -0.337633 * U  | 1.732446 * U  |

            addps xmm6, xmm7
            addps xmm6, xmm8    

            ; xmm6 : |   Y2   | Y2 + 1.370705 * V  | Y2 - 0.698001 * V - 0.337633 * U  | Y2 + 1.732446 * U |

            pand xmm6, xmm14

            ; xmm6 : |   00   | Y2 + 1.370705 * V  | Y2 - 0.698001 * V - 0.337633 * U  | Y2 + 1.732446 * U |

            addps xmm6, xmm13

            ; xmm6 : |   255   | Y2 + 1.370705 * V  | Y2 - 0.698001 * V - 0.337633 * U  | Y2 + 1.732446 * U |


            ; TENEMOS ENTONCES

            ; xmm3 : |   255   | Y1 + 1.370705 * V  | Y1 - 0.698001 * V - 0.337633 * U  | Y1 + 1.732446 * U |
            ; xmm6 : |   255   | Y2 + 1.370705 * V  | Y2 - 0.698001 * V - 0.337633 * U  | Y2 + 1.732446 * U |

            ; xmm3 : | A  | R  | G  | B  |
            ; xmm6 : | A  | R  | G  | B  |

            ; Intercambiamos los R y B porque entendimos mal el formato
            pshufd xmm3, xmm3, 0b11000110
            pshufd xmm6, xmm6, 0b11000110

            ; xmm3 : | A  | B  | G  | R  |
            ; xmm6 : | A  | B  | G  | R  |

            ;Convert Packed Single Precision Floating-Point Values to Packed SignedDoubleword Integer Values
            cvttps2dq xmm3, xmm3
            cvttps2dq xmm6, xmm6

            ; Para hacer el wrap around, nos quedamos con los 8 bits menos significativos de cada double word
            pand xmm3, xmm9
            packusdw xmm3, xmm3
            packuswb xmm3, xmm3

            pand xmm6, xmm9
            packusdw xmm6, xmm6
            packuswb xmm6, xmm6

            ; xmm3 : | A1 | R1 | G1 | B1 | A1 | R1 | G1 | B1 | A1 | R1 | G1 | B1 | A1 | R1 | G1 | B1 | 
            ; xmm6 : | A2 | R2 | G2 | B2 | A2 | R2 | G2 | B2 | A2 | R2 | G2 | B2 | A2 | R2 | G2 | B2 |

            pand xmm3, xmm15
            pand xmm6, xmm15

            ; xmm3 : | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | A1 | R1 | G1 | B1 | 
            ; xmm6 : | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | A2 | R2 | G2 | B2 |

            paddb xmm7, xmm6

            ; xmm7 : | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | A2 | R2 | G2 | B2 |
            
            pslldq xmm7, 4

            ; xmm7 : | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | A2 | R2 | G2 | B2 | 00 | 00 | 00 | 00 |

            paddb xmm7, xmm3

            ; xmm7 : | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | A2 | R2 | G2 | B2 | A1 | R1 | G1 | B1 |


            .endLoop:
                ; Cargamos a memoria
                movq [rsi + r9], xmm7

                add r8, 4
                add r9, 8

                dec rax
                jmp .loop        

    .end:
        pop rbp
        ret
