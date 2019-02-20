#! /bin/sh

set -e

# $1 : arch
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt
# $6 : jobopt

dir_name=`tar t$5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name

EWPI_OS=`uname`
case ${EWPI_OS} in
    MSYS*|MINGW*)
	prefix_unix=`cygpath -u $3`
    ;;
    *)
	prefix_unix=$3
    ;;
esac
if test "x$4" = "xx86_64-w64-mingw32" ; then
    proc="AMD64"
else
    proc="X86"
fi

cmake \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_STATIC=FALSE \
    -DCMAKE_C_COMPILER=$4-gcc \
    -DCMAKE_C_FLAGS="-I.. -O2 -pipe -march=$1 -mtune=$1" \
    -DCMAKE_EXE_LINKER_FLAGS="-s" \
    -DCMAKE_SYSTEM_NAME=Windows \
    -DCMAKE_SYSTEM_PROCESSOR=$proc \
    -DREQUIRE_SIMD=TRUE \
    -DWITH_JAVA=FALSE \
    -DWITH_JPEG8=TRUE \
    -DWITH_TURBOJPEG=FALSE \
    -G "Unix Makefiles" \
    . > ../config.log 2>&1

make -j $jobopt install > ../make.log 2>&1
