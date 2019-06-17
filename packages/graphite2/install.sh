#! /bin/sh

. ../../common.sh

cp ../cross_toolchain.txt .

sed -i -e 's/add_subdirectory(tests)//g' CMakeLists.txt

if test "x$4" = "xx86_64-w64-mingw32" ; then
    proc="AMD64"
    machine=-m64
else
    proc="X86"
    machine=-m32
fi

sed -i -e "s|@host@|$4|g;s|@proc@|$proc|g" cross_toolchain.txt

export CFLAGS="$machine -I../src -I../include $CFLAGS"
export CXXFLAGS="$machine -I../src -I../include $CCCFLAGS"
export LDFLAGS="$machine $LDFLAGS"

cmake \
    -DCMAKE_TOOLCHAIN_FILE=cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-I../src -I../include -O2 -pipe -march=$1" \
    -DCMAKE_CXX_FLAGS="-I../src -I../include -O2 -pipe -march=$1" \
    -DCMAKE_EXE_LINKER_FLAGS="-s" \
    -DCMAKE_SHARED_LINKER_FLAGS="-s" \
    -G "Unix Makefiles" \
    . > ../config.log 2>&1

make -j $jobopt install > ../make.log 2>&1

sed -i -e "s|$prefix_unix|$3|g" $3/lib/pkgconfig/graphite2.pc
