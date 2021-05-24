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

sed -i -e "s|@prefix@|$3|g;s|@host@|$4|g;s|@proc@|$proc|g" cross_toolchain.txt

rm -rf builddir && mkdir builddir && cd builddir

cmake \
    -DCMAKE_TOOLCHAIN_FILE=../cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_STATIC_LIBS:BOOL=OFF \
    -DBUILD_TESTS:BOOL=OFF \
    -G "Unix Makefiles" \
    .. > ../../config.log 2>&1

case ${EWPI_OS} in
    MSYS*|MINGW*)
    ;;
    *)
        sed -i -e "s|-I/usr/include|-I$3/include|g" src/CMakeFiles/mysofa-shared.dir/includes_C.rsp
        sed -i -e "s|/usr/lib/libz.a|-lz|g" src/CMakeFiles/mysofa-shared.dir/linklibs.rsp
    ;;
esac

make -j $jobopt install > ../../make.log 2>&1

cp src/libmysofa.dll.a $3/lib
