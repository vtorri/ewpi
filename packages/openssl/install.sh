#! /bin/sh

. ../../common.sh

if test "x$4" = "xx86_64-w64-mingw32" ; then
    toolchain="mingw64"
    toolchain_prefix="x86_64-w64-mingw32-"
else
    toolchain="mingw32"
    toolchain_prefix="i686-w64-mingw32-"
fi

/usr/bin/perl \
    Configure \
    $toolchain \
    --cross-compile-prefix=x86_64-w64-mingw32- \
    --prefix=$prefix_unix \
    --libdir=lib \
    --openssldir=$prefix_unix/etc/ssl \
    $verbninja \
    shared \
    zlib-dynamic \
    enable-camellia \
    enable-capieng \
    enable-idea \
    enable-mdc2 \
    enable-rc5  \
    enable-rfc3779 \
    no-apps \
    no-docs \
    > ../config.log 2>&1

make $verbmake install > ../make.log 2>&1
