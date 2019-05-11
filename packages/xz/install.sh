#! /bin/sh

source ../../common.sh

./configure --prefix=$3 --host=$4 --disable-static --enable-threads=vista --disable-lzmainfo --disable-lzma-links --disable-scripts --disable-doc > ../config.log 2>&1

make V=0 -j $5 install > ../make.log 2>&1
