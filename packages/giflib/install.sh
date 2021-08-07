#! /bin/sh

. ../../common.sh

$4-gcc \
    -s -O2 -std=gnu99 -Wall -Wall -Wno-format-truncation \
    -shared \
    -Wl,--out-implib,libgif.dll.a \
    -o libgif-7.dll \
    dgif_lib.c \
    egif_lib.c \
    gifalloc.c \
    gif_err.c \
    gif_font.c \
    gif_hash.c \
    openbsd-reallocarray.c \
    > ../make.log 2>&1

mkdir -p $3/{bin,include,lib}
cp libgif-7.dll $3/bin
cp libgif.dll.a $3/lib
cp gif_lib.h $3/include
