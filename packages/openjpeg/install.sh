#! /bin/sh

. ../../common.sh

ewpi_cmake "Unix Makefiles" \
    -DBUILD_STATIC_LIBS=OFF \
    -DBUILD_CODEC=OFF \
    -DBUILD_JPIP=OFF
