#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt2

cd packages/$1 > /dev/null
dir_name=`tar $5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
if test "x$host" = "xi686-w64-mingw32" ; then
    arch=X86
else
    arch=AMD64
fi
ar_exe=`where ar.exe`
rm -rf build && \
mkdir build && \
cd build && \
cmake \
    -DCMAKE_INSTALL_PREFIX=$3 \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DCMAKE_SYSTEM_NAME=Windows \
    -DCMAKE_C_COMPILER=$4-gcc \
    -DCMAKE_RC_COMPILER=$4-windres \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_AR=$ar_exe \
    -DENABLE_STATIC:BOOL=OFF \
    -DWITH_TURBOJPEG:BOOL=OFF \
    -G "MSYS Makefiles" \
    .. > ../config.log 2>&1
make -j install > ../make.log 2>&1
