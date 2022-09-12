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
    -DJPEG_INCLUDE_DIR=$3/include \
    -DLIBLZMA_INCLUDE_DIR=$3/include \
    -DWebP_INCLUDE_DIR=$3/include \
    -DZLIB_INCLUDE_DIR=$3/include \
    -DZSTD_INCLUDE_DIR=$3/include \
    -Djbig=FALSE \
    -Dlzma=TRUE \
    -Dwebp=TRUE \
    -Dcxx=FALSE \
    -Dtiff-opengl=OFF \
    -G "Unix Makefiles" \
    .. > ../../config.log 2>&1

make -j $jobopt $verbmake install > ../../make.log 2>&1
