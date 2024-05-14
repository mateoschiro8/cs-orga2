
section .rodata

mascaraTodosCeros: times 32 db 0x00
mascaraTodosUnos: times 32 db 0xFF
mascaraConservarValores: times 32 db 0x0F ; Nos quedamos solo con los valores de las cartas,nos sacamos el suit de encima
mascaraShuffleShiftIzq: dd 0x02010003, 0x06050407, 0x0A09080B, 0x0E0D0C0F  ; Nueva
; mascaraShuffleShiftIzq: dd 0x0E0D0C0F, 0x0A09080B, 0x0605040C, 0x02010003  ; Original
mascaraComparacionTres: times 4 dd 0x00000003

section .text

global four_of_a_kind_asm

; uint32_t four_of_a_kind_asm(card_t *hands, uint32_t n);
; *hands -> rdi, n -> rsi

four_of_a_kind_asm:
	;prologo
	push rbp
	mov rbp, rsp 

	shr rsi, 2 ; Dividimos por 4 la cantidad de manos 

	movdqu xmm8, [mascaraConservarValores]  ; Mascara para conservar los valores y sacarnos los palos
	movdqu xmm9, [mascaraShuffleShiftIzq]   ; Mascara para shiftear los valores a la izquierrda
	movdqu xmm10, [mascaraTodosCeros] 		 ; Mascara para comparar con ceros
	movdqu xmm11, [mascaraComparacionTres]  ; Mascara para comparar con el 3
	movdqu xmm12, [mascaraTodosUnos]

	pxor xmm4, xmm4 ; ponemos en 0 registros para acumular las comparaciones
	pxor xmm5, xmm5
	pxor xmm6, xmm6

	xor rax, rax

	.loop:

		cmp rsi, 0  ; Comparamos la cantidad de manos restantes
		je .end

		movdqu xmm0, [rdi] ; Traemos 4 manos

		; xmm0 = A | B | C | D para las 4 manos

		pand xmm0, xmm8 ; Aplicamos mascara de valores

		; Aplicamos la mascara para shiftear
		movdqu xmm1, xmm0  
		pshufb xmm1, xmm9 ; xmm1 = B | C | D | A para las 4 manos
		
		; llevamos a xxm2 el resultado anterior y shifteamos otra vez
		movdqu xmm2, xmm1
		pshufb xmm2, xmm9 ; xmm2 = C | D | A | B
		
		; llevamos a xxm3 el resultado anterior y shifteamos otra vez
		movdqu xmm3, xmm2
		pshufb xmm3, xmm9 ; xmm3 = D | A | B | C;

		; hacemos las copias de xmm0 para guardar los resultados
		movdqu xmm4, xmm0
		movdqu xmm5, xmm0
		movdqu xmm6, xmm0
		
		; Restamos a la mano original las 3 manos shifteadas 
		psubb xmm4, xmm1 
		psubb xmm5, xmm2
		psubb xmm6, xmm3

		; Comparamos las 3 restas con 0 para chequear que las manos sean efectivamente de las mismas cartas 
		pcmpeqb xmm4, xmm10 
		pcmpeqb xmm5, xmm10
		pcmpeqb xmm6, xmm10
		
		; Comparamos cada MANO con 0 para ver si las cartas eran iguales
		pcmpeqd xmm4, xmm12
		pcmpeqd xmm5, xmm12
		pcmpeqd xmm6, xmm12

		; Shifteamos a izquierda y derecha para quedarnos con el bit menos significativo
		pslld xmm4, 31        
		pslld xmm5, 31
		pslld xmm6, 31 

		psrld xmm4, 31
		psrld xmm5, 31
        psrld xmm6, 31

		; Sumas verticales para ver cuantas restas dieron iguales
		paddd xmm4, xmm5
		paddd xmm4, xmm6
		
		; Comparamos con 3 para ver si son todas cartas iguales
		pcmpeqd xmm4, xmm11

		; Shifteamos el resultado
		pslld xmm4, 31  
		psrld xmm4, 31				

		; Sumas horizontales y sumamos al contador
		phaddd xmm4, xmm4
		phaddd xmm4, xmm4 

		; Movemos y sumamos al contador
		movd ecx, xmm4
		add eax, ecx

		; Incrementamos el puntero y loopeamos
		add rdi, 16

		dec rsi
		jmp .loop
 
	.end:
		;epilogo
		pop rbp
		ret


