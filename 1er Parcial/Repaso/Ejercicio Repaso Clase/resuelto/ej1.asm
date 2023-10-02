; exportamos:
global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm

; importamos:
extern calloc
extern strcmp

; definimos:
%define OFFSET_MONTO 	0
%define OFFSET_COMERCIO 8
%define OFFSET_CLIENTE  16
%define OFFSET_APROBADO 17

%define SIZE_PAGO_T		24
%define SIZE_UIN32_T    4
%define SIZE_POINTER 	8
%define NULL			0


;########### SECCION DE TEXTO (PROGRAMA)
section .text

;uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos)
; RDI -> cantidadDePagos . RSI -> arr_pagos
acumuladoPorCliente_asm:
	push rbp
	mov rbp, rsp

	push r12
	push r13
	push r15
	sub rsp, 8			; alineamos la pila

	mov r12, rdi		; r12 <- cantidadDePagos
	mov r13, rsi		; r13 <- arr_pagos

	mov rdi, 10
	mov rsi, SIZE_UIN32_T
	call calloc

	xor r15, r15  		; a r15 lo usaremos para guardarnos el pago_i.cliente
	xor rdi, rdi		; a rdi lo usaremos para el pago_i.monto

	xor rcx, rcx 		; inicializamos iterador ciclo en 0

	.ciclo:
		cmp rcx, r12
		jge .finCiclo

		cmp byte [r13 + OFFSET_APROBADO], 1 ; if (pago_i.aprobado == 1)
		jne .proxIteracion

		; Esto esta mal! Pensar por que se rompe:
		;mov r15, [r13 + OFFSET_CLIENTE] 	; r15b <- pago_i.cliente
		;mov rdi, [r13 + OFFSET_MONTO]		; rdi <- pago_i.monto
		;add [rax + r15 * OFFSET_MONTO], rdi	; directamente vamos trabajando con el rax

		;Forma correcta:
		mov r15b, [r13 + OFFSET_CLIENTE] 	; r15b <- pago_i.cliente
		mov dil, [r13 + OFFSET_MONTO]		; dil <- pago_i.monto
		add [rax + r15 * SIZE_UIN32_T], dil	; directamente vamos trabajando con el rax


		.proxIteracion:
		inc rcx
		add r13, SIZE_PAGO_T
		jmp .ciclo

	.finCiclo:

	add rsp, 8		
	pop r15
	pop r13
	pop r12
	pop rbp
	ret

; uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n)
; RDI -> comercio . RSI -> lista_comercios . RDX -> n
en_blacklist_asm:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14

	mov r12, rdi		; r12 <- comercio
	mov r13, rsi		; r13 <- lista_comercios
	mov r14, rdx		; r14 <- n

	xor r15, r15

	.ciclo:
		cmp r15, r14
		jge .finCiclo

		mov rdi, r12 		; <- Que pasaria si sacasemos esta linea (total, el rdi que nos llega a nosotros seria el mismo que el que le pasamos
							; a strcmp)   [Respuesta en respuestas.txt 2)a), primero pensarla!]
		mov rsi, [r13]
		call strcmp			

		cmp rax, 0
		je .encontrado

		.proxIteracion:
		inc r15
		add r13, SIZE_POINTER
		jmp .ciclo
	
	.finCiclo:
		xor rax, rax
		jmp .fin
	.encontrado:
		mov rax, 1

	.fin:
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

; Funcion auxiliar para blacklistComercios_asm. Mismos parametros (y mismo orden)
contar_en_blacklist:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx

	mov r12, rdi 	; r12 -> cantidad_pagos
	mov r13, rsi	; r13 -> arr_pagos
	mov r14, rdx	; r14 -> arr_comercios
	mov r15, rcx	; r15 -> size_comercios

	xor rbx, rbx	; variable contador
	.ciclo:
		cmp r12, 0
		je .finCiclo

		mov rdi, [r13 + OFFSET_COMERCIO]
		mov rsi, r14
		mov rdx, r15
		call en_blacklist_asm		; en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios)
		cmp rax, 1
		jne .proxIteracion

		;; cuerpo if
		inc rbx
		;;

		.proxIteracion:
		dec r12
		add r13, SIZE_PAGO_T
		jmp .ciclo

	.finCiclo:

	; el resultado nos quedo en rbx, lo movemos a rax para retornarlo:
	mov rax, rbx

	.fin:
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret


;pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios)
; RDI -> cantidad_pagos . RSI -> arr_pagos . RDX -> arr_comercios . RCX -> size_comercios
blacklistComercios_asm:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx

	mov r12, rdi 	; r12 -> cantidad_pagos
	mov r13, rsi	; r13 -> arr_pagos
	mov r14, rdx	; r14 -> arr_comercios
	mov r15, rcx	; r15 -> size_comercios

	call contar_en_blacklist		; contar_en_blacklist recibe los mismos parametros
	mov rdi, rax
	mov rsi, SIZE_POINTER
	call calloc
	mov rbx, rax

	xor rbx, rbx					; Variable contador.

	.ciclo:							; Practicamente igual que contar_en_blacklist
									; solo cambia lo que hacemos en el cuerpo del if.

		cmp r12, 0
		je .finCiclo

		mov rdi, [r13 + OFFSET_COMERCIO]
		mov rsi, r14
		mov rdx, r15
		call en_blacklist_asm		
		cmp rax, 1
		jne .proxIteracion 			
		
		;; cuerpo if
		mov [rbx], r13
		add rbx, SIZE_POINTER
		;;

		.proxIteracion:
		dec r12
		add r13, SIZE_PAGO_T
		jmp .ciclo

	.finCiclo:
	mov rax, rbx

	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
