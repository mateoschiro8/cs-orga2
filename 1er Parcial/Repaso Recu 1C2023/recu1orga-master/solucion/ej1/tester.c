#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <assert.h>
#include <errno.h>
#include "ej1.h"


#define RUN(filename, action) pfile=fopen(filename,"a"); action; fclose(pfile);
#define NL(filename) pfile=fopen(filename,"a"); fprintf(pfile,"\n"); fclose(pfile);

char *filename_ej1 =  "salida.propios.ej1.txt";
void test_ej1a(char* filename);
void test_ej1b(char* filename);


int main() {
	srand(0);
    remove(filename_ej1);
	test_ej1a(filename_ej1);
	test_ej1b(filename_ej1);
	return 0;
}

#define ARRAY_SIZE 20
#define NUM_ARRAYS 4
#define MAX_CLIENTES 10

uint32_t shuffle_int(uint32_t min, uint32_t max){
	return (uint32_t) (rand() % (max + 1)) + min;
}

void test_ej1a(char* filename) {
    
    uint32_t* (*func_acum)(uint8_t, pago_t*);
    if (USE_ASM_IMPL){
        func_acum = acumuladoPorCliente_asm;
    }else{
        func_acum = acumuladoPorCliente;
    }

    FILE* pfile;

    RUN(filename, fprintf(pfile, "== Ejercicio 1a ==\n");) NL(filename)
    char comercios[6][10] = {"coto","dia","adidas","nike","carrefour","zara"};

    for (int j=0; j<NUM_ARRAYS; ++j){
       pago_t* arrayPagos = malloc(ARRAY_SIZE*sizeof(pago_t));

        for (int i=0; i<ARRAY_SIZE; ++i){
            arrayPagos[i].monto = shuffle_int(1,10);
            arrayPagos[i].cliente = shuffle_int(1,1024)%10;
            arrayPagos[i].aprobado = shuffle_int(1,1024)%2;
            uint8_t comercio_idx = shuffle_int(1,1024)%6;
            arrayPagos[i].comercio = comercios[comercio_idx];

        }
        uint32_t* res =func_acum(ARRAY_SIZE, arrayPagos);
        for(int i=0;i<MAX_CLIENTES;++i){
            RUN(filename, fprintf(pfile, "Cliente %d: %d\n", i+1,res[i]));
        }
        free(res);
        free(arrayPagos);
    }
}

void test_ej1b(char* filename){
    pago_t** (*func_blacklist) (uint8_t, pago_t*, char**, uint8_t);
    if (USE_ASM_IMPL){
        func_blacklist = blacklistComercios_asm;
    }else{
        func_blacklist = blacklistComercios;
    }

    FILE* pfile;

    RUN(filename, fprintf(pfile, "== Ejercicio 1b ==\n");) NL(filename)
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
    
    uint32_t size_black_list_comercios = 3;
    for (int j=0; j<NUM_ARRAYS; ++j){
        pago_t* arrayPagos = malloc(ARRAY_SIZE*sizeof(pago_t));
        uint32_t total_pagos_rechazados = 0;
        for (int i=0; i<ARRAY_SIZE; ++i){
            arrayPagos[i].monto = shuffle_int(1,10);
            arrayPagos[i].cliente = shuffle_int(1,1024)%10;
            arrayPagos[i].aprobado = shuffle_int(1,1024)%2;
            uint8_t comercio_idx = shuffle_int(1,1024)%6;
            arrayPagos[i].comercio = comercios[comercio_idx];

            if((strcmp(comercios[comercio_idx], black_list_comercios[0])==0) || (strcmp(comercios[comercio_idx], black_list_comercios[1])==0) || (strcmp(comercios[comercio_idx], black_list_comercios[2])==0))total_pagos_rechazados++;

        }
        pago_t** res = func_blacklist(ARRAY_SIZE, arrayPagos, black_list_comercios, size_black_list_comercios);
        
        for(uint32_t i=0;i<total_pagos_rechazados;++i){
            RUN(filename, fprintf(pfile, "Pago %d monto: %d\n", i+1, res[i]->monto));
            RUN(filename, fprintf(pfile, "Pago %d cliente: %d\n", i+1, res[i]->cliente));
            RUN(filename, fprintf(pfile, "Pago %d aprobado: %d\n", i+1, res[i]->aprobado));
            RUN(filename, fprintf(pfile, "Pago %d comercio: %s\n", i+1, res[i]->comercio));
        }
        free(arrayPagos);
        free(res);
    }
    free(comercios);
    free(black_list_comercios);

}
