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

export CPPFLAGS="-D_WIN32_WINNT=0x0600"
export CFLAGS="-O2 -pipe -march=$1 -mtune=$1"
export LDFLAGS="-s"

./configure --prefix=$3 --host=$4 --disable-static  > ../config.log 2>&1

make V=0 -j $jobopt install > ../make.log 2>&1
