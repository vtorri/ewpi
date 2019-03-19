#! /bin/sh

set -e

unset PKG_CONFIG_PATH

# $1 : arch
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt
# $6 : jobopt

dir_name=`tar t$5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name

export CFLAGS="-O2 -pipe -march=$1 -mtune=$1"
export LDFLAGS="-s"

make -f win32/Makefile.gcc clean prefix=$3 PREFIX=$4- STATICLIB= SHARED_MODE=1 SHAREDLIB=zlib-1.dll BINARY_PATH=$3/bin LIBRARY_PATH=$3/lib INCLUDE_PATH=$3/include > ../make.log 2>&1
make -f win32/Makefile.gcc install prefix=$3 PREFIX=$4- STATICLIB= SHARED_MODE=1 SHAREDLIB=zlib-1.dll BINARY_PATH=$3/bin LIBRARY_PATH=$3/lib INCLUDE_PATH=$3/include >> ../make.log 2>&1
