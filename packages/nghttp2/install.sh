#! /bin/sh

. ../../common.sh

./configure --prefix=$3 --host=$4 --disable-static --enable-lib-only > ../config.log 2>&1

sed -i -e "s/HAVE_CLOCK_GETTIME/HAVE_CLOCK_GETTIME1/g" lib/nghttp2_time.c

make -j $jobopt $verbmake install > ../make.log 2>&1
