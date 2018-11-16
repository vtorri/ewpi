#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt
# $6 : jobopt

cd packages/$1 > /dev/null
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
cmake \
    -DCMAKE_SYSTEM_NAME=Windows \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DCMAKE_C_COMPILER=$4-gcc \
    -DCMAKE_CXX_COMPILER=$4-g++ \
    -DCMAKE_RC_COMPILER=$4-windres \
    -DCMAKE_BUILD_TYPE=Release \
    -DTARGET_SUPPORTS_SHARED_LIBS=TRUE \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DCMAKE_CXX_FLAGS=-isystem\ $EWPI_PWD/src \
    -DINSTALL_LIBS:BOOL=ON \
    -DINSTALL_EXTRA_LIBS:BOOL=ON \
    -DBUILD_UNIT_TESTS:BOOL=OFF \
    -DBUILD_BULLET2_DEMOS:BOOL=OFF \
    -DBUILD_OPENGL3_DEMOS:BOOL=OFF \
    -DBUILD_EXTRAS:BOOL=OFF \
    -DUSE_GLUT:BOOL=OFF \
    -DBUILD_BULLET3:BOOL=ON \
    -DBUILD_PYBULLET:BOOL=OFF \
    -DBUILD_EXTRAS:BOOL=OFF \
    -LAH \
    -G "Unix Makefiles" \
    . > config.log 2>&1

make -j $jobopt install > make.log 2>&1

sed -i -e 's/installed: no/installed: yes/g' ../$1.ewpi
