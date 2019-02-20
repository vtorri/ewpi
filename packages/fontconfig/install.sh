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
sed -i -e 's/@INTLLIBS@/@LTLIBINTL@/g' src/Makefile.in

EWPI_PWD=`pwd`
EWPI_OS=`uname`
case ${EWPI_OS} in
    MSYS*|MINGW*)
        # for dependency DLL
	prefix_unix=`cygpath -u $3`
	export PATH=$prefix_unix/bin:$PATH
        # for fontconfig DLL
	export PATH=${EWPI_PWD}/src/.libs:$PATH
    ;;
esac
export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=$3/lib/pkgconfig
export PKG_CONFIG_SYSROOOT_DIR=$3
export CPPFLAGS=-I$3/include
export CFLAGS="-O2 -pipe -march=$1 -mtune=$1"
export LDFLAGS="-L$3/lib -s"

./configure --prefix=$3 --host=$4 --disable-static --enable-iconv --with-libiconv=$3 --with-expat=$3 --disable-docs > ../config.log 2>&1

make -j $jobopt install > ../make.log 2>&1
