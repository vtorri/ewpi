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
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_STATIC_LIBS=OFF \
    -DBUILD_CURL_EXE=OFF \
    -DBUILD_STATIC_CURL=OFF \
    -DBUILD_LIBCURL_DOCS=OFF \
    -DBUILD_MISC_DOCS=OFF \
    -DENABLE_CURL_MANUAL=OFF \
    -DENABLE_THREADED_RESOLVER=ON \
    -DCURL_USE_PKGCONFIG=ON \
    -DUSE_NGHTTP2=ON \
    -DUSE_LIBIDN2=OFF \
    -DUSE_WIN32_IDN=ON \
    -DCURL_BROTLI=ON \
    -DCURL_ZSTD=ON \
    -DCURL_USE_SCHANNEL=ON \
    -DCURL_USE_LIBSSH2=ON \
    -DCURL_TARGET_WINDOWS_VERSION=$winver \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTING=OFF \
    -G "Ninja" \
    .. > ../../config.log 2>&1

ninja $verbninja install > ../../make.log 2>&1
