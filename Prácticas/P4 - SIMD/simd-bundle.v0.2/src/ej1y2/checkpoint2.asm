
section .text

global checksum_asm

; uint8_t checksum_asm(void* array, uint32_t n)

checksum_asm:
	push rbp
	mov rbp, rsp

looop:
	; | A0 | A1 | ... | A8 | B0 | B1 | .. | B8 |  C0  |  C1  |  ...  |  C8  | 

	; Traer la parte baja de A y B, extendiendo a 32 bits con 0's en las posiciones altas
	PMOVZXWD xmm0, [rdi]
	PMOVZXWD xmm1, [rdi + 0x10]

	; Traer  la parte alta de A y B, extendiendo a 32 bits con 0's en las posiciones altas
	PMOVZXWD xmm2, [rdi + 0x08]
	PMOVZXWD xmm3, [rdi + 0x18]

	; Traer 4 posiciones de C 
	movups xmm4, [rdi + 0x20]
	movups xmm5, [rdi + 0x30]

	; Calcular la suma,la guardamos en xmm0
	paddd xmm0, xmm1
	paddd xmm2, xmm3

	; Multiplicar por 8 el resultado de la suma
	pslld xmm0, 0x03
	pslld xmm2, 0x03

	; Comparar para ver si se mantiene la relacion de la suma con C.
	pcmpeqd xmm0, xmm4
	pcmpeqd xmm2, xmm5
	
	; Llenar un registro con 1's para negar el resultado de la comparacion anterior
	pcmpeqd xmm7, xmm7

	; Negar el resultado de xmm0 y de xmm2
	pxor xmm0, xmm7
	pxor xmm2, xmm7

	; Hacer una suma horizontal para que en la palabra menos significativa tengamos la suma de la comparacion negada (que deberia ser 0 en caso de igualdad)
	phaddd xmm0, xmm0
	phaddd xmm0, xmm0

	phaddd xmm2, xmm2
	phaddd xmm2, xmm2

	; Llevar el resultado de la suma a eax para determinar si seguir comparando o no
	movq rax, xmm0
	movq r11, xmm2
	add rax, r11
	cmp rax, 0x0
	
	; En caso de que la suma haya sido 0, seguimos con el loop. 0x40 es el offset de la secuencia de ternas
	je check_tam

	; Si no fue 0, saltamos a la etiqueta de fin
	jmp end

check_tam:
	; Disminuir en 1 el tam que queda por recorrer
	sub rsi, 0x01

	; Si tam es 0, entonces recorrimos todo por lo tanto son iguales
	jz son_iguales
	add rdi, 0x40

	; Si no, seguimos con el loop
	jmp looop

son_iguales:
	; Ponemos el 1, y retornamos
	mov rax, 0x01
	pop rbp
	ret

end:
	; Ponemos el 0, y retornamos
	mov rax, 0x00
	pop rbp
	ret
