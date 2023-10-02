#include "ej1.h"
#include <stdint.h>

uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos){

    uint32_t* pagos_aprobados = calloc(10, sizeof(uint32_t));

    for (int i = 0; i < cantidadDePagos; i++) {
        pago_t pago_i = arr_pagos[i];
        if (pago_i.aprobado == 1) {
            pagos_aprobados[pago_i.cliente] += pago_i.monto;
        }
    }

    return pagos_aprobados;
}

uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n){
    for (int i = 0; i < n; i++) {
        char* comercio_i = lista_comercios[i];
        // Por que hace falta el strcmp?
        // Por que no simplemente:
        //      if (comercio == comercio_i) {
        // ?
        // Respuesta en respuestas.txt 2)b)
        if (strcmp(comercio, comercio_i) == 0) {
            return 1;
        }
    }
    return 0;
}

pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){

    // La idea es: Tenemos el arr_pagos, y debemos iterar sobre ellos, para cada pago, si el comercio asociado a ese pago
    // esta en arr_comercios, entonces lo agregamos al resultado que retornaremos.

    // En principio pareceria que hay dos opciones para el malloc: Una forma naive seria pedir cantidad_pagos ylisto.
    //pago_t** blacklist = malloc(cantidad_pagos * sizeof(pago_t*));

    // Y sino, una mejor forma, primero contar cuantos estan en la blacklist. 

    int total_en_blacklist = 0;
    for (int i = 0; i < cantidad_pagos; i++) {
        if (en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios) == 1) {
            total_en_blacklist++;
        }
    }
    pago_t** blacklist = malloc(total_en_blacklist * sizeof(pago_t*));

    int idx = 0;

    // Pensar porque el siguiente ciclo estaria mal:
    /*
    for (int i = 0; i < cantidad_pagos; i++) {
        pago_t pago_i = arr_pagos[i];
        if (en_blacklist(pago_i.comercio, arr_comercios, size_comercios) == 1) {
            blacklist[idx] = &pago_i;
            idx++;
        }
    }
    */
    for (int i = 0; i < cantidad_pagos; i++) {
        if (en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios) == 1) {
            blacklist[idx] = &(arr_pagos[i]);
            idx++;
        }
    }

    return blacklist;    
}


pago_t** blacklistComercios_V2(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){

    // Ahora la idea es que cada pago en arr_pagos lo debemos copiar, y que sobreviva a esta funcion por lo tanto la copia vivira en el ...
    
    int total_en_blacklist = 0;
    for (int i = 0; i < cantidad_pagos; i++) {
        if (en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios) == 1) {
            total_en_blacklist++;
        }
    }

    // Pensar porque lo siguiente en este caso no funcionaria.
    //  La respuesta en archivo respuestas.txt, inciso 3)a), pero recomendamos fuertemente que intenten solucionarlo por su cuenta.
    //pago_t** blacklist_ptrs = malloc(total_en_blacklist * sizeof(pago_t*));
    //pago_t* blacklist = malloc(total_en_blacklist * sizeof(pago_t));

    pago_t** blacklist_ptrs = calloc(cantidad_pagos, sizeof(pago_t*));

    int idx = 0;
    for (int i = 0; i < cantidad_pagos; i++) {
        if (en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios) == 1) {
            
            pago_t* pago_en_heap = malloc(sizeof(pago_t));
            memcpy(pago_en_heap, &arr_pagos[i], sizeof(pago_t));

            blacklist_ptrs[idx] = pago_en_heap;
            
            idx++;
        }
    }

    return blacklist_ptrs;    
}
