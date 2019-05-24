#! /bin/sh

source ../../common.sh

cp ../cross_toolchain.txt .

sed -i '/typedef SSIZE_T ssize_t;/ d' src/lib/openjpip/sock_manager.c

if test "x$4" = "xx86_64-w64-mingw32" ; then
    proc="AMD64"
    machine=-m64
else
    proc="X86"
    machine=-m32
fi

sed -i -e "s|@host@|$4|g;s|@proc@|$proc|g" cross_toolchain.txt

case ${EWPI_OS} in
    MSYS*|MINGW*)
	codec="ON"
    ;;
    *)
	codec="OFF"
    ;;
esac

export CFLAGS="$machine $CFLAGS"
export CXXFLAGS="$machine $CXXFLAGS"
export LDFLAGS="$machine $LDFLAGS"

cmake \
    -DCMAKE_TOOLCHAIN_FILE=cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_STATIC_LIBS:BOOL=OFF \
    -DCMAKE_C_FLAGS="-O2 -pipe -march=$1 -I../common -I../../../src/lib/openjp2 -I$3/include" \
    -DCMAKE_CXX_FLAGS="-O2 -pipe -march=$1" \
    -DCMAKE_EXE_LINKER_FLAGS="-s -L$prefix_unix/lib" \
    -DCMAKE_SHARED_LINKER_FLAGS="-s" \
    -DBUILD_CODEC:BOOL=$codec \
    -DBUILD_JPWL:BOOL=OFF \
    -DBUILD_MJ2:BOOL=OFF \
    -DBUILD_JPIP:BOOL=OFF \
    -DBUILD_JP3D:BOOL=OFF \
    -DBUILD_PKGCONFIG_FILES:BOOL=ON \
    -G "Unix Makefiles" \
    . > ../config.log 2>&1

case ${EWPI_OS} in
    MSYS*|MINGW*)
        sed -i -e "s|$prefix_unix|$3|g" src/bin/jp2/CMakeFiles/opj_compress.dir/linklibs.rsp
        sed -i -e "s|$prefix_unix|$3|g" src/bin/jp2/CMakeFiles/opj_decompress.dir/linklibs.rsp
        sed -i -e "s|$prefix_unix|$3|g" src/bin/jp2/CMakeFiles/opj_dump.dir/linklibs.rsp
    ;;
    *)
    ;;
esac

make -j $5 install > ../make.log 2>&1

sed -i -e "s|$prefix_unix|$3|g" $3/lib/pkgconfig/libopenjp2.pc
