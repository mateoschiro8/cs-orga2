#include "checkpoints.h"

/* Retorna la cantidad de manos que tienen cuatro cartas del mismo valor */

uint32_t four_of_a_kind_c(card_t *hands, uint32_t n)
{
    uint32_t count = 0;
    for (uint32_t i = 0; i < n; i++)
    {
        uint8_t matches = 1;
        uint8_t value = hands[i * 4].value;
        for (uint32_t j = 1; j < 4; j++)
        {
            if (hands[i * 4 + j].value == value)
            {
                matches++;
            }
        }
        if (matches == 4)
        {
            count++;
        }
    }
    return count;
}
