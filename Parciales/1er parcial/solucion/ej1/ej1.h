#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <stdbool.h>
#include <unistd.h>
#define USE_ASM_IMPL 1

typedef struct nodo_display_list_t {
    // Puntero a la función que calcula z (puede ser distinta para cada nodo):
    uint8_t (*primitiva)(uint8_t x, uint8_t y, uint8_t z_size);
    // Coordenadas del nodo en la escena:
    uint8_t x;
    uint8_t y;
    uint8_t z;
    //Puntero al nodo siguiente:
    struct nodo_display_list_t* siguiente;
} nodo_display_list_t;

typedef struct nodo_ot_t {
    struct nodo_display_list_t* display_element;
    struct nodo_ot_t* siguiente;
} nodo_ot_t;

typedef struct ordering_table_t {
    uint8_t table_size;
    struct nodo_ot_t** table;
} ordering_table_t;

ordering_table_t* inicializar_OT(uint8_t table_size);
ordering_table_t* inicializar_OT_asm(uint8_t table_size);

void calcular_z(nodo_display_list_t* nodo, uint8_t z_size);
void calcular_z_asm(nodo_display_list_t* nodo, uint8_t z_size);

void ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list);
void ordenar_display_list_asm(ordering_table_t* ot, nodo_display_list_t* display_list);

nodo_display_list_t* inicializar_nodo(
  uint8_t (*primitiva)(uint8_t x, uint8_t y, uint8_t z_size),
  uint8_t x, uint8_t y, nodo_display_list_t* siguiente);
