#! /bin/sh

. ../../common.sh

if test "x$4" = "xx86_64-w64-mingw32" ; then
    targetOS="mingw64"
    arch="x86_64"
else
    targetOS="mingw32"
    arch="i686"
fi

./configure --prefix=$3 --disable-static --enable-shared \
            --enable-cross-compile --cross-prefix=$4- \
            --target-os=$targetOS --arch=$arch \
            --enable-gcrypt \
            --enable-libass \
            --enable-libbluray \
            --enable-libbs2b \
            --enable-libfontconfig \
            --enable-libfreetype \
            --enable-libfribidi \
            --enable-libgme \
            --enable-libgsm \
            --enable-libilbc \
            --enable-libkvazaar \
            --enable-libmodplug \
            --enable-libmp3lame \
            --enable-libmysofa \
            --enable-libopenh264 \
            --enable-libopenjpeg \
            --enable-libopenmpt \
            --enable-libopus \
            --enable-librtmp \
            --enable-libsnappy \
            --enable-libsoxr \
            --enable-libspeex \
            --enable-libtheora \
            --enable-libtls \
            --enable-libvorbis \
            --enable-libwavpack \
            --enable-libwebp \
            --enable-libxml2 \
            > ../config.log 2>&1

make -j $jobopt $verbff install > ../make.log 2>&1
