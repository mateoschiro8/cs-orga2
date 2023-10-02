section .text

extern main_en_c
global main
main:
	; Necesitamos algún lugar dónde el rbp nos sea conocido!
	;
	; Para eso vamos a hacer un stackframe que nos sirva de marcador
	;
	; ┌─────────────────┐ 0xFFFF...
	; │ BASE DE LA PILA │
	; ├─────────────────┤
	; │                 │
	; │ ...             │ ^
	; │                 │ │
	; ├─────────────────┤ │
	; │ RIP (caller)    │ │
	; ├─────────────────┤ │
	; │ RBP (caller)    │─┘
	; ├─────────────────┤ ┌─────────> No va a ningún lado porque
	; │ RIP (main)      │ │           0 no es un puntero válido!
	; ├─────────────────┤ │
	; │ RBP (main) = 0  │<┐
	; ├─────────────────┤ │
	; │                 │ │
	; │ frame           │ │
	; │ (main_en_c)     │ │
	; ├─────────────────┤ │
	; │                 │ ╎
	; │ ...             │ ┆
	; │                 │ ┊
	; └─────────────────┘ 0x0

	; Arrancamos guardando el rbp de quién nos llamó
	push rbp
	; E inmediatamente ponemos el marcador en rbp
	mov rbp, 0

	; Finalmente hacemos lo que tenga que hacer el programa
	call main_en_c

	; Deshacemos nuestro stackframe raro y retornamos
	pop rbp
	; EXTRA: ¿El return de `main_en_c` va a propagarse correctamente o
	;        nos olvidamos de algo?
	ret

global leer_rbp
leer_rbp:
	mov rax, rbp
	ret

global medir_stack_asm
medir_stack_asm:


	; Como tenemos un `main` especial sabemos que la lista enlazada de RBPs
	; termina en un NULL.
	;
	; Podemos usar ese conocimiento para contar los stackframes.
	;COMPLETAR

	pop rbp
	ret
