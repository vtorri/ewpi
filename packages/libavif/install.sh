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

#sed -i -e "s|aom REQUIRED|aom|g" CMakeLists.txt

case ${EWPI_OS} in
    MSYS*|MINGW*)
        sed -i -e "s|%zu|%Iu|g" apps/avifenc.c
        sed -i -e "s|%zu|%Iu|g" apps/avifdec.c
        sed -i -e "s|%zu|%Iu|g" apps/shared/avifutil.c
    ;;
    *)
    ;;
esac

rm -rf builddir && mkdir builddir && cd builddir

cmake \
    -DCMAKE_TOOLCHAIN_FILE=../cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=TRUE \
    -DAVIF_CODEC_AOM:BOOL=ON \
    -DAVIF_CODEC_DAV1D:BOOL=ON \
    -DAVIF_BUILD_APPS:BOOL=ON \
    -G Ninja \
    .. > ../../config.log 2>&1

case ${EWPI_OS} in
    MSYS*|MINGW*)
    ;;
    *)
        sed -i -e "s|-I/usr/include||g" build.ninja
    ;;
esac

ninja $verbninja install > ../../make.log 2>&1
