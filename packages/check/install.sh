#! /bin/sh

. ../../common.sh

export LIBS="-lregex $LIBS"

./configure --prefix=$3 --host=$4 --disable-static --disable-subunit > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
