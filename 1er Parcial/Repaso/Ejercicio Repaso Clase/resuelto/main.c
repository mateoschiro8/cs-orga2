#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "ej1.h"


/*
    Este archivo normalmente en los parciales se los damos vacios, aca es donde ustedes pueden hacer sus propios tests y/o probar cosas.
    Estos tests que ahora estan aca los preparamos para la clase expositiva, mas que nada para poder mostrar como debuggear con gdb.

    Los tests que se terminaran ejecutando 'de verdad' son aquellos en tester.c, estos son bastantes y bien abarcativos, por eso les recomendamos
    que aca en el main.c ustedes se armen tests mas chiquitos que puedan controlar ustedes.

    Una forma de hacerse sus propios tests es agarrar algunos de los de tester.c y tratar de darles valores concretos que tengan sentido
    (si ven el archivo tester.c los tests tienen valores aleatorio. Debuggear con valores concretos es un poco mas facil).
*/

#define ARRAY_SIZE 5

void testear_acumulado_por_cliente(void) {
    char comercios[6][10] = {"coto","dia","adidas","nike","carrefour","zara"};

    pago_t* arrayPagos = malloc(ARRAY_SIZE*sizeof(pago_t));

    // cliente 0 hizo un pago en adidas, por un monto de 80, y fue aprobado
    arrayPagos[0].monto = 80;
    arrayPagos[0].cliente = 0;
    arrayPagos[0].aprobado = 1;
    arrayPagos[0].comercio = comercios[2];

    // cliente 1 hizo un pago en coto, por un monto de 50, y fue aprobado
    arrayPagos[1].monto = 50;
    arrayPagos[1].cliente = 1;
    arrayPagos[1].aprobado = 1;
    arrayPagos[1].comercio = comercios[0];

    // cliente 0 hizo un pago en coto, por un monto de 100, y NO fue aprobado
    arrayPagos[2].monto = 100;
    arrayPagos[2].cliente = 0;
    arrayPagos[2].aprobado = 0;
    arrayPagos[2].comercio = comercios[0];

    // cliente 3 hizo un pago en nike, por un monto de 40, y fue aprobado
    arrayPagos[3].monto = 40;
    arrayPagos[3].cliente = 3;
    arrayPagos[3].aprobado = 1;
    arrayPagos[3].comercio = comercios[3];

    // cliente 1 hizo un pago en carrefour, por un monto de 17, y fue aprobado
    arrayPagos[4].monto = 17;
    arrayPagos[4].cliente = 1;
    arrayPagos[4].aprobado = 1;
    arrayPagos[4].comercio = comercios[4];

    uint32_t* res = acumuladoPorCliente_asm(5, arrayPagos);

    if (res[0] != 80) {
        printf("fallo en test1\n");
    }
    if (res[1] != 67) {
        printf("fallo en test2\n");
    }
    if (res[3] != 40) {
        printf("fallo en test3\n");
    }
    
    free(res);
    free(arrayPagos);
    
}

void testear_blacklistComercios(void) {
    char comercios[6][10] = {"coto","dia","adidas","nike","carrefour","zara"};

    pago_t* arrayPagos = malloc(ARRAY_SIZE*sizeof(pago_t));

    // cliente 0 hizo un pago en adidas, por un monto de 80, y fue aprobado
    arrayPagos[0].monto = 80;
    arrayPagos[0].cliente = 0;
    arrayPagos[0].aprobado = 1;
    arrayPagos[0].comercio = comercios[2];

    // cliente 1 hizo un pago en coto, por un monto de 50, y fue aprobado
    arrayPagos[1].monto = 50;
    arrayPagos[1].cliente = 1;
    arrayPagos[1].aprobado = 1;
    arrayPagos[1].comercio = comercios[0];

    // cliente 0 hizo un pago en coto, por un monto de 100, y NO fue aprobado
    arrayPagos[2].monto = 100;
    arrayPagos[2].cliente = 0;
    arrayPagos[2].aprobado = 0;
    arrayPagos[2].comercio = comercios[0];

    // cliente 3 hizo un pago en nike, por un monto de 40, y fue aprobado
    arrayPagos[3].monto = 40;
    arrayPagos[3].cliente = 3;
    arrayPagos[3].aprobado = 1;
    arrayPagos[3].comercio = comercios[3];

    // cliente 1 hizo un pago en carrefour, por un monto de 17, y fue aprobado
    arrayPagos[4].monto = 17;
    arrayPagos[4].cliente = 1;
    arrayPagos[4].aprobado = 1;
    arrayPagos[4].comercio = comercios[4];

    // comercios en blacklist:
    char** black_list_comercios = (char**)malloc(3*sizeof(char*));
    black_list_comercios[0]="coto";
    black_list_comercios[1]="zara";
    black_list_comercios[2]="adidas";

    pago_t** res = blacklistComercios(ARRAY_SIZE, arrayPagos,
                         black_list_comercios, 3);

    // se que en res habra 3 elementos (los 3 primeros pagos)
    for (int i = 0; i < 3; i++) {
        printf("Pago %d monto: %d\n", i+1, res[i]->monto);
        printf("Pago %d cliente: %d\n", i+1, res[i]->cliente);
        printf("Pago %d aprobado: %d\n", i+1, res[i]->aprobado);
        printf("Pago %d comercio: %s\n", i+1, res[i]->comercio);
    }
    
    free(res);
    free(arrayPagos);
    free(black_list_comercios);
}

void testear_en_blacklist(void) {
    char** comercios = (char**)malloc(6*sizeof(char*));
    comercios[0]="adidas";
    comercios[1]="dia";
    comercios[2]="coto";
    comercios[3]="nike";
    comercios[4]="carrefour";
    comercios[5]="zara";
    char** black_list_comercios = (char**)malloc(3*sizeof(char*));
    black_list_comercios[0]="coto";
    black_list_comercios[1]="zara";
    black_list_comercios[2]="adidas";

    if (en_blacklist_asm(comercios[0],black_list_comercios, 3) != 1) {
        printf("fallo en test1\n");
    }
    if (en_blacklist_asm(comercios[1],black_list_comercios, 3) != 0) {
        printf("fallo en test2\n");
    }
    if (en_blacklist_asm(comercios[2],black_list_comercios, 3) != 1) {
        printf("fallo en test3\n");
    }
}

int main (void){

    testear_acumulado_por_cliente();
    //testear_en_blacklist();
    //testear_blacklistComercios();

}


