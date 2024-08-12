/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de la tabla de descriptores globales
*/

#include "gdt.h"

/* Aca se inicializa un arreglo de forma estatica
GDT_COUNT es la cantidad de líneas de la GDT y esta definido en defines.h */

// int num[3] = {[0] = 1, [1] = 2, [2] = 3};

gdt_entry_t gdt[GDT_COUNT] = {
    /* Descriptor nulo*/
    /* Offset = 0x00 */
    [GDT_IDX_NULL_DESC] =
        {
            // El descriptor nulo es el primero que debemos definir siempre
            // Cada campo del struct se matchea con el formato que figura en el manual de intel
            // Es una entrada en la GDT.
            .limit_15_0 = 0x0000,
            .base_15_0 = 0x0000,
            .base_23_16 = 0x00,
            .type = 0x0,
            .s = 0x00,
            .dpl = 0x00,
            .p = 0x00,
            .limit_19_16 = 0x00,
            .avl = 0x0,
            .l = 0x0,
            .db = 0x0,
            .g = 0x00,
            .base_31_24 = 0x00,
        },

    /* Completar la GDT: 
      Es conveniente completar antes las constantes definidas en defines.h y valerse
      de las mismas para definir los descriptores acá. Traten en lo posible de usar las 
      macros allí definidas.
      Tomen el descriptor nulo como ejemplo y definan el resto.
     */

    [GDT_IDX_CODE_0] =
        {
            .limit_15_0 = GDT_LIMIT_LOW(FLAT_SEGM_SIZE),
            .base_15_0 = GDT_BASE_LOW(FLAT_SEGM_BASE),
            .base_23_16 = GDT_BASE_MID(FLAT_SEGM_BASE),
            .type = TYPE_READ_EXECUTE,
            .s = BIT_ON,
            .dpl = ROOT_PRIVILEGE,
            .p = BIT_ON,
            .limit_19_16 = GDT_LIMIT_HIGH(FLAT_SEGM_SIZE),
            .avl = BIT_OFF,
            .l = BIT_OFF,
            .db = BIT_ON,
            .g = BIT_ON,
            .base_31_24 = GDT_BASE_HIGH(FLAT_SEGM_BASE),
        },
    
    [GDT_IDX_CODE_3] =
        {
            .limit_15_0 = GDT_LIMIT_LOW(FLAT_SEGM_SIZE),
            .base_15_0 = GDT_BASE_LOW(FLAT_SEGM_BASE),
            .base_23_16 = GDT_BASE_MID(FLAT_SEGM_BASE),
            .type = TYPE_READ_EXECUTE,
            .s = BIT_ON,
            .dpl = USER_PRIVILEGE,
            .p = BIT_ON,
            .limit_19_16 = GDT_LIMIT_HIGH(FLAT_SEGM_SIZE),
            .avl = BIT_OFF,
            .l = BIT_OFF,
            .db = BIT_ON,
            .g = BIT_ON,
            .base_31_24 = GDT_BASE_HIGH(FLAT_SEGM_BASE),
        },

    [GDT_IDX_DATA_0] =
        {
            .limit_15_0 = GDT_LIMIT_LOW(FLAT_SEGM_SIZE),
            .base_15_0 = GDT_BASE_LOW(FLAT_SEGM_BASE),
            .base_23_16 = GDT_BASE_MID(FLAT_SEGM_BASE),
            .type = TYPE_READ_WRITE,
            .s = BIT_ON,
            .dpl = ROOT_PRIVILEGE,
            .p = BIT_ON,
            .limit_19_16 = GDT_LIMIT_HIGH(FLAT_SEGM_SIZE),
            .avl = BIT_OFF,
            .l = BIT_OFF,
            .db = BIT_ON,
            .g = BIT_ON,
            .base_31_24 = GDT_BASE_HIGH(FLAT_SEGM_BASE),
        },

    [GDT_IDX_DATA_3] =
        {
            .limit_15_0 = GDT_LIMIT_LOW(FLAT_SEGM_SIZE),
            .base_15_0 = GDT_BASE_LOW(FLAT_SEGM_BASE),
            .base_23_16 = GDT_BASE_MID(FLAT_SEGM_BASE),
            .type = TYPE_READ_WRITE,
            .s = BIT_ON,
            .dpl = USER_PRIVILEGE,
            .p = BIT_ON,
            .limit_19_16 = GDT_LIMIT_HIGH(FLAT_SEGM_SIZE),
            .avl = BIT_OFF,
            .l = BIT_OFF,
            .db = BIT_ON,
            .g = BIT_ON,
            .base_31_24 = GDT_BASE_HIGH(FLAT_SEGM_BASE),
        },

    [GDT_IDX_VIDEO] =
        {
            .limit_15_0 = GDT_LIMIT_LOW(GDT_LIMIT_4KIB(VIDEO_SEGM_SIZE)),
            .base_15_0 = GDT_BASE_LOW(VIDEO),
            .base_23_16 = GDT_BASE_MID(VIDEO),
            .type = TYPE_READ_WRITE,
            .s = BIT_ON,
            .dpl = USER_PRIVILEGE,
            .p = BIT_ON,
            .limit_19_16 = GDT_LIMIT_HIGH(GDT_LIMIT_4KIB(VIDEO_SEGM_SIZE)),
            .avl = BIT_OFF,
            .l = BIT_OFF,
            .db = BIT_ON,
            .g = BIT_ON,
            .base_31_24 = GDT_BASE_HIGH(VIDEO),
        }    
    
};

// Aca hay una inicializacion estatica de una structura que tiene su primer componente el tamano 
// y en la segunda, la direccion de memoria de la GDT. Observen la notacion que usa. 
gdt_descriptor_t GDT_DESC = {sizeof(gdt) - 1, (uint32_t)&gdt};
