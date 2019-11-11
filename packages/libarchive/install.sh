#! /bin/sh

. ../../common.sh

./configure --prefix=$3 --host=$4 --disable-static --enable-bsdtar=shared --enable-bsdcat=shared --enable-bsdcpio=shared --without-xml2 --with-expat --without-nettle > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
