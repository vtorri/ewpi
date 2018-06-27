#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt2

cd packages/$1 > /dev/null
dir_name=`tar $5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
autoreconf -vif  > ../config.log 2>&1 &&
./configure --prefix=$3 --host=$4 --disable-static --with-zlib-include-dir=$3/include --with-zlib-lib-dir=$3/lib --with-jpeg-include-dir=$3/include --with-jpeg-lib-dir=$3/lib --with-lzma-include-dir=$3/include --with-lzma-lib-dir=$3/lib >> ../config.log 2>&1
make V=0 -j install > ../make.log 2>&1
