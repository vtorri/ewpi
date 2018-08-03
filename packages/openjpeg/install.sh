#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt2

cd packages/$1 > /dev/null
dir_name=`tar $5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
export PKG_CONFIG_LIBDIR=$3/lib/pkgconfig
export PKG_CONFIG_PATH=$3/lib/pkgconfig
ar_exe=`where ar.exe`
rm -rf build && \
mkdir build && \
cd build && \
cmake \
    -DCMAKE_INSTALL_PREFIX=$3 \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DCMAKE_C_COMPILER=$4-gcc \
    -DCMAKE_CXX_COMPILER=$4-g++ \
    -DCMAKE_RC_COMPILER=$4-windres \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_AR=$ar_exe \
    -DBUILD_CODEC:BOOL=OFF \
    -DBUILD_JPWL:BOOL=OFF \
    -DBUILD_MJ2:BOOL=OFF \
    -DBUILD_JPIP:BOOL=OFF \
    -DBUILD_JP3D:BOOL=OFF \
    -DBUILD_PKGCONFIG_FILES:BOOL=ON \
    -DCMAKE_SYSTEM_NAME=Windows \
    -G "MSYS Makefiles" \
    .. > ../config.log 2>&1

make -j install > ../make.log 2>&1

