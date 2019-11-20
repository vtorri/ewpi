#! /bin/sh

. ../../common.sh

sed -i -e 's/-D_FORTIFY_SOURCE=2//g' configure

./configure --prefix=$3 --host=$4 --disable-static --enable-experimental > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
