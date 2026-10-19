#! /bin/sh

. ../../common.sh

ewpi_cmake "Ninja" \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -DHWY_ENABLE_CONTRIB=OFF \
    -DHWY_ENABLE_EXAMPLES=OFF \
    -DHWY_ENABLE_TESTS=OFF
