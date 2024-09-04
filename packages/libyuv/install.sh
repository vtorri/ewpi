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

sed -i -e "s|target_link_libraries( yuvconvert \${JPEG_LIBRARY} )|target_link_libraries( \${ly_lib_shared} \${JPEG_LIBRARY} )|g;s|PROGRAMS \${CMAKE_BINARY_DIR}/yuvconvert|TARGETS yuvconvert|g" CMakeLists.txt

rm -rf builddir && mkdir builddir && cd builddir

cmake \
    -DCMAKE_TOOLCHAIN_FILE=../cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -G "Unix Makefiles" \
    .. > ../../config.log 2>&1

make -j $jobopt install > ../../make.log 2>&1

cat > libyuv.pc <<EOF
prefix=$3
exec_prefix=\${prefix}
bindir=\${exec_prefix}/bin
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libyuv
Description: YUV conversion and scaling library
Version: 1840
Requires.private: libjpeg
Libs: -L\${libdir} -lyuv
Cflags: -I\${includedir}
EOF

cp libyuv.dll.a $3/lib
cp libyuv.pc $3/lib/pkgconfig
