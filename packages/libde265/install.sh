#! /bin/sh

. ../../common.sh

./configure --prefix=$3 --host=$4 --disable-static --disable-sherlock265 --disable-dec265 --enable-log-error --enable-encoder --enable-sse > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
