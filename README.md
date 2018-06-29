# ewpi
EFL Windows package installer

# Requirements:
 * mingw-w64 toolchain
 * autotools
 * cmake
 * nasm
 * libcurl development package
 * patch

# Installation of requirement on Fedora

dnf install aotoconf automake libtool cmake nasm libcurl-devel patch

for the 32-bit cross toolchain :

dnf install mingw32-gcc mingw32-gcc-c++

for the 64-bit cross toolchain :

dnf install mingw64-gcc mingw64-gcc-c++
