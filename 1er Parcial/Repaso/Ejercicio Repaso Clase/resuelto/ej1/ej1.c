#include "ej1.h"

uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos){

    // Pido la memoria para poner los datos
    uint32_t* arregloPagos = calloc(10, sizeof(uint32_t)); 

    // No hace falta iniciarlas en 0 porque calloc ya hace eso

    // Voy iterando los pagos, y sumo cada pago aprobado donde corresponda
    for(int i = 0; i < cantidadDePagos; i++) {

        // Obtengo los datos del pago
        pago_t pago = arr_pagos[i];

        uint8_t cliente = pago.cliente;
        bool aprobado = pago.aprobado;
        uint8_t monto = pago.monto;

        if(aprobado)
            arregloPagos[cliente] += monto;
    } 

    return arregloPagos;
}

uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n){

    for(int i = 0; i < n; i++) {
        if(strcmp(comercio, lista_comercios[i]) == 0)
            return 1;
    }
    return 0;
}

pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){

    // Me fijo primero cuantos pagos están en la blacklist
    int totalPagos = 0;
    for(int i = 0; i < cantidad_pagos; i++) {
        if(en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios))
            totalPagos++;
    }

    // Pido la memoria para la cantidad de pagos necesaria
    pago_t** pagosBlacklist = calloc(totalPagos, sizeof(pago_t));
    
    // Recorro los pagos, y agrego los que estén en la blacklist
    int ult = 0;
    for(int i = 0; i < cantidad_pagos; i++) {
        if(en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios)) {
            pagosBlacklist[ult] = &arr_pagos[i];
            ult++;
        }
    }
    return pagosBlacklist;
}

// Funcion que devuelve cant_en_blacklist
uint8_t cantEnBlacklist(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){
    
    uint8_t cant_en_blacklist = 0;
    for (int i = 0; i < cantidad_pagos; i++){
        if (en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios)) 
            cant_en_blacklist++;
    }
    return cant_en_blacklist;
}