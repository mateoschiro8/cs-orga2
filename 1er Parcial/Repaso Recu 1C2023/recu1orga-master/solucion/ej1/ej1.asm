global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm
extern malloc  
extern strcmp
extern CantEnBlacklist

section .data 
%define SIZE_UINT32_T 4 
%define OFFSET_MONTO 0
%define OFFSET_COMERCIO 8
%define OFFSET_CLIENTE 16
%define OFFSET_APROBADO 17
%define SIZE_STRUCT 24
%define UINT32_SIZE 4
%define SIZE_PUNTERO_A_PAGO 8


;########### SECCION DE TEXTO (PROGRAMA)
section .text


acumuladoPorCliente_asm:
	push rbp 
	mov rbp, rsp
	push r15
	push r14 
	push r13 
	sub rsp, 8


	xor r15,r15
	xor r14,r14
	xor rcx,rcx
	;los paso a registros no volatiles porque voy a llamar a malloc 
	mov r15, rdi ;cantidad de pagos en el arreglo de pagos 
	mov r14, rsi ;arreglo de pagos

	;reservo memoria para el arreglo de acumulados
	mov rdi, 10 
	imul rdi, SIZE_UINT32_T
	
	;pido memoria para 10 enteros de 32 bits 
	call malloc
	mov rdi, rax ;guardo la direccion de memoria donde empieza el arreglo de acumulados
	mov r13,rdi ;guardo la direccion de memoria donde empieza el arreglo de acumulados por cliente 
	;inicializo el arreglo de acumulados en 0

	mov rcx, 10 
	.inicializo:
		mov dword [rdi], 0
		add rdi, SIZE_UINT32_T
		loop .inicializo

	;armo el ciclo general 
	mov rcx, r15 ;cantidad de pagos en el arreglo de pagos
	.ciclo: 
		xor rax,rax ;pongo en 0 para limpiar 
		;me fijo que el pago este aprobado 
		mov al, [r14 + OFFSET_APROBADO]
		cmp rax, 1
		jne .no_aprobado
		;si esta aprobado lo sumo al acumulado del cliente
		mov al, [r14 + OFFSET_CLIENTE]
		xor rdi,rdi
		mov dil, [r14 + OFFSET_MONTO]
		add [r13 + rax*SIZE_UINT32_T],edi
		.no_aprobado:
		add r14, SIZE_STRUCT
		loop .ciclo

	mov rax, r13

	add rsp, 8
	pop r13
	pop r14
	pop r15
	pop rbp
	ret

en_blacklist_asm:
	push rbp 
	mov rbp, rsp
	push r15
	push r14
	push r13
	push r12

	xor r15,r15
	xor r14,r14
	xor r13,r13
	xor r12,r12

	mov r15, rdi ;char* comercio 
	mov r14, rsi ;char** lista_comercios
	mov r13, rdx ;n

	;armo ciclo
	;no puedo armar el ciclo con el rcx dentro porque el call me lo modifica por la convencion c 
	

	.ciclo:
	cmp r13, 0
	je .no_encontrado
		xor rax,rax
		mov r12, [r14] ;obtengo el puntero al comercio
		mov rdi, r15   ;comercio
		mov rsi, r12   ;comercio de la lista
		call strcmp    ; comparo los string 
		cmp rax, 0
		je .encontrado
		add r14, 8
		dec r13
		jmp .ciclo
		jmp .no_encontrado
		.encontrado:
			mov rax, 1
			jmp .fin
		.no_encontrado:
			mov rax, 0
		.fin:

	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp
	ret

blacklistComercios_asm:
	push rbp
	mov rbp, rsp
	push r15
	push r14
	push r13
	push r12
	push rbx
	sub rsp,8

	mov r15, rdi ;cantidad de pagos 
	mov r14, rsi ;arr pagos 
	mov r13, rdx ;arr comercios 
	mov r12, rcx ;cantidad comercios 


	call CantEnBlacklist 
	mov rdi, rax ;cantidad de comercios en blacklist
	imul rdi, SIZE_PUNTERO_A_PAGO ;cantidad de bytes que necesito para guardar los punteros a los pagos en blacklist
	call malloc
	mov rbx, rax ;lo que voy a devolver

	push rax 

	.ciclo: 
	cmp r15, 0
	je .fin
		xor rax,rax
		mov rdi, [r14 + OFFSET_COMERCIO] ;comercio del pago
		mov rsi, r13 ;arr de comercios
		mov rdx, r12 ;cantidad de punteros a pagos en blacklist
		call en_blacklist_asm
		cmp rax, 1
		je .esta_en_blacklist
		add r14, SIZE_STRUCT
		dec r15
		jmp .ciclo
		jmp .fin
		.esta_en_blacklist:
			mov [rbx], r14 ;guardo el puntero al pago en el arreglo de punteros a pagos en blacklist
			add rbx, SIZE_PUNTERO_A_PAGO
			add r14, SIZE_STRUCT
			dec r15
			jmp .ciclo


	.fin:
	pop rax
	add rsp, 8
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp 
	ret
