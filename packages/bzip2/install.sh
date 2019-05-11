#! /bin/sh

source ../../common.sh

$4-gcc \
    -s -O2 -pipe -march=$1 \
    -shared \
    -Wl,--out-implib,libbz2.dll.a \
    -o libbz2-1.dll \
    -Wall -Winline -O2 \
    -D_FILE_OFFSET_BITS=64 \
    blocksort.c  \
    huffman.c    \
    crctable.c   \
    randtable.c  \
    compress.c   \
    decompress.c \
    bzlib.c \
    > ../make.log 2>&1

cat > bzip2.pc <<EOF
prefix=$3
exec_prefix=\${prefix}
bindir=\${exec_prefix}/bin
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: bzip2
Description: Lossless, block-sorting data compression
Version: 1.0.6
Libs: -L\${libdir} -lbz2
Cflags: -I\${includedir}
EOF

mkdir -p $3/{bin,include,lib/pkgconfig}
cp libbz2-1.dll $3/bin
cp libbz2.dll.a $3/lib
cp bzip2.pc $3/lib/pkgconfig
cp bzlib.h $3/include
