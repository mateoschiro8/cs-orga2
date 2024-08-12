/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"

#include "kassert.h"

static pd_entry_t* kpd = (pd_entry_t*)KERNEL_PAGE_DIR;
static pt_entry_t* kpt = (pt_entry_t*)KERNEL_PAGE_TABLE_0;

static const uint32_t identity_mapping_beginning = 0x00000000;
static const uint32_t identity_mapping_end = 0x003FFFFF; // 4194303 / PAGE_SIZE = ~1024
static const uint32_t user_memory_pool_end = 0x02FFFFFF;

static paddr_t next_free_kernel_page = 0x100000;
static paddr_t next_free_user_page = 0x400000;

/**
 * kmemset asigna el valor c a un rango de memoria interpretado
 * como un rango de bytes de largo n que comienza en s
 * @param s es el puntero al comienzo del rango de memoria
 * @param c es el valor a asignar en cada byte de s[0..n-1]
 * @param n es el tamaño en bytes a asignar
 * @return devuelve el puntero al rango modificado (alias de s)
*/
static inline void* kmemset(void* s, int c, size_t n) {
  uint8_t* dst = (uint8_t*)s;
  for (size_t i = 0; i < n; i++) {
    dst[i] = c;
  }
  return dst;
}

/**
 * zero_page limpia el contenido de una página que comienza en addr
 * @param addr es la dirección del comienzo de la página a limpiar
*/
static inline void zero_page(paddr_t addr) {
  kmemset((void*)addr, 0x00, PAGE_SIZE);
}


void mmu_init(void) {
  
}


/**
Recuerden que las entradas del directorio y la tabla deben realizar un mapeo por identidad (las direcciones lineales son
iguales a las direcciones fisicas) para el rango reservado para el kernel, de 0x00000000 a 0x003FFFFF, como ilustra la
figura 2. Esta funcion debe inicializar tambien el directorio de paginas en la direccion 0x25000 y las tablas de paginas
segun muestra la figura 1. Cuantas entradas del directorio de pagina hacen falta?


 * mmu_next_free_kernel_page devuelve la dirección física de la próxima página de kernel disponible. 
 * Las páginas se obtienen en forma incremental, siendo la primera: next_free_kernel_page
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de kernel
 */
paddr_t mmu_next_free_kernel_page(void) {
  paddr_t current_free_kernel_page = next_free_kernel_page; 
  next_free_kernel_page = next_free_kernel_page + PAGE_SIZE;
  // zero_page(current_free_kernel_page);
  return current_free_kernel_page;
}

/**
 * mmu_next_free_user_page devuelve la dirección de la próxima página de usuarix disponible
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de usuarix
 */
paddr_t mmu_next_free_user_page(void) {
  paddr_t current_free_user_page = next_free_user_page; 
  next_free_user_page = next_free_user_page + PAGE_SIZE;
  // zero_page(current_free_user_page);
  return current_free_user_page;
}

/**
 * mmu_init_kernel_dir inicializa las estructuras de paginación vinculadas al kernel y
 * realiza el identity mapping
 * @return devuelve la dirección de memoria de la página donde se encuentra el directorio
 * de páginas usado por el kernel
 */
paddr_t mmu_init_kernel_dir(void) {

    zero_page((paddr_t) kpd);
    zero_page((paddr_t) kpt);

    uint32_t total_iterations = (identity_mapping_end + 1) / PAGE_SIZE;
              
    for (size_t i = 0; i < total_iterations; i++) {
        // attrs = 0b000100000011
        // page era = (identity_mapping_beginning + i * PAGE_SIZE)
        pt_entry_t current_entry = {.attrs = MMU_P | MMU_W, .page = i}; // capaz los attr estan al reves 
        kpt[i] = current_entry;
    }

    kpd[0] = (pd_entry_t){.attrs = MMU_P | MMU_W, .pt = 0x26}; 
    // estan bien los attr? no los cambiamos, dejamos los de la pt
    // Ese 0x26 era originalmente KERNEL_PAGE_TABLE_0 = 0x26000

    return (paddr_t) kpd;
}

/**
 * mmu_map_page agrega las entradas necesarias a las estructuras de paginacion de modo de que
 * la direccion virtual virt se traduzca en la direccion física phy con los atributos definidos en attrs
 * @param cr3 el contenido que se ha de cargar en un registro CR3 al realizar la traduccion
 * @param virt la direccion virtual que se ha de traducir en phy
 * @param phy la direccion física que debe ser accedida (direccion de destino)
 * @param attrs los atributos a asignar en la entrada de la tabla de páginas
 */
void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs) {

    // #define VIRT_PAGE_OFFSET(X) ((X) & 0xFFF)  
    // #define VIRT_PAGE_TABLE(X)  (((X) >> 12) & 0x3FF)
    // #define VIRT_PAGE_DIR(X)    (((X) >> 22) & 0x3FF)
    // #define CR3_TO_PAGE_DIR(X)  (X & 0xFFFFF000)
    
    uint32_t offset_page_directory = VIRT_PAGE_DIR(virt);
    uint32_t offset_table_directory = VIRT_PAGE_TABLE(virt);
    uint32_t offset_physical_page = VIRT_PAGE_OFFSET(virt);

    // 1) Hallar la entrada en el Page Directory

    pd_entry_t* base_page_directory = CR3_TO_PAGE_DIR(cr3);
    pd_entry_t page_directory_entry = base_page_directory[offset_page_directory];

    // 2) Si no existe, crear la entrada
    
    if (!(page_directory_entry.attrs & MMU_P)) {
        base_page_directory[offset_page_directory] = (pd_entry_t) {.attrs = MMU_P | MMU_U | MMU_W, .pt = (mmu_next_free_kernel_page() >> 12)};  
        // nos traemos el actualizado
        page_directory_entry = base_page_directory[offset_page_directory];
    }
    
    // 3) Crear la entrada de la page table

    uint32_t newAttrs =  attrs | MMU_P;
    pt_entry_t* page_table_base = page_directory_entry.pt << 12;
    page_table_base[offset_table_directory] = (pt_entry_t) {.attrs = newAttrs, .page = phy >> 12};

    tlbflush();

    /*
    void mapPage(cr3, virt, phy, attrs) {
        if (!tienePageTableAsociada(cr3, virt.pd_index) {
            pedirlePageTable(cr3, virt.pd_index)
        }
        attrs_pd = calcularAttrsEfectivos(cr3[virt.pd_index].attrs, attrs);
        cr3[virt.pd_index].page[virt.pt_index].page = phy.page;
        cr3[virt.pd_index].page[virt.pt_index].attrs = attrs;
    }    
    */
}

/**
 * mmu_unmap_page elimina la entrada vinculada a la direccion virt en la tabla de páginas correspondiente
 * @param virt la direccion virtual que se ha de desvincular
 * @return la direccion física de la página desvinculada
 static pd_entry_t* kpd = (pd_entry_t*)KERNEL_PAGE_DIR;
  static pt_entry_t* kpt = (pt_entry_t*)KERNEL_PAGE_TABLE_0;
 */
paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt) {

    uint32_t phy = 0;

    uint32_t offset_page_directory = VIRT_PAGE_DIR(virt);
    uint32_t offset_table_directory = VIRT_PAGE_TABLE(virt);
    uint32_t offset_physical_page = VIRT_PAGE_OFFSET(virt);

    pd_entry_t* base_page_directory = CR3_TO_PAGE_DIR(cr3);

    pd_entry_t page_directory_entry = base_page_directory[offset_page_directory];    
    
    if (page_directory_entry.attrs & MMU_P) {

        pt_entry_t* page_table_base = page_directory_entry.pt << 12;
        phy = page_table_base[offset_table_directory].page << 12;
        page_table_base[offset_table_directory].attrs &= ~MMU_P;// bit present en 0

        tlbflush();

    }
    return phy;
}

#define DST_VIRT_PAGE 0xA00000  
#define SRC_VIRT_PAGE 0xB00000

/**
 * copy_page copia el contenido de la página física localizada en la dirección src_addr a la página física ubicada en dst_addr
 * @param dst_addr la dirección a cuya página queremos copiar el contenido
 * @param src_addr la dirección de la página cuyo contenido queremos copiar
 *
 * Esta función mapea ambas páginas a las direcciones SRC_VIRT_PAGE y DST_VIRT_PAGE, respectivamente, realiza
 * la copia y luego desmapea las páginas. Usar la función rcr3 definida en i386.h para obtener el cr3 actual
 */
void copy_page(paddr_t dst_addr, paddr_t src_addr) {
    
    uint32_t cr3 = rcr3(); 

    mmu_map_page(cr3, SRC_VIRT_PAGE, src_addr, MMU_P);
    mmu_map_page(cr3, DST_VIRT_PAGE, dst_addr, MMU_W | MMU_P);

    uint32_t* dst =  (uint32_t*) DST_VIRT_PAGE;
    uint32_t* src =  (uint32_t*) SRC_VIRT_PAGE; 
    
    for(int i = 0; i < 1024; i++){ // 4KB = 4096B = 1024*4B (4B el tamaño que escribo)
        dst[i] = src[i];
    }

    mmu_unmap_page(cr3, DST_VIRT_PAGE);
    mmu_unmap_page(cr3, SRC_VIRT_PAGE);

}

 /**
 * mmu_init_task_dir inicializa las estructuras de paginación vinculadas a una tarea cuyo código se encuentra en la dirección phy_start
 * @param phy_start es la dirección donde comienzan las dos páginas de código de la tarea asociada a esta llamada
 * @return el contenido que se ha de cargar en un registro CR3 para la tarea asociada a esta llamada
   La rutina debe mapear las paginas de codigo como solo lectura, a partir de la direccion
   virtual 0x08000000, el stack como lectura-escritura con base en 0x08003000 y la pagina de memoria compartida luego
   00000 1000 00 | 00 0000 0000 | 0000 0000 0000
   00000 1000 00 | 00 0000 0001 | 0000 0000 0000
     offset dir    offset table    offset phy
   del stack
 */

#define CODE_VIRTUAL_ADDR 0x08000000
#define STACK_VIRTUAL_ADDR 0x08002000
#define SHARED_VIRTUAL_ADDR (STACK_VIRTUAL_ADDR + PAGE_SIZE)
paddr_t mmu_init_task_dir(paddr_t phy_start) {

    pd_entry_t* cr3 = mmu_next_free_kernel_page(); // reservamos memoria para el page directory
    zero_page(cr3);    

    paddr_t tabla_kernel = mmu_next_free_kernel_page();
    zero_page(tabla_kernel);

    copy_page(tabla_kernel, (paddr_t) kpt);

    // Definimos una copia de la kpt en la entrada 0 del directorio
    cr3[0] = (pd_entry_t){.attrs = MMU_P | MMU_W, .pt = tabla_kernel >> 12};

    // mapeamos las dos paginas de codigo como solo lectura
    mmu_map_page(cr3, CODE_VIRTUAL_ADDR, phy_start, MMU_U | MMU_P);
    mmu_map_page(cr3, CODE_VIRTUAL_ADDR + PAGE_SIZE, phy_start + PAGE_SIZE, MMU_U | MMU_P);

    // mapeamos stack como r/w
    // attrs = 0b000000000111
    paddr_t first_free_user_page = mmu_next_free_user_page();
    mmu_map_page(cr3, STACK_VIRTUAL_ADDR, first_free_user_page, MMU_U | MMU_P | MMU_W);

    // mapeamos shared como solo lectura
    mmu_map_page(cr3, SHARED_VIRTUAL_ADDR, SHARED, MMU_U | MMU_P);

    return cr3; // todos los atributos del CR3 en 0 PIBE

}

// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución 
// y false si no se pudo atender
bool page_fault_handler(vaddr_t virt) {
    print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);

    // Chequeemos si el acceso fue dentro del area on-demand
    if (virt >> 12 == ON_DEMAND_MEM_START_VIRTUAL >> 12) {
        
        // En caso de que si, mapear la pagina
        mmu_map_page(rcr3(), virt, ON_DEMAND_MEM_START_PHYSICAL, MMU_P | MMU_U | MMU_W);
        print("Atendidoo", 0, 10, C_FG_WHITE | C_BG_BLACK);
        return 1;

    } else
        print("El PG no fue de la memoria on-demand", 0, 2, C_FG_WHITE | C_BG_BLACK);

    return 0;
}

