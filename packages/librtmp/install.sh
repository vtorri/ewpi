#! /bin/sh

. ../../common.sh

cd librtmp

export XCFLAGS="$CPPFLAGS $CFLAGS"
export XLDFLAGS=$LDFLAGS

make -j $5 clean prefix=$3 CROSS_COMPILE=$4- SYS=mingw > ../../make.log 2>&1
make -j $5 install prefix=$3 CROSS_COMPILE=$4- SYS=mingw >> ../../make.log 2>&1
