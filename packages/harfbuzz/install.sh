#! /bin/sh

. ../../common.sh

cp ../cross_toolchain.txt .

if test "x$4" = "xi686-w64-mingw32" ; then
    sed -i -e 's/@cpu_family@/x86/g;s/@cpu@/i686/g' cross_toolchain.txt
else
    sed -i -e 's/@cpu_family@/x86_64/g;s/@cpu@/x86_64/g' cross_toolchain.txt
fi

sed -i -e "s/@host@/$4/g;s/@arch@/$1/g;s|@prefix@|$3|g" cross_toolchain.txt

sed -i -e 's/SUBDIRS = src util test docs/SUBDIRS = src util docs/g' Makefile.in

rm -rf builddir && mkdir builddir && cd builddir
meson .. \
      --prefix=$3 \
      --libdir=lib \
      --buildtype=release \
      --strip \
      --cross-file ../cross_toolchain.txt \
      --default-library shared \
      -Dfreetype=enabled \
      -Dgdi=enabled \
      -Dgraphite=enabled \
      -Dicu=enabled \
      -Dcairo=disabled \
      -Dfontconfig=disabled \
      -Dtests=disabled \
      -Dglib=disabled  \
      -Dgobject=disabled > ../../config.log 2>&1

ninja $verbninja install > ../../make.log 2>&1

