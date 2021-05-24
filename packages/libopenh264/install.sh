#! /bin/sh

. ../../common.sh

cp ../cross_toolchain.txt .

if test "x$4" = "xi686-w64-mingw32" ; then
    sed -i -e 's/@cpu_family@/x86/g;s/@cpu@/i686/g' cross_toolchain.txt
else
    sed -i -e 's/@cpu_family@/x86_64/g;s/@cpu@/x86_64/g' cross_toolchain.txt
fi

sed -i -e "s/@host@/$4/g;s/@arch@/$1/g;s|@prefix@|$3|g" cross_toolchain.txt

export CPPFLAGS="-D_WIN32_WINNT=0x0601 -D__USE_MINGW_ANSI_STDIO $CPPFLAGS"
export CXXFLAGS="-D_WIN32_WINNT=0x0601 -D__USE_MINGW_ANSI_STDIO $CXXFLAGS"
export CFLAGS="-D_WIN32_WINNT=0x0601 -D__USE_MINGW_ANSI_STDIO $CFLAGS"

rm -rf builddir && mkdir builddir && cd builddir
meson .. \
      --prefix=$3 \
      --libdir=lib \
      --buildtype=release \
      --strip \
      --cross-file ../cross_toolchain.txt \
      --default-library shared \
      -Dtests=false \
      > ../../config.log 2>&1

ninja $verbninja install > ../../make.log 2>&1
