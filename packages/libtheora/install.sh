#! /bin/sh

. ../../common.sh

case ${EWPI_OS} in
    MSYS*|MINGW*)
    ;;
    *)
        disableogg=--disable-oggtest
        disablevorbis=--disable-vorbistest
	sed -i -e 's/$//' win32/xmingw32/libtheoraenc-all.def
	sed -i -e 's/$//' win32/xmingw32/libtheoradec-all.def
    ;;
esac

./configure --prefix=$3 --host=$4 --disable-static --disable-spec --disable-examples $disableogg $disablevorbis > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
