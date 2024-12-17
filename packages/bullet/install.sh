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
    -DUSE_GRAPHICAL_BENCHMARK=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_CPU_DEMOS=OFF \
    -DUSE_GLUT=OFF \
    -DBUILD_UNIT_TESTS=OFF \
    -DBUILD_BULLET2_DEMOS=OFF \
    -DINSTALL_CMAKE_FILES=OFF \
    -DBUILD_OPENGL3_DEMOS=OFF \
    -DBUILD_EXTRAS=OFF \
    -DINSTALL_LIBS=ON \
    -G "Ninja" \
    .. > ../../config.log 2>&1

ninja $verbninja > ../../make.log 2>&1
ninja $verbninja install >> ../../make.log 2>&1
