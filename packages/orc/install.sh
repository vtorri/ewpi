#! /bin/sh

source ../../common.sh

./configure --prefix=$3 --host=$4 --disable-static --disable-tests > ../config.log 2>&1

make -j $5 install > ../make.log 2>&1
