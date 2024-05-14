
;void Pintar_asm(unsigned char *src, rdi
;              unsigned char *dst, rsi
;              int width, rdx           	-> Ancho en pixeles
;              int height,  rcx				-> Alto en pixeles
;              int src_row_size, r8			-> Ancho en bytes de cada fila
;              int dst_row_size); r9		

; El ancho es multiplo de 8

; En memoria se guarda en el orden B, G, R, A
;  A R G B 
section .rodata

mascaraPixelNegro:    dd 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000 
mascaraTodosBlancos:  dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
mascaraPrincipioFila: dd 0xFF000000, 0xFF000000, 0xFFFFFFFF, 0xFFFFFFFF
mascaraFinalFila:     dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFF000000, 0xFF000000

section .text

global Pintar_asm

Pintar_asm:
	push rbp
	mov rbp, rsp 
	push r12
	push r13

	movdqu xmm0, [mascaraPixelNegro] ; 4 pixeles negros
	movdqu xmm1, [mascaraPrincipioFila] ; 2 negros 2 blancos
	movdqu xmm2, [mascaraTodosBlancos] ; 4 blancos
	movdqu xmm3, [mascaraFinalFila] ; 2 blancos 2 negros
	
	.pintarDosNegras:
		
		mov r12, rdx  ; Copiamos el ancho en pixeles
		.loopFilaNegra:
		
			movdqu [rsi], xmm0 ; Copiamos los primeros 4 pixeles negros en memoria
			movdqu [rsi + r8], xmm0  ; + offset para pintar dos filas a la vez

			add rsi, 16 ; movemos el puntero del dst
			sub r12, 4  ; restamos el acumulador de pixeles restantes
			cmp r12, 0  ; Si no terminamos la fila
			jne .loopFilaNegra

		sub rcx, 2  ; restamos 2 a la cantidad de filas restantes

		add rsi, r8 ; como pintamos de a 2 filas, movemos rsi a la proxima fila que es la primera que va de blanco
  
		cmp rcx, 0 ; para saber si estamos en las ultimas dos filas
		je .end
		
	.loop: 
		mov r12, rdx  ; Copiamos el ancho en pixeles
		;chequear si nos quedan solamente las ultimas dos para saltar a pintar dos negras
		cmp rcx, 2
		je .pintarDosNegras

		.loopFila:
			cmp r12, rdx
			je .primeros4PixelesFila  ; Si estamos en el borde izquierdo
			
			cmp r12, 4   
			je .ultimos4PixelesFila ; Si estamos en el borde derecho 

			movdqu [rsi], xmm2 ; Copiamos a memoria 4 pixel Blanco
			
			sub r12, 4  ; restamos el acumulador de pixeles restantes
			add rsi, 16	 ; Avanzamos puntero
			
			jmp .loopFila
				
	.primeros4PixelesFila: 
		movdqu [rsi], xmm1 ; Copiamos a memoria 2 pixeles Blanco y 2 negros
		add rsi, 16	 ; Avanzamos puntero
		sub r12, 4	; restamos el acumulador de pixeles restantes
		jmp .loopFila
	
	.ultimos4PixelesFila:
		movdqu [rsi], xmm3 ; Copiamos a memoria 2 pixeles Blanco y 2 negros
		add rsi, 16 ; Avanzamos puntero
		sub r12, 4	; restamos el acumulador de pixeles restantes
		sub rcx, 1
		jmp .loop

	.end:
		pop r13
		pop r12
		pop rbp
		ret
	
