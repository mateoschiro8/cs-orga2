#include<stdio.h>

/**
 * Un entero con signo de 24 bits guardado en formato big-endian
 */
typedef unsigned char int24_big_t[3];

/**
 * Un array de `length` elementos
 */
struct sized_array {
        void* arr;
        size_t length;
};

/**
 * Construye un array cuyo tamaño es conocido en tiempo de compilación
 */
#define STATIC_ARRAY(T, ...) ((_Alignas(16) T[]) { __VA_ARGS__ })

/**
 * Calcula el tamaño de un array (si este es conocido en tiempo de compilación)
 */
#define STATIC_ARRAY_SIZE(arr) (sizeof(arr) / sizeof(*arr))

/**
 * Construye un `struct sized_array` de forma similar a `STATIC_ARRAY`
 */
#define SIZED_STATIC_ARRAY(T, ...) ((struct sized_array) {         \
        .arr = STATIC_ARRAY(T, __VA_ARGS__),                       \
        .length = STATIC_ARRAY_SIZE(STATIC_ARRAY(T, __VA_ARGS__)), \
})

/**
 * Convierte una expresión numérica a un `int24_big_t`
 */
#define INT24_BIG(i) {      \
    ((i) & 0xFF0000) >> 16, \
    ((i) & 0x00FF00) >>  8, \
    ((i) & 0x0000FF) >>  0, \
}

/**
 * Convierte un `int24_big_t` en un entero común y corriente
 */
int int24_big_t_to_int(int24_big_t n) {
    return (n[0] & 0b10000000 ? -1u ^ 0xFFFFFFu : 0u) | (n[0] << 16) | (n[1] <<  8) | (n[2] <<  0);
}

/**
 * Imprime un `int24_big_t` en hexa
 */
void print_int24_big_t(int24_big_t n) {
    int m = int24_big_t_to_int(n);
    printf("%c0x%.6X", m > 0 ? ' ' : '-', m < 0 ? -m : m);
}

/**
 * Suma un `struct sized_array` de `int24_big_t`
 */
int ejercicio(struct sized_array input) {
    int24_big_t* arr = input.arr;
    int result = 0;

    for (int i = 0; i < input.length; i++) {
        result += int24_big_t_to_int(arr[i]);
    }
    return result;
}

int ejercicio_asm(struct sized_array input);

/**
 * Dado un entero nos devuelve su signo (usamos un espacio para los positivos)
 */
char sign(int v) {
	return v < 0 ? '-' : ' ';
}

/**
 * Dado un entero con signo nos devuelve un valor absoluto. Puede incurrir en
 * overflow para enteros negativos muy grandes.
 */
int abs(int v) {
	return v < 0 ? -v : v;
}

int main() {
    /**
    * Nuestro array de pruebas
    */
    int24_big_t a = INT24_BIG(0);
    struct sized_array test_data = SIZED_STATIC_ARRAY(
        int24_big_t,
        INT24_BIG(-0x1),
        INT24_BIG(0x1),
        INT24_BIG(0xFAABB),
        INT24_BIG(-0x800000),
        INT24_BIG(0x7FFFFF),
        INT24_BIG(-0x5),
        INT24_BIG(-0xA),
        INT24_BIG(-0x506),
        INT24_BIG(0x0),
        INT24_BIG(0xFFFF),
        INT24_BIG(0xBABA),
        INT24_BIG(-0xB0B0),
        INT24_BIG(0xCAFE),
        INT24_BIG(-0xFECA),
        INT24_BIG(0xC050),
        INT24_BIG(-0xCA5A)
    );

    printf("test_data values:\n");
    for (int i = 0; i < test_data.length; i++) {
        int24_big_t* arr = test_data.arr;
        printf("  [0x%X] = ", i);
        print_int24_big_t(arr[i]);
        printf("\n");
    }
    int resultado = ejercicio(test_data);
    printf("sum(test_data) = %c0x%X\n", sign(resultado), abs(resultado));

    int resultado_asm = ejercicio_asm(test_data);
    printf("sum(test_data) = %c0x%X (asm)\n", sign(resultado), abs(resultado));

    // Si son distintos salgo del main con un código de error
    return resultado != resultado_asm;
}
