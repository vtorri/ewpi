#! /bin/sh

. ../../common.sh

./configure --prefix=$3 --host=$4 --disable-static --with-zlib-include-dir=$3/include --with-zlib-lib-dir=$3/lib --with-jpeg-include-dir=$3/include --with-jpeg-lib-dir=$3/lib --with-lzma-include-dir=$3/include --with-lzma-lib-dir=$3/lib --disable-cxx > ../config.log 2>&1

make -j $5 $verbmake install > ../make.log 2>&1
