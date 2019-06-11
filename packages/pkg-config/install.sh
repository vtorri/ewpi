#! /bin/sh

source ../../common.sh

./configure --prefix=$3 --host=$4 --disable-static --with-internal-glib=yes &> ../config.log

make -j $5 $verbmake install &> ../make.log
