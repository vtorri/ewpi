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

sed -i -e 's/lame_init_old//g' include/libmp3lame.sym

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
export CFLAGS="-O2 -pipe -march=$1 -mtune=$1"
export LDFLAGS="-s"

./configure --prefix=$3 --host=$4 --disable-static --disable-frontend > ../config.log 2>&1

make -j $jobopt install > ../make.log 2>&1
