#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {

    // Reservar memoria
    vector_t* nuevo = malloc(sizeof(vector_t));

    // Inicializar las variables
    nuevo->capacity = 2;
    nuevo->size = 0;
    nuevo->array = malloc(2*sizeof(uint32_t));
    
    return nuevo;
}

uint64_t get_size(vector_t* vector) {
    return vector->size;
}

void push_back(vector_t* vector, uint32_t elemento) {
    
    // Si la capacidad del vector se lleno
    if (vector->size == vector->capacity) {
    
        // Hacemos un realloc con el doble de la capacidad
        uint32_t* array = realloc(vector->array,2*(vector->capacity)*sizeof(uint32_t));

        // Actualizamos las variables
        // free(vector->array);
        vector->array = array;
        vector->capacity = vector->capacity * 2; 
    }

    // Agregamos el elemento y actualizamos el size
    uint32_t* primer_posicion_libre = vector->array + vector->size;
    *primer_posicion_libre = elemento;
    vector->size++; 
}

int son_iguales(vector_t* v1, vector_t* v2) {

    // Primero chequeamos que tengan el mismo size
    if (v1->size == v2->size) {
        for (uint64_t i = 0; i < v1->size; i++) {
            
            // Si el elemento es distinto devuelve 0
            if (*(v1->array + i) != *(v2->array + i))
                return 0;
        }

        // Termina el for, todos iguales, devuelve 1
        return 1;
    }

    // Size distinto, devuelve 0
    return 0;
}

uint32_t iesimo(vector_t* vector, size_t index) {

    // Si el index no es mayor al size del vector
    if (-1 < index < vector->size)
        return *(vector->array + index);

    // Si el index esta fuera de rango, devuelve 0
    return 0;
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out) {
    *out = iesimo(vector,index);
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
    
    // Chequear que el array no sea vacio
    if (array_de_vectores != NULL) {

        // Elegimos el primero como el máximo
        vector_t* max = *array_de_vectores;
        size_t count = 0;

        // Los vamos recorriendo
        while (count < longitud_del_array) {

            vector_t* actual = *array_de_vectores;  

            // Si el actual es mayor al guardado como máximo, lo actualizamos
            if (actual->size > max->size)
                max = actual;

            // Avanzamos el puntero y el contador
            array_de_vectores++;
            count++;
        }
        return max;
    }   

    return NULL;
}
