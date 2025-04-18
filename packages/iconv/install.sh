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

rm -rf builddir && mkdir builddir && cd builddir

cmake \
    -DCMAKE_TOOLCHAIN_FILE=../cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DWIN_ICONV_BUILD_STATIC=OFF \
    -DWIN_ICONV_BUILD_EXECUTABLE=OFF \
    -G "Ninja" \
    .. > ../../config.log 2>&1

ninja $verbninja install > ../../make.log 2>&1

cd ..

cat > iconv.pc <<EOF
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
