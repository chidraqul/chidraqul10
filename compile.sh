#!/bin/bash
name="${1:-chidraqul10}"
mkdir -p build/
nasm -f elf64 "$name.asm" -o "build/$name.o"
ld -s -o "$name" "build/$name.o"
