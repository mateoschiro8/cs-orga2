global maximosYMinimos_asm

section .data 
; Mascara para transparencias 
mascaraTransp:  db 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00
mascaraPares:   db 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0XFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00
mascaraImpares: db 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0X00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00

;db 13,15,14,12,9,11,10,8,5,7,6,4,1,3,2,0
;########### SECCION DE TEXTO (PROGRAMA)

section .text
; maximosYMinimos_asm(uint8_t *src, uint8_t *dst, uint32_t width, uint32_t height)
;  src      -> rdi 
;  dst      -> rsi  
;  width    -> rdx  
;  height   -> rcx

maximosYMinimos_asm:
    push rbp 
    mov rbp, rsp

    push r12
    push r13

    mov r12, rdx  ; Ancho
    mov r13, rcx  ; Alto

    ; Mascara para sacar transparencias
    movdqu xmm5, [mascaraTransp]

    ; Mascara para sacar pares e impares
    movdqu xmm6, [mascaraPares]
    movdqu xmm7, [mascaraImpares]

    loopMatriz:

        ; Comparo la cantidad de filas que me quedan por recorrer
        cmp r13, 0
        je end

        sub r13, 1

        ; Restauro el ancho
        mov r12, rdx
        jmp loopFila

        loopFila:

            ; Comparo la cantidad de pixeles restantes en la fila
            cmp r12, 0
            je loopMatriz

            ; Me traigo 4 pixeles y adelanto el puntero
            movdqu xmm0, [rdi]
            add rdi, 16

            ; Pongo las transparencias en 0
            pand xmm0, xmm5

            ; Pongo los pixeles impares en xmm1, los pares quedan en xmm0
            ; (aplico mascaras para borrar los otros)
            movdqu xmm1, xmm0
            pand xmm1, xmm7 

            pand xmm0, xmm6

            ; Tengo entonces los registros así:

            ; xmm0 : | R0 | G0 | B0 | 00 | 00 | 00 | 00 | 00 | R2 | G2 | B2 | 00 | 00 | 00 | 00 | 00 |
            ; xmm1 : | 00 | 00 | 00 | 00 | R1 | G1 | B1 | 00 | 00 | 00 | 00 | 00 | R3 | G3 | B3 | 00 | 

            ; Tengo que encontrar el máximo de los valores de cada pixel en los pares
            ; y el mínimo en los impares

            ; Me traigo los pixeles a registros de 64 bits
            movq r9, xmm0
            psrldq xmm0, 8
            movq r8, xmm0

            shr r8, 32
            add r8, r9

            movq r11, xmm1
            psrldq xmm1, 8
            movq r10, xmm1

            shr r10, 32
            add r10, r11

            ; Tengo entonces los siguientes registros:

            ; r8 :  | R2 | G2 | B2 | 00 | R0 | G0 | B0 | 00 | 
            ; r10 : | R3 | G3 | B3 | 00 | R1 | G1 | B1 | 00 |

            ; Voy a usar los registros de 8 bits al, bl y dl para comparar

            ; Por cada pixel, comparo los 3 valores y tomo la decisión correspondiente

            ; Voy a ir armando los pixeles en xmm3 mediante r9, arranco poniendolos en 0
            pxor xmm3, xmm3
            xor r9, r9

            ; Muevo los valores del primer pixel
            shr r8, 8
            mov dl, byte r8b 
            shr r8, 8
            mov bl, byte r8b
            shr r8, 8
            mov al, byte r8b
            shr r8, 8

            ; Tengo entonces los siguientes registros:

            ; al : R0
            ; bl : G0
            ; dl : B0

            ; r8 :  | 00 | 00 | 00 | 00 | R2 | G2 | B2 | 00 | 
            ; r10 : | R3 | G3 | B3 | 00 | R1 | G1 | B1 | 00 |

            ; Y arranco las comparaciones para el primer pixel

            cmp al, bl
            jg  RmayoraG0
            jmp GmayoraR0

            RmayoraG0:   ; R0 > G0
            cmp al, dl
            jg Rmayor0
            jmp Bmayor0

            GmayoraR0:   ; G0 > R0
            cmp bl, dl
            jg Gmayor0
            jmp Bmayor0

            ; Una vez decidido cuál es el más grande, cargo en r9 tres veces ese valor
            ; y dejo uno vacío para transparencia

            Rmayor0:     ; R0 es el más grande
            add r9b, al
            shl r9, 8
            add r9b, al
            shl r9, 8
            add r9b, al
            shl r9, 8
            jmp segundoPixel
  
            Gmayor0:     ; G0 es el más grande
            add r9b, bl
            shl r9, 8
            add r9b, bl
            shl r9, 8
            add r9b, bl
            shl r9, 8
            jmp segundoPixel
  
            Bmayor0:     ; B0 es el más grande
            add r9b, dl
            shl r9, 8
            add r9b, dl
            shl r9, 8
            add r9b, dl
            shl r9, 8
            jmp segundoPixel

            ; Realizo el mismo proceso para el segundo pixel

            ; r9 : | 00 | 00 | 00 | 00 | x0 | x0 | x0 | 00 |

            ; Donde x0 es el máximo entre Ri, Bi, Gi
            
            segundoPixel:
  
            ; Muevo los valores del segundo pixel
            shr r10, 8
            mov dl, byte r10b 
            shr r10, 8
            mov bl, byte r10b
            shr r10, 8
            mov al, byte r10b
            shr r10, 8

            ; Tengo entonces los siguientes registros:

            ; al : R1
            ; bl : G1
            ; dl : B1

            ; r8 :  | 00 | 00 | 00 | 00 | R2 | G2 | B2 | 00 | 
            ; r10 : | 00 | 00 | 00 | 00 | R3 | G3 | B3 | 00 |

            ; Y arranco las comparaciones para el segundo pixel

            ; Shift para acomodar r9
            shl r9, 8

            cmp al, bl
            jg  RmayoraG1
            jmp GmayoraR1

            RmayoraG1:   ; R1 > G1
            cmp al, dl
            jg Rmayor1
            jmp Bmayor1

            GmayoraR1:   ; G1 > R1
            cmp bl, dl
            jg Gmayor1
            jmp Bmayor1

            ; Una vez decidido cuál es el más grande, cargo en r9 tres veces ese valor
            ; y dejo uno vacío para transparencia

            Rmayor1:     ; R1 es el más grande
            add r9b, al
            shl r9, 8
            add r9b, al
            shl r9, 8
            add r9b, al
            shl r9, 8
            jmp tercerPixel
  
            Gmayor1:     ; G1 es el más grande
            add r9b, bl
            shl r9, 8
            add r9b, bl
            shl r9, 8
            add r9b, bl
            shl r9, 8
            jmp tercerPixel
  
            Bmayor1:     ; B1 es el más grande
            add r9b, dl
            shl r9, 8
            add r9b, dl
            shl r9, 8
            add r9b, dl
            shl r9, 8
            jmp tercerPixel

            ; Realizo el mismo proceso para el tercer pixel

            ; r9 : | x0 | x0 | x0 | 00 | x1 | x1 | x1 | 00 |

            ; Donde: xi es el máximo entre Ri, Bi, Gi

            tercerPixel:
  
            ; Una vez que llené r9, lo cargo en la memoria y lo vuelvo a 0
            mov [rsi], r9
            add rsi, 8 
            xor r9, r9

            ; Muevo los valores del tercer pixel
            shr r8, 8
            mov dl, byte r8b 
            shr r8, 8
            mov bl, byte r8b
            shr r8, 8
            mov al, byte r8b
            shr r8, 8

            ; Tengo entonces los siguientes registros:

            ; al : R2
            ; bl : G2
            ; dl : B2

            ; r8 :  | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 
            ; r10 : | 00 | 00 | 00 | 00 | R3 | G3 | B3 | 00 |

            ; Y arranco las comparaciones para el tercer pixel

            cmp al, bl
            jg  RmayoraG2
            jmp GmayoraR2

            RmayoraG2:   ; R2 > G2
            cmp al, dl
            jg Rmayor2
            jmp Bmayor2

            GmayoraR2:   ; G2 > R2
            cmp bl, dl
            jg Gmayor2
            jmp Bmayor2

            ; Una vez decidido cuál es el más grande, cargo en r9 tres veces ese valor
            ; y dejo uno vacío para transparencia

            Rmayor2:     ; R2 es el más grande
            add r9b, al
            shl r9, 8
            add r9b, al
            shl r9, 8
            add r9b, al
            shl r9, 8
            jmp cuartoPixel
  
            Gmayor2:     ; G2 es el más grande
            add r9b, bl
            shl r9, 8
            add r9b, bl
            shl r9, 8
            add r9b, bl
            shl r9, 8
            jmp cuartoPixel
  
            Bmayor2:     ; B2 es el más grande
            add r9b, dl
            shl r9, 8
            add r9b, dl
            shl r9, 8
            add r9b, dl
            shl r9, 8
            jmp cuartoPixel

            ; Realizo el mismo proceso para el cuarto pixel

            cuartoPixel:

            ; Muevo los valores del tercer pixel
            shr r10, 8
            mov dl, byte r10b 
            shr r10, 8
            mov bl, byte r10b
            shr r10, 8
            mov al, byte r10b
            shr r10, 8

            ; Tengo entonces los siguientes registros:

            ; al : R3
            ; bl : G3
            ; dl : B3

            ; r8 :  | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 
            ; r10 : | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 |

            ; Y arranco las comparaciones para el cuarto pixel

            ; Shift para acomodar r9
            shl r9, 8
            
            cmp al, bl
            jg  RmayoraG3
            jmp GmayoraR3

            RmayoraG3:   ; R3 > G3
            cmp al, dl
            jg Rmayor3
            jmp Bmayor3

            GmayoraR3:   ; G3 > R3
            cmp bl, dl
            jg Gmayor3
            jmp Bmayor3

            ; Una vez decidido cuál es el más grande, cargo en r9 tres veces ese valor
            ; y dejo uno vacío para transparencia

            Rmayor3:     ; R3 es el más grande
            add r9b, al
            shl r9, 8
            add r9b, al
            shl r9, 8
            add r9b, al
            shl r9, 8
            jmp cargarPixel
  
            Gmayor3:     ; G3 es el más grande
            add r9b, bl
            shl r9, 8
            add r9b, bl
            shl r9, 8
            add r9b, bl
            shl r9, 8
            jmp cargarPixel
  
            Bmayor3:     ; B3 es el más grande
            add r9b, dl
            shl r9, 8
            add r9b, dl
            shl r9, 8
            add r9b, dl
            shl r9, 8
            jmp cargarPixel

            cargarPixel:

            ; Una vez que llené r9, lo cargo en la memoria y lo vuelvo a 0
            mov [rsi], r9
            add rsi, 8
            xor r9, r9

            ; Disminuyo la cantidad de elementos restantes en la fila, y vuelvo a arrancar
            sub r12, 4
            jmp loopFila

    end:
    
        pop r13
        pop r12

        pop rbp 
        ret