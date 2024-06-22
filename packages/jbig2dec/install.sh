#! /bin/sh

. ../../common.sh

sed -i -e "s/bin_PROGRAMS/#bin_PROGRAMS/g;s/jbig2dec_SOURCES/#jbig2dec_SOURCES/g;s/jbig2dec_LDADD/#jbig2dec_LDADD/g" Makefile.in

./configure --prefix=$3 --host=$4 --disable-static > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
