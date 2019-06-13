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

sed -i -e "s|@host@|$4|g;s|@proc@|$proc|g" cross_toolchain.txt

export CFLAGS="$machine -I.. $CFLAGS"
export LDFLAGS="$machine $LDFLAGS"

cmake \
    -DCMAKE_TOOLCHAIN_FILE=cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-I.. -O2 -pipe -march=$1" \
    -DCMAKE_EXE_LINKER_FLAGS="-s" \
    -DCMAKE_SHARED_LINKER_FLAGS="-s" \
    -DENABLE_STATIC=FALSE \
    -DREQUIRE_SIMD=TRUE \
    -DWITH_JAVA=FALSE \
    -DWITH_JPEG8=TRUE \
    -DWITH_TURBOJPEG=FALSE \
    -G "Unix Makefiles" \
    . >> ../config.log 2>&1

make -j $5 install > ../make.log 2>&1

sed -i -e "s|$prefix_unix|$3|g" $3/lib/pkgconfig/libjpeg.pc
sed -i -e "s|$prefix_unix|$3|g" $3/lib/pkgconfig/libturbojpeg.pc
