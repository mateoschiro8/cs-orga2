; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "print.mac"

global start


; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
extern A20_enable
extern GDT_DESC
extern screen_draw_layout

extern idt_init
extern IDT_DESC

extern pic_reset
extern pic_enable
extern pic_disable

extern mmu_init_kernel_dir
extern mmu_init_task_dir

extern tss_init

extern tasks_screen_draw

extern sched_init
extern tasks_init

; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
%define CS_RING_0_SEL  0x08   
                    ; 0b1000   
%define DS_RING_0_SEL 0x18   
                    ; 0b11000
%define GDT_IDX_TASK_IDLE 0x0C
%define GDT_IDX_TASK_INITIAL 0x0B

%define GDT_TASK_INITIAL_SEL (GDT_IDX_TASK_INITIAL << 3)
%define GDT_TASK_IDLE_SEL (GDT_IDX_TASK_IDLE << 3)

BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; Deshabilitar interrupciones
    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; Imprimir mensaje de bienvenida - MODO REAL
    print_text_rm start_rm_msg, start_rm_len, 0x5F, 40, 20
    
    ; Habilitar A20
    call A20_enable
    
    ; Cargar la GDT
    lgdt [GDT_DESC]

    ; LGDT: Loads the values in the source operand into the global descriptor table register (GDTR).
    ; The source operand specifies a 6-byte memory location that contains the base address (a linear address) 
    ; and the limit (size of table in bytes) of the global descriptor table (GDT).

    ; Setear el bit PE del registro CR0
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; Saltar a modo protegido (far jump)
    jmp CS_RING_0_SEL:modo_protegido
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo


BITS 32
modo_protegido:
    ; A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo

    mov ax, DS_RING_0_SEL
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax
    mov ss, ax
    
    ; Establecer el tope y la base de la pila
    mov ebp, 0x25000
    mov esp, ebp
    
    ; Imprimir mensaje de bienvenida - MODO PROTEGIDO
    print_text_pm start_pm_msg, start_pm_len, 0x5F, 40, 20

    ; Inicializar pantalla
    call screen_draw_layout

    ; Inicializamos y cargamos la IDT
    call idt_init
    lidt [IDT_DESC]

    ; Inicializar PICs
    call pic_reset
    call pic_enable

    ; Inicializar directorio    
    call mmu_init_kernel_dir
    mov cr3, eax

    ; Activar paginacion
    mov eax, cr0       
    or eax, 0x80000000 
    mov cr0, eax       

    ; Habilitamos interrupciones
    ; sti

    ; Interrumpimos
    ; int 88
    ; int 98

    ; int 32
    ; int 33
    
    push 0xC050
    call mmu_init_task_dir ; Devuelve un esquema de paginación para una tarea
    mov ecx, cr3 ; Me guardo el CR3 de la tarea idle
    mov cr3, eax ; Cargo el esquema de paginación que creé
    ; pongo un breakpoint acá para ver que funque todo

    mov dword [0x07000020], 0x0000B0CA ;En la memoria del ondemand escribimos un valor
    mov dword [0x07000BCA], 0x00000700

    ; Creamos entradas de gdt para las tareas Initial e Idle
    call tss_init

    call tasks_screen_draw

    ; 15                   3 2  1 0
    ; +---------------------+--+--+
    ; |       Index         |TI|RPL|
    ; +---------------------+--+--+


    mov ax, GDT_TASK_INITIAL_SEL 
    ltr ax ; (con ax = selector segmento tarea inicial)

    call sched_init
    call tasks_init

    mov ax, 5000
    out 0x40, al
    rol ax, 8
    out 0x40, al

    jmp GDT_TASK_IDLE_SEL:0
    
    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"