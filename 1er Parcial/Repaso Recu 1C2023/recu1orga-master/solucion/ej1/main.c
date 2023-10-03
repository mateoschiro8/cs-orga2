#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "ej1.h"

int main (void){
    //quiero testear la funcion acumuladoPorCliente_asm 
    // uint32_t* acumuladoPorCliente_asm(uint8_t cantidadDePagos, pago_t* arr_pagos);

    //creo un arreglo de pagos
    pago_t* arr_pagos = malloc(sizeof(pago_t)*5);
    arr_pagos[0].cliente = 1;
    arr_pagos[0].monto =(uint8_t) 100;
    arr_pagos[0].comercio = "comercio1";
    arr_pagos[0].aprobado = 1;
    arr_pagos[1].cliente = 2;
    arr_pagos[1].monto =(uint8_t) 200;
    arr_pagos[1].comercio = "comercio2";
    arr_pagos[1].aprobado = 1;
    arr_pagos[2].cliente = 3;
    arr_pagos[2].monto = (uint8_t)210;
    arr_pagos[2].comercio = "comercio3";
    arr_pagos[2].aprobado = 1;
    arr_pagos[3].cliente = 1;
    arr_pagos[3].monto = (uint8_t)100;
    arr_pagos[3].comercio = "comercio1";
    arr_pagos[3].aprobado = 0;
    arr_pagos[4].cliente = 2;
    arr_pagos[4].comercio = "comercio2";
    arr_pagos[4].monto =(uint8_t) 55;
    arr_pagos[4].aprobado = 0;

    //llamo a la funcion 
    uint32_t* acumulado = acumuladoPorCliente_asm(5, arr_pagos);
    //printeo 
    for (int i = 0; i < 10; i++){
        printf("cliente %d: %d\n", i, acumulado[i]);
    }
    free(acumulado);
    


    //test para la funcion en_blacklist_asm uint8_t en_blacklist_asm(char* comercio, char** lista_comercios, uint8_t n);
    char* comercio = "comercio";
    char** lista_comercios = malloc(sizeof(char*)*3);
    lista_comercios[0] = "banco";
    lista_comercios[1] = "super";
    lista_comercios[2] = "comercio";
    uint8_t n = 3;
    uint8_t res = en_blacklist_asm(comercio, lista_comercios, n);
    printf("res: %d\n", res); //anduvo
    free(lista_comercios);

    //test para la funcion pago_t** blacklistComercios_asm(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios);
    //creo un arreglo de pagos
    pago_t* arr_pagos2 = malloc(sizeof(pago_t)*5);
    arr_pagos2[0].cliente = 1;
    arr_pagos2[0].monto =(uint8_t) 100;
    arr_pagos2[0].comercio = "comercio1";
    arr_pagos2[0].aprobado = 1;
    arr_pagos2[1].cliente = 2;
    arr_pagos2[1].monto =(uint8_t) 200;
    arr_pagos2[1].comercio = "comercio2";
    arr_pagos2[1].aprobado = 1;
    arr_pagos2[2].cliente = 3;
    arr_pagos2[2].monto = (uint8_t)210;
    arr_pagos2[2].comercio = "comercio3";
    arr_pagos2[2].aprobado = 1;
    arr_pagos2[3].cliente = 1;
    arr_pagos2[3].monto = (uint8_t)100;
    arr_pagos2[3].comercio = "comercio1";
    arr_pagos2[3].aprobado = 0;
    arr_pagos2[4].cliente = 2;
    arr_pagos2[4].comercio = "comercio2";
    arr_pagos2[4].monto =(uint8_t) 55;
    arr_pagos2[4].aprobado = 0;

    //creo un arreglo de comercios
    char** arr_comercios = malloc(sizeof(char*)*3);
    arr_comercios[0] = "banco";
    arr_comercios[1] = "super";
    arr_comercios[2] = "comercio1";
    uint8_t size_comercios = 3;

    //llamo a la funcion
    pago_t** res2 = blacklistComercios_asm(5, arr_pagos2, arr_comercios, size_comercios);
    //printeo
    for (int i = 0; i < 5; i++){
        printf("cliente: %d, monto: %d, comercio: %s, aprobado: %d\n", res2[i]->cliente, res2[i]->monto, res2[i]->comercio, res2[i]->aprobado);
    }
    free(res2);
    free(arr_pagos2);
    free(arr_comercios);
    return 0;
}


