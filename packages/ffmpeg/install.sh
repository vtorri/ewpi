#! /bin/sh

source ../../common.sh

./configure --prefix=$3 --disable-static --enable-shared \
            --enable-cross-compile --cross-prefix=$4- \
            --enable-gcrypt \
            --enable-libbluray \
            --enable-libfontconfig \
            --enable-libfreetype \
            --enable-libfribidi \
            --enable-libgme \
            --enable-libmp3lame \
            --enable-libopenh264 \
            --enable-libopenjpeg \
            --enable-libopus \
            --enable-librtmp \
            --enable-libsoxr \
            --enable-libspeex \
            --enable-libtheora \
            --enable-libtls \
            --enable-libvorbis \
            --enable-libwebp \
            --enable-libxml2 \
            > ../config.log 2>&1

make -j $5 install > ../make.log 2>&1
