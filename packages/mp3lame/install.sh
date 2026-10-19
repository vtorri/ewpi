#! /bin/sh

. ../../common.sh

sed -i -e 's/lame_init_old//g' include/libmp3lame.sym

ewpi_autoconf --disable-static --enable-nasm --disable-frontend
