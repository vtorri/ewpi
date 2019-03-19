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
    -DCMAKE_SYSTEM_NAME=Windows \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DCMAKE_C_COMPILER=$4-gcc \
    -DCMAKE_CXX_COMPILER=$4-g++ \
    -DCMAKE_RC_COMPILER=$4-windres \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DCMAKE_C_FLAGS="-O2 -pipe -march=$1 -mtune=$1" \
    -DCMAKE_CXX_FLAGS="$TAG_CPP_FLAGS -O2 -pipe -march=$1 -mtune=$1" \
    -DCMAKE_EXE_LINKER_FLAGS="-s" \
    -DCMAKE_SHARED_LINKER_FLAGS="-s" \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DBUILD_BINDINGS:BOOL=OFF \
    -DZLIB_INCLUDE_DIR=$prefix_unix/include \
    -DZLIB_LIBRARY=z \
    -G "Unix Makefiles" \
    . > ../config.log 2>&1

make -j $jobopt install > ../make.log 2>&1
