#! /bin/sh

source ../../common.sh

case ${EWPI_OS} in
    MSYS*|MINGW*)
    ;;
    *)
        autoreconf -vif > ../config.log 2>&1
        ./configure --prefix=$3 --host=$4 --disable-static --disable-apps >> ../config.log 2>&1

        make -j $5 $verbmake install > ../make.log 2>&1
    ;;
esac
