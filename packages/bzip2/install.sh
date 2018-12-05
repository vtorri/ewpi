#! /bin/sh

set -e

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt
# $6 : jobopt

cd packages/$1
dir_name=`tar t$5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
$4-gcc \
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

mkdir -p $3/{bin,include,lib}
cp libbz2-1.dll $3/bin
cp libbz2.dll.a $3/lib
cp bzlib.h $3/include

sed -i -e 's/installed: no/installed: yes/g' ../$1.ewpi
