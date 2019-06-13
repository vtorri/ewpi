#! /bin/sh

. ../../common.sh

case ${EWPI_OS} in
    MSYS*|MINGW*)
    ;;
    *)
        disableogg=--disable-oggtest
    ;;
esac

./configure --prefix=$3 --host=$4 --disable-static --enable-examples $disableogg > ../config.log 2>&1

make -j $5 $verbmake install > ../make.log 2>&1
