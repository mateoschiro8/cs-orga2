#include "contar_espacios.h"
#include <stdio.h>

// Dado un string, retorna su longitud, es decir la cantidad de caracteres que este tiene. No se permite el uso de 'strlen'.
uint32_t longitud_de_string(char* string) {
    uint32_t size = 0;

    if (string == NULL)
    {
        return 0;
    }
    

    while(*string != '\0'){
        size++;
        string++;
    }
    return size;
}

// Dado un string, retorna la cantidad de espacios que hay en él.
uint32_t contar_espacios(char* string) {
    uint32_t size = longitud_de_string(string);
    uint32_t count = 0;
    for (uint32_t i = 0; i < size; i++)
    {
        if (string[i] == ' ')
        {
            count++;
        }
    }
    
    return count;
}

// Pueden probar acá su código (recuerden comentarlo antes de ejecutar los tests!)
/*
int main() {

    printf("1. %d\n", contar_espacios("hola como andas?"));

    printf("2. %d\n", contar_espacios("holaaaa orga2"));
}
*/