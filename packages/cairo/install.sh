#! /bin/sh

source ../../common.sh

./configure --prefix=$3 --host=$4 --disable-static --disable-xlib --disable-quartz --disable-png --enable-ft --disable-gtk-doc-html --disable-ps --disable-pdf --disable-svg > ../config.log 2>&1

make -j $5 $verbmake install > ../make.log 2>&1
