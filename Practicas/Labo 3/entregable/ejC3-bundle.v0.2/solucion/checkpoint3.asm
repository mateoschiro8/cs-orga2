

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
NODO_LENGTH	EQU	0x20
LONGITUD_OFFSET	EQU	0x18

PACKED_NODO_LENGTH	EQU	0x15
PACKED_LONGITUD_OFFSET	EQU	0x11

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos:
	;prologo
	push rbp 
	mov rbp, rsp 

	xor r8, r8
	mov rax, [rdi] ; Muevo a rax la posicion apuntada por el puntero, obtenemos el puntero al nodo head.

.loop:
	add r8, [rax + LONGITUD_OFFSET] ; Al acceder a la direccion de memoria del nodo head sumado el offset obtenemos la longitud
	mov rax, [rax] ; Actualizo rax entrando el nodo next, que es el primer elemento de cada nodo.
	cmp rax, 0 ; Chequeamos si el next es null. En ese caso, dejamos de iterar porque terminamos de recorrer la lista.
	jne .loop

	mov rax, r8 ; Movemos a rax lo que acumulamos en r8 para devolverlo

	; epilogo
	pop rbp
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos_packed:
	;prologo
	push rbp 
	mov rbp, rsp 
	
	xor r8, r8

.is_null:
	cmp rdi, 0
	je .end

	mov rax, [rdi] ; Muevo a rax la posicion apuntada por el puntero, obtenemos el puntero al nodo head.

.loop:
	cmp rax, 0 ; Chequeamos si el next es null. En ese caso, dejamos de iterar porque terminamos de recorrer la lista.
	je .end
	
	add r8d, [rax + PACKED_LONGITUD_OFFSET] ; Al acceder a la direccion de memoria del nodo head sumado el offset obtenemos la longitud
	mov rax, [rax] ; Actualizo rax entrando el nodo next, que es el primer elemento de cada nodo.
	jmp .loop

; PREGUNTAR aca por que al hacer el mov a rax en vez de a eax el resultado que obtenemos es erroneo (incluso cuando ya limpiamos rax con un xor)
.end:
	mov eax, r8d  ; Movemos a eax lo que acumulamos en r8 para devolverlo
	;epilogo
	pop rbp
	ret
