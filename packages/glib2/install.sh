#! /bin/sh

set -e

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt
# $6 : jobopt

dir_name=`tar t$5 $2 | head -1 | cut -f1 -d"/"`
if test "x$4" = "xi686-w64-mingw32" ; then
    sed 's/@host@/i686-w64-mingw32/g;s/@cpu_family@/x86/g;s/@cpu@/i686/g' cross_toolchain.txt > $dir_name/cross_toolchain.txt
else
    sed 's/@host@/x86_64-w64-mingw32/g;s/@cpu_family@/x86_64/g;s/@cpu@/x86_64/g' cross_toolchain.txt > $dir_name/cross_toolchain.txt
fi
cd $dir_name
export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=$3/lib/pkgconfig
export PKG_CONFIG_SYSROOOT_DIR=$3
export CPPFLAGS=-I$3/include
export LDFLAGS=-L$3/lib

rm -rf builddir && mkdir builddir && cd builddir
meson .. \
      --prefix=$3 \
      --libdir=lib \
      --strip \
      --cross-file ../cross_toolchain.txt \
      --default-library shared \
      -Dinternal_pcre=true > ../../config.log 2>&1

ninja install > ../../make.log 2>&1
