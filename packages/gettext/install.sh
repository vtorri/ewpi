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

sed -i -e 's/gettext-runtime gettext-tools/gettext-runtime/g' configure
sed -i -e 's/SUBDIRS = gnulib-local gettext-runtime gettext-tools/SUBDIRS = gnulib-local gettext-runtime/g' Makefile.in

export CFLAGS="-O2 -pipe -march=$1 -mtune=$1"
export CXXFLAGS="-O2 -pipe -march=$1 -mtune=$1"
export LDFLAGS="-s"

./configure --prefix=$3 --host=$4 --disable-static --disable-c++ --disable-java--disable-native-java --enable-threads=windows --disable-rpath --disable-libasprintf --disable-curses --disable-acl --with-libiconv-prefix=$3 --with-libunistring-prefix=$3 > ../config.log 2>&1

make -j $jobopt install > ../make.log 2>&1
