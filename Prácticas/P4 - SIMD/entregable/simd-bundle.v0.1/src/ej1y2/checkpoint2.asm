
section .text

global checksum_asm

; uint8_t checksum_asm(void* array, uint32_t n)

checksum_asm:
	push rbp
	mov rbp, rsp

	; Traer A y B 
	mov xmm0, [rdi]
	mov xmm1, [rdi + 0x10]

	; Traer C
	mov xmm2, [rdi + 0x20]
	mov xmm3, [rdi + 0x30]

	; Calcular la suma
	paddw xmm0, xmm1

	; Copiar a xmm1 el resultado y shiftear xmm0 para tener la parte alta del registro
	movdqa xmm1, xmm0
	psrldq xmm0, 0x08

	; Extender el signo
	pmovsxwd xmm0, xmm0
	pmovsxwd xmm1, xmm1	

	; Multiplicar por 8 ambos registros
	pslld xmm0, 0x03
	pslld xmm1, 0x03

	; Comparar para ver si se mantiene la relacion
	pcmpeqd xmm0, xmm2
	pcmpeqd xmm1, xmm3

	; Dejar en la dword menos significativa la suma de los resultados de la comparacion (si todos son iguales debe ser 4)
	phaddd xmm0, xmm0
	phaddd xmm0, xmm0

	phaddd xmm1, xmm1
	phaddd xmm1, xmm1

	



	pop rbp
	ret

