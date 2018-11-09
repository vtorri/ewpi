#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt

cd packages/$1 > /dev/null
dir_name=`tar t$5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=$3/lib/pkgconfig
export PKG_CONFIG_SYSROOOT_DIR=$3
export CPPFLAGS=-I$3/include
export LDFLAGS=-L$3/lib
sed -i -e 's/MidnightBSD/MidnightBSD MINGW32_NT-6.1 MINGW64_NT-6.1/g' lib/Makefile
make PREFIX=$3 BUILD_STATIC=no CC=$4-gcc SHARED_EXT_VER=1 V=1 > ../make.log 2>&1
mkdir -p $3/{bin,include,lib/pkgconfig}
cp lz4.exe $3/bin
cd lib
cp dll/liblz4.1.dll $3/bin/liblz4-1.dll
dlltool -D $3/bin/liblz4-1.dll -d dll/liblz4.def -l $3/lib/liblz4.dll.a >> ../make.log 2>&1
cp lz4.h lz4hc.h lz4frame.h $3/include
make liblz4.pc PREFIX=$3 BUILD_STATIC=no CC=$4-gcc SHARED_EXT_VER=1 V=1 >> ../make.log 2>&1
cp liblz4.pc $3/lib/pkgconfig
cd ..

sed -i -e 's/installed: no/installed: yes/g' ../$1.ewpi
