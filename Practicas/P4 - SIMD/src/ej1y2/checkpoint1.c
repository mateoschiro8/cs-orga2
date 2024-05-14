#include "checkpoints.h"

uint32_t dot_product_c(uint16_t *p, uint16_t *q, uint32_t length)
{
    uint32_t result = 0;
    for (uint32_t i = 0; i < length; i++)
    {
        result += p[i] * q[i];
    }
    return result;
}
