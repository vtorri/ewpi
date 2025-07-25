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
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_TOOLCHAIN_FILE=../cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_PROGRAMS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTING=OFF \
    -DENABLE_CPACK=OFF \
    -DENABLE_STATIC_RUNTIME=OFF \
    -DENABLE_COMPATIBLE_LIBSNDFILE_NAME=ON \
    -G "Unix Makefiles" \
    .. > ../../config.log 2>&1

make -j $jobopt $verbmake install > ../../make.log 2>&1

