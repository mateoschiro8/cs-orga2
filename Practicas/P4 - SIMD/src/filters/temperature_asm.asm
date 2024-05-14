global temperature_asm

section .data

mascaraSinTransparencia: times 4 dd 0x00FFFFFF 
mascaraDivisionTres: times 4 dd 0x00000003
; xmm5 es registro temporal en calculo de casos.
; OJO PUEDE ESTAR MAL

mascaraR255: dd 0x00FF0000 , 0x00FF0000, 0x00FF0000, 0x00FF0000
mascaraG255: times 4 dd 0x0000FF00
mascaraB255: times 4 dd 0x000000FF
mascaraTransparencia: times 4 dd 0xFF000000  

mascaraTodos1:   times 16 db 1 ; para corregir jejee
mascaraTodos255: times 16 db 0xFF ; todos 255
mascaraTodos32:  times 16 db 0x1F ; 32 unsigned
mascaraTodos96:  times 16 db 0x5F ; 32 unsigned
mascaraTodos128: times 16 db 0x80 ; 128 unsigned
mascaraTodos160: times 16 db 0x9F; 159
mascaraTodos224: times 16 db 223

mascaraTodosUnos: times 4 dd 0xFFFFFFFF   ; 223 idem

mascaraShuffleT: dd 0x00000000, 0x01010101, 0x00000000, 0x01010101 ; tal vez sea al reves, ojo

section .text
;void temperature_asm(unsigned char *src,   -> rdi
;              unsigned char *dst,          -> rsi
;              int width,                   -> rdx 
;              int height,                  -> rcx
;              int src_row_size,            -> r8
;              int dst_row_size);           -> r9

; En memoria se guarda en el orden B, G, R, A

temperature_asm:
    push rbp
	mov rbp, rsp 
    
    imul rcx, rdx ; en rcx vamos a tener la cantidad de pixeles totales

    movdqu xmm8, [mascaraShuffleT]
    movdqu xmm9, [mascaraTodosUnos]

    movdqu xmm10, [mascaraSinTransparencia]
    movdqu xmm11, [mascaraDivisionTres]
    cvtdq2ps xmm11, xmm11 ; lo pasamos a float porque lo vamos a usar para dividir

    movdqu xmm12, [mascaraTodos32]
    movdqu xmm13, [mascaraTodos96]
    movdqu xmm14, [mascaraTodos160]
    movdqu xmm15, [mascaraTodos224]

    movdqu xmm1, [mascaraTodos128]
    paddb xmm12, xmm1
    paddb xmm13, xmm1
    paddb xmm14, xmm1
    paddb xmm15, xmm1
    pxor xmm1, xmm1
    xor r8, r8

    .loop:

        cmp rcx, 0  ; Cantidad de pixeles restantes
        je .end

        ; DIBUJOS AL REVES

        movq xmm0, [rdi + r8] ; Trae de memoria 4 pixeles
        ; xmm0 = | -- | -- | -- | -- | -- | -- | -- | -- | B1 | G1 | R1 | A1 | B0 | G0 | R0 | A0 |
        ;         0x0F                                                                           0x0
        
        pand xmm0, xmm10 ; sacamos la componente A de cada pixel
        ; xmm0 = | -- | -- | -- | -- | -- | -- | -- | -- | B1 | G1 | R1 | 00 | B0 | G0 | R0 | 00 |

        pmovzxbw xmm1, xmm0 ; Extendemos a words
        ; xmm1 = |   B1    |    G1   |    R1   |    00   |    B0   |    G0   |    R0   |    00   |

        phaddw xmm1, xmm1 ; Hacemmos las sumas horizontales 
        ; xmm1 = | B1 + G1 | R1 + 00 | B0 + G0 | R0 + 00 | B1 + G1 | R1 + 00 | B0 + G0 | R0 + 00 | 
        phaddw xmm1, xmm1
        ; xmm1 = |B1+G1+R1+00|B0+G0+R0+00|B1+G1+R1+00|B0+G0+R0+00|B1+G1+R1+00|B0+G0+R0+00|B1+G1+R1+00|B0+G0+R0+00|  
        
        pmovzxwd xmm1, xmm1 ; extendemos a double word las sumas
        ; xmm1 = |B1+G1+R1+00|B0+G0+R0+00|B1+G1+R1+00|B0+G0+R0+00|

        cvtdq2ps xmm1, xmm1 ; Convert packed double integers to packed single precision floating point values
        divps xmm1, xmm11 ; dividimos los valores por 3 con la mascara

        cvttps2dq xmm1, xmm1  ; Convertimos a entero 
        ; xmm1 = |  t1  |  t0  |  t1  |  t0  |

        packssdw xmm1, xmm1  ; Packs 32 bits (signado) a 16 bits (signado) usando saturation
        packuswb xmm1, xmm1  ; Packs 16 bits (signado) a 8 bits (unsigned) usando saturation
        ; xmm1 = | t1 | t0 | t1 | t0 | t1 | t0 | t1 | t0 | t1 | t0 | t1 | t0 | t1 | t0 | t1 | t0 |

        pshufb xmm1, xmm8
        ; xmm1 = | t1 | t1 | t1 | t1 | t0 | t0 | t0 | t0 | t1 | t1 | t1 | t1 | t0 | t0 | t0 | t0 |

        .armarResultados:
            ; xmm3 - xmm7
            pxor xmm7, xmm7 ; acumulador de resultados          

            .caso1:
                ; CASO 1, t menor a 32
                movdqu xmm3, xmm1

                ;multiplicamos temperatura por 4
                paddb xmm3, xmm3
                paddb xmm3, xmm3 ; 2*t + 2*t = 4t, los genio

                ; sumamos 128 a temperatura
                movdqu xmm5, [mascaraTodos128]
                paddb xmm3, xmm5 ; tenemos 4t + 128

                ; compare para armar mascara que nos deja el resultado solo si t es menor a 32
                movdqu xmm2, [mascaraTodos128]
                paddb xmm2, xmm1
                ; Compare packed signed int for greater than
                pcmpgtb xmm2, xmm12   ; t > 31, es igual a t >= 32
                pxor xmm2, xmm9       ; !(t > 31) -> t <= 31 -> t < 32

                ; hacemos el and con la mascara
                pand xmm3, xmm2
                movdqu xmm5, [mascaraB255] ; para quedarnos solamente con el pixel en la B, resto en 0 
                pand xmm3, xmm5 

                ; sumamos al resultado
                paddb xmm7, xmm3
            
            .caso2:
                ; CASO 2, t menor a 96 mayor igual a 32
                movdqu xmm3, xmm1

                ; restamos 32 a t
                movdqu xmm5, [mascaraTodos32]
                movdqu xmm6, [mascaraTodos1]
                paddb xmm5, xmm6
                psubb xmm3, xmm5

                ;multiplicamos por 4 el resultado
                paddb xmm3, xmm3
                paddb xmm3, xmm3 ; 2*t + 2*t = 4t, los genio

                ; comparaciones, t >= a 32 , t < 96 
                ; la mascara del 32 ya esta en xmm12
                movdqu xmm2, [mascaraTodos128]
                paddb xmm2, xmm1
                pcmpgtb xmm2, xmm12 ; t > 31, es igual a t >= 32

                ; la mascara del 96 ya esta en xmm13
                movdqu xmm4, [mascaraTodos128]
                paddb xmm4, xmm1
                pcmpgtb xmm4, xmm13 ; compare, t > 95

                pxor xmm4, xmm9 ; not(t > 95 = t >=96) -> t < 96
                pand xmm2, xmm4 ; combinamos ambas mascaras para tener la guarda de la funcion

                pand xmm3, xmm2 ; nos quedamos con el valor solo si estamos en el rango de t correspondiente
                movdqu xmm5, [mascaraG255] ; si estamos en rango, ademas nos quedamos con el valor solo en G
                pand xmm3, xmm5

                movdqu xmm5, [mascaraB255] ; traemos la mascara que pone 255 en B
                pand xmm5, xmm2 ; la limpiamos en caso de que el pixel no este en el rango de temperatura
                paddb xmm3, xmm5 ; ponemos la componente B en 255
                
                paddb xmm7, xmm3 ; mandamos al registro acumulador

            .caso3:
                ; CASO 3, t menor a 160 mayor igual a 96
                movdqu xmm3, xmm1

                ; restamos 96 a t
                movdqu xmm5, [mascaraTodos96]
                movdqu xmm6, [mascaraTodos1]
                paddb xmm5, xmm6
                psubb xmm3, xmm5

                ;multiplicamos por 4 el resultado
                paddb xmm3, xmm3
                paddb xmm3, xmm3 ; xmm3 -> (t - 96) * 4

                ; comparaciones, t >= a 96 , t < 160 
                ; la mascara del 96 ya esta en xmm13
                movdqu xmm2, [mascaraTodos128]
                paddb xmm2, xmm1
                pcmpgtb xmm2, xmm13 ; t > 96, es igual a t >= 96

                ; la mascara del 160 ya esta en xmm13
                movdqu xmm4, [mascaraTodos128]
                paddb xmm4, xmm1
                pcmpgtb xmm4, xmm14 ; compare, t < 160

                pxor xmm4, xmm9 ; not(t > 159 = t >= 160) -> t < 160
                pand xmm2, xmm4 ; combinamos ambas mascaras para tener la guarda de la funcion

                ; a partir de aca podemos usar xmm4 para otra cosa

                pxor xmm4, xmm4
                movdqu xmm4, [mascaraTodos255]
                
                movdqu xmm5, [mascaraB255] ; Para dejar solo la componenete B
                psubb xmm4, xmm3 ; hacemos b = 255 - (t - 96) * 4 . quedan en todos los bytes el resultado
                pand xmm4, xmm5   ; Nos queda 255 - (t - 96) * 4 en las componentes b
                
                movdqu xmm5, [mascaraR255]
                pand xmm3, xmm5 ; nos queda en las componentes r = (t - 96) * 4

                paddb xmm4, xmm3 ; Unimos componentes r y b

                movdqu xmm5, [mascaraG255]
                paddb xmm4, xmm5 ; agregamos g = 255

                pand xmm4, xmm2 ; aplicamos mascara de condicion
                paddb xmm7, xmm4 ; Agregamos el resultado al acumulado

            .caso4:
                ; CASO 4, t menor a 224 mayor igual a 160 
                movdqu xmm3, xmm1

                ; restamos 160 a t
                movdqu xmm5, [mascaraTodos160]
                movdqu xmm6, [mascaraTodos1]
                paddb xmm5, xmm6
                psubb xmm3, xmm5

                ;multiplicamos por 4 el resultado
                paddb xmm3, xmm3
                paddb xmm3, xmm3 ; xmm3 -> (t - 160) * 4

                ; comparaciones, t >= a 160 , t < 224 
                ; la mascara del 160 ya esta en xmm14
                movdqu xmm2, [mascaraTodos128]
                paddb xmm2, xmm1
                pcmpgtb xmm2, xmm14 ; t > 159, es igual a t >= 160

                ; la mascara del 224 ya esta en xmm15
                movdqu xmm4, [mascaraTodos128]
                paddb xmm4, xmm1
                pcmpgtb xmm4, xmm15 ; compare, t > 224

                pxor xmm4, xmm9 ; not(t > 223 = t >= 223) -> t < 224
                pand xmm2, xmm4 ; combinamos ambas mascaras para tener la guarda de la funcion

                ; a partir de aca podemos usar xmm4 para otra cosa

                pxor xmm4, xmm4
                movdqu xmm4, [mascaraTodos255]
                
                movdqu xmm5, [mascaraG255] ; Para dejar solo la componenete B
                psubb xmm4, xmm3 ; hacemos g = 255 - (t - 160) * 4 . quedan en todos los bytes el resultado
                pand xmm4, xmm5   ; Nos queda 255 - (t - 160) * 4 en las componentes g
                
                movdqu xmm5, [mascaraR255]
                paddb xmm4, xmm5 ; agregamos r = 255

                pand xmm4, xmm2 ; aplicamos mascara de condicion
                paddb xmm7, xmm4 ; Agregamos el resultado al acumulado



            .caso5:
                ; CASO 5, t Mayor igual a 224
                movdqu xmm3, xmm1

                ; restamos 224 a t
                movdqu xmm5, [mascaraTodos224]
                movdqu xmm6, [mascaraTodos1]
                paddb xmm5, xmm6
                psubb xmm3, xmm5

                ;multiplicamos por 4 el resultado
                paddb xmm3, xmm3
                paddb xmm3, xmm3 ; xmm3 -> (t - 224) * 4

                ; comparaciones, t >= a 224  
                ; la mascara del 224 ya esta en xmm15
                movdqu xmm2, [mascaraTodos128]
                paddb xmm2, xmm1
                pcmpgtb xmm2, xmm15 ; t > 223, es igual a t >= 224

                ; a partir de aca podemos usar xmm4 para otra cosa

                pxor xmm4, xmm4
                movdqu xmm4, [mascaraTodos255]
                
                movdqu xmm5, [mascaraR255] ; Para dejar solo la componenete B
                psubb xmm4, xmm3 ; hacemos r = 255 - (t - 224) * 4 . quedan en todos los bytes el resultado
                pand xmm4, xmm5   ; Nos queda 255 - (t - 224) * 4 en las componentes r

                pand xmm4, xmm2 ; aplicamos mascara de condicion
                paddb xmm7, xmm4 ; Agregamos el resultado al acumulado
                
            .cargarResultados:
            
                movdqu xmm6, [mascaraTransparencia]
                paddb xmm7, xmm6
                movq [rsi + r8], xmm7 


        .siguiente:
            add r8, 8 ; Porque cargamos de a 2 pixeles
            sub rcx, 2   
            jmp .loop    
        
    
    .end:
        pop rbp
        ret
