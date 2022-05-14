#! /bin/sh

. ../../common.sh

cp ../cross_toolchain.txt .

sed -i '/typedef SSIZE_T ssize_t;/ d' src/lib/openjpip/sock_manager.c

if test "x$4" = "xx86_64-w64-mingw32" ; then
    proc="AMD64"
    machine=-m64
else
    proc="X86"
    machine=-m32
fi

sed -i -e "s|@prefix@|$3|g;s|@host@|$4|g;s|@proc@|$proc|g;s|@winver@|$winver|g" cross_toolchain.txt

case ${EWPI_OS} in
    MSYS*|MINGW*)
	codec="ON"
    ;;
    *)
	codec="OFF"
    ;;
esac

rm -rf builddir && mkdir builddir && cd builddir

cmake \
    -DCMAKE_TOOLCHAIN_FILE=../cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_STATIC_LIBS=OFF \
    -DBUILD_CODEC:BOOL=$codec \
    -DBUILD_JPIP:BOOL=OFF \
    -DBUILD_PKGCONFIG_FILES:BOOL=ON \
    -G "Unix Makefiles" \
    .. > ../../config.log 2>&1

make -j $jobopt install > ../../make.log 2>&1
