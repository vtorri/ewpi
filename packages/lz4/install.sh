#! /bin/sh

set -e

# $1 : arch
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt
# $6 : jobopt

dir_name=`tar t$5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name

export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=$3/lib/pkgconfig
export PKG_CONFIG_SYSROOOT_DIR=$3
export CPPFLAGS=-I$3/include
export CFLAGS="-O2 -pipe -march=$1 -mtune=$1"
export LDFLAGS="-L$3/lib -s"

sed -i \
    -e 's/MidnightBSD/MidnightBSD MINGW32_NT-6.1 MINGW64_NT-6.1/g' \
    -e 's|dll\\|dll/|g' \
    lib/Makefile
sed -i \
    -e 's|$@.dll|$@.dll -Wl,--out-implib,liblz4.dll.a|g' \
    -e 's|dlltool|#dlltool|g' \
    lib/Makefile

make -j $jobopt PREFIX=$3 BUILD_STATIC=no CC=$4-gcc SHARED_EXT_VER=1 V=1 OS=Windows_NT > ../make.log 2>&1

mkdir -p $3/{bin,include,lib/pkgconfig}
cp lz4.exe $3/bin
cd lib
cp dll/liblz4.1.dll $3/bin/liblz4-1.dll
cp liblz4.dll.a $3/lib
cp lz4.h lz4hc.h lz4frame.h $3/include
make liblz4.pc PREFIX=$3 BUILD_STATIC=no CC=$4-gcc SHARED_EXT_VER=1 V=1 OS=Windows_NT >> ../make.log 2>&1
cp liblz4.pc $3/lib/pkgconfig
cd ..
