#! /bin/sh

. ../../common.sh

$4-gcc \
    -s -O2 -pipe -march=$1 \
    -fomit-frame-pointer \
    -std=c99 \
    -shared \
    -Wl,--out-implib,libdeflate.dll.a \
    -Wl,--output-def,libdeflate.def \
    -o libdeflate-1.dll \
    -I. \
    -D_ANSI_SOURCE \
    -D_WIN32_WINNT=$winver \
    -Wall \
    -Wdeclaration-after-statement \
    -Wimplicit-fallthrough \
    -Winline \
    -Wmissing-prototypes \
    -Wpedantic \
    -Wstrict-prototypes \
    -Wundef \
    -Wvla \
    lib/adler32.c \
    lib/zlib_compress.c \
    lib/zlib_decompress.c \
    lib/deflate_compress.c \
    lib/deflate_decompress.c \
    lib/utils.c \
    lib/x86/cpu_features.c \
    > ../make.log 2>&1

deflatever=`sed -n 's/\#define LIBDEFLATE_VERSION_STRING.*"\(.*\)"/\1/p' libdeflate.h`
cp libdeflate.pc.in libdeflate.pc
sed -i -e "s|@PREFIX@|$3|g;s|@INCDIR@|\${prefix}/include|g;s|@LIBDIR@|\${exec_prefix}/lib|g;s|@VERSION@|$deflatever|g" libdeflate.pc
cp libdeflate.pc $3/lib/pkgconfig

mkdir -p $3/{bin,include,lib/pkgconfig}
cp libdeflate-1.dll $3/bin
cp libdeflate.dll.a $3/lib
cp libdeflate.pc $3/lib/pkgconfig
cp libdeflate.h $3/include
