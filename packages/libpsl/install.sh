#! /bin/sh

. ../../common.sh

export LDFLAGS="$LDFLAGS -liconv -lws2_32"

./configure --prefix=$3 --host=$4 --disable-static --disable-gtk-doc-html --disable-man --with-libiconv-prefix=$3 > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
