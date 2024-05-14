
OFFSET_8WORDS 	EQU	16

section .text

global dot_product_asm

; uint32_t dot_product_asm(uint16_t *p, uint16_t *q, uint32_t length);
; implementacion simd de producto punto

; p = rdi, q = rsi, length = rdx

dot_product_asm:
	;prologo
	push rbp
	mov rbp, rsp
	
	pxor xmm2, xmm2 ; parte alta de multiplicaciones
	pxor xmm3, xmm3 ; acumulador de sumas parciales 

	.loop:

		; check si no salimos de rango de los vectores, tambien chequea que no sea vacio de arranque.
		cmp rdx, 0
		je .end

		; traemos de a 8 extendiendo a doubleword
		movdqu xmm0, [rdi] 
		movdqu xmm1, [rsi]
		
		; armamos un registro temp para poder hacer multiplicaciones de parte baja y alta
		movdqu xmm2, xmm0
			
		;multiplicacion entre ambos xmm, queda en xmm0 la parte baja 
		pmulhw xmm2, xmm1
		pmullw xmm0, xmm1

		;copiamos el resultado low de la multiplicacion para usarlo de registro temporal al desempaquetar
		movdqu xmm1, xmm0
		
		;empaquetamos los resultados de la multiplicacion
		punpcklwd xmm0, xmm2 ; xmm0 = | hi:low(a3*b3) ... hi:low(0a*b0) |	
		punpckhwd xmm1, xmm2; xmm1 = | hi:low(a7*b7) ... hi:low(a4*b4) | ; la parte alta que pone en el resultado la agarra del operando destino!!!

		;sumamos ambos resultados al registro acumulador
		paddd xmm3, xmm1
		paddd xmm3, xmm0
	
		;seguir loop
		sub rdx, 8 ; restamos cantidad de elementos totales
		add rdi, OFFSET_8WORDS ; avanzamos punteros
		add rsi, OFFSET_8WORDS
		jmp .loop
	
	
	.end:
		;sumas horizontales
		phaddd xmm3, xmm3 ; xmm3 = | ... | ... | SUM3+SUM2 | SUM1+SUM0 |
		phaddd xmm3, xmm3 ; xmm3 = | ... | ... | ... | SUM3+SUM2+SUM1+SUM0 |

		movd eax, xmm3

		;epilogo
		pop rbp
		ret
