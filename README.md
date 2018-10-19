# ewpi
EFL Windows package installer

# Requirements:
 * mingw-w64 toolchain (rename ar, ranlib, strip and windres with the host prefix when compiling on Windows)
 * autotools
 * cmake
 * nasm
 * wget
 * gperf
 * python

## Windows with MSYS2

1. Install MSYS2 : https://www.msys2.org/ (steps 1 to 6)
2. run "pacman -S git autoconf automake libtool gettext-devel cmake nasm wget gperf python mingw-w64-x86_64-toolchain mingw-w64-i686-toolchain"

## Fedora 32 bits

dnf install autoconf automake libtool cmake nasm gperf python mingw32-gcc mingw32-gcc-c++

## Fedora 64 bits

dnf install autoconf automake libtool cmake nasm gperf python mingw64-gcc mingw64-gcc-c++

# Compilation

gcc -std=c99 -o ewpi ewpi.c ewpi_map.c

# Usage

./ewpi /path/to/prefix toolchain

Examples :

 * ./ewpi $HOME/ewpi_32 i686-w64-mingw32
 * ./ewpi $HOME/ewpi_64 x86_64-w64-mingw32
