#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {

    // Crear la instancia de la lista
    lista_t* nueva;
    
    // Asignar memoria en el heap
    nueva = malloc(sizeof(lista_t));

    // Definir el primer nodo como NULL
    nueva->head = NULL;

    return nueva; 
}

uint32_t longitud(lista_t* lista) {

    uint32_t longitud = 0;

    // Si la cabeza no es nula (existe algún nodo)
    if(lista->head != NULL) {

        nodo_t* actual = lista->head; 

        // Mientras haya nodos, los recorremos y vamos contando
        while (actual != NULL) {
            longitud++;
            actual = actual->next;
        }
    }

    return longitud;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {

    // Inicializar el nuevo nodo
    nodo_t* nuevo = malloc(sizeof(nodo_t));
    
    // Reservar memoria para el array y guardar el puntero
    uint32_t* tmp = malloc(sizeof(arreglo)*longitud);
    nuevo->arreglo = tmp;

    // Copiar el arreglo
    for (uint64_t i = 0; i <= longitud; i++) {
        *tmp = *arreglo;
        arreglo++;
        tmp++;
    }

    nuevo->longitud = longitud;
    nuevo->next = NULL;

    // Si el head es vacio
    if (lista->head == NULL)
        lista->head = nuevo;
    else {
        nodo_t* actual = lista->head;

        // Llegar al ultimo nodo de la lista
        while (actual->next != NULL) {
            actual = actual->next;
        }

        // Actualizar el nuevo ultimo
        actual->next = nuevo;
    }    
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {

    nodo_t* actual = lista->head;

    // Vamos avanzando y contando
    while (i > 0) {
        actual = actual->next;
        i--;
    }
    return actual;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {

    uint64_t res = 0; 

    // Si existe algún nodo
    if(lista->head != NULL) {

        nodo_t* actual = lista->head; 
        
        // Vamos avanzando y sumando las longitudes
        while (actual != NULL) {
            res+=actual->longitud;
            actual = actual->next;
        }
    }

    return res;
}

void imprimir_lista(lista_t* lista) {

    // Si existe algún nodo
    if(lista->head != NULL) {

        nodo_t* actual = lista->head; 
        
        // Vamos avanzando e imprimiendo las longitudes
        while (actual != NULL) {
            printf("| %ld | -> ",actual->longitud);
            actual = actual->next;
        }
    }   
    printf("null");
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {

    // Recorremos el array
    for (uint64_t i = 0; i < size_of_array; i++) {

        // Si es el elemento, devolvemos 1, sino avanzamos el puntero
        if (*array == elemento_a_buscar)
            return 1;
        array++;
    }
    return 0;
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {

    // Si existe algún nodo
    if(lista->head != NULL) {

        nodo_t* actual = lista->head; 

        // Vamos avanzando hasta encontrar el elemento en algún arreglo, o en ninguno
        while (actual != NULL) {
            if (array_contiene_elemento(actual->arreglo,actual->longitud,elemento_a_buscar))
                return 1;
            actual = actual->next;
        }
    }
    return 0;
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
    
    // Si existe algún nodo
    if(lista->head != NULL) {

        nodo_t* actual = lista->head; 
        
        // Vamos avanzando, y liberando la memoria
        while (actual != NULL) {
         
            // TODO Liberar la memoria del array
            free(actual->arreglo);

            // Liberar la memoria del nodo
            nodo_t* tmp;
            tmp = actual->next;
            free(actual);
            actual = tmp;
        }

    }
    free(lista);
}