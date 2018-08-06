#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt2

cd packages/$1 > /dev/null
dir_name=`tar $5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
rm -rf build && \
mkdir build && \
cd build && \
cmake \
    -DCMAKE_SYSTEM_NAME=Generic \
    -DCMAKE_CROSSCOMPILING=1 \
    -DCMAKE_INSTALL_PREFIX=$3 \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DCMAKE_C_COMPILER=$4-gcc \
    -DCMAKE_CXX_COMPILER=$4-g++ \
    -DCMAKE_RC_COMPILER=$4-windres \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DINSTALL_LIBS:BOOL=ON \
    -DINSTALL_EXTRA_LIBS:BOOL=ON \
    -DBUILD_UNIT_TESTS:BOOL=OFF \
    -DBUILD_BULLET2_DEMOS:BOOL=OFF \
    -DBUILD_OPENGL3_DEMOS:BOOL=OFF \
    -DBUILD_EXTRAS:BOOL=OFF \
    -DUSE_GLUT:BOOL=OFF \
    -DBUILD_BULLET3:BOOL=OFF \
    -DBUILD_EXTRAS:BOOL=OFF \
    -LAH \
    -G "Unix Makefiles" \
    .. > ../config.log 2>&1

make -j install > ../make.log 2>&1
