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

sed -i -e "s|@prefix@|$3|g;s|@host@|$4|g;s|@proc@|$proc|g;s|@winver@|$winver|g" cross_toolchain.txt

sed -i -e "s|if(BUILD_TESTING)|set(BUILD_TESTING FALSE)\nif(BUILD_TESTING)|g" CMakeLists.txt

sed -i -e "s|curl|/usr/bin/curl|g" ./deps.sh

./deps.sh

rm -rf builddir && mkdir builddir && cd builddir

cmake \
    -DCMAKE_TOOLCHAIN_FILE=../cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_STATIC=FALSE \
    -DBUILD_TESTING:BOOL=FALSE \
    -DJPEGXL_ENABLE_BENCHMARK:BOOL=FALSE \
    -DJPEGXL_ENABLE_COVERAGE:BOOL=FALSE \
    -DJPEGXL_ENABLE_EXAMPLES:BOOL=FALSE \
    -DJPEGXL_ENABLE_FUZZERS:BOOL=FALSE \
    -DJPEGXL_ENABLE_JNI:BOOL=FALSE \
    -DJPEGXL_ENABLE_MANPAGES:BOOL=FALSE \
    -DJPEGXL_ENABLE_PLUGINS:BOOL=FALSE \
    -DJPEGXL_ENABLE_PROFILER:BOOL=FALSE \
    -DJPEGXL_ENABLE_TOOLS:BOOL=FALSE \
    -DJPEGXL_ENABLE_VIEWERS:BOOL=TRUE \
    -DJPEGXL_FORCE_SYSTEM_BROTLI:BOOL=TRUE \
    -DJPEGXL_FORCE_SYSTEM_HWY:BOOL=TRUE \
    -DJPEGXL_FORCE_SYSTEM_LCMS2:BOOL=TRUE \
    -G "Unix Makefiles" \
    .. >> ../../config.log 2>&1

make -j $jobopt install > ../../make.log 2>&1
