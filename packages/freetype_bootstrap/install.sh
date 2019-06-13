#! /bin/sh

. ../../common.sh

./configure --prefix=$3 --host=$4 --disable-static --with-harfbuzz=no --with-bzip2=no > ../config.log 2>&1

make -j $5 $verbmake install > ../make.log 2>&1
