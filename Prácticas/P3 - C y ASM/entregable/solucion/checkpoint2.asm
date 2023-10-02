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
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp 

	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx

	;epilogo
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp

	;guardar los valores anteriores de r12 y r13 en el stack
	push r12
	push r13

	;guardar los valores de entrada en registros no volatiles
	mov r12, rdx
	mov r13, rcx

	;call a la funcion de c y mover el resultado parcial a rdi para continuar
	call restar_c
	mov rdi, rax

	;poner x3 en rsi, hacer el call y mover el resultado a rdi para seguir operando
	mov rsi,r12
	call sumar_c
	mov rdi, rax

	;poner x4 en rsi, hacer el call 
	mov rsi,r13
	call restar_c

	;hacer el pop de r12 y r13
	pop r13
	pop r12

	;epilogo
	pop rbp
	ret



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4_simplified:
	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx
	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[?], x2[?], x3[?], x4[?], x5[?], x6[?], x7[?], x8[?]
alternate_sum_8:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp 

	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx
	add rax,r8
	sub rax,r9

	;los traigo del stack,a dos registros temporalres
	mov r10,[rbp + 0x10] 
	mov r11,[rbp + 0x18] 

	add rax,r10
	sub rax,r11

	;epilogo
	pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[?], x1[?], f1[?]
product_2_f:

;Convert Scalar Doubleword Integer to Scalar Single-Precision Floating-Point)
	cvtsi2ss xmm1,rsi ;convierte x1 a un valor flotante y lo guarda en xmm1
	mulss xmm0,xmm1 ;los multiplico asi ya que ambos son floats

	;Convertir Entero a Flotante

	cvttps2dq xmm0,xmm0 ;lo trunca es decir le saca la parte decimal
	movd eax,xmm0 ;me permite mover los 32 bits mas significantes de xmm0

	mov [rdi],eax ;lo paso a destino,al lugar apuntado por destino


	ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[?], f1[?], x2[?], f2[?], x3[?], f3[?], x4[?], f4[?]
;	, x5[?], f5[?], x6[?], f6[?], x7[?], f7[?], x8[?], f8[?],
;	, x9[?], f9[?]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	; ; Convertimos los flotantes de cada registro xmm en doubles

	cvtss2sd xmm0, xmm0      ; Convierte f1 a double y lo guarda en xmm1
    cvtss2sd xmm1, xmm1      ; Convierte f2 a double y lo guarda en xmm1
    cvtss2sd xmm2, xmm2      ; Convierte f3 a double y lo guarda en xmm2
    cvtss2sd xmm3, xmm3      ; Convierte f4 a double y lo guarda en xmm3
    cvtss2sd xmm4, xmm4      ; Convierte f5 a double y lo guarda en xmm4
    cvtss2sd xmm5, xmm5      ; Convierte f6 a double y lo guarda en xmm5
    cvtss2sd xmm6, xmm6      ; Convierte f7 a double y lo guarda en xmm6
    cvtss2sd xmm7, xmm7      ; Convierte f8 a double y lo guarda en xmm7
	cvtss2sd xmm8, [rbp + 0x30]      ; Convierte f9 a double y lo guarda en xmm7

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...  
	mulsd xmm0, xmm1         ; xmm1 = xmm1 * xmm1
    mulsd xmm0, xmm2         ; xmm1 * xmm2
    mulsd xmm0, xmm3         ;y asi sucesivaente
    mulsd xmm0, xmm4         
    mulsd xmm0, xmm5         
    mulsd xmm0, xmm6         
    mulsd xmm0, xmm7   
	mulsd xmm0, xmm8    


;destination = rdi 
;x1=rsi 
;f1=xmm0 
;x2=rdx 
;f2=xmm1 
;x3=rcx 
;f3=xmm2 
;x4=r8 
;f4=xmm3 
;x5=r9 
;f5=xmm4 
;x6=rbp + 0x10 
;f6=xmm5 
;x7= rbp + 0x18 
;f7=xmm6 
;x8=rbp + 0x20 
;f8=xmm7 
;x9=rbp + 0x28 
;f9 = rbp + 0x30

	; convertimos los enteros en doubles y los multiplicamos por xmm1.
	cvtsi2sd xmm9, rsi       ; lo guardo en regsitro temporal a x1
    mulsd xmm0, xmm9  		 ; Lo multiplico por lo que estaba en xmm1 y qeuda ahi

	cvtsi2sd xmm10, rdx      ; lo guardo en regsitro temporal x2
    mulsd xmm0, xmm10 		 ; Lo multiplico por lo que estaba en xmm1 y qeuda ahi

	cvtsi2sd xmm11, rcx       ; lo guardo en regsitro temporal x3
    mulsd xmm0, xmm11  		 ; Lo multiplico por lo que estaba en xmm1 y qeuda ahi

	cvtsi2sd xmm12, r8      ; lo guardo en regsitro temporal x4
    mulsd xmm0, xmm12

	cvtsi2sd xmm13, r9       ; lo guardo en regsitro temporal x5
    mulsd xmm0, xmm13 

	cvtsi2sd xmm14, [rbp + 0x10]      ; ya este entero no entra en los argumentos de las funciones,lo busco en stack
    mulsd xmm0, xmm14 

	cvtsi2sd xmm15, [rbp + 0x18]       ; lo busco en stack
    mulsd xmm0, xmm15
	 
	cvtsi2sd xmm9, [rbp + 0x20]       
    mulsd xmm0, xmm9

	cvtsi2sd xmm10,[rbp + 0x28]       ; lo guardo en regsitro temporal a x1
    mulsd xmm0, xmm10  


	;move scalar double-precision",mover números de punto flotante de doble precisión.
	movsd [rdi],xmm0

	; epilogo
	pop rbp
	ret


