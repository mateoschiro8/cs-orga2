#include <stdio.h>
#include <stdint.h>

/**
 * Retorna el valor del rbp.
 *
 * Se define en medir-stack.asm
 */
void** leer_rbp();

/**
 * Retorna la cantidad de stackframes del programa actual.
 *
 * Se define en medir-stack.asm
 *
 * NOTA: Asume que todas las funciones que fueron llamadas crean un stackframe!
 *       ¿Qué pasa si alguna no lo hace? ¿Qué pasa si alguna usa rbp para hacer
 *       cuentas?
 */
uint64_t medir_stack_asm();

/**
 * Retorna la cantidad de stackframes del programa actual.
 *
 * NOTA: Asume que todas las funciones que fueron llamadas crean un stackframe!
 *       ¿Qué pasa si alguna no lo hace? ¿Qué pasa si alguna usa rbp para hacer
 *       cuentas?
 */
uint64_t medir_stack_c() {
	void** rbp = *leer_rbp();
	uint64_t frame_count = 0;

	while (rbp != NULL) {
		frame_count++;
		rbp = *rbp;
	}

	return frame_count;
}

/**
 * Realiza `niveles` llamadas recursivas y imprime en pantalla la altura del
 * stack.
 *
 * Para calcular la altura del stack utiliza la función implementada en C.
 */
void test_medir_stack_c(uint64_t niveles) {
	if (niveles != 0) {
		test_medir_stack_c(niveles - 1);
		return;
	}

	printf("[  C] La altura del stack es %lld\n", medir_stack_c());
}

/**
 * Realiza `niveles` llamadas recursivas y imprime en pantalla la altura del
 * stack.
 *
 * Para calcular la altura del stack utiliza la función implementada en asm.
 */
void test_medir_stack_asm(uint64_t niveles) {
	if (niveles != 0) {
		test_medir_stack_asm(niveles - 1);
		return;
	}

	printf("[ASM] La altura del stack es %lld\n", medir_stack_asm());
}

int main_en_c() {
	/*
	 * Salida esperada:
	 *
	 * ```
	 * [  C] La altura del stack es 2
	 * [  C] La altura del stack es 3
	 * [  C] La altura del stack es 4
	 * [  C] La altura del stack es 12
	 * [  C] La altura del stack es 17
	 * ```
	 *
	 * ¡Tengan en mente que tanto `main_en_c` cómo `test_medir_stack_c`
	 * tienen sus stackframes!
	 */
	test_medir_stack_c( 0);
	test_medir_stack_c( 1);
	test_medir_stack_c( 2);
	test_medir_stack_c(10);
	test_medir_stack_c(15);

	/*
	 * Salida esperada:
	 *
	 * ```
	 * [ASM] La altura del stack es 2
	 * [ASM] La altura del stack es 3
	 * [ASM] La altura del stack es 4
	 * [ASM] La altura del stack es 12
	 * [ASM] La altura del stack es 17
	 * ```
	 *
	 * ¡Tengan en mente que tanto `main_en_c` cómo `test_medir_stack_asm`
	 * tienen sus stackframes!
	 */
	test_medir_stack_asm( 0);
	test_medir_stack_asm( 1);
	test_medir_stack_asm( 2);
	test_medir_stack_asm(10);
	test_medir_stack_asm(15);

	return 0;
}
