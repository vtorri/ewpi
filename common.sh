
# $1 : arch
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : jobopt
# $6 : verbose

set -e

unset PKG_CONFIG_PATH

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
export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=$3/lib/pkgconfig
export PKG_CONFIG_SYSROOOT_DIR=$3
export CPPFLAGS=-I$3/include
export CFLAGS="-O2 -pipe -march=$1"
export CXXFLAGS="-O2 -pipe -march=$1"
export LDFLAGS="-L$3/lib -s"

case $2 in
    *.git)
        bn=`basename $2`
        dir_name=${bn%.*}
        ;;
    *.xz)
        dir_name=`tar tJf $2 | head -1 | cut -f1 -d"/"`
        ;;
    *.bz2)
        dir_name=`tar tjf $2 | head -1 | cut -f1 -d"/"`
        ;;
    *.gz|*.tgz)
        dir_name=`tar tzf $2 | head -1 | cut -f1 -d"/"`
        ;;
esac

cd $dir_name

EWPI_PWD=`pwd`
