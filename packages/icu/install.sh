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
cd $dir_name/source

export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=$3/lib/pkgconfig
export PKG_CONFIG_SYSROOOT_DIR=$3
export CPPFLAGS=-I$3/include
export LDFLAGS=-L$3/lib

./runConfigureICU MinGW --prefix=$3 --host=$4 --enable-tools --disable-tests --disable-samples > ../../config.log 2>&1

make -j $jobopt > ../../make.log 2>&1
make -j $jobopt install >> ../../make.log 2>&1

mv $3/lib/*.dll $3/bin
sed -i -e \
    's/Libs: -licuin64/Libs: -L${libdir} -licuin/g' \
    $3/lib/pkgconfig/icu-i18n.pc
sed -i -e \
    's/Libs: -licuio64/Libs: -L${libdir} -licuio/g' \
    $3/lib/pkgconfig/icu-io.pc
sed -i -e \
    's/-licuuc64 -licudt64/-licuuc -licudt/g' \
    $3/lib/pkgconfig/icu-uc.pc
