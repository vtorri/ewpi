#! /bin/sh

. ../../common.sh

ewpi_cmake "Ninja" \
    -DWIN_ICONV_BUILD_STATIC=OFF \
    -DWIN_ICONV_BUILD_EXECUTABLE=OFF

cat >iconv.pc <<EOF
prefix=$3
exec_prefix=\${prefix}
bindir=\${exec_prefix}/bin
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: iconv
Description: iconv implementation using Win32 API to convert
Version: 0.0.9
Libs: -L\${libdir} -liconv
Cflags: -DWINICONV_CONST= -I\${includedir}
EOF

mkdir -p $3/lib/pkgconfig
cp iconv.pc $3/lib/pkgconfig
