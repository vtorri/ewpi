#! /bin/sh

. ../../common.sh

git fetch && git fetch --tags
git checkout da9e4adc619ee3d1ae5e68da3ed14aa5e60b3ec1

cp ../cross_toolchain.txt .

if test "x$4" = "xx86_64-w64-mingw32" ; then
    proc="AMD64"
    machine=-m64
else
    proc="X86"
    machine=-m32
fi

sed -i -e "s|@prefix@|$3|g;s|@host@|$4|g;s|@proc@|$proc|g;s|@winver@|$winver|g" cross_toolchain.txt
sed -i -e "s|PROPERTIES ARCHIVE_OUTPUT_NAME mysofa_shared)|PROPERTIES ARCHIVE_OUTPUT_NAME mysofa)|g" src/CMakeLists.txt

rm -rf builddir && mkdir builddir && cd builddir

cmake \
    -DCMAKE_TOOLCHAIN_FILE=../cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_STATIC_LIBS=OFF \
    -DBUILD_TESTS=OFF \
    -G "Ninja" \
    .. > ../../config.log 2>&1

cd ..
ninja $verbninja -C builddir install > ../make.log 2>&1
