#!/bin/bash
mkdir -p build/
nasm -f elf64 chidraqul10.asm -o build/chidraqul10.o
ld -s -o chidraqul10 build/chidraqul10.o
