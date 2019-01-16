#! /bin/sh

set -e

# $1 : name
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
    -DCMAKE_CXX_FLAGS="-I../src -I../include" \
    -DCMAKE_SYSTEM_NAME=Windows \
    -G "Unix Makefiles" \
    . > ../config.log 2>&1

make -j $jobopt install > ../make.log 2>&1
