.SUFFIXES: .o .c .asm

CFLAGS += -g

.asm.o:
	nasm -f elf64 -g -F DWARF $^ -o $@

all: ejercicio

clean:
	rm -f main.o medir-stack.o ejercicio

ejercicio: main.o medir-stack.o
	$(CC) $(LDFLAGS) $^ -o $@

.PHONY: all clean
