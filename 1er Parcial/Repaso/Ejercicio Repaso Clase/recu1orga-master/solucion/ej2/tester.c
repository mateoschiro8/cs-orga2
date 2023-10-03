#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <assert.h>
#include <errno.h>
#include "ej2.h"

#define H 20
#define W 12

static uint8_t input[H][W];

void shuffle(uint32_t max){
		for (int i = 0; i < H; i++) {
        for (int j = 0; j < W; j++){
				    input[i][4*j] = (uint8_t) rand() % max;
				    input[i][4*j+1] = (uint8_t) rand() % max;
				    input[i][4*j+2] = (uint8_t) rand() % max;
				    input[i][4*j+3] = (uint8_t) rand() % max;
        }
		}
}

void shuffleBGRA(uint32_t max){
		for (int i = 0; i < H; i++) {
        for (int j = 0; j < W; j++){
				    input[i][4*j] = (uint8_t) rand() % max;
				    input[i][4*j+1] = (uint8_t) rand() % (input[i][4*j] + 1);
				    input[i][4*j+2] = (uint8_t) rand() % (input[i][4*j+1] + 1);
				    input[i][4*j+3] = (uint8_t) rand() % (input[i][4*j+2] + 1);
        }
		}
}

void shuffleARGB(uint32_t max){
		for (int i = 0; i < H; i++) {
        for (int j = 0; j < W; j++){
						input[i][4*j+3] = (uint8_t) rand() % max;
				    input[i][4*j+2] = (uint8_t) rand() % (input[i][4*j+3] + 1);
				    input[i][4*j+1] = (uint8_t) rand() % (input[i][4*j+2] + 1);
				    input[i][4*j] = (uint8_t) rand() % (input[i][4*j+1] + 1);
        }
		}
}

#define RUN(filename, action) pfile=fopen(filename,"a"); action; fclose(pfile);
#define NL(filename) pfile=fopen(filename,"a"); fprintf(pfile,"\n"); fclose(pfile);

char *filename_ej2 =  "salida.propios.ej2.txt";
void test_ej2(char* filename);

int main() {
	srand(0);
  remove(filename_ej2);
	test_ej2(filename_ej2);
	return 0;
}

uint32_t shuffle_int(uint32_t min, uint32_t max){
	return (uint32_t) (rand() % (max + 1)) + min;
}

void test_ej2(char* filename) {

    void (*func_maxymin)(uint8_t*, uint8_t*, uint32_t, uint32_t);
    if (USE_ASM_IMPL){
        func_maxymin = maximosYMinimos_asm;
    }else{
        func_maxymin = maximosYMinimos;
    }

    FILE* pfile;
    shuffleBGRA(256);
    RUN(filename, fprintf(pfile, "== Ejercicio 2 ==\n");) NL(filename)
    RUN(filename, fprintf(pfile, "== Ordenados ==\n");) NL(filename)

    uint8_t *result = malloc(H*W*4);
    func_maxymin((uint8_t*)input,(uint8_t*)result,W,H);

    for(int i=0;i<H;++i){
        for(int j=0;j<4*W;++j){
            RUN(filename, fprintf(pfile, "%3d ",result[i*W +j]);)
        }
        NL(filename)
    }

		shuffleARGB(256);
    RUN(filename, fprintf(pfile, "\n== Ordenados(inverso) ==\n");) NL(filename)

    func_maxymin((uint8_t*)input,(uint8_t*)result,W,H);

    for(int i=0;i<H;++i){
        for(int j=0;j<4*W;++j){
            RUN(filename, fprintf(pfile, "%3d ",result[i*W +j]);)
        }
        NL(filename)
    }

		shuffle(256);
    RUN(filename, fprintf(pfile, "\n== Random ==\n");) NL(filename)

    func_maxymin((uint8_t*)input,(uint8_t*)result,W,H);

    for(int i=0;i<H;++i){
        for(int j=0;j<4*W;++j){
            RUN(filename, fprintf(pfile, "%3d ",result[i*W +j]);)
        }
        NL(filename)
    }

    free(result);
}
