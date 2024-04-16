#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
    lista_t* new = malloc(sizeof(lista_t)); 
    new->head = NULL;
    return new;
}

uint32_t longitud(lista_t* lista) {

    // Casos base
    if (lista == NULL || lista->head == NULL)
    {
        return 0;
    }
    
    // Casos NO base
    uint32_t size = 0;
    nodo_t* nodoActual = lista->head;

    while (nodoActual != NULL)
    {
        nodoActual = nodoActual->next;
        size++;
    }
    
    return size;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {

    // Pedimos memoria para el nodo
    nodo_t * nodoAAgregar = malloc(24);

    // Pedimos memoria para el array porque el enunciado pide copiarlo
    uint32_t* array = malloc(longitud*(sizeof(uint32_t)));
    for (uint64_t i = 0; i < longitud; i++)
    {
        array[i] = arreglo[i];
    }
    

    nodoAAgregar->arreglo = array;
    nodoAAgregar->longitud = longitud;
    nodoAAgregar->next = NULL;

    // Caso base lista vacia
    if (lista->head == NULL)
    {
        lista->head = nodoAAgregar;
    }


    // Caso no base
    else
    {
        nodo_t* nodoActual = lista->head;

        while (nodoActual->next != NULL)
        {
         nodoActual = nodoActual->next;   
        }

        nodoActual->next = nodoAAgregar;
    }
    
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
    nodo_t* nodoActual = lista->head;
    for (uint32_t j = 0; j < i; j++)
    {
        nodoActual = nodoActual->next;
    }
    
    return nodoActual;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {
    if (lista == NULL || lista->head == NULL)
    {
        return 0;
    }
    
    nodo_t* nodoActual = lista->head;
    uint64_t cantidadTotal = 0;

    while (nodoActual != NULL)
    {
        cantidadTotal += nodoActual->longitud;
        nodoActual = nodoActual->next;
    }

    return cantidadTotal;
}

void imprimir_lista(lista_t* lista) {
    if (lista != NULL && lista->head != NULL)
    {
        nodo_t* nodoActual = lista->head;
        while (nodoActual != NULL)
        {
            printf("| %ld | -> ",nodoActual->longitud);
            nodoActual = nodoActual->next;
        }
    }
    printf("null");
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
    int contiene = 0;
    for (uint64_t i = 0; i < size_of_array; i++)
    {
        if (array[i] == elemento_a_buscar)
        {
            contiene = 1;
            break;
        }
    }
    
    return contiene;
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {
    if (lista == NULL || lista->head == NULL)
    {
        return 0;
    }
    
    nodo_t* nodoActual = lista->head;

    int res = 0;

    while (nodoActual != NULL && res != 1)
    {
        res = array_contiene_elemento(nodoActual->arreglo,nodoActual->longitud,elemento_a_buscar);
        nodoActual = nodoActual->next;
    }
    
    return res;
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
    if (lista->head == NULL)
    {
        free(lista);
    }
    
    else
    {
        nodo_t* nodoActual = lista->head;

        while (nodoActual != NULL)
        {
            nodo_t* temp = nodoActual;
            free(nodoActual->arreglo);
            nodoActual = nodoActual->next;
            free(temp);
        }
        
        free(lista);
    }
}