#! /bin/sh

. ../../common.sh

sed -i '/^#/ ! s/\<iconv\.dll\>/libiconv.dll/g' Makefile

sed -i -- \
  "s,\(-DDEFAULT_LIBICONV_DLL\)=\(\\\$(DEFAULT_LIBICONV_DLL)\),\1=\'\"\2\"\'," \
  Makefile

sed -i \
  -e '/\$(CC) -shared/ s,$(CC),& $(LDFLAGS) ,' \
  -e '/ -o win_iconv.exe\>/ s,\$(CC),& $(LDFLAGS),' \
  Makefile

make -j $jobopt clean > ../make.log 2>&1
make -j $jobopt install prefix=$3 CC=$4-gcc AR=$4-ar RANLIB=$4-ranlib DLLTOOL=$4-dlltool >> ../make.log 2>&1

cat > iconv.pc <<EOF
prefix=$3
exec_prefix=\${prefix}
bindir=\${exec_prefix}/bin
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: iconv
Description: iconv implementation using Win32 API to convert
Version: 0.0.8
Libs: -L\${libdir} -liconv
Cflags: -DWINICONV_CONST= -I\${includedir}
EOF

mkdir -p $3/lib/pkgconfig
cp iconv.pc $3/lib/pkgconfig
