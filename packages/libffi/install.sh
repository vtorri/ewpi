#! /bin/sh

. ../../common.sh

export CPPFLAGS="-D_WIN32_WINNT=0x0600 $CPPFLAGS"

./configure --prefix=$3 --host=$4 --disable-static --disable-docs --disable-debug  > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
