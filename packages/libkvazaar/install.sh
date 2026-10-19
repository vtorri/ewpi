#! /bin/sh

. ../../common.sh

ewpi_cmake "Unix Makefiles" \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTS=OFF
