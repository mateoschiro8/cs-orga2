extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global alternate_sum_4_using_c
global product_9_f 

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4:
	;prologo
	push rbp
	mov rbp,rsp 

	;codigo
	xor rax, rax ; limpiamos rax 
	add rax, rdi ; movemos el primer parametro
	sub rax, rsi ; hacemos el resto de operaciones
	add rax, rdx 
	sub rax, rcx 

	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp

	push r12 ; registros no volatiles para conservar los parametros al hacer call 
	push r13

	mov r12, rdx
	mov r13, rcx 

	call restar_c ; hacemos el call directo porque los parametros ya vinieron en los registros de pasaje

	mov rdi,rax ; traemos a rdi desde rax el resultado de la resta para pasarla como parametro al prox call
	mov rsi,r12 

	call sumar_c

	mov rdi,rax 
	mov rsi,r13 

	call restar_c

	;epilogo
	pop r13
	pop r12
	pop rbp
	ret

; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4_simplified:

	xor rax, rax 
	add rax, rdi 
	sub rax, rsi 
	add rax, rdx 
	sub rax, rcx 

	ret

; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[?], x2[?], x3[?], x4[?], x5[?], x6[?], x7[?], x8[?]
alternate_sum_8:
	push rbp
	mov rbp,rsp 

	push r12 ;pusheamos los no volatiles que vamos a usar 
	push r13

	xor rax, rax ; todas las sumas correspondientes a los parametros que nos llegan por registros
	add rax, rdi ; Traemos el x1 al rax

	sub rax, rsi ; hacemos los calculos
	add rax, rdx 
	sub rax, rcx 
	add rax, r8
	sub rax, r9

	mov r12, [rbp + 0x10] ;Hacemos esto para traer el septimo y octavo parametro que vienen por memoria
	mov r13, [rbp + 0x18] ; Los parametros se pushean de derecha a izquierda al stack, por eso traemos x8 a r13 asi.

	add rax, r12 
	sub rax, r13 
	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	pop r13
	pop r12
	pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[rsi], f1[xmm0]
product_2_f:
	;prologo
	push rbp
	mov rbp, rsp

	; cvtsi2ss: Convert Doubleword Integer to Scalar Single Precision Floating-Point Value
	cvtsi2ss xmm1, rsi ; Convertimos de integer a float
	mulss xmm0, xmm1  ; Multiplicamos ambos parametros

	; cvttps2dq: Convert With Truncation Packed Single Precision Floating-Point Values to Packed
	; Signed Doubleword Integer Values
	cvttps2dq xmm0, xmm0 ; Convertimos de float a integer
	movd eax, xmm0

	mov [rdi], eax 

	pop rbp
	ret


;extern void product_9_f(uint32_t * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[rsi], f1[xmm0], x2[rdx], f2[xmm1], x3[rcx], f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[rbp + 0x10], f6[xmm5], x7[rbp + 0x18], f7[xmm6], x8[rbp + 0x20], f8[xmm7],
;	, x9[rbp + 0x28], f9[rbp + 0x30]


product_9_f:
	;prologo
	push rbp ;alineada
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	; preguntar dif en la representacion entre doubles y single precision

	; cvtss2sd: Convert Scalar Single Precision Floating-Point Value to Scalar Double Precision
	; Floating-Point Value
	cvtss2sd xmm0, xmm0 ;Convierto los floats a double
	cvtss2sd xmm1, xmm1
	cvtss2sd xmm2, xmm2
	cvtss2sd xmm3, xmm3
	cvtss2sd xmm4, xmm4
	cvtss2sd xmm5, xmm5
	cvtss2sd xmm6, xmm6
	cvtss2sd xmm7, xmm7
	cvtss2sd xmm8, [rbp + 0x30] ; traemos de memoria el ultimo float y lo convertimos a double tambien

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	; mulsd: Multiply Scalar Double Precision Floating-Point Value
	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5
	mulsd xmm0, xmm6
	mulsd xmm0, xmm7
	mulsd xmm0, xmm8

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	; cvtsi2sd: Convert Doubleword Integer to Scalar Double Precision Floating-Point Value
	cvtsi2sd xmm1, rsi
	cvtsi2sd xmm2, rdx
	cvtsi2sd xmm3, rcx
	cvtsi2sd xmm4, r8
	cvtsi2sd xmm5, r9
	cvtsi2sd xmm6, [rbp + 0x10]
	cvtsi2sd xmm7, [rbp + 0x18]
	cvtsi2sd xmm8, [rbp + 0x20]
	cvtsi2sd xmm9, [rbp + 0x28]

	mulsd xmm0, xmm1 
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5 
	mulsd xmm0, xmm6
	mulsd xmm0, xmm7
	mulsd xmm0, xmm8
	mulsd xmm0, xmm9
	
	movsd [rdi], xmm0 ; llevamos al destination el resultado. 

	; epilogo
	pop rbp
	ret


