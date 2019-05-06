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
cp ../cross_toolchain.txt .

sed -i '/typedef SSIZE_T ssize_t;/ d' src/lib/openjpip/sock_manager.c

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
    machine=-m64
else
    proc="X86"
    machine=-m32
fi

sed -i -e "s|@host@|$4|g;s|@proc@|$proc|g" cross_toolchain.txt

export PATH=$prefix_unix/bin:$PATH
export CFLAGS="$machine -O2 -pipe -march=$1"
export CXXFLAGS="$machine -O2 -pipe -march=$1"
export LDFLAGS="$machine -s"
export PKG_CONFIG_LIBDIR=$3/lib/pkgconfig
export PKG_CONFIG_PATH=$3/lib/pkgconfig

cmake \
    -DCMAKE_TOOLCHAIN_FILE=cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_STATIC_LIBS:BOOL=OFF \
    -DCMAKE_C_FLAGS="-O2 -pipe -march=$1 -I../common -I../../../src/lib/openjp2 -I$3/include" \
    -DCMAKE_CXX_FLAGS="-O2 -pipe -march=$1" \
    -DCMAKE_EXE_LINKER_FLAGS="-s -L$prefix_unix/lib" \
    -DCMAKE_SHARED_LINKER_FLAGS="-s" \
    -DBUILD_CODEC:BOOL=ON \
    -DBUILD_JPWL:BOOL=OFF \
    -DBUILD_MJ2:BOOL=OFF \
    -DBUILD_JPIP:BOOL=OFF \
    -DBUILD_JP3D:BOOL=OFF \
    -DBUILD_PKGCONFIG_FILES:BOOL=ON \
    -G "Unix Makefiles" \
    . > ../config.log 2>&1

sed -i -e "s|$prefix_unix|$3|g" src/bin/jp2/CMakeFiles/opj_compress.dir/linklibs.rsp
sed -i -e "s|$prefix_unix|$3|g" src/bin/jp2/CMakeFiles/opj_decompress.dir/linklibs.rsp
sed -i -e "s|$prefix_unix|$3|g" src/bin/jp2/CMakeFiles/opj_dump.dir/linklibs.rsp

make -j $jobopt install > ../make.log 2>&1

sed -i -e "s|$prefix_unix|$3|g" $3/lib/pkgconfig/libopenjp2.pc
