#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int isVowel(char letter){
    return (letter == 'A' || letter == 'E'|| letter == 'I' || letter == 'O' || letter =='U' || 
            letter == 'a' || letter == 'e'|| letter == 'i' || letter == 'o' || letter =='u'); 
}


void classify_chars_in_string(char* string, char** vowels_and_cons) {
    
    char* vowels = calloc(64, sizeof(char));
    char* cons = calloc(64, sizeof(char));

    vowels_and_cons[0] = vowels;
    vowels_and_cons[1] = cons;

    char* current = string;

    while (*current != '\0') 
    {
        if (isVowel(*current))
        {
            *vowels = *current;
            vowels++;
        }else {
            *cons = *current;
            cons ++;
        }
        current++;
    }
}

// puntero -->  [[vowels][cons]]

void classify_chars(classifier_t* array, uint64_t size_of_array) {
    for (uint64_t i = 0; i < size_of_array; i++)
    {
        // memoria para el array de vowels y cons
        array[i].vowels_and_consonants = malloc(2 * sizeof(char*));

        classify_chars_in_string(array[i].string, array[i].vowels_and_consonants);
    }
}