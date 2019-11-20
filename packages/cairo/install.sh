#! /bin/sh

. ../../common.sh

sed -i -e 's/-Wp,-D_FORTIFY_SOURCE=2//g' configure

./configure --prefix=$3 --host=$4 --disable-static --disable-xlib --disable-quartz --disable-png --enable-ft --disable-gtk-doc-html --disable-ps --disable-pdf --disable-svg > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
