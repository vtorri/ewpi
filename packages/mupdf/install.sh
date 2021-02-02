#! /bin/sh

. ../../common.sh

make prefix=$3 \
     verbose=$verbose \
     -j $jobopt \
     USE_SYSTEM_FREETYPE=yes \
     SYS_FREETYPE_CFLAGS="`pkg-config --cflags freetype2`" \
     SYS_FREETYPE_LIBS="`pkg-config --libs freetype2`" \
     USE_SYSTEM_HARFBUZZ=yes \
     SYS_HARFBUZZ_CFLAGS="`pkg-config --cflags harfbuzz`" \
     SYS_HARFBUZZ_LIBS="`pkg-config --libs harfbuzz`" \
     USE_SYSTEM_LIBJPEG=yes \
     SYS_LIBJPEG_CFLAGS="`pkg-config --cflags libjpeg`" \
     SYS_LIBJPEG_LIBS="`pkg-config --libs libjpeg`" \
     USE_SYSTEM_OPENJPEG=yes \
     SYS_OPENJPEG_CFLAGS="`pkg-config --cflags libopenjp2`" \
     SYS_OPENJPEG_LIBS="`pkg-config --libs libopenjp2`" \
     USE_SYSTEM_ZLIB=yes \
     SYS_ZLIB_CFLAGS="`pkg-config --cflags zlib`" \
     SYS_ZLIB_LIBS="`pkg-config --libs zlib`" \
     USE_SYSTEM_CURL=yes \
     SYS_CURL_CFLAGS="`pkg-config --cflags libcurl`" \
     SYS_CURL_LIBS="`pkg-config --libs libcurl`" \
     USE_SYSTEM_JBIG2DEC=yes \
     SYS_JBIG2DEC_CFLAGS="-I/opt/ewpi_64/include" \
     SYS_JBIG2DEC_LIBS="-L/opt/ewpi_64/lib -ljbig2dec" \
     install > ../make.log 2>&1
