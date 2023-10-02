section .rodata
shuffle:
    ; Registro leído de memoria
    ; |  0        |  1       |  2      |  3        |  4       |  5      |  6        |  7       |  8      |  9        | 10       | 11      | 12        | 13       | 14      | 15        |
    ; | x0[16:23] | x0[8:15] | x0[0:8] | x1[16:23] | x1[8:15] | x1[0:8] | x2[16:23] | x2[8:15] | x2[0:8] | x3[16:23] | x3[8:15] | x3[0:8] | x4[16:23] | x4[8:15] | x4[0:8] | x5[16:23] |
    ; Registro que queremos conseguir
    ; |  0 |  1 |  2 |  3 |  4 |  5 |  6 |  7 |  8 |  9 | 10 | 11 | 12 | 13 | 14 | 15 |
    ; | ?? | x0           | ?? | x1           | ?? | x2           | ?? | x3           |
    ; | FF |  2 |  1 |  0 | FF |  5 |  4 |  3 | FF |  8 |  7 |  6 | FF | 11 | 10 |  9 |
    ; Tenemos que tener en cuenta el byte-order!
    db 0xFF, 2, 1, 0, 0xFF, 5, 4, 3, 0xFF, 8, 7, 6, 0xFF, 11, 10, 9

section .text
global ejercicio_asm
ejercicio_asm:
    ; Vamos a procesar de a cuatro elementos porque es lo más sencillo.
    ; Shiftear dos bits a la derecha es lo mismo que dividir por 4.
    mov rcx, rsi
    shr rcx, 2
    ; Cargamos el shuffle que vamos a usar
    movdqu xmm1, [rel shuffle]
    ; Vamos a acumular nuestro resultado en xmm0
    pxor xmm0, xmm0
    .loop:
        ; Leemos los datos
        movdqu xmm2, [rdi]
        ; Acomodamos para que nos queden sólo 4 dwords
        pshufb xmm2, xmm1
        ; Shifteamos el byte que "nos faltaba" y de paso extendemos el signo
        psrad xmm2, 8
        ; Acumulamos los resultados
        paddd xmm0, xmm2
        add rdi, 12
    loop .loop
    ; Acumulamos horizontalmente
    phaddd xmm0, xmm0
    phaddd xmm0, xmm0
    ; Devolvemos el resultado
    movd eax, xmm0
    ret
