#! /bin/sh

. ../../common.sh

git fetch && git fetch --tags
git checkout 6bbe6ae701d65bdf36bb72053db9b71f9739a083

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
    -DCONFIG_AV1_DECODER=1 \
    -DCONFIG_AV1_ENCODER=1 \
    -DCONFIG_MULTITHREAD=1 \
    -DCONFIG_TUNE_VMAF=1 \
    -DENABLE_DOCS=FALSE \
    -DENABLE_EXAMPLES=FALSE \
    -DENABLE_TESTS=FALSE \
    -DENABLE_TOOLS=FALSE \
    -G "Unix Makefiles" \
    .. > ../../config.log 2>&1

make -j $jobopt install > ../../make.log 2>&1
