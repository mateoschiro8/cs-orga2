
section .text

global invertirQW_asm

; void invertirQW_asm(uint8_t* p)

invertirQW_asm:
	;prologo
	push rbp
	mov rbp,rsp

	;Traer a un xmm 
	movdqu xmm0, [rdi]

	;Poner p2 en xmm1 y setearlo en la otra posicion
	movq xmm1, xmm0
	pslldq xmm1, 0x08

	; Poner p1 en la otra posicion
	psrldq xmm0, 0x08

	; Mergear las dos palabras
	paddq xmm0, xmm1

	; Llevar a memoria
	movdqu [rdi], xmm0

	;epilogo
	pop rbp
	ret
