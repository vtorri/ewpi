#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt2

cd packages/$1 > /dev/null
dir_name=`tar $5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
export PATH=$3/bin:$PATH
export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=$3/lib/pkgconfig
export PKG_CONFIG_SYSROOOT_DIR=$3
export CPPFLAGS=-I$3/include
export LDFLAGS=-L$3/lib
./configure --prefix=$3 --host=$4 --disable-static --enable-iconv --with-libiconv=$3 --with-libiconv-includes=$3/include --with-libiconv-lib=$3/lib --with-expat-includes=$3/include --with-expat-lib=$3/lib --disable-docs > ../config.log 2>&1
make -j install > ../make.log 2>&1
