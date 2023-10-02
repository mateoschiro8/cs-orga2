#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <stddef.h> // Necesario para offsetof
#include <stdint.h>		//contiene la definición de tipos enteros ligados a tamaños int8_t, int16_t, uint8_t,...
#include <math.h>		//define funciones matemáticas como cos, sin, abs, sqrt, log...
#include <stdbool.h>	//contiene las definiciones de datos booleanos, true (1), false (0)
#include <unistd.h>		//define constantes y tipos standard, NULL, R_OK, F_OK, STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO...
#include <assert.h>	

// Define la estructura
typedef struct nodo_s {
    struct nodo_s* next;   // Siguiente elemento de la lista o NULL si es el final
    uint8_t categoria;     // Categoría del nodo
    uint32_t* arreglo;     // Arreglo de enteros
    uint32_t longitud;     // Longitud del arreglo
} nodo_t;

int main() {
    // Calcula el offset del campo "longitud" en la estructura
    size_t offset = offsetof(nodo_t, longitud);

    // Muestra el offset por consola
    printf("El offset del campo 'longitud' en la estructura 'nodo_t' es: %zu\n", offset);

    return 0;
}


