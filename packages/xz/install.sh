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
    -DBUILD_SHARED_LIBS=TRUE \
    -DBUILD_TESTING=OFF \
    -DENABLE_SMALL=FALSE \
    -DSUPPORTED_THREADING_METHODS=vista \
    -DXZ_MICROLZMA_ENCODER=OFF \
    -DXZ_MICROLZMA_DECODER=OFF \
    -DXZ_TOOL_XZDEC=OFF \
    -DXZ_TOOL_LZMADEC=OFF \
    -DXZ_TOOL_LZMAINFO=OFF \
    -DXZ_TOOL_XZ=OFF \
    -DXZ_DOC=OFF \
    -DXZ_NLS=OFF \
    -G "Unix Makefiles" \
    .. > ../../config.log 2>&1

make -j $jobopt install > ../../make.log 2>&1
