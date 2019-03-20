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
cd $dir_name/gettext-runtime

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
export CFLAGS="-O2 -pipe -march=$1"
export CXXFLAGS="-O2 -pipe -march=$1"
export LDFLAGS="-s"

./configure --prefix=$3 --host=$4 --disable-static --disable-c++ --disable-java --disable-native-java --enable-threads=windows --disable-rpath --disable-libasprintf --disable-curses --disable-acl --with-libiconv-prefix=$3 --with-libunistring-prefix=$3 > ../../config.log 2>&1

make -j $jobopt install > ../../make.log 2>&1
