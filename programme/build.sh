#!/bin/bash
# Uebersetzt ein Assemblerprogramm in eine hex-Datei fuer den Programmspeicher (ROM) in Digital.
#   ./build.sh fibonacci.s   ->   fibonacci.hex
# Benoetigt die GNU binutils fuer RISC-V (riscv64-unknown-elf-as, -ld, -objcopy).
set -e
P=${RISCV_PREFIX:-riscv64-unknown-elf-}
for src in "$@"; do
    n="${src%.s}"
    ${P}as -march=rv32i -mabi=ilp32 -o "$n.o" "$src"
    ${P}ld -m elf32lriscv -Ttext=0 -e _start -o "$n.elf" "$n.o"
    ${P}objcopy -O binary -j .text "$n.elf" "$n.bin"
    ( echo "v2.0 raw"; od -An -v -tx4 -w4 "$n.bin" | tr -d ' ' ) > "$n.hex"
    rm -f "$n.o" "$n.elf" "$n.bin"
    echo "$n.hex: $(($(wc -l < "$n.hex") - 1)) Befehle"
done
