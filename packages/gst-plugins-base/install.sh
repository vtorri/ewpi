#! /bin/sh

set -e

# $1 : arch
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

EWPI_OS=`uname`
case ${EWPI_OS} in
    MSYS*|MINGW*)
	prefix_unix=`cygpath -u $3`
    ;;
    *)
	prefix_unix=$3
    ;;
esac
export PATH=$prefix_unix/bin:$PATH
export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=$3/lib/pkgconfig
export PKG_CONFIG_SYSROOOT_DIR=$3
export CFLAGS="-I$3/include -O2 -pipe -march=$1 -mtune=$1"
export CXXFLAGS="-I$3/include -O2 -pipe -march=$1 -mtune=$1"
export LDFLAGS="-L$3/lib -s"

rm -rf builddir && mkdir builddir && cd builddir
meson .. \
      --prefix=$3 \
      --libdir=lib \
      --strip \
      --cross-file ../cross_toolchain.txt \
      --default-library shared > ../../config.log 2>&1

ninja install > ../../make.log 2>&1
