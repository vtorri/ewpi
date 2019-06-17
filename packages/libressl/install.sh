#! /bin/sh

. ../../common.sh

sed -i -e 's/SUBDIRS = crypto ssl tls include apps tests man/SUBDIRS = crypto ssl tls include apps tests/g' Makefile.in

./configure --prefix=$3 --host=$4 --disable-static --enable-windows-ssp > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
