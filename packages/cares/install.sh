#! /bin/sh

source ../../common.sh

export CPPFLAGS="-D_WIN32_WINNT=0x0600 $CPPFLAGS"

./configure --prefix=$3 --host=$4 --disable-static  > ../config.log 2>&1

make V=0 -j $5 install > ../make.log 2>&1
