#! /bin/sh

. ../../common.sh

export CPPFLAGS="-D_WIN32_WINNT=0x0600 $CPPFLAGS"

sed -i -e 's/aom_img_fmt_t img_format;/aom_img_fmt_t img_format = AOM_IMG_FMT_NONE;/g' libheif/heif_encoder_aom.cc

./configure --prefix=$3 --host=$4 --disable-static --disable-go --disable-examples --disable-tests > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
