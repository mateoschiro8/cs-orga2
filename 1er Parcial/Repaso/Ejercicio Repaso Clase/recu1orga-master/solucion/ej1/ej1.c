#include "ej1.h"

//el error de esta función fue no preguntar si el pago estaba aprobado y solo sumar los montos de 
//los pagos aprobados
uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos){
    uint32_t* acumulado = malloc(sizeof(uint32_t)*10);
    for (int i = 0; i < cantidadDePagos; i++){
        if (arr_pagos[i].aprobado){
            acumulado[arr_pagos[i].cliente] += arr_pagos[i].monto;
        }
    }
    return acumulado;
}

uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n){
    for (int i = 0; i < n; i++){
        if (strcmp(comercio, lista_comercios[i]) == 0){
            return 1;
        }
    }
    return 0;
}


//hago una funcion que devuelva cant_en_blacklist
uint8_t CantEnBlacklist(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){
    uint8_t cant_en_blacklist = 0;
    for (int i = 0; i < cantidad_pagos; i++){
        if (en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios)){
            cant_en_blacklist++;
        }
    }
    return cant_en_blacklist;
}


pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){
    uint8_t cant_en_blacklist = CantEnBlacklist(cantidad_pagos, arr_pagos, arr_comercios, size_comercios);
    pago_t** pagos_en_blacklist = malloc(sizeof(pago_t*)*cant_en_blacklist);
    int j = 0;
    for (int i = 0; i < cantidad_pagos; i++){
        if (en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios)){
            pagos_en_blacklist[j] = &arr_pagos[i];
            j++;
        }
    }
    return pagos_en_blacklist;
}


