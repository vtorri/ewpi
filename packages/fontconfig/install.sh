#! /bin/sh

source ../../common.sh

sed -i -e 's/@INTLLIBS@/@LTLIBINTL@/g' src/Makefile.in
sed -i -e 's/po-conf test/po-conf/g' Makefile.in

# for fontconfig DLL
export PATH=${EWPI_PWD}/src/.libs:$PATH

./configure --prefix=$3 --host=$4 --disable-static --enable-iconv --with-libiconv=$3 --with-expat=$3 --disable-docs > ../config.log 2>&1

make -j $5 install > ../make.log 2>&1
