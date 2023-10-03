section .rodata

    divisor: times 4 dd 3.0 ; Nos definimos 4 palabras con el valor 3, para cargar en un registro xmm    
    mascara: times 2 dq 0x0000FFFFFFFFFFFF

section .text
global temperature_asm

;void temperature_asm(unsigned char *src,
;              unsigned char *dst,
;              int width,
;              int height,
;              int src_row_size,
;              int dst_row_size);

; *src rdi
; *dst rsi
; width rdx 
; height rcx 
; src_row_size r8
; dst_row_size r9

; Cada píxel ocupa 4 bytes (32 bits) -> (b, g, r, a) -> blue, green, red, transparencia. Cada uno ocupa 1 byte y transparencia es siempre 255

; t = (r + g + b) / 3

; dst <r, g, b> = | < 0, 0, 128 + t * 4 >                           si t < 32
;                 | < 0, (t - 32) * 4, 255 >                        si 32 <= t < 96
;                 | < (t - 96) * 4, 255, 255 - (t - 96) * 4 >       si 96 <= t < 160
;                 | < 255, 255 - (t - 160) * 4, 0 >                 si 160 <= t < 224
;                 | < 255 - (t - 224) * 4, 0, 0 >                   si no

; Nos traemos 2 pixeles a la vez, y los extendemos a 16 bits

; Nos quedan los registros así

; |  r1  |  g1  |  b1  |  a1  |  r2  |  g2  |  b2  |  a2  |

; Aplicamos una máscara para poner los valores de a en 0

; |  r1  |  g1  |  b1  |  00  |  r2  |  g2  |  b2  |  00  |

; Hacemos 2 sumas horizontales

; | r1 + g1 | b1 + 00 | r2 + g2 | b2 + 00 | r1 + g1 | b1 + 00 | r2 + g2 | b2 + 00 | r1 + g1 | b1 + 00 | r2 + g2 | b2 + 00 | r1 + g1 | b1 + 00 | r2 + g2 | b2 + 00 |   
; | r1 + g1 + b1 + 00 | r2 + g2 + b2 + 00 | r1 + g1 + b1 + 00 | r2 + g2 + b2 + 00 | r1 + g1 + b1 + 00 | r2 + g2 + b2 + 00 | r1 + g1 + b1 + 00 | r2 + g2 + b2 + 00 |
 
; Extendemos a 32 bits

; | r1 + g1 + b1 + 00 | r2 + g2 + b2 + 00 | r1 + g1 + b1 + 00 | r2 + g2 + b2 + 00 |

; Convertimos a float

; Dividimos por 3

; Truncamos los valores, y los agarramos por separado


temperature_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r15
    push rbx

    ; Cargamos en xmm6 el valor 3 cada 32 bits, para hacer después la división, en xmm7 la mascara
    movdqu xmm6, [divisor]
    movdqu xmm7, [mascara]

loop_matriz:
	; Comparamos la cantidad de filas restantes para ver si ya terminamos de llenar la matriz
	cmp rcx, 0
	je end

    sub rcx,0x01
	; Armar un registro temporal con width para llevar la cuenta de las posiciones que quedan en la fila
	;mov r11, rdx
    xor r11,r11
	; Loopear para las filas
	jmp loop_fila

loop_fila:

	; Hacer el compare para ver cuantas filas nos quedan por pintar
	cmp r11, r8
	je loop_matriz

	; Nos traemos 2 pixeles, los extendemos a 16 bits y adelantamos el puntero
	PMOVZXBW xmm0, [rdi]
	add rdi, 0x08	

    ; En xmm7 tenemos una mascara para eliminar el valor de a de cada pixel
    pand xmm0, xmm7
    
    ; Hacemos 2 sumas horizontales
    phaddw xmm0, xmm0
    phaddw xmm0, xmm0

    ; Extendemos a 32 bits
    PMOVZXWD xmm0, xmm0

    ; Convertimos a floats
    CVTDQ2PS xmm0, xmm0

    ; Dividimos por 3 (cargados en xmm6 cada 32 bits)
    divps xmm0, xmm6

    ; Truncamos y convertimos a enteros
    ; Manual -> Convert With Truncation Packed Single Precision Floating-Point Values to Packed Dword Integers
    ;CVTTPS2PI xmm0, xmm0  
	cvttps2dq xmm0,xmm0 ;lo trunca es decir le saca la parte decimal

    mov r14, 2 ; contador
    
ciclo_pixel:
    ; Guardamos en al los 8 bits bajos (t1)
    movd eax,xmm0
    ; Shifteamos r10 a la derecha para poner t1 en la parte baja, y movemos a otro registro
    psrldq xmm0, 4 

    cmp r14, 0
    je terminar_fila
    dec r14

    jmp comparacion_pixel

comparacion_pixel:
    ; Arrancamos las comparaciones
    ; Si es menor a 32
    cmp eax, 32
    jl primer_casouno

    ; Si es mayor o igual a 32 y menor a 96
    cmp eax, 96
    jl primer_casodos

    ; Si es mayor o igual a 96 y menor a 160
    cmp eax, 160
    jl primer_casotres

    ; Si es mayor o igual a 160 y menor a 224
    cmp eax, 224
    jl primer_casocuatro

    jmp primer_casocinco

primer_casouno:

    xor r15, r15

    add r15d, 0xFF ; transparencia
    shl r15d, 8

    shl r15d, 8 ; red

    shl r15d, 8 ;green
    
    imul eax, 4
    add eax, 128 
    add r15d, eax; blue

    mov [rsi],r15d ; paso al destino el color final
    add rsi, 4
    jmp ciclo_pixel

primer_casodos:

    xor r15, r15

    add r15d, 0xFF ; transparencia
    shl r15d, 8

    shl r15d, 8 ; red

    sub eax, 32
    imul eax, 4 ; green
    add r15d, eax 
    shl r15d, 8
    
    add r15d, 255 ; blue
    

    mov [rsi],r15d
    add rsi, 4
    jmp ciclo_pixel

primer_casotres:

    xor r15, r15

    add r15d, 0xFF ; transparencia
    shl r15d, 8

    sub eax, 96
    imul eax, 4
    add r15d, eax
    shl r15d, 8 ; red


    add r15d, 255 ; green
    shl r15d, 8


    add r15d, 255 ; blue
    sub r15d, eax

    mov [rsi],r15d
    add rsi, 4
    jmp ciclo_pixel

primer_casocuatro:

    xor r15, r15

    add r15d, 0xFF ; transparencia
    shl r15d, 8

    add r15d, 255 ; red
    shl r15d, 8

    sub eax, 160
    imul eax, 4
    add r15d, 255
    sub r15d, eax ; green
    shl r15d, 8

    ;shl r15, 8 ; blue

    mov [rsi],r15d
    add rsi, 4
    jmp ciclo_pixel

primer_casocinco:

    xor r15, r15

    add r15d, 0xFF ; transparencia
    shl r15d, 8

    add r15d, 255 
    sub eax, 224
    imul eax, 4 
    sub r15d, eax ; red
    shl r15d, 8

    shl r15d, 8 ; green

    ;shl r15d, 8 ; blue

    mov [rsi],r15d
    add rsi, 4
    jmp ciclo_pixel

terminar_fila:
	; Restamos la cantidad de elementos restantes y volvemos al loop
	add r11, 0x08
	jmp loop_fila

end:
    pop rbx
    pop r15
    pop r12
    pop rbp
    ret
