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

sed -i -e "s|%zu|%Iu|g" apps/avifenc.c
sed -i -e "s|%zu|%Iu|g" apps/avifdec.c
sed -i -e "s|%zu|%Iu|g" apps/shared/avifutil.c

rm -rf builddir && mkdir builddir && cd builddir

cmake \
    -DCMAKE_TOOLCHAIN_FILE=../cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-O2 -pipe $machine -march=$1 -D__USE_MINGW_ANSI_STDIO=0" \
    -DCMAKE_EXE_LINKER_FLAGS="-s" \
    -DCMAKE_SHARED_LINKER_FLAGS="-s $machine" \
    -DBUILD_SHARED_LIBS=TRUE \
    -DAVIF_CODEC_AOM:BOOL=ON \
    -DAVIF_CODEC_DAV1D:BOOL=ON \
    -DAVIF_BUILD_APPS:BOOL=ON \
    -G "Unix Makefiles" \
    .. >> ../../config.log 2>&1

make -j $jobopt install > ../../make.log 2>&1
