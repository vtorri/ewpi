#! /bin/sh

. ../../common.sh

ewpi_cmake "Ninja" \
    -DENABLE_LIBXML2=OFF \
    -DENABLE_TAR=OFF \
    -DENABLE_CPIO=OFF \
    -DENABLE_CAT=OFF \
    -DENABLE_TEST=OFF
