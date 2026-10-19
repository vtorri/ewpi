#! /bin/sh

. ../../common.sh

ewpi_cmake "Ninja" \
    -DBUILD_SHARED_LIBS=ON \
    -DINSTALL_DOCS=OFF \
    -DINSTALL_PKG_CONFIG_MODULE=ON \
    -DINSTALL_CMAKE_PACKAGE_MODULE=OFF
