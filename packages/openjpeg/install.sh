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
sed -i '/typedef SSIZE_T ssize_t;/ d' src/lib/openjpip/sock_manager.c
export PKG_CONFIG_LIBDIR=$3/lib/pkgconfig
export PKG_CONFIG_PATH=$3/lib/pkgconfig
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
    -DCMAKE_RC_COMPILER=$4-windres \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_STATIC_LIBS:BOOL=OFF \
    -DBUILD_CODEC:BOOL=OFF \
    -DBUILD_JPWL:BOOL=OFF \
    -DBUILD_MJ2:BOOL=OFF \
    -DBUILD_JPIP:BOOL=OFF \
    -DBUILD_JP3D:BOOL=OFF \
    -DBUILD_PKGCONFIG_FILES:BOOL=ON \
    -DCMAKE_SYSTEM_NAME=Windows \
    -G "Unix Makefiles" \
    . > ../config.log 2>&1

make -j $jobopt install > ../make.log 2>&1
