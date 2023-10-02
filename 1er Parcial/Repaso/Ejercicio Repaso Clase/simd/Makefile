CFLAGS = -g
LDFLAGS = -z noexecstack

# Para hacer `all` se necesitan compilar todas las implementaciones
all: main main-clases main-dos-shifts main-sin-padd main-dos-shifts-sin-padd

main: main.o ejercicio.o
	$(CC) $(LDFLAGS) $^ -o $@

main-clases: main.o ejercicio-clases.o
	$(CC) $(LDFLAGS) $^ -o $@

main-dos-shifts: main.o ejercicio-dos-shifts.o
	$(CC) $(LDFLAGS) $^ -o $@

main-sin-padd: main.o ejercicio-sin-padd.o
	$(CC) $(LDFLAGS) $^ -o $@

main-dos-shifts-sin-padd: main.o ejercicio-dos-shifts-sin-padd.o
	$(CC) $(LDFLAGS) $^ -o $@


# Así se borran todos los archivos creados por este makefile
clean:
	rm  -f *.o main main-clases main-dos-shifts main-sin-padd main-dos-shifts-sin-padd

# Así se testea la implementación principal
test: main
	./main || (echo "Falló el código de main" && exit 1)

# Así se testean todas las implementaciones juntas
test-all: all
	# La @ hace que no se imprima la línea de comandos a ejecutar
	@./main                     || (echo "Falló el código de main"                     && exit 1)
	@./main-clases              || (echo "Falló el código de main-clases"              && exit 1)
	@./main-dos-shifts          || (echo "Falló el código de main-dos-shifts"          && exit 1)
	@./main-sin-padd            || (echo "Falló el código de main-sin-padd"            && exit 1)
	@./main-dos-shifts-sin-padd || (echo "Falló el código de main-dos-shifts-sin-padd" && exit 1)

# Le explicamos a `make` que algunas reglas no generan archivos sino que son de utilidad para nosotros
.PHONY: clean all test test-all

# Le explicamos a `make` cómo construir un .o desde un .asm
.asm.o:
	nasm -felf64 -g -Fdwarf $< -o $@

# Agregamos .asm a la lista de extensiones que tienen "reglas implícitas"
.SUFFIXES: .asm
