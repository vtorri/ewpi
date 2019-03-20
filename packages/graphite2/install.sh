#! /bin/sh

set -e

unset PKG_CONFIG_PATH

# $1 : arch
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt
# $6 : jobopt

dir_name=`tar t$5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
sed -i -e 's/add_subdirectory(tests)//g' CMakeLists.txt

EWPI_OS=`uname`
case ${EWPI_OS} in
    MSYS*|MINGW*)
	prefix_unix=`cygpath -u $3`
    ;;
    *)
	prefix_unix=$3
    ;;
esac

cmake \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DCMAKE_C_COMPILER=$4-gcc \
    -DCMAKE_CXX_COMPILER=$4-g++ \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-I../src -I../include -O2 -pipe -march=$1" \
    -DCMAKE_CXX_FLAGS="-I../src -I../include -O2 -pipe -march=$1" \
    -DCMAKE_EXE_LINKER_FLAGS="-s" \
    -DCMAKE_SHARED_LINKER_FLAGS="-s" \
    -DCMAKE_SYSTEM_NAME=Windows \
    -G "Unix Makefiles" \
    . > ../config.log 2>&1

make -j $jobopt install > ../make.log 2>&1
