#! /bin/sh

set -e

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

export CFLAGS="-O2 -pipe -march=$1 -mtune=$1"
export LDFLAGS="-s"

make clean > ../make.log 2>&1
make -j $jobopt install prefix=$3 CC=$4-gcc AR=$4-ar RANLIB=$4-ranlib DLLTOOL=$4-dlltool >> ../make.log 2>&1
