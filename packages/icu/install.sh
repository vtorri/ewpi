#! /bin/sh

source ../../common.sh

cd source

./runConfigureICU MinGW --prefix=$3 --host=$4 --enable-tools --disable-tests --disable-samples > ../../config.log 2>&1

make -j $5 > ../../make.log 2>&1
make -j $5 install >> ../../make.log 2>&1

mv $3/lib/*.dll $3/bin
sed -i -e \
    's/Libs: -licuin64/Libs: -L${libdir} -licuin/g' \
    $3/lib/pkgconfig/icu-i18n.pc
sed -i -e \
    's/Libs: -licuio64/Libs: -L${libdir} -licuio/g' \
    $3/lib/pkgconfig/icu-io.pc
sed -i -e \
    's/-licuuc64 -licudt64/-licuuc -licudt/g' \
    $3/lib/pkgconfig/icu-uc.pc
