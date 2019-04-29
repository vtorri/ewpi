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
cp ../cross_toolchain.txt .

EWPI_PWD=`pwd`
EWPI_OS=`uname`
case ${EWPI_OS} in
    MSYS*|MINGW*)
	prefix_unix=`cygpath -u $3`
    ;;
    *)
	prefix_unix=$3
    ;;
esac

if test "x$4" = "xx86_64-w64-mingw32" ; then
    proc="AMD64"
    machine=-m64
else
    proc="X86"
    machine=-m32
fi

sed -i -e "s|@host@|$4|g;s|@proc@|$proc|g" cross_toolchain.txt

export PATH=$prefix_unix/bin:$PATH
export CFLAGS="$machine -I$EWPI_PWD -O2 -pipe -march=$1"
export CXXFLAGS="$machine -I$EWPI_PWD -O2 -pipe -march=$1"
export LDFLAGS="$machine -s"

TAG_CPP_FLAGS="-I$EWPI_PWD \
             -I$EWPI_PWD/taglib \
             -I$EWPI_PWD/taglib/ape \
             -I$EWPI_PWD/taglib/asf \
             -I$EWPI_PWD/taglib/flac \
             -I$EWPI_PWD/taglib/it \
             -I$EWPI_PWD/taglib/mp4 \
             -I$EWPI_PWD/taglib/mod \
             -I$EWPI_PWD/taglib/mpc \
             -I$EWPI_PWD/taglib/mpeg \
             -I$EWPI_PWD/taglib/mpeg/id3v1 \
             -I$EWPI_PWD/taglib/mpeg/id3v2 \
             -I$EWPI_PWD/taglib/mpeg/id3v2/frames \
             -I$EWPI_PWD/taglib/ogg \
             -I$EWPI_PWD/taglib/ogg/flac \
             -I$EWPI_PWD/taglib/ogg/opus \
             -I$EWPI_PWD/taglib/ogg/speex \
             -I$EWPI_PWD/taglib/ogg/vorbis \
             -I$EWPI_PWD/taglib/riff \
             -I$EWPI_PWD/taglib/riff/aiff \
             -I$EWPI_PWD/taglib/riff/wav \
             -I$EWPI_PWD/taglib/s3m \
             -I$EWPI_PWD/taglib/toolkit \
             -I$EWPI_PWD/taglib/trueaudio \
             -I$EWPI_PWD/taglib/wavpack \
             -I$EWPI_PWD/taglib/xm"

cmake \
    -DCMAKE_TOOLCHAIN_FILE=cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DCMAKE_C_FLAGS="-O2 -pipe -march=$1 -I$3/include" \
    -DCMAKE_CXX_FLAGS="$TAG_CPP_FLAGS -O2 -pipe -march=$1 -I$3/include" \
    -DCMAKE_EXE_LINKER_FLAGS="-s -L$3/lib" \
    -DCMAKE_SHARED_LINKER_FLAGS="-s -L$3/lib" \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DBUILD_BINDINGS:BOOL=OFF \
    -DZLIB_INCLUDE_DIR=$prefix_unix/include \
    -DZLIB_LIBRARY=z \
    -G "Unix Makefiles" \
    . > ../config.log 2>&1

make -j $jobopt install > ../make.log 2>&1

sed -i -e "s|$prefix_unix|$3|g" $3/lib/pkgconfig/taglib.pc
