#! /bin/sh

source ../../common.sh

if test "x$4" = "xi686-w64-mingw32" ; then
    cpu=x86
else
    cpu=x86-64
fi

./configure --prefix=$3 --host=$4 --disable-static --with-cpu=$cpu --enable-yasm --enable-int-quality --with-default-audio=win32_wasapi > ../config.log 2>&1

make -j $5 install > ../make.log 2>&1
