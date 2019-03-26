#! /bin/sh

set -e

unset PKG_CONFIG_PATH

# $1 : arch
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt
# $6 : jobopt

dir_name=`tar t$5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name

sed -i '/^#/ ! s/\<iconv\.dll\>/libiconv.dll/g' Makefile

sed -i -- \
  "s,\(-DDEFAULT_LIBICONV_DLL\)=\(\\\$(DEFAULT_LIBICONV_DLL)\),\1=\'\"\2\"\'," \
  Makefile

sed -i \
  -e '/\$(CC) -shared/ s,$(CC),& $(LDFLAGS) ,' \
  -e '/ -o win_iconv.exe\>/ s,\$(CC),& $(LDFLAGS),' \
  Makefile

export CFLAGS="-O2 -pipe -march=$1"
export LDFLAGS="-s"

make clean > ../make.log 2>&1
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
Cflags: -DWINICONV_CONST -I\${includedir}
EOF

mkdir -p $3/lib/pkgconfig
cp iconv.pc $3/lib/pkgconfig
