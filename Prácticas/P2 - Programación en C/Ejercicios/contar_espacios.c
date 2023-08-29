#include "contar_espacios.h"
#include <stdio.h>

uint32_t longitud_de_string(char* string) {
    
    uint32_t longitud = 0;    

    // Mientras el string no sea nulo o termine, contamos sus caracteres
    while (string != NULL && *string != '\0') {
        longitud++;
        string++;
    }
    
    return longitud;
}

uint32_t contar_espacios(char* string) {

    uint32_t cantEspacios = 0;
    
    // Mientras el string no sea nulo o termine, contamos los espacios
    while (string != NULL && *string != '\0') {
        if (*string == ' ')
            cantEspacios++;
        string++;
    }

    return cantEspacios;
}


/*int main() {

    printf("1. %d\n", contar_espacios("hola como andas?"));

    printf("2. %d\n", contar_espacios("holaaaa orga2"));
    
}*/
