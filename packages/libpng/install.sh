#! /bin/sh

. ../../common.sh

cp ../cross_toolchain.txt .

if test "x$4" = "xx86_64-w64-mingw32" ; then
    proc="AMD64"
    machine=-m64
else
    proc="X86"
    machine=-m32
fi

sed -i -e "s|@prefix@|$3|g;s|@host@|$4|g;s|@proc@|$proc|g;s|@winver@|$winver|g" cross_toolchain.txt

rm -rf builddir && mkdir builddir && cd builddir

cmake \
    -DCMAKE_TOOLCHAIN_FILE=../cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DPNG_SHARED=TRUE \
    -DPNG_STATIC=FALSE \
    -DPNG_TESTS=FALSE \
    -DPNG_TOOLS=FALSE \
    -DPNG_EXECUTABLES=FALSE \
    -DPNG_DEBUG=FALSE \
    -DPNG_HARDWARE_OPTIMIZATIONS=TRUE \
    -DPNG_BUILD_ZLIB=FALSE \
    -G "Ninja" \
    .. > ../../config.log 2>&1

ninja $verbninja install > ../../make.log 2>&1
