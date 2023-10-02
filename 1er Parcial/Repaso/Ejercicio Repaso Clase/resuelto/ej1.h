#include <stdio.h>    //encabezado de funciones de entrada y salida fopen, fclose, fgetc, printf, fprintf ...
#include <stdlib.h>   //biblioteca estándar, atoi, atof, rand, srand, abort, exit, system, NULL, malloc, calloc, realloc...
#include <stdint.h>   //contiene la definición de tipos enteros ligados a tamaños int8_t, int16_t, uint8_t,...
#include <ctype.h>    //contiene funciones relacionadas a caracteres, isdigit, islower, tolower...
#include <string.h>   //contiene las funciones relacionadas a strings, memcmp, strcat, memset, memmove, strlen,strstr...
#include <math.h>   //define funciones matemáticas como cos, sin, abs, sqrt, log...
#include <stdbool.h>  //contiene las definiciones de datos booleanos, true (1), false (0)
#include <unistd.h>   //define constantes y tipos standard, NULL, R_OK, F_OK, STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO...
#include <assert.h>   //provee la macro assert que evalúa una condición, y si no se cumple provee información diagnóstica y aborta la ejecución

//*************************************
//Declaración de estructuras
//*****
#define USE_ASM_IMPL 0

typedef struct pago {     // size     ofsset
  uint8_t monto;          //  1         0
  char* comercio;         //  8         8
  uint8_t cliente;        //  1         16
  uint8_t aprobado;       //  1         17
} pago_t;                 // total: 24        


uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos);
uint32_t* acumuladoPorCliente_asm(uint8_t cantidadDePagos, pago_t* arr_pagos);

uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n);
uint8_t en_blacklist_asm(char* comercio, char** lista_comercios, uint8_t n);

// Para la siguiente funcion, notar que son muchos parametros, pero fijense que simplemente son dos arrays con sus respectivos tamanos.
pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios);
pago_t** blacklistComercios_asm(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios);

// Una version agregada (que no pertencecia al examen original), donde no se puede confiar en que la memoria perteneciente a los
// pagos es valida. Para cada pago que pertenezca a la blacklist, no tenemos garantias de que la memoria 'sobreviva'.
pago_t** blacklistComercios_V2(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios);
