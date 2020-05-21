#! /bin/sh

. ../../common.sh

./configure --prefix=$3 --host=$4 --disable-static > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
