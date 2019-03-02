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

if test "x$4" = "xx86_64-w64-mingw32" ; then
sed -i -e 's/$ac_cv_sizeof_long)/8)/g' configure
sed -i -e 's/visual_size_type=long/visual_size_type=__int64/g' configure
sed -i -e 's/\"lu\"/\"I64u\"/g' configure
fi

EWPI_OS=`uname`
case ${EWPI_OS} in
    MSYS*|MINGW*)
        # for pkg-config
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
export CPPFLAGS=-I$3/include
export CFLAGS="-O2 -pipe -march=$1 -mtune=$1"
export LDFLAGS="-L$3/lib -s"

./configure --prefix=$3 --host=$4 --disable-static  > ../config.log 2>&1

if test "x$4" = "xx86_64-w64-mingw32" ; then
sed -i -e 's/__int64/long long/g' libvisual/lvconfig.h
sed -i -e 's/VISUAL_SIZE_T_FORMAT/VISUAL_SIZE_T_FORMAT "I64u"/g' libvisual/lvconfig.h
sed -i -e 's/Eip/Rip/g' libvisual/lv_cpu.c
fi

make -j $jobopt install > ../make.log 2>&1
