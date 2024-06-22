#! /bin/sh

. ../../common.sh

if test "x$4" = "xx86_64-w64-mingw32" ; then
    targetOS=mingw64
    arch=x86_64
else
    targetOS="mingw32"
    arch="x86"
fi

sed -i -e 's/DEPWINDRES=$dep_cc//g;s/-D__USE_MINGW_ANSI_STDIO=1//g' configure
sed -i -e 's/--preprocessor "$(DEPWINDRES) -E -xc-header -DRC_INVOKED $(CC_DEPFLAGS)"/$(foreach ARG,$(CC_DEPFLAGS),--preprocessor-arg "$(ARG)")/g' ffbuild/common.mak

wget https://git.ffmpeg.org/gitweb/ffmpeg.git/blobdiff_plain/6caf34dbe0f0e406c49394c6c6552cc1345957b7..42982b5a5d461530a792e69b3e8abdd9d6d67052:/libavformat/rtmpdh.c
patch -p1 < rtmpdh.c

rm -rf builddir && mkdir builddir && cd builddir

export CPPFLAGS="$CPPFLAGS -I$3/include/libxml2 -DWINICONV_CONST="

../configure --prefix=$3 --disable-static --enable-shared \
             --pkg-config=pkg-config \
             --enable-cross-compile --cross-prefix=$4- \
             --target-os=$targetOS --arch=$arch \
             --enable-gcrypt \
             --enable-libaom \
             --enable-libass \
             --enable-libbluray \
             --enable-libbs2b \
             --enable-libdav1d \
             --enable-libfontconfig \
             --enable-libfreetype \
             --enable-libfribidi \
             --enable-libharfbuzz \
             --enable-libgme \
             --enable-libgsm \
             --enable-libilbc \
             --enable-libjxl \
             --enable-libkvazaar \
             --enable-libmodplug \
             --enable-libmp3lame \
             --enable-libmysofa \
             --enable-libopenh264 \
             --enable-libopenjpeg \
             --enable-libopenmpt \
             --enable-libopus \
             --enable-libsnappy \
             --enable-libsoxr \
             --enable-libvorbis \
             --enable-libwebp \
             --enable-libxml2 \
             --enable-openssl \
             --disable-sdl2 \
	     --disable-vulkan \
             --disable-debug \
             --disable-doc \
             --disable-programs \
             > ../../config.log 2>&1

make -j $jobopt $verbff install > ../../make.log 2>&1
