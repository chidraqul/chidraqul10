ASM=nasm
LD=ld

all: chidraqul10

build/chidraqul10.o: chidraqul10.asm
	mkdir -p build
	$(ASM) -f elf64 chidraqul10.asm -o build/chidraqul10.o

chidraqul10: build/chidraqul10.o
	$(LD) -s -o chidraqul10 build/chidraqul10.o

.PHONY: clean

clean:
	rm -rf build
