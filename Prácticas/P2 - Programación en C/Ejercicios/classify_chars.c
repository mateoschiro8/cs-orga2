#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int isVowel(char c) {
    if (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u' ||
        c == 'A' || c == 'E' || c == 'I' || c == 'O' || c == 'U' )
        return 1;
    else
        return 0;
}

void classify_chars_in_string(char* string, char** vowels_and_cons)
{
    // Obtener el largo del string
    int str_len = strlen(string);

    // Definir dos punteros temporales para movernos sin cambiar el original
    char* vowels_tmp = vowels_and_cons[0]; 
    char* cons_tmp = vowels_and_cons[1]; 

    for (int i = 0; i < str_len; i++)
    {
        if (isVowel(*string)) 
        {
            // Asignar la vocal actual al array de vocales
            *(vowels_tmp) = *string;
            vowels_tmp++;
        }
        else
        {
            // Asignar la consonante actual al array de consonantes
            *(cons_tmp) = *string;
            cons_tmp++;
        }
        // Desplazar el string
        string++;
    }
}


void classify_chars(classifier_t* array, uint64_t size_of_array) 
{
    for (uint64_t i = 0; i < size_of_array; i++)
    {
        // Como vowels_and_consonants es un puntero a NULL, reservamos su memoria primero
        array[i].vowels_and_consonants = malloc(2*sizeof(char*));

        // Reservar memoria en el heap
        array[i].vowels_and_consonants[0] = malloc(65 * sizeof(char));
        array[i].vowels_and_consonants[1] = malloc(65 * sizeof(char));

        // Inicializar todas las posiciones en 0
        memset(array[i].vowels_and_consonants[0], 0, 65 * sizeof(char));
        memset(array[i].vowels_and_consonants[1], 0, 65 * sizeof(char));

        // Llamado a la funcion
        classify_chars_in_string(array[i].string, array[i].vowels_and_consonants);
    }
}



