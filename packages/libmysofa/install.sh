#! /bin/sh

. ../../common.sh

cp ../cross_toolchain.txt .

if test "x$4" = "xx86_64-w64-mingw32" ; then
    proc="AMD64"
    machine=-m64
else
    proc="X86"
    machine=-m32
fi

sed -i -e "s|@host@|$4|g;s|@proc@|$proc|g" cross_toolchain.txt

export CFLAGS="$machine -I$EWPI_PWD/src -I.. $CFLAGS"
export CXXFLAGS="$machine -I$EWPI_PWD/src -I.. $CXXFLAGS"
export LDFLAGS="$machine $LDFLAGS"

sed -i -e "s|add_library(mysofa-static|#add_library(mysofa-static|g" src/CMakeLists.txt
sed -i -e "s|target_link_libraries (mysofa-static|#target_link_libraries (mysofa-static|g" src/CMakeLists.txt
sed -i -e "s|SET_TARGET_PROPERTIES(mysofa-static|#SET_TARGET_PROPERTIES(mysofa-static|g" src/CMakeLists.txt
sed -i -e "s|install(TARGETS mysofa-static|#install(TARGETS mysofa-static|g" src/CMakeLists.txt
sed -i -e "s|  ARCHIVE DESTINATION|#  ARCHIVE DESTINATION|g" src/CMakeLists.txt

cmake \
    -DCMAKE_TOOLCHAIN_FILE=cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-I$EWPI_PWD/src -I.. -O2 -pipe -march=$1" \
    -DCMAKE_CXX_FLAGS="-I$EWPI_PWD/src -I.. -O2 -pipe -march=$1" \
    -DCMAKE_EXE_LINKER_FLAGS="-s" \
    -DCMAKE_SHARED_LINKER_FLAGS="-L$3/lib -s" \
    -DBUILD_TESTS:BOOL=OFF \
    -G "Unix Makefiles" \
    . > ../config.log 2>&1

sed -i -e "s|$prefix_unix/lib/libz.dll.a|-lz|g" src/CMakeFiles/mysofa-shared.dir/linklibs.rsp

make -j $jobopt install > ../make.log 2>&1

sed -i -e "s|$prefix_unix|$3|g" $3/lib/pkgconfig/libmysofa.pc

cp src/libmysofa.dll.a $3/lib
