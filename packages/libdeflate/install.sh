#! /bin/sh

. ../../common.sh

ewpi_cmake "Unix Makefiles" \
    -DLIBDEFLATE_BUILD_STATIC_LIB=OFF \
    -DLIBDEFLATE_BUILD_GZIP=OFF
