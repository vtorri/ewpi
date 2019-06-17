#! /bin/sh

. ../../common.sh

./configure --prefix=$3 --host=$4 --disable-static --disable-openmpt123 --disable-examples --disable-tests --disable-libmodplug > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
