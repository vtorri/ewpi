# ewpi
EFL Windows package installer

# Requirements:
 * mingw-w64 toolchain (rename ar, ranlib, strip and windres with the host prefix when compiling on Windows)
 * autotools
 * cmake
 * nasm
 * libcurl development package
 * patch
 * gperf

# Compilation

gcc -o ewpi ewpi.c ewpi_map.c `pkg-config --cflags --libs libcurl`

# Installation of requirement on Fedora

dnf install autoconf automake libtool cmake nasm libcurl-devel patch gperf

for the 32-bit cross toolchain :

dnf install mingw32-gcc mingw32-gcc-c++

for the 64-bit cross toolchain :

dnf install mingw64-gcc mingw64-gcc-c++

# Usage

./ewpi /path/to/prefix toolchain

Examples :

./ewpi $HOME/ewpi_32 i686-w64-mingw32
./ewpi $HOME/ewpi_64 x86_64-w64-mingw32
