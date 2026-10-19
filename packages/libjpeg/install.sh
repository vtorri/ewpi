#! /bin/sh

. ../../common.sh

ewpi_cmake "Unix Makefiles" \
    -DENABLE_STATIC=FALSE \
    -DREQUIRE_SIMD=TRUE \
    -DWITH_JAVA=FALSE \
    -DWITH_JPEG8=TRUE \
    -DWITH_TURBOJPEG=FALSE
