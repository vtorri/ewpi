#! /bin/sh

. ../../common.sh

export LIBS="-L$3/lib -liconv"

./configure --prefix=$3 --host=$4 --disable-static --with-libiconv-prefix=$3 --disable-cpplibs > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
