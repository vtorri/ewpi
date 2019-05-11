#! /bin/sh

source ../../common.sh

sed -i -e 's/lame_init_old//g' include/libmp3lame.sym

./configure --prefix=$3 --host=$4 --disable-static --disable-frontend > ../config.log 2>&1

make -j $5 install > ../make.log 2>&1
