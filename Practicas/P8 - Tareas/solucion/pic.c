/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Rutinas del controlador de interrupciones.
*/
#include "pic.h"

#define PIC1_PORT 0x20
#define PIC2_PORT 0xA0

static __inline __attribute__((always_inline)) void outb(uint32_t port,
                                                         uint8_t data) {
  __asm __volatile("outb %0,%w1" : : "a"(data), "d"(port));
}
void pic_finish1(void) { outb(PIC1_PORT, 0x20); }
void pic_finish2(void) {
  outb(PIC1_PORT, 0x20);
  outb(PIC2_PORT, 0x20);
}

// COMPLETAR: implementar pic_reset()
void pic_reset() {

  // Inicialización PIC1
  outb(PIC1_PORT,     0x11);  // ICW1: IRQs activas por flanco, modo cascada 
  outb(PIC1_PORT + 1, 0x20);  // ICW2: INT base para el PIC1 tipo 0x20
  outb(PIC1_PORT + 1, 0x04);  // ICW3: PIC1 master, tiene un slave conectado a IRQ2
  outb(PIC1_PORT + 1, 0x01);  // ICW4: Modo no buffered, fin de interrupción normal
  outb(PIC1_PORT + 1, 0xFF);  // OCW1: Deshabilitamos interrupciones del PIC1

  // Inicialización PIC2
  outb(PIC2_PORT,     0x11);  // ICW1: IRQs activas por flanco, modo cascada 
  outb(PIC2_PORT + 1, 0x28);  // ICW2: INT base para el PIC2 tipo 0x28
  outb(PIC2_PORT + 1, 0x02);  // ICW3: PIC2 slave, IRQ2 es la linea que envia al master 
  outb(PIC2_PORT + 1, 0x01);  // ICW4: Modo no buffered, fin de interrupción normal 
  outb(PIC2_PORT + 1, 0xFF);  // OCW1: Deshabilitamos interrupciones del PIC2

}

void pic_enable() {
  outb(PIC1_PORT + 1, 0x00);
  outb(PIC2_PORT + 1, 0x00);
}

void pic_disable() {
  outb(PIC1_PORT + 1, 0xFF);
  outb(PIC2_PORT + 1, 0xFF);
}
