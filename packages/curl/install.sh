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

sed -i -e "s|@host@|$4|g;s|@proc@|$proc|g" cross_toolchain.txt

rm -rf builddir && mkdir builddir && cd builddir

cmake \
    -DCMAKE_TOOLCHAIN_FILE=../cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-O2 -pipe $machine -march=$1 -D__USE_MINGW_ANSI_STDIO=0" \
    -DCMAKE_EXE_LINKER_FLAGS="-s" \
    -DCMAKE_SHARED_LINKER_FLAGS="-s $machine" \
    -DBUILD_CURL_EXE=OFF \
    -DENABLE_INET_PTON=OFF \
    -DCURL_TARGET_WINDOWS_VERSION=0x0601 \
    -DUSE_NGHTTP2=ON \
    -DCURL_ZSTD=ON \
    -DCURL_BROTLI=ON \
    -DCMAKE_USE_SCHANNEL=ON \
    -G Ninja \
    .. > ../../config.log 2>&1


case ${EWPI_OS} in
    MSYS*|MINGW*)
    ;;
    *)
	sed -i -e "s|-I /usr/include||g" build.ninja
	sed -i -e "s|-I/usr/include||g" build.ninja
	sed -i -e "s|-isystem /usr/include||g" build.ninja
    ;;
esac

ninja -j $jobopt install > ../../make.log 2>&1
