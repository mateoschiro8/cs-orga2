global maximosYMinimos_asm

section .data 
;mascara para las transparencias 
mascara:    db 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00

mascaraImpares: db 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0X00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00
mascaraPares: db 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0XFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00
mascaraShifter: db 2,0,1,3,6,4,5,7,10,8,9,11,14,12,13,15
;db 13,15,14,12,9,11,10,8,5,7,6,4,1,3,2,0
;########### SECCION DE TEXTO (PROGRAMA)
section .text
;void maximosYMinimos_asm(uint8_t *src, uint8_t *dst, uint32_t width, uint32_t height)
;los registros quedan con los siguientes valores: 
;rdi = src
;rsi = dst
;rdx = width
;rcx = height

maximosYMinimos_asm:
    push rbp 
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp,8

    mov r12, rdi ;r12 = src
    mov r13, rsi ;r13 = dst
    mov r14, rdx ;r14 = width
    mov r15, rcx ;r15 = height

    shr r14, 2 ;r14 = width/4 por que voy a procesar de a 4 pixeles 
xor r8,r8
;aplico la transparencia de la mascara a los pixeles de la imagen


;---------------------------------- Esto está de más y se pisa con lo que hago desp -----------------------------------------

   ; .ciclo: 
   ;     .recorroAncho:
   ;         movdqu xmm0, [r12] ;cargo 4 pixeles de la imagen
   ;         movdqu xmm1, [mascara] ;cargo 4 pixeles de la mascara
   ;         pand xmm0, xmm1 ;aplico la transparencia, seteando la mascara en 0 
   ;         movdqu [r13], xmm0 ;guardo los 4 pixeles de la imagen en destino
   ;         add r12, 16 ;avanzo 4 pixeles en la imagen
   ;         add r13, 16 ;avanzo 4 pixeles en la mascara
   ;         inc r8 
   ;         cmp r8, r14 ;comparo si llegue al final de la fila
   ;         jne .recorroAncho ;si no llegue al final de la fila, sigo recorriendo la fila
   ;         xor r8, r8 ;pongo en 0 el contador de ancho
   ;         loop .ciclo ;si no llegue al final de la imagen, sigo recorriendo la imagen
   ; ;esto me setea las mascaras en 0 
;


;--------------------------------------------------------------------------------------------------------

;ahora voy a buscar los maximos y minimos de cada fila dependiendo de la paridad de la columna 


; suponiendo que la imagen es de un tamaño multiplo de 4 pixeles que es de a los que yo voy a procesar
; mi idea es que siempre en el primer pixel busco el maximo, en el segundo el minimo y en el tercero el maximo y en el 4to el minimo
; veamos: |  busco max | busco min  | busco max | busco min | 
;me voy a hacer una mascara que se quede solo con los de paridad par y otra impar 
;las defini en el .data 
pxor xmm0, xmm0
pxor xmm1, xmm1
pxor xmm2, xmm2
pxor xmm3, xmm3
pxor xmm4, xmm4
pxor xmm5,xmm5
pxor xmm6, xmm6
movdqu xmm0, [mascaraPares] ;cargo la mascara de pares
movdqu xmm1, [mascaraImpares] ;cargo la mascara de impares


; la idea es la siguiente: 

; si tengo en un xmm esto | b | g | r | a | b | g | r | a | b | g | r | a | b | g | r | a |
;los pixeles pares son los que comienzan en una posicion par, como cuento desde cero en el xmm seran los 
;correspondientes a la dword 0 y 2 
; quiero quedarme con esto primero, (los pares) | 0 | 0 | 0 | 0 | b | g | r | a | 0 | 0 | 0 | 0 | b | g| r | a  
;las transparencias ya las volé y son 0 luego tengo 
; | 0 | 0 | 0 | 0 | b | g | r | 0 | 0 | 0 | 0 | 0 | b | g | r | 0 | (*k) 
; ahora aplico una vez la mascara de shift y lo guardo en otro xmm 
; | 0 | 0 | 0 | 0 | r | b | g | 0 | 0 | 0 | 0 | 0 | r | b | g| 0 | 
;ahora comparo por maximo entre lo que tenia en (*k) y lo que tengo ahora en otro xmm 
; un posible resultado será 
; | 0 | 0 | 0 | 0 | b | b | r | 0 | 0 | 0 | 0 | 0 | r | g | g  (*m)
;aprovecho que comienza a haber pixeles con el mismo valor y aplico de nuevo el shifteo sobre el resultado (*m)
; | 0 | 0 | 0 | 0 | r | b | b | 0 | 0 | 0 | 0 | 0 | g | r | g  (*n)
;realizo la comparacion de nuevo usando pmaxub , byte a byte entre (*m) y (*n)
; | 0 | 0 | 0 | 0 | b | b | b | 0 | 0 | 0 | 0 | 0 | g | g | g  (*o)
; lo agrego a un xmm hago lo mismo para los minimos pero cambiando pmaxub por pminub y lo guardo en la imagen destino 



mov rcx, r15 ;rcx = height
mov rbx, r15 ;rbx = height
.ciclo2: 
cmp rbx, 0 
je .fin ;si ya recorri todas las filas salgo
;opero los pares o sea seteo maximo 
xor r9, r9 
.recorroAncho2:
movdqu xmm2, [r12] ;cargo 4 pixeles de la imagen 
movdqu xmm3, [r12]
;laburo los maximos 
pand xmm3, xmm0 ;seteo en 0 los impares   ;b g r 
pand xmm2, xmm0 ;seteo en 0 los impares   ; b g r 

pshufb xmm2, [mascaraShifter] ;shifteo los pares  ; r b g 
pmaxub xmm3, xmm2                                 ; comparo b g r con r b g 

movdqu xmm2, xmm3                                 ;el resultado de la comparacion  b b g por ejemplo 
;de nuevo 
pshufb xmm2, [mascaraShifter]                     ;g b b 
pmaxub xmm3, xmm2                                 ;b b g cambie un par de registros xmm
                                                  ;b b b 

                                                  ;podria comparar de nuevo con b g r  

;ahora tengo en xmm3 los maximos de los pares 
movdqu xmm5, xmm3 ; voy preparando lo que va a guardarse en la imagen destino 

;vamos a laburar los impares y sacar los minimos 
movdqu xmm2, [r12] ;cargo 4 pixeles de la imagen 
movdqu xmm3, [r12]
pand xmm2, xmm1 ;seteo en 0 los pares 
pand xmm3, xmm1 ;seteo en 0 los pares

pshufb xmm2, [mascaraShifter] ;shifteo los impares  ;r b g 
pminub xmm3, xmm2                                   ;b g r 
                                                    ;b g g , a modo de ejemplo 
;de nuevo

;agrego los mismos cambios que arriba 
movdqu xmm2, xmm3                    


pshufb xmm2, [mascaraShifter]                      ;g b g 
pminub xmm3, xmm2                                  ;g g g 

;ahora tengo en xmm3 los minimos de los impares

paddb xmm5, xmm3 

;aca deberia de agregar lo de la mascara por que se me pisa cuando muevo esto a memoria 
pand xmm5, [mascara] ;asi piso las transparencias con 0 sin modificar lo demas 

movdqu [r13], xmm5 ;guardo los maximos en la imagen destino
add r13, 16 ;avanzo 4 pixeles en la imagen destino
add r12, 16 ;avanzo 4 pixeles en la imagen original
inc r9 
cmp r9, r14 
jne .recorroAncho2
xor r9, r9

dec rbx 
jmp .ciclo2

.fin: 
    add rsp,8 
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    mov rsp, rbp
    pop rbp 
    ret