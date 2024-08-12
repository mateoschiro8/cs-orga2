#include "task_lib.h"

#define WIDTH TASK_VIEWPORT_WIDTH
#define HEIGHT TASK_VIEWPORT_HEIGHT

#define SHARED_SCORE_BASE_VADDR (PAGE_ON_DEMAND_BASE_VADDR + 0xF00)
#define CANT_PONGS 3

void task(void) {
	screen pantalla;
	// ¿Una tarea debe terminar en nuestro sistema? 
	while (true)
	{
	uint8_t current_task_id = ENVIRONMENT->task_id;
	for(uint8_t i = 0; i < CANT_PONGS; i++) {
		if(i != current_task_id) {
			uint32_t* current_task_record = (uint32_t*) SHARED_SCORE_BASE_VADDR + ((uint32_t) i * sizeof(uint32_t)*2);

			task_print(pantalla, "Tarea ", 5, 5 + i * 4 , C_FG_BLUE | C_BLINK);
			task_print_dec(pantalla, i + 1, 1, 11, 5 + i * 4, C_FG_BLUE | C_BLINK);			

			task_print(pantalla, "Puntaje jugador 1: ", 5, 6 + i * 4 , C_FG_MAGENTA);
			task_print_dec(pantalla, current_task_record[0], 2, 24, 6 + i * 4, C_FG_LIGHT_BLUE);
			
			task_print(pantalla, "Puntaje jugador 2: ", 5, 7 + i * 4 , C_FG_MAGENTA);
			task_print_dec(pantalla, current_task_record[1], 2, 24 , 7 + i * 4, C_FG_LIGHT_BLUE);
		}
	}
		syscall_draw(pantalla);
	}
} 