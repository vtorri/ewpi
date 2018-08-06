#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt2

cd packages/$1 > /dev/null
dir_name=`tar $5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
export PKG_CONFIG_LIBDIR=$3/lib/pkgconfig
export PKG_CONFIG_PATH=$3/lib/pkgconfig
./configure --prefix=$3 --host=$4 --disable-static --with-libiconv-prefix=$3 --disable-cpplibs > ../config.log 2>&1
make -j install > ../make.log 2>&1