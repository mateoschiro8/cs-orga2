#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Construye y retorna un nuevo vector vacío con capacity=2.
vector_t* nuevo_vector(void) {
    // Reservar memoria
    vector_t* nuevo = malloc(sizeof(vector_t));

    // Inicializar las variables
    nuevo->capacity = 2;
    nuevo->size = 0;
    nuevo->array = malloc(2*sizeof(uint32_t));
    return nuevo;
    
}

// Retorna la cantidad de elementos (válidos) del vector
uint64_t get_size(vector_t* vector) {
    return vector->size;
}

// Agrega un elemento al final del vector
void push_back(vector_t* vector, uint32_t elemento) {
    if(vector->size == vector->capacity) {
        vector->array = realloc(vector->array, 2 * (vector->capacity) * sizeof(uint32_t));
        vector->capacity = 2 * vector->capacity;
    } 
    vector->array[vector->size] = elemento;
    vector->size++;
}

int son_iguales(vector_t* v1, vector_t* v2) {
    if (v1 == NULL || v2 == NULL)
    {
        return 0;
    }
    
    if (v1->size == v2->size)
    {
        for (uint64_t i = 0; i < v1->size; i++)
        {
            if (v1->array[i] != v2->array[i])
            {
                return 0;
            }
        }
        return 1;
    }
    return 0;
}

uint32_t iesimo(vector_t* vector, size_t index) {
    if (index >= vector->size)
    {
        return 0;
    }
    
    return vector->array[index];
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out)
{
    uint32_t elemento = iesimo(vector,index);
    *out = elemento;
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
    vector_t* masGrande = *array_de_vectores;
    for (size_t i = 0; i < longitud_del_array; i++)
    {
        if (masGrande->size < array_de_vectores[i]->size)
        {
            masGrande = array_de_vectores[i];
        }
    }

    return masGrande;
    
}
