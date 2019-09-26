#! /bin/sh

. ../../common.sh

sed -i -e "s/{ S }/{ S; }/g" src/hb-icu.cc

./configure --prefix=$3 --host=$4 --disable-static --with-glib=no --disable-gtk-doc-html --disable-gtk-doc-pdf --with-cairo=no --with-fontconfig=no --with-freetype=yes --with-graphite2=yes --with-icu=yes > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
