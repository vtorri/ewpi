#! /bin/sh

. ../../common.sh

ewpi_cmake "Unix Makefiles" \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_STATIC_LIBS=OFF \
    -DENABLE_DOC=OFF \
    -DENABLE_LIB_ONLY=ON \
    -DENABLE_EXAMPLES=OFF
