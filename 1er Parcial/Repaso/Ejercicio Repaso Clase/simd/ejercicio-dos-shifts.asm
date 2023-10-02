;
; Dado un array de enteros con signo de 24 bits big-endian calcular su suma y
; devolverla como un entero de 32 bits con signo.
;
; - Asumir que el array tiene la alineación y el padding que necesiten.
; - Utilizar SIMD para el cálculo de la suma (no vale procesar el array de a
;   un numerito).
;
;     int32_t ejercicio_asm(int24_big_t* arr, uint64_t length);
;

section .rodata
align 16
mask: db 2, 1, 0, 0xFF, 5, 4, 3, 0xFF, 8, 7, 6, 0xFF, 0xB, 0xA, 9, 0xFF

section .text
global ejercicio_asm
ejercicio_asm:
	pxor xmm2, xmm2
	movdqa xmm1, [mask]

	mov rcx, rsi
	shr rcx, 2

.loop:
	movdqu xmm0, [rdi]
	pshufb xmm0, xmm1
	pslld xmm0, 8
	psrad xmm0, 8

	paddd xmm2, xmm0

	add rdi, 12
	loop .loop

	phaddd xmm2, xmm2
	phaddd xmm2, xmm2

	movd eax, xmm2
	ret
