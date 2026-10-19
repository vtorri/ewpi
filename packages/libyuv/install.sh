#! /bin/sh

. ../../common.sh

ewpi_cmake "Unix Makefiles" \
    -DBUILD_SHARED_LIBS=ON

# See include/libyuv/version.h for the version

cat >libyuv.pc <<EOF
prefix=$3
exec_prefix=\${prefix}
bindir=\${exec_prefix}/bin
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libyuv
Description: YUV conversion and scaling library
Version: 1917
Requires.private: libjpeg
Libs: -L\${libdir} -lyuv
Cflags: -I\${includedir}
EOF

cp libyuv.pc $3/lib/pkgconfig
