#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <assert.h>
#include <math.h>
#include <stdbool.h>
#include <float.h>

#include "test-utils.h"
#include "checkpoints.h"

#define ITERATIONS 30
#define VECTOR_LENGTH 128
static uint16_t x[VECTOR_LENGTH];
static uint16_t y[VECTOR_LENGTH];

char suits[4][9] = {"\xE2\x99\xA5", "\xE2\x99\xA6", "\xE2\x99\xA3", "\xE2\x99\xA0"};
char faces[13][6] = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J",
                     "Q", "K"};

void shuffle(uint64_t max)
{
    for (int i = 0; i < VECTOR_LENGTH; i++)
    {
        x[i] = (uint16_t)rand() % max;
        y[i] = (uint16_t)rand() % max;
    }
}

uint32_t shuffle_int(uint32_t min, uint32_t max)
{
    return (uint32_t)(rand() % (max - min)) + min;
}

card_t *get_deck()
{
    card_t *deck = (card_t *)malloc(sizeof(card_t) * 52);
    for (int i = 0; i < 52; i++)
    {
        deck[i].suit = i / 13;
        deck[i].value = i % 13 + 1;
    }
    return deck;
}

void print_card(card_t card)
{
    printf("%s%s", faces[card.value - 1], suits[card.suit]);
}

void print_deck(card_t *deck)
{
    for (int i = 0; i < 52; i++)
    {
        printf("Card %d: ", i);
        print_card(deck[i]);
    }
}

card_t *get_hand(card_t *deck)
{
    card_t *hand = (card_t *)malloc(sizeof(card_t) * 5);
    for (int i = 0; i < 4; i++)
    {
        hand[i] = deck[i];
    }
    return hand;
}

card_t get_random_card()
{
    return (card_t){.suit = shuffle_int(0, 4), .value = shuffle_int(1, 14)};
}

void shuffle_cards(card_t *array, size_t n)
{
    if (n > 1)
    {
        size_t i;
        for (i = 0; i < n - 1; i++)
        {
            size_t j = i + rand() / (RAND_MAX / (n - i) + 1);
            card_t t = array[j];
            array[j] = array[i];
            array[i] = t;
        }
    }
}

card_t four[4] = {0};

void reset_four_of_a_kind()
{
    uint8_t value = shuffle_int(2, 14);
    four[0].suit = CLUBS;
    four[0].value = value;
    four[1].suit = DIAMONDS;
    four[1].value = value;
    four[2].suit = HEARTS;
    four[2].value = value;
    four[3].suit = SPADES;
    four[3].value = value;
}

void get_four_of_a_kind(card_t *hand)
{
    reset_four_of_a_kind();
    shuffle_cards(four, 4);

    for (int i = 0; i < 4; i++)
    {
        hand[i] = four[i];
    }
}

/**
 * Tests checkpoint 1
 */

// uint16_t dot_product_c(uint16_t *p, uint16_t *q, uint32_t length);

TEST(test_dot_product)
{
    for (int i = 0; i < ITERATIONS; i++)
    {
        uint16_t *p_c = (uint16_t *)malloc(VECTOR_LENGTH * sizeof(uint16_t));
        uint16_t *q_c = (uint16_t *)malloc(VECTOR_LENGTH * sizeof(uint16_t));
        uint16_t *p_asm = (uint16_t *)malloc(VECTOR_LENGTH * sizeof(uint16_t));
        uint16_t *q_asm = (uint16_t *)malloc(VECTOR_LENGTH * sizeof(uint16_t));
        shuffle(256);

        for (int k = 0; k < VECTOR_LENGTH; k++)
        {
            p_c[k] = x[k];
            p_asm[k] = x[k];
            q_c[k] = y[k];
            q_asm[k] = y[k];
        }

        sprintf(assert_name, "dot_product_asm(p,q,result)");
        uint32_t result_c = dot_product_c(p_c, q_c, VECTOR_LENGTH);
        uint32_t result_asm = dot_product_asm(p_asm, q_asm, VECTOR_LENGTH);

        TEST_ASSERT_EQUALS(uint32_t, result_c, result_asm);

        free(p_c);
        free(q_c);
        free(p_asm);
        free(q_asm);
    }
}

/**
 * Tests checkpoint 2
 */

#define HANDS 1024

TEST(test_four_of_a_kind)
{
    card_t *deck = get_deck();
    for (int i = 0; i < ITERATIONS; i++)
    {
        card_t *test_data = (card_t *)malloc(sizeof(card_t) * 4 * HANDS);

        for (int i = 0; i < HANDS; i++)
        {
            uint32_t luck = shuffle_int(0, 10);

            if (luck >= 9)
            {
                get_four_of_a_kind(&test_data[i * 4]);
            }
            else
            {
                shuffle_cards(deck, 52);
                card_t *hand = get_hand(deck);
                for (int j = 0; j < 4; j++)
                {
                    test_data[i * 4 + j] = hand[j];
                }
                free(hand);
            }
        }

        sprintf(assert_name, "four_of_a_kind(test_data, HANDS)");

        uint32_t poker_hands_c = four_of_a_kind_c(test_data, HANDS);
        uint32_t poker_hands_asm = four_of_a_kind_asm(test_data, HANDS);
        TEST_ASSERT_EQUALS(uint32_t, poker_hands_c, poker_hands_asm);

        if (*test__fallo)
        {
            // print hands
            for (int i = 0; i < HANDS; i++)
            {
                 printf("Hand %d: ", i);
                for (int j = 0; j < 4; j++)
                {
                    print_card(test_data[i * 4 + j]);
                    printf(" ");
                }
                if (four_of_a_kind_c(&test_data[i * 4], 1) == 1)
                {
                    printf(" (Four of a kind!!)");
                }
                printf("\n");
            }
        }
        free(test_data);
    }
    free(deck);
}

int main()
{
    srand(0);

    printf("= Checkpoint 1\n");
    printf("==============\n");
    test_dot_product();
    printf("\n");

    printf("= Checkpoint 2\n");
    printf("==============\n");
    test_four_of_a_kind();

    printf("\n");

    tests_end();
    return 0;
}
