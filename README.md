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
2. run "pacman -S git autoconf automake libtool gettext-devel cmake nasm wget gperf python mingw-w64-x86_64-toolchain mingw-w64-i686-toolchain mingw-w64-x86_64-ninja mingw-w64-x86_64-python3-pip"
3. run "pip3 install meson"

## Fedora 32 bits

1. dnf install autoconf automake libtool cmake nasm gperf python ninja mingw32-gcc mingw32-gcc-c++
2. run "pip3 install meson"

## Fedora 64 bits

1. dnf install autoconf automake libtool cmake nasm gperf python ninja mingw64-gcc mingw64-gcc-c++
2. run "pip3 install meson"

# Compilation

gcc -std=c99 -o ewpi ewpi.c ewpi_map.c

# Usage

./ewpi /path/to/prefix toolchain [number of make jobs]

Examples :

 * ./ewpi $HOME/ewpi_32 i686-w64-mingw32
 * ./ewpi $HOME/ewpi_64 x86_64-w64-mingw32 4
