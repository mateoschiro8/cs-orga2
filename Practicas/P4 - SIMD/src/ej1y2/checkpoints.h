#ifndef CHECKPOINTS
#define CHECKPOINTS

#include <stdint.h> //contiene la definición de tipos enteros ligados a tamaños int8_t, int16_t, uint8_t,...

enum suits
{
    HEARTS,
    DIAMONDS,
    CLUBS,
    SPADES
};

typedef struct card_s
{
    uint8_t value : 4;
    uint8_t suit : 4;
} card_t;

uint32_t dot_product_c(uint16_t *p, uint16_t *q, uint32_t length);
uint32_t dot_product_asm(uint16_t *p, uint16_t *q, uint32_t length);
uint32_t four_of_a_kind_c(card_t *hands, uint32_t n);
uint32_t four_of_a_kind_asm(card_t *hands, uint32_t n);

#endif /* CHECKPOINTS */
